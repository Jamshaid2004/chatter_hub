abstract class OtpEvents {}

class SendOtpEvent extends OtpEvents{
  final String phoneNumber;
  SendOtpEvent(this.phoneNumber);
}

class VerifyOtpEvent extends OtpEvents{
  final String otpCode;
  VerifyOtpEvent(this.otpCode);
}

class ResendOtpEvent extends OtpEvents {
  final String phoneNumber;
  ResendOtpEvent(this.phoneNumber);
}

