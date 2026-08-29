abstract class LoginEvent {}

class UserLoginEvent extends LoginEvent {
  final String username;
  final String password;

  UserLoginEvent({required this.username, required this.password});
}

class UserLogOutEvent extends LoginEvent {
  UserLogOutEvent();
}

class SendOtpEvent extends LoginEvent {
  final int mobile;
  final int countryCode;

  SendOtpEvent({required this.mobile, required this.countryCode});
}

class VerifyOtpEvent extends LoginEvent {
  final int mobile;
  final int countryCode;
  final int otp;

  VerifyOtpEvent(
      {required this.otp, required this.mobile, required this.countryCode});
}
