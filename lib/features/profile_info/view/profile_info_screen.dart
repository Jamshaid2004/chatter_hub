import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_chatter_hub/features/profile_info/view_model/profile_info_view_model.dart';
import 'package:provider/provider.dart';

class ProfileInfoScreen extends StatelessWidget {
  const ProfileInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ProfileInfoViewModel(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            "Profile info",
            style: TextStyle(color: Colors.black),
          ),
          backgroundColor: const Color(0xFFF48BB8),
          centerTitle: true,
          elevation: 0,
        ),
        body: Consumer<ProfileInfoViewModel>(
          builder: (_, vm, __) => Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 30),
                Center(
                  child: Stack(
                    children: [
                      ValueListenableBuilder<File?>(
                        valueListenable: vm.profileImage,
                        builder: (_, pfp, __) => CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.grey[300],
                          backgroundImage: pfp == null ? null : FileImage(pfp),
                          child: pfp == null ? const Icon(Icons.person, size: 50, color: Colors.white) : null,
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: InkWell(
                          onTap: () {
                            vm.pickImage();
                          },
                          child: const CircleAvatar(
                            radius: 18,
                            backgroundColor: Color(0xFFF48BB8),
                            child: Icon(Icons.camera_alt, size: 18, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                TextField(
                  controller: vm.nameController,
                  decoration: InputDecoration(
                    hintText: "Type your name here",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: const BorderSide(color: Color(0xFFF48BB8)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: const BorderSide(color: Color(0xFFF48BB8)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: const BorderSide(color: Color(0xFFF48BB8)),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                Align(
                  alignment: Alignment.center,
                  child: SizedBox(
                    width: 130,
                    child: ElevatedButton(
                      onPressed: vm.createUser,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF48BB8),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Text("Next", style: TextStyle(fontSize: 16, color: Colors.black)),
                    ),
                  ),
                ),
                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
