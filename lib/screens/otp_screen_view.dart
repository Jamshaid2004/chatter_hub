import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chatter_hub/auth/bloc/otp_bloc.dart';
import 'package:flutter_chatter_hub/auth/bloc/otp_events.dart';
import 'package:flutter_chatter_hub/auth/bloc/otp_states.dart';
import 'package:flutter_chatter_hub/dialogs/audio_permission_dialog.dart';
import 'package:flutter_chatter_hub/dialogs/camera_permission_dialog.dart';
import 'package:flutter_chatter_hub/dialogs/contact_permission_dialog.dart';
import 'package:flutter_chatter_hub/screens/profile_info_screen.dart';



class OtpScreenView extends StatelessWidget {
  final String phoneNumber;
  final TextEditingController _otpController = TextEditingController();

  OtpScreenView({super.key, required this.phoneNumber});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => OtpBloc()..add(SendOtpEvent(phoneNumber)),
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Verify your number"),
          backgroundColor:  const Color.fromARGB(255, 244, 181, 225),
        ),
        body: Padding(
          padding: const EdgeInsets.all(24.0),
          child: BlocConsumer<OtpBloc, OtpStates>(
            listener: (context, state) {
              if (state is OtpVerifiedState) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("OTP Verified! 🎉")),
                );
                Future.delayed(Duration.zero, (){
                  _showContactsDialog(context);
                });


              } else if (state is OtpErrorState) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.message)),
                );
              }
            },
            builder: (context, state) {
              if (state is OtpLoadingState) {
                return const Center(child: CircularProgressIndicator());
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),
                  Text("We sent an SMS to $phoneNumber"),
                  const SizedBox(height: 40),

                  TextField(
                    controller: _otpController,
                    maxLength: 6,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 24, letterSpacing: 8),
                    decoration: const InputDecoration(
                      counterText: "",
                      hintText: "Enter 6-digit code",
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.pink),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.pink, width: 2),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        context
                            .read<OtpBloc>()
                            .add(VerifyOtpEvent(_otpController.text));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 224, 21, 170),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      child: const Text("VERIFY",
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),
                    ),
                  ),

                  const SizedBox(height: 20),

                  TextButton(
                    onPressed: () {
                      context.read<OtpBloc>().add(ResendOtpEvent(phoneNumber));
                    },
                    child: const Text("Didn’t receive code? Resend",
                        style: TextStyle(color: Colors.pink, fontSize: 16)),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
void _showContactsDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => ContactsPermissionDialog(
      onAllow: () {
        Navigator.pop(context);
        _showCameraDialog(context); // go to next
      },
      onDontAllow: () {
        Navigator.pop(context);
        _showCameraDialog(context); // still go to next
      },
    ),
  );
}

void _showCameraDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => CameraPermissionDialog(
      onAllow: () {
        Navigator.pop(context);
        _showAudioDialog(context); // go to next
      },
      onDontAllow: () {
        Navigator.pop(context);
        _showAudioDialog(context);
      },
    ),
  );
}

void _showAudioDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => AudioPermissionDialog(
      onAllow: () {
        Navigator.pop(context);
        _goToProfileScreen(context); // after last dialog
      },
      onDontAllow: () {
        Navigator.pop(context);
        _goToProfileScreen(context);
      },
    ),
  );
}

void _goToProfileScreen(BuildContext context) {
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (context) => ProfileInfoScreen()),
  );
}

