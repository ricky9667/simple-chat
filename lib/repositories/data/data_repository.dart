import 'package:simple_chat/models/chat_room.dart';
import 'package:simple_chat/models/user.dart';

abstract class DataRepository {
  Future<User> getUser({required String userId});
  Future<void> submitNewUser({required User user});
  Stream<List<ChatRoom>> getChatRooms({required String userId});
  Stream<ChatRoom> getChatRoom({required String chatRoomId});
  Future<void> createChatroom({required String name, required List<String> userIdList});
}