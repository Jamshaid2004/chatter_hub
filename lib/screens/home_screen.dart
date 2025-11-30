import 'package:flutter/material.dart';
import 'package:flutter_chatter_hub/features/chats/screen/chats_screen.dart';
import 'package:flutter_chatter_hub/features/status/screen/status_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  // Only 2 screens for now
  final screens = [
    ChatsScreen(),
    StatusScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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

        backgroundColor:  const Color(0xFFF48BB8),        // Bottom bar background
        selectedItemColor: const Color.fromARGB(255, 146, 33, 70),       // Selected icon + text color
        unselectedItemColor: const Color.fromARGB(255, 96, 96, 96),     // Unselected icon + text color
        type: BottomNavigationBarType.fixed,  // Required for custom colors

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
    );
  }
}
