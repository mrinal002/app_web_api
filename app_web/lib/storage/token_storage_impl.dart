import 'token_storage.dart';

// Fallback implementation that uses an in-memory map
class DefaultTokenStorage implements TokenStorageBase {
  final Map<String, String> _storage = {};

  @override
  String? getItem(String key) {
    return _storage[key];
  }

  @override
  void setItem(String key, String value) {
    _storage[key] = value;
  }

  @override
  void removeItem(String key) {
    _storage.remove(key);
  }
}

TokenStorageBase getTokenStorage() => DefaultTokenStorage();
