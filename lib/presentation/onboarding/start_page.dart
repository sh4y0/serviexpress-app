import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:serviexpress_app/core/config/app_session_config.dart';
import 'package:serviexpress_app/core/theme/app_color.dart';

class StartPage extends StatefulWidget {
  const StartPage({super.key});

  @override
  State<StartPage> createState() => _StartPageState();
}

class _StartPageState extends State<StartPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _startWithNotificationCheck();

    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _startWithNotificationCheck() async {
    await Future.delayed(const Duration(seconds: 2));

    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();

    if (context.mounted) {
      AppSessionConfig.handleAuthRedirect(context, initialMessage);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FadeTransition(
        opacity: _animation,
        child: Container(
          decoration: const BoxDecoration(gradient: AppColor.bgGradient),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [Image.asset("assets/icons/ic_logo.png", width: 175)],
            ),
          ),
        ),
      ),
    );
  }
}
