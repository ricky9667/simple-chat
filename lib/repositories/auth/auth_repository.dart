abstract class AuthRepository {
  Future<void> signUp(String email, String password);
  Future<void> login(String email, String password);
  Future<void> logout();
}