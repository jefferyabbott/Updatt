import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:upddat/models/user.dart';

class DatabaseService {
  // get instance of firebase db & auth
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  // user profile

  Future<UserProfile?> getUserFromFirebase(String uid) async {
    try {
      DocumentSnapshot userDoc = await _db.collection("Users").doc(uid).get();
      return UserProfile.fromDocument(userDoc);
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<void> saveUserInfoInFirebase(
      {required String name, required String email}) async {
    // get uid
    String uid = _auth.currentUser!.uid;

    // extract username from email
    String username = email.split('@')[0];

    // create a user profile
    UserProfile user = UserProfile(
      uid: uid,
      name: name,
      email: email,
      username: username,
      bio: '',
    );

    // convert user into a map so that we can store it
    final userMap = user.toMap();

    // save the user info in firebase
    await _db.collection("Users").doc(uid).set(userMap);
  }

  // post message

  // likes

  // comments

  // account management

  // follow
}
