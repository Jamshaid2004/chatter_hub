import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chatter_hub/features/auth/bloc/otp_events.dart';
import 'package:flutter_chatter_hub/features/auth/bloc/otp_states.dart';

class OtpBloc extends Bloc<OtpEvents, OtpStates> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  OtpBloc() : super(OtpInitialState()) {
    // ✅ SEND OTP
    on<SendOtpEvent>(_onSendOtp);

    // ✅ INTERNAL EVENTS
    on<OtpCodeSentInternal>(_onCodeSentInternal);
    on<OtpAutoVerifiedInternal>(_onAutoVerifiedInternal);
    on<OtpErrorInternal>(_onErrorInternal);

    // ✅ MANUAL VERIFY
    on<VerifyOtpEvent>(_onVerifyOtp);

    // ✅ RESEND
    on<ResendOtpEvent>(_onResendOtp);
  }

  // ---------------- SEND OTP ----------------
  Future<void> _onSendOtp(
    SendOtpEvent event,
    Emitter<OtpStates> emit,
  ) async {
    emit(OtpLoadingState());

    if (event.phoneNumber.isEmpty || !event.phoneNumber.startsWith('+')) {
      emit(OtpErrorState('Invalid phone number format. Use +92...'));
      return;
    }

    try {
      await _auth.verifyPhoneNumber(
        timeout: const Duration(seconds: 0),
        phoneNumber: event.phoneNumber,
        verificationCompleted: (credential) async {
          try {
            await _auth.signInWithCredential(credential);
            add(OtpAutoVerifiedInternal());
          } catch (e) {
            add(OtpErrorInternal(_getErrorMessage(e)));
          }
        },
        verificationFailed: (e) {
          add(OtpErrorInternal(_getErrorMessage(e)));
        },
        codeSent: (verificationId, resendToken) {
          debugPrint('code sent');
          debugPrint('Verification ID: $verificationId in callback');
          add(OtpCodeSentInternal(
            verificationId: verificationId,
            resendToken: resendToken,
          ));
        },
        codeAutoRetrievalTimeout: (_) {},
      );
    } catch (e) {
      emit(OtpErrorState(_getErrorMessage(e)));
    }
  }

  // ---------------- INTERNAL HANDLERS ----------------
  void _onCodeSentInternal(
    OtpCodeSentInternal event,
    Emitter<OtpStates> emit,
  ) {
    emit(OtpSentState(
      verificationId: event.verificationId,
      resendToken: event.resendToken,
    ));
  }

  void _onAutoVerifiedInternal(
    OtpAutoVerifiedInternal event,
    Emitter<OtpStates> emit,
  ) {
    emit(OtpVerifiedState());
  }

  void _onErrorInternal(
    OtpErrorInternal event,
    Emitter<OtpStates> emit,
  ) {
    emit(OtpErrorState(event.message));
  }

  // ---------------- MANUAL VERIFY ----------------
  Future<void> _onVerifyOtp(
    VerifyOtpEvent event,
    Emitter<OtpStates> emit,
  ) async {
    emit(OtpLoadingState());
    try {
      log('Verifying OTP with id: ${event.verificationId} and code: ${event.otpCode}');
      final credential = PhoneAuthProvider.credential(
        verificationId: event.verificationId,
        smsCode: event.otpCode,
      );

      await _auth.signInWithCredential(credential);
      emit(OtpVerifiedState());
    } catch (e) {
      debugPrint('Cant verify OTPPPPPPPPPPPPPPP : ${e.toString()}');
      emit(OtpErrorState(_getErrorMessage(e)));
    }
  }

  // ---------------- RESEND ----------------
  Future<void> _onResendOtp(
    ResendOtpEvent event,
    Emitter<OtpStates> emit,
  ) async {
    emit(OtpLoadingState());

    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: event.phoneNumber,
        forceResendingToken: event.resendToken,
        verificationCompleted: (credential) async {
          await _auth.signInWithCredential(credential);
          add(OtpAutoVerifiedInternal());
        },
        verificationFailed: (e) {
          add(OtpErrorInternal(_getErrorMessage(e)));
        },
        codeSent: (verificationId, resendToken) {
          add(OtpCodeSentInternal(
            verificationId: verificationId,
            resendToken: resendToken,
          ));
        },
        codeAutoRetrievalTimeout: (_) {},
      );
    } catch (e) {
      emit(OtpErrorState(_getErrorMessage(e)));
    }
  }
}

String _getErrorMessage(dynamic error) {
  if (error is FirebaseAuthException) {
    switch (error.code) {
      case 'invalid-phone-number':
        return 'Invalid phone number format';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later';
      case 'session-expired':
        return 'Session expired. Please request a new code';
      case 'invalid-verification-code':
        return 'Invalid verification code. Please try again';
      case 'invalid-verification-id':
        return 'Verification session expired. Please request a new code';
      case 'quota-exceeded':
        return 'SMS quota exceeded. Please try again later';
      default:
        return error.message ?? 'An error occurred. Please try again';
    }
  }
  return error.toString();
}
