import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../routes.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  Future<void> _login(BuildContext context) async {
    await context.read<AuthProvider>().login('guest');
    if (!context.mounted) return;
    Navigator.pushReplacementNamed(context, AppRoutes.catalog);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Center(
        child: ElevatedButton(
          onPressed: () => _login(context),
          child: const Text('Sign in'),
        ),
      ),
    );
  }
}
