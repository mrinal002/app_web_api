import 'dart:html' show window;
import 'dart:convert';

class TokenService {
  static const String _tokenKey = 'auth_token';
  
  static void setToken(String token) {
    window.localStorage[_tokenKey] = token;
  }

  static String? getToken() {
    return window.localStorage[_tokenKey];
  }

  static void removeToken() {
    window.localStorage.remove(_tokenKey);
  }

  static bool hasValidToken() {
    final token = getToken();
    if (token == null) return false;
    
    try {
      // JWT token consists of 3 parts separated by dots
      final parts = token.split('.');
      if (parts.length != 3) return false;

      // Decode the payload (second part)
      final payload = json.decode(
        utf8.decode(base64Url.decode(base64Url.normalize(parts[1])))
      );

      // Check if token has expired
      final exp = payload['exp'];
      if (exp == null) return false;

      final expiry = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
      return expiry.isAfter(DateTime.now());
    } catch (e) {
      return false;
    }
  }
}
