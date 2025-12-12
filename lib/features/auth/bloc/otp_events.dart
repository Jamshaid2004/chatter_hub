abstract class OtpEvents {}

// User Actions
class SendOtpEvent extends OtpEvents {
  final String phoneNumber;
  SendOtpEvent(this.phoneNumber);
}

class VerifyOtpEvent extends OtpEvents {
  final String verificationId;
  final String otpCode;
  VerifyOtpEvent(this.verificationId, this.otpCode);
}

class ResendOtpEvent extends OtpEvents {
  final String phoneNumber;
  final int? resendToken;
  ResendOtpEvent(this.phoneNumber, this.resendToken);
}

// Internal Events
class OtpCodeSentInternal extends OtpEvents {
  final String verificationId;
  final int? resendToken;

  OtpCodeSentInternal({
    required this.verificationId,
    required this.resendToken,
  });
}

class OtpAutoVerifiedInternal extends OtpEvents {}

class OtpErrorInternal extends OtpEvents {
  final String message;
  OtpErrorInternal(this.message);
}
