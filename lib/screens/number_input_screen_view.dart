
import 'package:flutter/material.dart';
import 'package:flutter_chatter_hub/dialogs/confirm_number_dialog.dart';
import 'package:flutter_chatter_hub/screens/otp_screen_view.dart';


class NumberInputScreenView extends StatelessWidget {
  const NumberInputScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final controller = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 244, 181, 225),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text(
          "Enter your phone number",
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              const Text(
                "WhatsApp will need to verify your account.\nWhat’s my number?",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 40),

              // Phone number input
              TextFormField(
                controller: controller,
                keyboardType: TextInputType.phone,
                cursorColor: Colors.pink,
                maxLength: 11,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter your phone number";
                  }
                  if (!RegExp(r'^[0-9]{11}$').hasMatch(value)) {
                    return "Enter a valid 11-digit number";
                  }
                  return null;
                },
                decoration: const InputDecoration(
                  hintText: "Phone number",
                  prefixIcon: Icon(Icons.phone, color: Colors.pink),
                  counterText: "",
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.pink, width: 2),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.pink, width: 2),
                  ),
                ),
              ),

              const SizedBox(height: 40),

              
              SizedBox(
                width: 140,
                height: 40,
                child: ElevatedButton(
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      showDialog(
                        context: context,
                        builder: (_) => ConfirmNumberDialogView(
                          enteredNumber: controller.text,
                          onEdit: () => Navigator.pop(context),
                          onOk: () {
                            Navigator.pop(context); 
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>OtpScreenView(phoneNumber: controller.text), 
                                
                              ),
                            );
                          },
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 224, 21, 170),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: const Text(
                    "NEXT",
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
