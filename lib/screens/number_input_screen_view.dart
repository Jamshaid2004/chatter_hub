
import 'package:flutter/material.dart';
import 'package:flutter_chatter_hub/dialogs/confirm_number_dialog.dart';
import 'package:flutter_chatter_hub/screens/otp_screen_view.dart';


class NumberInputScreenView extends StatefulWidget {
  const NumberInputScreenView({super.key});

  @override
  State<NumberInputScreenView> createState() => _NumberInputScreenViewState();
}

class _NumberInputScreenViewState extends State<NumberInputScreenView> {
  final formKey = GlobalKey<FormState>();
  final controller = TextEditingController();
  String countryCode = '+1'; // Default to US country code

  String _formatPhoneNumber(String phoneNumber) {
    // Remove any non-digit characters
    String digitsOnly = phoneNumber.replaceAll(RegExp(r'[^0-9]'), '');
    // Format to E.164: +[country code][number]
    return '$countryCode$digitsOnly';
  }
  
  @override
  Widget build(BuildContext context) {
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

              // Country code selector
              Row(
                children: [
                  SizedBox(
                    width: 100,
                    child: TextFormField(
                      initialValue: countryCode,
                      keyboardType: TextInputType.phone,
                      cursorColor: Colors.pink,
                      onChanged: (value) {
                        setState(() {
                          countryCode = value.startsWith('+') ? value : '+$value';
                        });
                      },
                      decoration: const InputDecoration(
                        hintText: "+1",
                        prefixText: "",
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.pink, width: 2),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.pink, width: 2),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: controller,
                      keyboardType: TextInputType.phone,
                      cursorColor: Colors.pink,
                      maxLength: 15,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please enter your phone number";
                        }
                        // Validate that it contains only digits
                        if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                          return "Enter a valid phone number";
                        }
                        if (value.length < 7) {
                          return "Phone number too short";
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
                  ),
                ],
              ),

              const SizedBox(height: 40),

              
              SizedBox(
                width: 140,
                height: 40,
                child: ElevatedButton(
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      final formattedNumber = _formatPhoneNumber(controller.text);
                      showDialog(
                        context: context,
                        builder: (_) => ConfirmNumberDialogView(
                          enteredNumber: formattedNumber,
                          onEdit: () => Navigator.pop(context),
                          onOk: () {
                            Navigator.pop(context); 
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => OtpScreenView(phoneNumber: formattedNumber), 
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
