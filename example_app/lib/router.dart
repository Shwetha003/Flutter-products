import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'models/auth_model.dart';
import 'screens/welcome_page.dart';
import 'screens/login_form_page.dart';
import 'screens/register_page.dart';
import 'screens/products_page.dart';
import 'screens/cart_page.dart';
import 'screens/support_screen.dart';

GoRouter createRouter(AuthModel auth) {
  return GoRouter(
    initialLocation: '/welcome',
    refreshListenable: auth,
    routes: [
      GoRoute(
        path: '/welcome',
        name: 'welcome',
        builder: (context, state) => const WelcomePage(),
        //builder: (_, __) =>
        //    const Scaffold(body: Center(child: CircularProgressIndicator())),
      ),

      // Login screen
      GoRoute(
        path: '/login-form',
        name: 'login-form',
        builder: (context, state) => const LoginFormPage(),
      ),

      // Register screen
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterPage(),
      ),

      // Products screen
      GoRoute(
        path: '/products',
        name: 'products',
        builder: (context, state) => ProductsPage(),
      ),

      // Cart screen
      GoRoute(
        path: '/cart',
        name: 'cart',
        builder: (context, state) => CartPage(),
      ),

      GoRoute(
        path: '/support',
        name: 'support',
        builder: (context, state) => const SupportScreen(),
      ),
    ],
    redirect: (context, state) {
      //final auth = context.read<AuthModel>();
      if (!auth.initialized) return null; // don’t redirect yet
      final dest = state.uri.path;

      // If not logged in, send to login form
      if (!auth.loggedIn &&
          dest != '/login-form' &&
          dest != '/welcome' &&
          dest != '/register') {
        return '/login-form';
      }
      // If logged in, productss
      if (auth.loggedIn &&
          (dest == '/welcome' ||
              dest == '/login-form' ||
              dest == '/register')) {
        return '/products';
      }
      return null;
    },
    /* // Redirect based on login state:
    //before secure storage
    redirect: (context, state) {
      final loggedIn = auth.loggedIn;
      final dest = state
          .matchedLocation; // e.g. '/login', '/cart', etc.(or state.uri.path)

      if (!loggedIn && dest != '/login' && dest != '/register') {
        return '/login';
      }
      if (loggedIn && (dest == '/login' || dest == '/register')) {
        return '/products';
      }

      return null; // no redirect needed
    },
    */

    // Fallback for unknown routes
    errorBuilder: (context, state) => Scaffold(
      body: Center(child: Text('Page not found: ${state.uri.toString()}')),
    ),
  );
}
