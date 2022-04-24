import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:simple_chat/models/user.dart';
import 'package:simple_chat/repositories/data/data_repository.dart';

class FirebaseDataRepository extends DataRepository {
  final _firestore = FirebaseFirestore.instance;

  CollectionReference<User> get _usersRef => _firestore.collection('users').withConverter<User>(
        fromFirestore: (snapshot, options) => User.fromJson(snapshot.data()!),
        toFirestore: (user, options) => user.toJson(),
      );

  @override
  Future<User> getUser({required String id}) async {
    final user = await _usersRef.doc(id).get();
    return user.data()!;
  }

  @override
  Future<void> submitNewUser({required User user}) async {
    await _usersRef.doc(user.id).set(user);
  }
}

final firebaseDataRepository = FirebaseDataRepository();
