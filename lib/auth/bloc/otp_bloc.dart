import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_chatter_hub/auth/bloc/otp_events.dart';
import 'package:flutter_chatter_hub/auth/bloc/otp_states.dart';

class OtpBloc extends Bloc<OtpEvents, OtpStates>{
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  OtpBloc():super(OtpInitialState()){
    on<SendOtpEvent>((event, emit) async {
      emit(OtpLoadingState());
      try {
        await _auth.verifyPhoneNumber(
          phoneNumber: event.phoneNumber,
          verificationCompleted: (PhoneAuthCredential credential) async {
            // Auto-verification completed (SMS code received automatically)
            if (emit.isDone) return;
            try {
              await _auth.signInWithCredential(credential);
              if (!emit.isDone) emit(OtpVerifiedState());
            } catch (e) {
              if (!emit.isDone) emit(OtpErrorState(_getErrorMessage(e)));
            }
          },
          verificationFailed: (FirebaseAuthException e) {
            if (!emit.isDone) emit(OtpErrorState(_getErrorMessage(e)));
          },
          codeSent: (String verificationId, int? resendToken) {
            if (!emit.isDone) {
              emit(OtpSentState(
                verificationId: verificationId,
                resendToken: resendToken,
              ));
            }
          },
          codeAutoRetrievalTimeout: (String verificationId) {
            // Auto-retrieval timeout, but code was sent
            if (!emit.isDone) emit(OtpSentState(verificationId: verificationId));
          },
          timeout: const Duration(seconds: 60),
        );
      } catch (e) {
        if (!emit.isDone) emit(OtpErrorState(_getErrorMessage(e)));
      }
    });

    on<VerifyOtpEvent>((event, emit) async {
      emit(OtpLoadingState());
      try {
        final credential = PhoneAuthProvider.credential(
          verificationId: event.verificationId,
          smsCode: event.otpCode,
        );
        
        await _auth.signInWithCredential(credential);
        emit(OtpVerifiedState());
      } on FirebaseAuthException catch (e) {
        emit(OtpErrorState(_getErrorMessage(e)));
      } catch (e) {
        emit(OtpErrorState(_getErrorMessage(e)));
      }
    });

    on<ResendOtpEvent>((event, emit) async {
      emit(OtpLoadingState());
      try {
        await _auth.verifyPhoneNumber(
          phoneNumber: event.phoneNumber,
          verificationCompleted: (PhoneAuthCredential credential) async {
            if (emit.isDone) return;
            try {
              await _auth.signInWithCredential(credential);
              if (!emit.isDone) emit(OtpVerifiedState());
            } catch (e) {
              if (!emit.isDone) emit(OtpErrorState(_getErrorMessage(e)));
            }
          },
          verificationFailed: (FirebaseAuthException e) {
            if (!emit.isDone) emit(OtpErrorState(_getErrorMessage(e)));
          },
          codeSent: (String verificationId, int? resendToken) {
            if (!emit.isDone) {
              emit(OtpSentState(
                verificationId: verificationId,
                resendToken: resendToken,
              ));
            }
          },
          codeAutoRetrievalTimeout: (String verificationId) {
            if (!emit.isDone) emit(OtpSentState(verificationId: verificationId));
          },
          forceResendingToken: event.resendToken,
          timeout: const Duration(seconds: 60),
        );
      } catch (e) {
        if (!emit.isDone) emit(OtpErrorState(_getErrorMessage(e)));
      }
    });
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
}


  