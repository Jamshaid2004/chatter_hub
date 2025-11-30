import 'package:flutter/material.dart';
// import 'package:flutter_chatter_hub/features/chats/screen/chats_screen.dart';
import 'package:flutter_chatter_hub/screens/home_screen.dart';

// import 'package:flutter_chatter_hub/features/chats/screen/chat_screen.dart';
// import 'package:flutter_chatter_hub/features/chats/screen/chats_home_screen.dart';

class ProfileInfoScreen extends StatelessWidget {
  final TextEditingController nameController = TextEditingController();

  ProfileInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile info", style: TextStyle(color: Colors.black),),
        backgroundColor: const Color(0xFFF48BB8),
        centerTitle: true,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 30),
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey[300],
                    child:
                        const Icon(Icons.person, size: 50, color: Colors.white),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: InkWell(
                      onTap: () {
                        //will add gallery access functionality
                      },
                      child: const CircleAvatar(
                        radius: 18,
                        backgroundColor:  Color(0xFFF48BB8),
                        child: Icon(Icons.camera_alt,
                            size: 18, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                hintText: "Type your name here",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: const BorderSide(
                      color: Color(0xFFF48BB8)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: const BorderSide(
                      color: Color(0xFFF48BB8)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: const BorderSide(
                      color:  Color(0xFFF48BB8)),
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.emoji_emotions_outlined,
                      color:  Color(0xFFF48BB8)),
                  onPressed: () {},
                ),
              ),
            ),
            const SizedBox(height: 30),
            Align(
              alignment: Alignment.center,
              child: SizedBox(
                width: 130,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const HomeScreen()),
                      (route) => false, 
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:const Color(0xFFF48BB8),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text("Next",
                      style: TextStyle(fontSize: 16, color: Colors.black)),
                ),
              ),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
