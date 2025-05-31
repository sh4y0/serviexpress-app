import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:serviexpress_app/config/app_routes.dart';
import 'package:serviexpress_app/core/theme/app_theme.dart';
import 'package:serviexpress_app/presentation/pages/auth_page.dart';
import 'package:serviexpress_app/presentation/pages/auth_page_recovery_password.dart';
import 'package:serviexpress_app/presentation/pages/chat_page.dart';
import 'package:serviexpress_app/presentation/pages/home_page.dart';
import 'package:serviexpress_app/presentation/pages/home_provider.dart';
import 'package:serviexpress_app/presentation/pages/start_page.dart';
import 'package:serviexpress_app/presentation/pages/verification.dart';
import 'package:serviexpress_app/presentation/widgets/cuentanos_screen.dart';
import 'package:sizer/sizer.dart';

class Serviexpress extends StatelessWidget {
  const Serviexpress({super.key});

  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, orientation, deviceType) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'ServiExpress',
          theme: AppTheme.themeData,

          onGenerateRoute: (settings) {
            switch (settings.name) {
              case AppRoutes.login:
                return CupertinoPageRoute(
                  builder: (context) => const AuthPage(),
                );
              case AppRoutes.home:
                final mapStyle = settings.arguments as String;
                return CupertinoPageRoute(
                  builder: (context) => HomePage(mapStyle: mapStyle),
                );
              case AppRoutes.homeProvider:
                
                return CupertinoPageRoute(
                  builder: (context) => const HomeProvider(),
                );
              case AppRoutes.recoveryPassword:
                return CupertinoPageRoute(
                  builder: (context) => const AuthPageRecoveryPassword(),
                );
              case AppRoutes.verified:
                return CupertinoPageRoute(
                  builder: (context) => const Verification(),
                );
              case AppRoutes.chat:
                return CupertinoPageRoute(
                  builder: (context) => const ChatScreen(),
                );
              case AppRoutes.completeProfile:
                final userData = settings.arguments as User;
                return CupertinoPageRoute(
                  builder: (context) => CuentanosScreen(data: userData),
                );
              default:
                return CupertinoPageRoute(
                  builder: (context) => const StartPage(),
                );
              //  default:
              //   return CupertinoPageRoute(
              //     builder: (context) => const AuthPage(),
              //   );
            }
          },
          //   getPages: [
          //     GetPage(name: "/", page: () => const StartPage()),
          //     GetPage(name: "/login", page: () => const AuthPage()),
          //     //GetPage(name: "/signUp", page: () => const SignUp()),
          // ],
        );
      },
    );
  }
}
