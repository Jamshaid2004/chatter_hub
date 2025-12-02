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

  
  String formatPakNumber(String input) {
    String digits = input.replaceAll(RegExp(r'[^0-9]'), '');

    
    if (digits.startsWith('0')) {
      digits = digits.substring(1);
    }

    
    if (digits.length == 10 && digits.startsWith('3')) {
      return '+92$digits';
    }

    return ''; 
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

              
              Row(
                children: [
                  SizedBox(
                    width: 100,
                    child: TextFormField(
                      initialValue: "+92",
                      readOnly: true,
                      decoration: const InputDecoration(
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFFF48BB8), width: 2),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFFF48BB8), width: 2),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 16),

                  
                  Expanded(
                    child: TextFormField(
                      controller: controller,
                      keyboardType: TextInputType.phone,
                      cursorColor: const Color(0xFFF48BB8),
                      maxLength: 15,
                      decoration: const InputDecoration(
                        hintText: "3001234567",
                        prefixIcon: Icon(Icons.phone, color: Color(0xFFF48BB8)),
                        counterText: "",
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color:  Color(0xFFF48BB8), width: 2),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color:  Color(0xFFF48BB8), width: 2),
                        ),
                      ),

                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please enter your phone number";
                        }

                        String formatted = formatPakNumber(value);

                        if (formatted.isEmpty) {
                          return "Enter a valid Pakistani mobile number";
                        }

                        return null;
                      },
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
                      final formattedNumber = formatPakNumber(controller.text);

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
                                builder: (_) => OtpScreenView(
                                  phoneNumber: formattedNumber,
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF48BB8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: const Text(
                    "NEXT",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
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
