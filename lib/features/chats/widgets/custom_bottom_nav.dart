import 'package:flutter/material.dart';

class CustomBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const CustomBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      selectedItemColor: Colors.pink,
      unselectedItemColor: Colors.grey,
      backgroundColor: const Color.fromARGB(255, 244, 181, 225),
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.chat),
          label: 'Chats',
        ),
        
        BottomNavigationBarItem(
          icon: Icon(Icons.circle_outlined),
          label: 'Status',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.call),
          label: 'Calls',
        ),
      ],
    );
  }
}