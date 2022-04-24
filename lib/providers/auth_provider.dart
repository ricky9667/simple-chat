import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simple_chat/models/user.dart';
import 'package:simple_chat/repositories/auth/firebase_auth_repository.dart';

class Auth {
  final bool isInitialized;
  final bool isLoggedIn;

  const Auth({required this.isInitialized, required this.isLoggedIn});

  Auth copyWith({bool? isInitialized, bool? isLoggedIn, User? user}) {
    return Auth(
      isInitialized: isInitialized ?? this.isInitialized,
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
    );
  }
}

class AuthNotifier extends StateNotifier<Auth> {
  AuthNotifier() : super(const Auth(isInitialized: false, isLoggedIn: false)) {
    initialize();
  }

  void initialize() async {
    if (firebaseAuthRepository.isLoggedIn) {
      state = const Auth(isInitialized: true, isLoggedIn: true);
    } else {
      state = const Auth(isInitialized: true, isLoggedIn: false);
    }
  }

  Future<void> signUp(String email, String password, String name) async {
    await firebaseAuthRepository.signUp(email, password);
    state = state.copyWith(isLoggedIn: true);
  }

  Future<void> login(String email, String password) async {
    await firebaseAuthRepository.login(email, password);
    state = state.copyWith(isLoggedIn: true);
  }

  void logout() {
    firebaseAuthRepository.logout();
    state = const Auth(isInitialized: true, isLoggedIn: false);
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, Auth>((ref) => AuthNotifier());
