import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'token_service.dart';
import 'login_screen.dart';
import 'register_screen.dart';
import 'profile_screen.dart';
import 'mobile_screen.dart';
import 'home_screen.dart';
import 'pages/online_users_page.dart';
import 'pages/chat_page.dart';
import 'route_middleware.dart';

void main() {
  // Configure URL strategy
  setUrlStrategy(PathUrlStrategy());
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  Map<String, WidgetBuilder> _buildAppRoutes() {
    return {
      '/': (context) => _guardRoute(
        route: '/',
        builder: (_) => HomeScreen(),
      ),
      '/login': (context) => _guardRoute(
        route: '/login',
        builder: (_) => LoginScreen(),
        requiresAuth: false,
      ),
      '/register': (context) => _guardRoute(
        route: '/register',
        builder: (_) => RegisterScreen(),
        requiresAuth: false,
      ),
      '/profile': (context) => _guardRoute(
        route: '/profile',
        builder: (_) => ProfileScreen(),
        requiresAuth: true,
      ),
      '/mobile': (context) => _guardRoute(
        route: '/mobile',
        builder: (_) => MobileScreen(),
        requiresAuth: false,
      ),
      '/online-users': (context) => _guardRoute(
        route: '/online-users',
        builder: (_) => const OnlineUsersPage(),
        requiresAuth: true,
      ),
    };
  }

  Widget _guardRoute({
    required String route,
    required WidgetBuilder builder,
    bool requiresAuth = false,
  }) {
    return Builder(
      builder: (context) {
        final hasToken = TokenService.hasValidToken();
        print('Route: $route, RequiresAuth: $requiresAuth, HasToken: $hasToken');

        if (requiresAuth && !hasToken) {
          print('Blocking access to protected route: $route');
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).pushReplacementNamed('/login');
          });
          return Container(); // Will be replaced immediately
        }

        if (!requiresAuth && hasToken && (route == '/login' || route == '/register' || route == '/mobile')) {
          print('Blocking access to public route: $route');
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).pushReplacementNamed('/profile');
          });
          return Container(); // Will be replaced immediately
        }

        return builder(context);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'My App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: _buildAppRoutes(),
      onGenerateRoute: (settings) {
        // Check route protection first
        final protectedRoute = RouteMiddleware.handleNavigation(settings);
        if (protectedRoute != null) {
          return protectedRoute;
        }

        // Handle chat route
        if (settings.name == '/chat') {
          final args = settings.arguments as Map<String, dynamic>?;
          return MaterialPageRoute(
            builder: (context) => _guardRoute(
              route: '/chat',
              requiresAuth: true,
              builder: (_) => ChatPage(
                userId: args?['userId'],
                userName: args?['userName'],
              ),
            ),
          );
        }
        return null;
      },
    );
  }
}
