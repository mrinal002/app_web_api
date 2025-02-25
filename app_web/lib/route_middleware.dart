import 'package:flutter/material.dart';
import 'token_service.dart';

class RouteMiddleware {
  static const List<String> _protectedRoutes = [
    '/profile',
    '/online-users',
    '/chat',
  ];

  static const List<String> _publicRoutes = [
    '/login',
    '/register',
    '/mobile',
  ];

  static bool requiresAuth(String route) {
    return _protectedRoutes.any((r) => route.startsWith(r));
  }

  static bool isPublicOnly(String route) {
    return _publicRoutes.any((r) => route == r);
  }

  static Route<dynamic>? handleNavigation(RouteSettings settings) {
    final String route = settings.name ?? '';
    final bool hasToken = TokenService.hasValidToken();

    // Debug information
    print('Route: $route');
    print('Has valid token: $hasToken');
    print('Requires auth: ${requiresAuth(route)}');
    print('Is public only: ${isPublicOnly(route)}');

    // Home route handling
    if (route == '/') {
      return MaterialPageRoute(
        builder: (_) => Redirect(
          destination: hasToken ? '/profile' : '/login'
        ),
        settings: RouteSettings(
          name: hasToken ? '/profile' : '/login'
        ),
      );
    }

    // Protected routes check
    if (requiresAuth(route) && !hasToken) {
      print('Redirecting to login: Protected route without token');
      return MaterialPageRoute(
        builder: (_) => const Redirect(destination: '/login'),
        settings: const RouteSettings(name: '/login'),
      );
    }

    // Public routes check
    if (isPublicOnly(route) && hasToken) {
      print('Redirecting to profile: Public route with token');
      return MaterialPageRoute(
        builder: (_) => const Redirect(destination: '/profile'),
        settings: const RouteSettings(name: '/profile'),
      );
    }

    return null;
  }
}

class Redirect extends StatefulWidget {
  final String destination;
  
  const Redirect({Key? key, required this.destination}) : super(key: key);

  @override
  State<Redirect> createState() => _RedirectState();
}

class _RedirectState extends State<Redirect> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.of(context).pushReplacementNamed(widget.destination);
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
