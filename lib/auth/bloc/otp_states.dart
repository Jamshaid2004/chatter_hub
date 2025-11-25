abstract class OtpStates {}

class OtpInitialState extends OtpStates {}

class OtpLoadingState extends OtpStates {}

class OtpSentState extends OtpStates {}

class OtpVerifiedState extends OtpStates {}

class OtpErrorState extends OtpStates {
  final String message;
  OtpErrorState(this.message);
}
