import 'dart:async';

import 'package:flutter/material.dart';
import 'package:serviexpress_app/config/app_session_config.dart';
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
    Timer(const Duration(seconds: 2), () {
      AppSessionConfig.handleAuthRedirect(context);
    });

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
