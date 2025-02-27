import 'dart:html' show window;
import 'token_storage.dart';

class WebTokenStorage implements TokenStorageBase {
  @override
  String? getItem(String key) {
    return window.localStorage[key];
  }

  @override
  void setItem(String key, String value) {
    window.localStorage[key] = value;
  }

  @override
  void removeItem(String key) {
    window.localStorage.remove(key);
  }
}

TokenStorageBase getTokenStorage() => WebTokenStorage();
