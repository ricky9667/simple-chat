import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simple_chat/pages/chat_list_page.dart';
import 'package:simple_chat/pages/loading_page.dart';
import 'package:simple_chat/pages/login_page.dart';
import 'package:simple_chat/providers/auth_provider.dart';

class AuthPageHandler extends ConsumerWidget {
  const AuthPageHandler({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    if (auth.isInitialized) {
      return auth.isLoggedIn ? const ChatListPage() : LoginPage();
    } else {
      return const LoadingPage();
    }
  }
}
