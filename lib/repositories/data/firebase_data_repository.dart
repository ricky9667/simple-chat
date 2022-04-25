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
  Stream<ChatRoom> getChatRoom({required String chatRoomId}) {
    return _chatRoomsRef.doc(chatRoomId).snapshots().map((snapshot) => snapshot.data()!);
  }

  @override
  Stream<List<ChatRoom>> getChatRooms({required String userId}) {
    return _chatRoomsRef
        .where('users', arrayContains: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  @override
  Future<void> createChatRoom({required String name, required List<String> userIdList}) async {
    final chatRoomId = const Uuid().v4();
    final chatRoom = ChatRoom(id: chatRoomId, users: userIdList, name: name);
    await _chatRoomsRef.doc(chatRoomId).set(chatRoom);
  }

  @override
  Future<void> addUserToChatRoom({required String chatRoomId, required String userEmail}) async {
    final userId =
        await _usersRef.where('email', isEqualTo: userEmail).get().then((snapshot) => snapshot.docs.single.id);

    final chatRoom = await _chatRoomsRef.doc(chatRoomId).get().then((value) => value.data()!);
    if (chatRoom.users.contains(userId)) throw 'User already exists';

    await _chatRoomsRef.doc(chatRoomId).update({
      'users': [...chatRoom.users, userId],
    });
  }

  @override
  Future<void> sendMessage({required String chatRoomId, required String userId, required String text}) async {
    final chatRoom = await _chatRoomsRef.doc(chatRoomId).get().then((value) => value.data()!);

    final Map<String, dynamic> message = {
      'user': userId,
      'text': text,
      'time': Timestamp.fromDate(DateTime.now()),
    };

    await _chatRoomsRef.doc(chatRoomId).update({
      'messages': [...chatRoom.messages, message],
    });
  }

  @override
  Future<void> deleteChatRoom({required String chatRoomId}) async {
    await _chatRoomsRef.doc(chatRoomId).delete();
  }
}

final firebaseDataRepository = FirebaseDataRepository();
