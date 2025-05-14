import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:serviexpress_app/presentation/pages/auth_screen.dart';
import 'firebase_options.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const ServiExpressApp());
}

class ServiExpressApp extends StatelessWidget {
  const ServiExpressApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ServiExpress',
      home: Scaffold(body: AuthScreen()),
    );
  }
}
