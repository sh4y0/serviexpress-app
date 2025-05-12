import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
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
    return MaterialApp(title: 'ServiExpress', theme: ThemeData());
  }
}
