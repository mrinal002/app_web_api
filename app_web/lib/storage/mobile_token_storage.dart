import 'package:shared_preferences/shared_preferences.dart';
import 'token_storage.dart';

class MobileTokenStorage implements TokenStorageBase {
  SharedPreferences? _prefs;
  
  Future<SharedPreferences> get prefs async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  @override
  String? getItem(String key) {
    // We need synchronous access, so using a cache or default value
    // For actual implementation, consider making TokenStorage methods asynchronous
    try {
      return _prefs?.getString(key);
    } catch (e) {
      return null;
    }
  }

  @override
  void setItem(String key, String value) async {
    final preferences = await prefs;
    await preferences.setString(key, value);
  }

  @override
  void removeItem(String key) async {
    final preferences = await prefs;
    await preferences.remove(key);
  }
}

TokenStorageBase getTokenStorage() => MobileTokenStorage();
