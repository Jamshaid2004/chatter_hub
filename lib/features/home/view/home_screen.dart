import 'package:flutter/material.dart';
import 'package:flutter_chatter_hub/features/chats/screen/chats_screen.dart';
import 'package:flutter_chatter_hub/features/home/view_model/home_view_model.dart';
import 'package:flutter_chatter_hub/features/status/screen/status_screen.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final screens = [
    const ChatsScreen(),
    const StatusScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HomeViewModel()..init(),
      builder: (_, __) => Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: screens,
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          backgroundColor: const Color(0xFFF48BB8),
          selectedItemColor: const Color.fromARGB(255, 146, 33, 70),
          unselectedItemColor: const Color.fromARGB(255, 96, 96, 96),
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.chat),
              label: "Chats",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.update),
              label: "Status",
            ),
          ],
        ),
      ),
    );
  }
}
