import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:serviexpress_app/config/app_routes.dart';
import 'package:serviexpress_app/config/navigation_config.dart';
import 'package:serviexpress_app/core/theme/app_theme.dart';
import 'package:serviexpress_app/data/models/service.dart';
import 'package:serviexpress_app/data/models/user_model.dart';
import 'package:serviexpress_app/presentation/pages/auth_page.dart';
import 'package:serviexpress_app/presentation/pages/auth_page_recovery_password.dart';
import 'package:serviexpress_app/presentation/pages/chat_page.dart';
import 'package:serviexpress_app/presentation/pages/home_page.dart';
import 'package:serviexpress_app/presentation/pages/home_provider.dart';
import 'package:serviexpress_app/presentation/pages/start_page.dart';
import 'package:serviexpress_app/presentation/pages/verification.dart';
import 'package:serviexpress_app/presentation/resources/constants/servi_express_string.dart';
import 'package:serviexpress_app/presentation/resources/constants/widgets/show_super_navigation_keys.dart';
import 'package:serviexpress_app/presentation/widgets/cambio_rol.dart';
import 'package:serviexpress_app/presentation/widgets/client_details.dart';
import 'package:serviexpress_app/presentation/widgets/cuentanos_screen.dart';
import 'package:serviexpress_app/presentation/widgets/location_permission.dart';
import 'package:serviexpress_app/presentation/widgets/provider_details.dart';
import 'package:serviexpress_app/presentation/widgets/show_super.dart';
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
          title: ServiExpressString.appName,
          theme: AppTheme.themeData,

          onGenerateRoute: (settings) {
            switch (settings.name) {
              case AppRoutes.login:
                final args = settings.arguments as Map<String, dynamic>?;
                final startWithLogin =
                    args?[ShowSuperNavigationKeys.login] ?? true;
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
                final provider =
                    args[ShowSuperNavigationKeys.selectedProvider] as UserModel;
                final clientPosition =
                    args[ShowSuperNavigationKeys.clientPosition] as LatLng?;
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
                final mapStyle =
                    args[ShowSuperNavigationKeys.mapStyle] as String;
                final service =
                    args[ShowSuperNavigationKeys.service] as ServiceComplete;
                final position =
                    args[ShowSuperNavigationKeys.position] as LatLng?;
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
                final mapStyle =
                    args[ShowSuperNavigationKeys.mapStyle] as String;
                final provider =
                    args[ShowSuperNavigationKeys.selectedProvider] as UserModel;
                final clientPosition =
                    args[ShowSuperNavigationKeys.clientPosition] as LatLng?;
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
