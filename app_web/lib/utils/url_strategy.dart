// This file acts as the interface for platform-specific URL strategy configuration

import 'url_strategy_stub.dart'
    if (dart.library.html) 'url_strategy_web.dart'
    if (dart.library.io) 'url_strategy_mobile.dart';

// This function will call the correct implementation based on platform
void configureUrlStrategy() {
  configureUrlStrategyImpl();
}
