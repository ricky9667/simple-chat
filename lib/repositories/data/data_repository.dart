import 'package:simple_chat/models/chat_room.dart';
import 'package:simple_chat/models/user.dart';

abstract class DataRepository {
  Future<User> getUser({required String userId});
  Future<void> submitNewUser({required User user});
  Stream<List<ChatRoom>> getChatRooms({required String userId});
  Stream<ChatRoom> getChatRoom({required String chatRoomId});
  Future<void> createChatRoom({required String name, required List<String> userIdList});
  Future<void> addUserToChatRoom({required String chatRoomId, required String userEmail});
  Future<void> sendMessage({required String chatRoomId, required String userId, required String text});
  Future<void> deleteChatRoom({required String chatRoomId});
  Future<void> leaveChatRoom({required String chatRoomId, required String userId});
}