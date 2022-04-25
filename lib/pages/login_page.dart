import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:queen_validators/queen_validators.dart';
import 'package:simple_chat/pages/signup_page.dart';
import 'package:simple_chat/providers/auth_provider.dart';

final _isLoadingProvider = StateProvider.autoDispose<bool>((ref) => false);

class LoginPage extends ConsumerWidget {
  LoginPage({Key? key}) : super(key: key);

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  void _loginUser(BuildContext context, WidgetRef ref) async {
    try {
      _emailController.text = _emailController.text.trim();
      _passwordController.text = _passwordController.text.trim();
      if (!_formKey.currentState!.validate()) throw 'Some fields are not valid';

      ref.read(_isLoadingProvider.notifier).state = true;
      final email = _emailController.text;
      final password = _passwordController.text;
      await ref.read(authProvider.notifier).login(email, password);

      _emailController.text = '';
      _passwordController.text = '';
      ref.read(_isLoadingProvider.notifier).state = false;
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login failed: $error')),
      );
    } finally {
      ref.read(_isLoadingProvider.notifier).state = false;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = ref.watch(_isLoadingProvider);

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(12),
            constraints: const BoxConstraints(maxWidth: 600),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Simple Chat',
                    style: Theme.of(context).textTheme.headline4!.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  const Text('Please login/signup an account'),
                  const SizedBox(height: 36),
                  TextFormField(
                    controller: _emailController,
                    enabled: !isLoading,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.mail_outline),
                      labelText: 'Email',
                    ),
                    validator: qValidator([
                      IsRequired(),
                      const IsEmail(),
                    ]),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _passwordController,
                    enabled: !isLoading,
                    obscureText: true,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.lock_outline),
                      labelText: 'Password',
                    ),
                    validator: qValidator([
                      IsRequired(),
                      MinLength(8),
                      MaxLength(20),
                    ]),
                  ),
                  const SizedBox(height: 36),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        flex: 1,
                        child: OutlinedButton(
                          onPressed: isLoading
                              ? null
                              : () => Navigator.push(context, MaterialPageRoute(builder: (context) => SignupPage())),
                          child: const Text('Signup new account'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 1,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : () => _loginUser(context, ref),
                          child: const Text('Login'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
