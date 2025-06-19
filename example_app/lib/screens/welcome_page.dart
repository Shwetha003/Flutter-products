import 'package:flutter/material.dart';
//import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

//import '../models/auth_model.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});
  @override
  Widget build(BuildContext context) {
    //final auth = context.read<AuthModel>();
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              onPressed: () => context.go('/login-form'),
              child: const Text('Log In'),
            ),
            TextButton(
              onPressed: () => context.goNamed('register'),
              child: const Text('Don’t have an account? Register'),
            ),
          ],
        ),
      ),
    );
  }
}
