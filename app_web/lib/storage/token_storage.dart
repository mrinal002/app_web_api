import 'token_storage_impl.dart'
    if (dart.library.html) 'web_token_storage.dart'
    if (dart.library.io) 'mobile_token_storage.dart';

abstract class TokenStorageBase {
  String? getItem(String key);
  void setItem(String key, String value);
  void removeItem(String key);
}

// This will be initialized with the correct platform implementation
TokenStorageBase createTokenStorage() => getTokenStorage();

class TokenStorage implements TokenStorageBase {
  static final TokenStorage _instance = TokenStorage._internal();
  final TokenStorageBase _storage = createTokenStorage();
  
  factory TokenStorage() {
    return _instance;
  }

  TokenStorage._internal();

  @override
  String? getItem(String key) => _storage.getItem(key);

  @override
  void setItem(String key, String value) => _storage.setItem(key, value);

  @override
  void removeItem(String key) => _storage.removeItem(key);
}
