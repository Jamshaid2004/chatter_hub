abstract class OtpEvents {}

class SendOtpEvent extends OtpEvents{
  final String phoneNumber;
  SendOtpEvent(this.phoneNumber);
}

class VerifyOtpEvent extends OtpEvents{
  final String otpCode;
  final String verificationId;
  VerifyOtpEvent(this.otpCode, this.verificationId);
}

class ResendOtpEvent extends OtpEvents {
  final String phoneNumber;
  final int? resendToken;
  ResendOtpEvent(this.phoneNumber, {this.resendToken});
}

