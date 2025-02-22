class UserEmailService {
  static String? _userEmail;

  static void setEmail(String email) {
    _userEmail = email;
  }

  static String? getEmail() {
    return _userEmail;
  }
}
