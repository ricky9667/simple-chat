import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:queen_validators/queen_validators.dart';
import 'package:simple_chat/providers/auth_provider.dart';

final _isLoadingProvider = StateProvider.autoDispose<bool>((ref) => false);

class SignupPage extends ConsumerWidget {
  SignupPage({Key? key}) : super(key: key);

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordVerificationController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  void _signupUser(BuildContext context, WidgetRef ref) async {
    try {
      _nameController.text = _nameController.text.trim();
      _emailController.text = _emailController.text.trim();
      _passwordController.text = _passwordController.text.trim();
      if (!_formKey.currentState!.validate()) throw 'Some fields are not valid';

      ref.read(_isLoadingProvider.notifier).state = true;
      final name = _nameController.text;
      final email = _emailController.text;
      final password = _passwordController.text;
      await ref.read(authProvider.notifier).signUp(email, password, name);

      Navigator.of(context).pop();
      _nameController.text = '';
      _emailController.text = '';
      _passwordController.text = '';
      _passwordVerificationController.text = '';
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Signup failed: $error')),
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
                    'Create an account',
                    style: Theme.of(context).textTheme.headline4!.copyWith(fontWeight: FontWeight.bold),
                  ),
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
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _passwordVerificationController,
                    enabled: !isLoading,
                    obscureText: true,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.lock_outline),
                      labelText: 'Confirm password',
                    ),
                    validator: (value) => value != _passwordController.text ? 'Password is not identical' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _nameController,
                    enabled: !isLoading,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.account_circle_outlined),
                      labelText: 'Name',
                    ),
                    validator: qValidator([IsRequired()]),
                  ),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        flex: 1,
                        child: OutlinedButton(
                          onPressed: isLoading ? null : () => Navigator.of(context).pop(),
                          child: const Text('Back to login'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 1,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : () => _signupUser(context, ref),
                          child: const Text('Signup'),
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
