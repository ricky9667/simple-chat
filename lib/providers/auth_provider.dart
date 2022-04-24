import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simple_chat/models/user.dart';
import 'package:simple_chat/repositories/auth/firebase_auth_repository.dart';
import 'package:simple_chat/repositories/data/firebase_data_repository.dart';

class Auth {
  final bool isInitialized;
  final bool isLoggedIn;
  final User? currentUser;

  const Auth({required this.isInitialized, required this.isLoggedIn, User? user}) : currentUser = user;

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
    state = Auth(isInitialized: true, isLoggedIn: firebaseAuthRepository.isLoggedIn);
  }

  Future<void> signUp(String email, String password, String name) async {
    await firebaseAuthRepository.signUp(email, password);
    final user = User(id: firebaseAuthRepository.id, email: firebaseAuthRepository.email, name: name);
    await firebaseDataRepository.submitNewUser(user: user);
    state = state.copyWith(isLoggedIn: true);
  }

  Future<void> login(String email, String password) async {
    await firebaseAuthRepository.login(email, password);
    final user = await firebaseDataRepository.getUser(id: firebaseAuthRepository.id);
    state = state.copyWith(isLoggedIn: true, user: user);
  }

  void logout() {
    firebaseAuthRepository.logout();
    state = const Auth(isInitialized: true, isLoggedIn: false);
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, Auth>((ref) => AuthNotifier());
