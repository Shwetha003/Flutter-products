import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../models/auth_model.dart';

class LoginFormPage extends StatefulWidget {
  const LoginFormPage({super.key});
  @override
  State<LoginFormPage> createState() => _LoginFormPageState();
}

class _LoginFormPageState extends State<LoginFormPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthModel>();
    return Scaffold(
      appBar: AppBar(title: const Text('Enter Credentials')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            if (_error != null)
              Text(_error!, style: const TextStyle(color: Colors.red)),
            _loading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: () async {
                      setState(() {
                        _loading = true;
                        _error = null;
                      });
                      final ok = await auth.loginWithEmail(
                        _emailController.text.trim(),
                        _passwordController.text.trim(),
                      );
                      setState(() {
                        _loading = false;
                      });
                      if (ok) {
                        context.go('/products');
                      } else {
                        context.go('/register');
                      }
                    },
                    child: const Text('Log In'),
                  ),
          ],
        ),
      ),
    );
  }
}
