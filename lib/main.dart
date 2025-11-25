import 'package:flutter/material.dart';
import 'package:flutter_chatter_hub/screens/agree_continue_view.dart';

void main() {
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
