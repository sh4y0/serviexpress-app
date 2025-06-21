import 'dart:async';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:logging/logging.dart';
import 'package:serviexpress_app/core/utils/user_preferences.dart';
import 'package:serviexpress_app/data/repositories/user_repository.dart';

enum LocationState {
  unknown,
  permissionDenied,
  serviceDisabled,
  searching,
  found,
  error,
}

class EnhancedLocationService extends ChangeNotifier {
  final Logger _log = Logger('EnhancedLocationService');
  static final EnhancedLocationService _instance =
      EnhancedLocationService._internal();

  factory EnhancedLocationService() {
    return _instance;
  }

  EnhancedLocationService._internal();

  LocationState _currentState = LocationState.unknown;
  Position? _currentPosition;
  Timer? _searchTimer;
  StreamSubscription<Position>? _positionStreamSubscription;
  bool _isInitialized = false;

  LocationState get currentState {
    return _currentState;
  }

  Position? get currentPosition => _currentPosition;
  bool get isInitialized => _isInitialized;
  bool get hasLocation => _currentPosition != null;

  StreamSubscription<ServiceStatus>? _serviceStatusSubscription;
  bool get shouldShowNotFoundBanner =>
      _currentState == LocationState.permissionDenied ||
      _currentState == LocationState.serviceDisabled;
  bool get shouldShowSearchingBanner =>
      _currentState == LocationState.searching;

  LocationSettings _getLocationSettings() {
    if (Platform.isAndroid) {
      return AndroidSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
        forceLocationManager: false,
        intervalDuration: const Duration(seconds: 5),
        // foregroundNotificationConfig: const ForegroundNotificationConfig(
        //   notificationText: "Obteniendo ubicación...",
        //   notificationTitle: "ServiExpress - Ubicación en uso",
        //   enableWakeLock: true,
        // ),
      );
    } else if (Platform.isIOS || Platform.isMacOS) {
      return AppleSettings(
        accuracy: LocationAccuracy.high,
        activityType: ActivityType.other,
        distanceFilter: 10,
        pauseLocationUpdatesAutomatically: true,
        showBackgroundLocationIndicator: false,
      );
    } else {
      return const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      );
    }
  }

  Future<void> initialize() async {
    if (_isInitialized) return;
    _listenToServiceStatus();
    await _checkAndRequestLocation();
    _isInitialized = true;
  }

  void _listenToServiceStatus() {
    _serviceStatusSubscription?.cancel();
    _serviceStatusSubscription = Geolocator.getServiceStatusStream().listen((
      ServiceStatus status,
    ) {
      if (status == ServiceStatus.disabled) {
        _updateState(LocationState.serviceDisabled);
      } else if (status == ServiceStatus.enabled &&
          _currentState == LocationState.serviceDisabled) {
        retryLocation();
      }
    });
  }

  Future<void> _checkAndRequestLocation() async {
    final isServiceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!isServiceEnabled) {
      _updateState(LocationState.serviceDisabled);
      return;
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _updateState(LocationState.permissionDenied);
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _updateState(LocationState.permissionDenied);
      return;
    }

    _startLocationSearch();
  }

  Future<void> _startLocationSearch() async {
    _updateState(LocationState.searching);

    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: _getLocationSettings(),
        timeLimit: const Duration(seconds: 15),
      );
      _handleNewPosition(position);
      _startLocationStream();
    } catch (e) {
      final lastKnown = await Geolocator.getLastKnownPosition();
      if (lastKnown != null) {
        _handleNewPosition(lastKnown);
        _startLocationStream();
      } else {
        _updateState(LocationState.error);
      }
    }
  }

  void _startLocationStream() {
    _positionStreamSubscription?.cancel();

    _positionStreamSubscription = Geolocator.getPositionStream(
      locationSettings: _getLocationSettings(),
    ).listen(
      _handleNewPosition,
      onError: (error) {
        debugPrint('ServiExpress - Error en stream de ubicación: $error');
      },
    );
  }

  void _handleNewPosition(Position position) {
    _currentPosition = position;
    _updateState(LocationState.found);
    updateUserLocation(_currentPosition!);
  }

  void _stopLocationSearch() {
    _searchTimer?.cancel();
    _positionStreamSubscription?.cancel();
  }

  void _updateState(LocationState newState) {
    if (_currentState != newState) {
      _currentState = newState;
      notifyListeners();
    }
  }

  Future<void> updateUserLocation(Position position) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await UserRepository.instance.setUserLocation(
          user.uid,
          position.latitude,
          position.longitude,
        );
      }
    } catch (e) {
      _log.warning('Error al actualizar ubicación en Firebase: $e');
    }
  }

  Future<bool> requestLocationPermission() async {
    try {
      final permission = await Geolocator.requestPermission();

      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        await _checkAndRequestLocation();
        return true;
      } else {
        if (permission == LocationPermission.deniedForever) {
          await Geolocator.openAppSettings();
        }
        _updateState(LocationState.permissionDenied);
        return false;
      }
    } catch (e) {
      _log.severe('Error al solicitar permisos de ubicación: $e');
      _updateState(LocationState.error);
      return false;
    }
  }

  Future<void> requestLocationService() async {
    try {
      await Geolocator.getCurrentPosition(
        locationSettings: _getLocationSettings(),
        timeLimit: const Duration(seconds: 1),
      );
      _updateState(LocationState.searching);
    } catch (e) {
      _log.info("Could not trigger native dialog, opening settings. Error: $e");
      await Geolocator.openLocationSettings();
    }
  }

  Future<void> retryLocation() async {
    await _checkAndRequestLocation();
  }

  Future<Position> getCurrentPosition() async {
    if (_currentPosition != null) {
      return _currentPosition!;
    }

    if (_currentState == LocationState.searching) {
      final completer = Completer<Position>();

      void listener() {
        if (_currentState == LocationState.found && _currentPosition != null) {
          removeListener(listener);
          completer.complete(_currentPosition!);
        } else if (_currentState == LocationState.error ||
            _currentState == LocationState.permissionDenied ||
            _currentState == LocationState.serviceDisabled) {
          removeListener(listener);
          completer.completeError('No se pudo obtener la ubicación');
        }
      }

      addListener(listener);

      Timer(const Duration(seconds: 30), () {
        if (!completer.isCompleted) {
          removeListener(listener);
          completer.completeError('Timeout al obtener ubicación');
        }
      });

      return completer.future;
    }

    await _startLocationSearch();
    return getCurrentPosition();
  }

  @override
  void dispose() {
    _stopLocationSearch();
    super.dispose();
  }

  String getStateMessage() {
    switch (_currentState) {
      case LocationState.unknown:
        return 'Verificando ubicación...';
      case LocationState.permissionDenied:
        return 'Permisos de ubicación denegados';
      case LocationState.serviceDisabled:
        return 'Servicio de ubicación desactivado';
      case LocationState.searching:
        return 'Buscándote en el mapa...';
      case LocationState.found:
        return 'Ubicación encontrada';
      case LocationState.error:
        return 'Error al obtener ubicación';
    }
  }
}
