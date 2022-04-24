import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simple_chat/pages/chat_list_page.dart';
import 'package:simple_chat/pages/login_page.dart';
import 'package:simple_chat/providers/auth_provider.dart';

class AuthPageHandler extends ConsumerWidget {
  const AuthPageHandler({Key? key}) : super(key: key);

  Widget _getLoadingPage(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Loading ...', style: Theme.of(context).textTheme.headline4),
            const SizedBox(height: 20),
            const CircularProgressIndicator(
              color: Colors.blue,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    if (auth.isInitialized) {
      return auth.isLoggedIn ? ChatListPage() : LoginPage();
    } else {
      return _getLoadingPage(context);
    }
  }
}
