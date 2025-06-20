import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../models/auth_model.dart';
import '../services/secure_storage.dart';
import 'dart:async';

class LoginFormPage extends StatefulWidget {
  const LoginFormPage({super.key});
  @override
  State<LoginFormPage> createState() => _LoginFormPageState();
}

class _LoginFormPageState extends State<LoginFormPage> {
  final _formKey = GlobalKey<FormState>();
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
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction, //
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                ), //background text

                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  // Simple email pattern check
                  final emailRegex = RegExp(r"^[^@\s]+@[^@\s]+\.[^@\s]+$"); //
                  if (!emailRegex.hasMatch(value)) {
                    return 'Please enter a valid email address';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              if (_error != null)
                Text(_error!, style: const TextStyle(color: Colors.red)),
              _loading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: () async {
                        if (!_formKey.currentState!.validate()) return;

                        setState(() {
                          _loading = true;
                          _error = null;
                        });

                        final email = _emailController.text.trim();
                        final password = _passwordController.text.trim();

                        // Attempt login via AuthModel
                        final ok = await auth.loginWithEmail(email, password);

                        setState(() {
                          _loading = false;
                        });
                        if (ok) {
                          context.go('/products');
                        } else {
                          // Determine if email exists in storage
                          final creds =
                              await SecureStorage.getCredentialsList();
                          final emailExists = creds.any(
                            (e) => e['email'] == email,
                          );

                          if (emailExists) {
                            // Email registered but wrong password
                            setState(() {
                              _error = 'Wrong password';
                            });
                          } else {
                            // Show dialog to register or cancel, auto-navigate after 5s
                            bool decisionMade = false;
                            Timer? timer;
                            timer = Timer(const Duration(seconds: 5), () {
                              if (!decisionMade) {
                                Navigator.of(
                                  context,
                                  rootNavigator: true,
                                ).pop();
                                context.go('/register');
                              }
                            });
                            final choice = await showDialog<bool>(
                              context: context,
                              barrierDismissible: false,
                              builder: (context) => AlertDialog(
                                title: const Text('Email not registered'),
                                content: const Text('Register?'),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      decisionMade = true;
                                      timer?.cancel();
                                      Navigator.of(context).pop(false);
                                    },
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      decisionMade = true;
                                      timer?.cancel();
                                      Navigator.of(context).pop(true);
                                    },
                                    child: const Text('Register'),
                                  ),
                                ],
                              ),
                            );

                            if (choice == true) {
                              context.go('/register');
                            }
                          }
                        }
                      },
                      child: const Text('Log In'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
