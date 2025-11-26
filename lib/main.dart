import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_chatter_hub/screens/agree_continue_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase asynchronously to avoid blocking UI startup
  unawaited(
    Firebase.initializeApp().then(
      (_) {},
      onError: (e) {
        debugPrint('Firebase initialization error: $e');
      },
    ),
  );
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, 
      title: 'Chatter Hub',
      theme: ThemeData(
        primarySwatch: Colors.pink,
      ),
      home: const AgreeContinueView(), 
    );
  }
}
