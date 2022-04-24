import 'package:firebase_auth/firebase_auth.dart';
import 'package:simple_chat/repositories/auth/auth_repository.dart';

class FirebaseAuthRepository implements AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool get isLoggedIn => _auth.currentUser != null;
  String get id => _auth.currentUser!.uid;
  String get email => _auth.currentUser!.email!;

  @override
  Future<void> signUp(String email, String password) async {
    await _auth.createUserWithEmailAndPassword(email: email, password: password);
  }

  @override
  Future<void> login(String email, String password) async {
    await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  @override
  Future<void> logout() async {
    await _auth.signOut();
  }
}

final firebaseAuthRepository = FirebaseAuthRepository();