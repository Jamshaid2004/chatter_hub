import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chatter_hub/core/injector/injector.dart';
import 'package:flutter_chatter_hub/core/services/db/db_local_service.dart';
import 'package:flutter_chatter_hub/dialogs/audio_permission_dialog.dart';
import 'package:flutter_chatter_hub/dialogs/camera_permission_dialog.dart';
import 'package:flutter_chatter_hub/dialogs/contact_permission_dialog.dart';
import 'package:flutter_chatter_hub/features/auth/bloc/otp_bloc.dart';
import 'package:flutter_chatter_hub/features/auth/bloc/otp_events.dart';
import 'package:flutter_chatter_hub/features/auth/bloc/otp_states.dart';
import 'package:flutter_chatter_hub/features/profile_info/view/profile_info_screen.dart';

class OtpScreenView extends StatefulWidget {
  final String phoneNumber;

  const OtpScreenView({super.key, required this.phoneNumber});

  @override
  State<OtpScreenView> createState() => _OtpScreenViewState();
}

class _OtpScreenViewState extends State<OtpScreenView> {
  final TextEditingController _otpController = TextEditingController();
  String? _verificationId;
  int? _resendToken;

  void _showContactsDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => ContactsPermissionDialog(
        onAllow: () {
          Navigator.pop(context);
          _showCameraDialog(context);
        },
        onDontAllow: () {
          Navigator.pop(context);
          _showCameraDialog(context);
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
          _showAudioDialog(context);
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
          _goToProfileScreen(context);
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
      MaterialPageRoute(builder: (context) => const ProfileInfoScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    log('Verification ID: $_verificationId');
    log('Resend Token: $_resendToken');
    log('Phone Number: ${widget.phoneNumber}');
    return BlocProvider(
      create: (_) => OtpBloc()..add(SendOtpEvent(widget.phoneNumber)),
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Verify your number"),
          backgroundColor: const Color(0xFFF48BB8),
        ),
        body: Padding(
          padding: const EdgeInsets.all(24.0),
          child: BlocConsumer<OtpBloc, OtpStates>(
            listener: (context, state) {
              if (state is OtpSentState) {
                debugPrint('Verification ID: ${state.verificationId} in builder');
                _verificationId = state.verificationId;
                _resendToken = state.resendToken;
              } else if (state is OtpVerifiedState) {
                injector<SharedPref>().saveValue('phoneNumber', widget.phoneNumber);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("OTP Verified! 🎉")),
                );
                // Use post-frame callback instead of Future.delayed for better performance
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) {
                    _showContactsDialog(context);
                  }
                });
              } else if (state is OtpErrorState) {
                // Clear verification ID for session-related errors
                if (state.message.contains('expired') || state.message.contains('invalid-verification')) {
                  _verificationId = null;
                  _resendToken = null;
                }
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    duration: const Duration(seconds: 4),
                  ),
                );
              }
            },
            builder: (context, state) {
              log('State: $state');
              final isLoading = state is OtpLoadingState;
              // if (state is OtpSentState) {
              //   debugPrint('Verification Id in builder is ');
              //   _verificationId = state.verificationId;
              //   _resendToken = state.resendToken;
              // }
              final isCodeSent = state is OtpSentState || _verificationId != null;
              final hasError = state is OtpErrorState;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),
                  if (state is OtpLoadingState)
                    const Column(
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 20),
                        Text("Sending OTP..."),
                      ],
                    )
                  else if (isCodeSent)
                    Text("We sent an SMS to ${widget.phoneNumber}")
                  else if (hasError)
                    Column(
                      children: [
                        const Icon(Icons.error_outline, color: Colors.red, size: 48),
                        const SizedBox(height: 10),
                        Text(
                          "Failed to send OTP",
                          style: TextStyle(color: Colors.red[700], fontSize: 16),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "Please try resending",
                          style: TextStyle(color: Colors.grey[600], fontSize: 14),
                        ),
                      ],
                    ),
                  const SizedBox(height: 40),
                  TextField(
                    controller: _otpController,
                    maxLength: 6,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    enabled: !isLoading && isCodeSent,
                    style: const TextStyle(fontSize: 24, letterSpacing: 8),
                    decoration: const InputDecoration(
                      counterText: "",
                      hintText: "Enter 6-digit code",
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFFF48BB8)),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFFF48BB8), width: 2),
                      ),
                      disabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: (isLoading || !isCodeSent)
                          ? null
                          : () {
                              final otpCode = _otpController.text.trim();
                              if (otpCode.length != 6) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Please enter a valid 6-digit code"),
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                                return;
                              }
                              if (_verificationId != null) {
                                debugPrint('Verification id when verifying otp : $_verificationId');
                                context.read<OtpBloc>().add(VerifyOtpEvent(_verificationId!, otpCode));
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF48BB8),
                        disabledBackgroundColor: Colors.grey,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      child: state is OtpLoadingState && _verificationId != null
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text("VERIFY", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: isLoading
                        ? null
                        : () {
                            context.read<OtpBloc>().add(
                                  ResendOtpEvent(widget.phoneNumber, _resendToken),
                                );
                          },
                    child: Text(
                      "Didn't receive code? Resend",
                      style: TextStyle(color: isLoading ? Colors.grey : const Color(0xFFF48BB8), fontSize: 16),
                    ),
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
