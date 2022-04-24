import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:simple_chat/models/chat_room.dart';
import 'package:simple_chat/models/user.dart';
import 'package:simple_chat/repositories/data/data_repository.dart';
import 'package:uuid/uuid.dart';

class FirebaseDataRepository extends DataRepository {
  final _firestore = FirebaseFirestore.instance;

  CollectionReference<User> get _usersRef => _firestore.collection('users').withConverter<User>(
        fromFirestore: (snapshot, options) => User.fromJson(snapshot.data()!),
        toFirestore: (user, options) => user.toJson(),
      );

  CollectionReference<ChatRoom> get _chatRoomsRef => _firestore.collection('chatrooms').withConverter<ChatRoom>(
        fromFirestore: (snapshot, options) => ChatRoom.fromJson(snapshot.data()!),
        toFirestore: (chatroom, options) => chatroom.toJson(),
      );

  @override
  Future<User> getUser({required String userId}) async {
    final user = await _usersRef.doc(userId).get();
    return user.data()!;
  }

  @override
  Future<void> submitNewUser({required User user}) async {
    await _usersRef.doc(user.id).set(user);
  }

  @override
  Stream<List<ChatRoom>> getChatRooms({required String userId}) {
    return _chatRoomsRef
        .where('users', arrayContains: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  @override
  Future<void> createChatroom({required String name, required List<String> userIdList}) async {
    final chatRoomId = const Uuid().v4();
    final chatRoom = ChatRoom(id: chatRoomId, users: userIdList, name: name);
    await _chatRoomsRef.doc(chatRoomId).set(chatRoom);
  }
}

final firebaseDataRepository = FirebaseDataRepository();
