import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chatter_hub/auth/bloc/otp_events.dart';
import 'package:flutter_chatter_hub/auth/bloc/otp_states.dart';

class OtpBloc extends Bloc<OtpEvents, OtpStates>{
  OtpBloc():super(OtpInitialState()){
    on<SendOtpEvent>((event, emit)async{
      emit(OtpLoadingState());
      await Future.delayed(const Duration(seconds: 2));
      emit (OtpSentState());
    });

    on<VerifyOtpEvent>((event, emit)async{
      emit(OtpLoadingState());
      await Future.delayed(const Duration(seconds: 2));

      if(event.otpCode == '123456' ){
        emit(OtpVerifiedState());
      }
      else{
        emit(OtpErrorState('Invalid Otp, Please try Again'));
      }

    });

    on<ResendOtpEvent>((event, emit) async{
      emit(OtpLoadingState());
      await Future.delayed(const Duration(seconds: 2));
      emit(OtpSentState());

    });

  }
}


  