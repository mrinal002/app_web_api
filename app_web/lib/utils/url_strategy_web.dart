import 'package:flutter_web_plugins/flutter_web_plugins.dart';

// Web-specific implementation
void configureUrlStrategyImpl() {
  // Use path URL strategy for cleaner URLs on the web
  setUrlStrategy(PathUrlStrategy());
}
