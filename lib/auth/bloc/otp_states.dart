abstract class OtpStates {}

class OtpInitialState extends OtpStates {}

class OtpLoadingState extends OtpStates {}

class OtpSentState extends OtpStates {
  final String verificationId;
  final int? resendToken;
  OtpSentState({required this.verificationId, this.resendToken});
}

class OtpVerifiedState extends OtpStates {}

class OtpErrorState extends OtpStates {
  final String message;
  OtpErrorState(this.message);
}
