// import 'package:chatting_app/screens/number_input_screen_view.dart';
// import 'package:chatting_app/dialog/notification_dialog_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chatter_hub/dialogs/notification_dialog_view.dart';
import 'package:flutter_chatter_hub/screens/number_input_screen_view.dart';


class AgreeContinueView extends StatelessWidget {
  const AgreeContinueView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/logo.jpeg',
                height: 100,
              ),
              const SizedBox(height: 40),
              const Text(
                'Welcome to WhatsApp',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 22),
              const Text(
                'Read our Privacy Policy. Tap "Agree and Continue" '
                'to accept the Terms of Service.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 50),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return NotificationDialogView(
                          onAllow: () {
                            Navigator.pop(context); // close dialog
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const NumberInputScreenView(),
                              ),
                            );
                          },
                          onDontAllow: () {
                            Navigator.pop(context); // just close dialog
                          },
                        );
                      },
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 224, 21, 170),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: const Text(
                    "AGREE AND CONTINUE",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
