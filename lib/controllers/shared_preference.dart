import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferenceServices {
  factory SharedPreferenceServices() => _instance;
  SharedPreferenceServices._internal();

  static final SharedPreferenceServices _instance =
      SharedPreferenceServices._internal();

  String isLoggedIn = "is_logged_in";
  String registerCookie = "register_cookie";

  String authCookie = "auth_cookie";
  late SharedPreferences pref;

  Future<void> init() async {
    pref = await SharedPreferences.getInstance();
  }

  Future<void> saveLoggedInStatus(bool status) async {
    await pref.setBool(isLoggedIn, status);
  }

  bool? getLoggedInStatus() {
    return pref.getBool(isLoggedIn);
  }

  // to save AuthCookie

  Future<void> saveAuthCookie(String cookie) async {
    await pref.setString(authCookie, cookie);
  }

  String? getAuthCookie() {
    return pref.getString(authCookie);
  }

  // TO save OTP cookie to verify
  Future<void> saveOtpCookie(String cookie) async {
    await pref.setString(registerCookie, cookie);
  }

  String? getOtpCookie() {
    return pref.getString(registerCookie);
  }
}
