import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:serviexpress_app/data/service/location_maps_service.dart';

final locationNotifierProvider = ChangeNotifierProvider<EnhancedLocationService>((ref) {
  final service = EnhancedLocationService();

  service.initialize();

  ref.onDispose(() {
    service.dispose();
  });

  return service;
});