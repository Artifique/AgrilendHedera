import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/auth_providers.dart';

class LoginExample extends ConsumerStatefulWidget {
  const LoginExample({super.key});

  @override
  ConsumerState<LoginExample> createState() => _LoginExampleState();
}

class _LoginExampleState extends ConsumerState<LoginExample> {
  final _emailCtrl = TextEditingController();
  final _pwCtrl = TextEditingController();
  bool _loading = false;

  Future<void> _onLogin() async {
    setState(() => _loading = true);
    final auth = ref.read(authNotifierProvider.notifier);
    final success =
        await auth.login(_emailCtrl.text.trim(), _pwCtrl.text.trim());
    setState(() => _loading = false);
    if (success) {
      // Navigate or show success
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Login success')));
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Login failed')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login example')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
                controller: _emailCtrl,
                decoration: const InputDecoration(labelText: 'Email')),
            TextField(
                controller: _pwCtrl,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true),
            const SizedBox(height: 20),
            ElevatedButton(
                onPressed: _loading ? null : _onLogin,
                child: _loading
                    ? const CircularProgressIndicator()
                    : const Text('Login')),
          ],
        ),
      ),
    );
  }
}
