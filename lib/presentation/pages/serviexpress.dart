import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:serviexpress_app/core/config/app_routes.dart';
import 'package:serviexpress_app/core/config/navigation_config.dart';
import 'package:serviexpress_app/core/theme/app_theme.dart';
import 'package:serviexpress_app/data/models/service.dart';
import 'package:serviexpress_app/data/models/user_model.dart';
import 'package:serviexpress_app/presentation/login/auth_page.dart';
import 'package:serviexpress_app/presentation/login/auth_page_recovery_password.dart';
import 'package:serviexpress_app/presentation/widgets/common/chat_page.dart';
import 'package:serviexpress_app/presentation/home/home_cliente/home_page.dart';
import 'package:serviexpress_app/presentation/home/home_proveedor/home_provider.dart';
import 'package:serviexpress_app/presentation/onboarding/start_page.dart';
import 'package:serviexpress_app/presentation/home/home_proveedor/verification.dart';
import 'package:serviexpress_app/presentation/widgets/common/cambio_rol.dart';
import 'package:serviexpress_app/presentation/home/home_cliente/client_details.dart';
import 'package:serviexpress_app/presentation/home/home_proveedor/cuentanos_screen.dart';
import 'package:serviexpress_app/presentation/widgets/common/location_permission.dart';
import 'package:serviexpress_app/presentation/home/home_proveedor/provider_details.dart';
import 'package:serviexpress_app/presentation/home/home_cliente/show_super.dart';
import 'package:sizer/sizer.dart';

class Serviexpress extends StatelessWidget {
  const Serviexpress({super.key});

  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, orientation, deviceType) {
        return MaterialApp(
          navigatorKey: NavigationConfig.navigatorKey,
          debugShowCheckedModeBanner: false,
          title: 'ServiExpress',
          theme: AppTheme.themeData,

          onGenerateRoute: (settings) {
            switch (settings.name) {
              case AppRoutes.login:
                final args = settings.arguments as Map<String, dynamic>?;
                final startWithLogin = args?['login'] ?? true;
                return MaterialPageRoute(
                  builder:
                      (context) => AuthPage(startWithLogin: startWithLogin),
                );
              case AppRoutes.home:
                final mapStyle = settings.arguments as String;
                return MaterialPageRoute(
                  builder: (context) => HomePage(mapStyle: mapStyle),
                );
              case AppRoutes.homeProvider:
                return MaterialPageRoute(
                  builder: (context) => const HomeProvider(),
                );
              case AppRoutes.recoveryPassword:
                return MaterialPageRoute(
                  builder: (context) => const AuthPageRecoveryPassword(),
                );
              case AppRoutes.locationPermissions:
                final args = settings.arguments as String;
                return MaterialPageRoute(
                  builder: (context) => LocationPermission(role: args),
                );
              case AppRoutes.verified:
                return MaterialPageRoute(
                  builder: (context) => const Verification(),
                );
              case AppRoutes.showSuper:
                final args = settings.arguments as Map<String, dynamic>;
                final provider = args['selectedProvider'] as UserModel;
                final clientPosition = args['clientPosition'] as LatLng?;
                return MaterialPageRoute(
                  builder:
                      (context) => ShowSuper(
                        provider: provider,
                        clientPosition: clientPosition,
                      ),
                );
              case AppRoutes.chat:
                return MaterialPageRoute(
                  builder: (context) => const ChatScreen(),
                );
              case AppRoutes.completeProfile:
                final userData = settings.arguments as UserModel;
                return MaterialPageRoute(
                  builder: (context) => CuentanosScreen(data: userData),
                );
              case AppRoutes.providerDetails:
                final args = settings.arguments as Map<String, dynamic>;
                final mapStyle = args['mapStyle'] as String;
                final service = args['service'] as ServiceComplete;
                final position = args['position'] as LatLng?;
                return MaterialPageRoute(
                  builder:
                      (context) => ProviderDetails(
                        service: service,
                        mapStyle: mapStyle,
                        position: position,
                      ),
                );
              case AppRoutes.clientDetails:
                final args = settings.arguments as Map<String, dynamic>;
                final mapStyle = args['mapStyle'] as String;
                final provider = args['selectedProvider'] as UserModel;
                final clientPosition = args['clientPosition'] as LatLng?;
                return MaterialPageRoute(
                  builder:
                      (context) => ClientDetails(
                        clientPosition: clientPosition,
                        mapStyle: mapStyle,
                        provider: provider,
                      ),
                );
              case AppRoutes.cambioRol:
                return MaterialPageRoute(
                  builder: (context) => const CambioRol(),
                );
              default:
                return MaterialPageRoute(
                  builder: (context) => const StartPage(),
                );
            }
          },
        );
      },
    );
  }
}
