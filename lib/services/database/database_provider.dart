import 'package:flutter/foundation.dart';
import 'package:upddat/services/auth/auth_service.dart';
import 'package:upddat/services/database/database_service.dart';

import '../../models/post.dart';
import '../../models/user.dart';

class DatabaseProvider extends ChangeNotifier {
  // final _auth = AuthService();
  final _db = DatabaseService();

  // user profile
  Future<UserProfile?> userProfile(String uid) => _db.getUserFromFirebase(uid);

  // update user bio
  Future<void> updateBio(String bio) => _db.updateUserBioInFirebase(bio);

  // posts

  // local list of posts
  List<Post> _allPosts = [];

  // get posts
  List<Post> get allPosts => _allPosts;

  // post message
  Future<void> postMessage(String message) async {
    await _db.postMessageInFirebase(message);
    await loadAllPosts();
  }

  // fetch all posts
  Future<void> loadAllPosts() async {
    final allPosts = await _db.getAllPostsFromFirebase();
    _allPosts = allPosts;
    notifyListeners();
  }

  // filter and return a user's posts
  List<Post> filterUserPosts(String uid) {
    return _allPosts.where((post) => post.uid == uid).toList();
  }
}
