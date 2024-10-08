// service that handles Firebase authentication

import 'package:firebase_auth/firebase_auth.dart';
import 'package:upddat/services/database/database_service.dart';

class AuthService {
  // get instance of the auth
  final _auth = FirebaseAuth.instance;

  // get current user
  User? getCurrentUser() => _auth.currentUser;
  String getCurrentUid() => _auth.currentUser!.uid;

  // login
  Future<UserCredential> loginEmailPassword(String email, password) async {
    // attempt login
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.code);
    }
  }

  // register
  Future<UserCredential> registerEmailPassword(String email, password) async {
    // attempt registration
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.code);
    }
  }

  // logout
  Future<void> logout() async {
    await _auth.signOut();
  }

  // delete user
  Future<void> deleteAccount() async {
    User? user = getCurrentUser();
    if (user != null) {
      // delete user data
      await DatabaseService().deleteUserInfoFromFirebase(user.uid);

      // delete user's auth account
      await user.delete();
    }
  }
}
