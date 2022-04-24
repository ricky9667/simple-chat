import 'package:simple_chat/models/user.dart';

abstract class DataRepository {
  Future<User> getUser({required String id});
  Future<void> submitNewUser({required User user});
}