
// import 'package:flutter/material.dart';
// import 'package:flutter_chatter_hub/features/chats/screen/chat_screen.dart';

// class HomeScreen extends StatefulWidget {
//   const HomeScreen({super.key});

//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> {
//   int _currentIndex = 0; // 0 for Chats, 1 for Status, 2 for Calls

//   // This will hold the different pages/screens
//   final List<Widget> _screens = [
//     const ChatsScreen(),
//     // const StatusScreen(),
//     // const CallsScreen(),
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: const Color.fromARGB(255, 244, 181, 225),
//         title: const Text(
//           "ChatterHub",
//           style: TextStyle(
//             fontWeight: FontWeight.bold,
//             color: Colors.black,
//           ),
//         ),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.search, color: Colors.black),
//             onPressed: () {
//               // TODO: Implement search functionality
//             },
//           ),
//         ],
//       ),
//       body: _screens[_currentIndex],
//       floatingActionButton: _buildFloatingActionButton(),
//       bottomNavigationBar: _buildBottomNavigationBar(),
//     );
//   }

//   Widget _buildFloatingActionButton() {
//     switch (_currentIndex) {
//       case 0: // Chats screen
//         return FloatingActionButton(
//           onPressed: () {
//             // TODO: Implement new chat functionality
//           },
//           backgroundColor: const Color.fromARGB(255, 224, 21, 170),
//           child: const Icon(Icons.chat, color: Colors.white),
//         );
//       case 1: // Status screen
//         return FloatingActionButton(
//           onPressed: () {
//             // TODO: Implement new status functionality
//           },
//           backgroundColor: const Color.fromARGB(255, 224, 21, 170),
//           child: const Icon(Icons.photo_camera, color: Colors.white),
//         );
//       case 2: // Calls screen
//         return FloatingActionButton(
//           onPressed: () {
//             // TODO: Implement new call functionality
//           },
//           backgroundColor: const Color.fromARGB(255, 224, 21, 170),
//           child: const Icon(Icons.add_call, color: Colors.white),
//         );
//       default:
//         return FloatingActionButton(
//           onPressed: () {},
//           backgroundColor: const Color.fromARGB(255, 224, 21, 170),
//           child: const Icon(Icons.chat, color: Colors.white),
//         );
//     }
//   }

//   BottomNavigationBar _buildBottomNavigationBar() {
//     return BottomNavigationBar(
//       currentIndex: _currentIndex,
//       onTap: (index) {
//         setState(() {
//           _currentIndex = index;
//         });
//       },
//       selectedItemColor: const Color.fromARGB(255, 224, 21, 170),
//       unselectedItemColor: Colors.grey,
//       items: const [
//         BottomNavigationBarItem(
//           icon: Icon(Icons.chat),
//           label: 'Chats',
//         ),
//         BottomNavigationBarItem(
//           icon: Icon(Icons.photo_library),
//           label: 'Status',
//         ),
//         BottomNavigationBarItem(
//           icon: Icon(Icons.call),
//           label: 'Calls',
//         ),
//       ],
//     );
//   }
// }