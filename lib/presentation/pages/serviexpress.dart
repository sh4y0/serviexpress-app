import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:serviexpress_app/config/app_routes.dart';
import 'package:serviexpress_app/core/theme/app_theme.dart';
import 'package:serviexpress_app/presentation/pages/auth_page.dart';
import 'package:serviexpress_app/presentation/pages/home_page.dart';
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
            case AppRoutes.home:
              final mapStyle = settings.arguments as String;
              return CupertinoPageRoute(
                builder: (context) => HomePage(mapStyle: mapStyle),
              );
            default:
              return CupertinoPageRoute(
                builder: (context) => const AuthPage(),
              );
          }
        },
      //   getPages: [
      //     GetPage(name: "/", page: () => const StartPage()),
      //     GetPage(name: "/login", page: () => const AuthPage()),
      //     //GetPage(name: "/signUp", page: () => const SignUp()),
      // ],
      );
      }
    );
  }
}