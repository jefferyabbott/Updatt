import 'package:flutter/foundation.dart';
import 'package:upddat/services/auth/auth_service.dart';
import 'package:upddat/services/database/database_service.dart';

import '../../models/post.dart';
import '../../models/user.dart';

class DatabaseProvider extends ChangeNotifier {
  final _auth = AuthService();
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
    // update local data
    _allPosts = allPosts;
    initializeLikeMap();
    notifyListeners();
  }

  // filter and return a user's posts
  List<Post> filterUserPosts(String uid) {
    return _allPosts.where((post) => post.uid == uid).toList();
  }

  // delete post
  Future<void> deletePost(String postId) async {
    // delete from firebase
    await _db.deletePostFromFirebase(postId);
    // reload data
    await loadAllPosts();
  }

  // likes
  // local map to track like counters for each poost
  Map<String, int> _likeCounts = {};

  // local list of posts liked by the current user
  List<String> _likedPosts = [];

  // does the current user like this post?
  bool isPostLikedByCurrentUser(String postId) => _likedPosts.contains(postId);

  // get like count of a post
  int getLikeCount(String postId) => _likeCounts[postId] ?? 0;

  // init local like map
  void initializeLikeMap() {
    final currentUserId = _auth.getCurrentUid();
    // clear liked posts (if a new user signs in)
    _likedPosts.clear();

    for (var post in _allPosts) {
      _likeCounts[post.id] = post.likeCount;
      if (post.likedBy.contains(currentUserId)) {
        _likedPosts.add(post.id);
      }
    }
  }

  // toggle like
  Future<void> toggleLike(String postId) async {
    // update the local values, optimistically... restore if db update fails
    final likedPostsOriginal = _likedPosts;
    final likeCountsOriginal = _likeCounts;
    if (_likedPosts.contains(postId)) {
      _likedPosts.remove(postId);
      _likeCounts[postId] = (_likeCounts[postId] ?? 0) - 1;
    } else {
      _likedPosts.add(postId);
      _likeCounts[postId] = (_likeCounts[postId] ?? 1) + 1;
    }
    // update the UI
    notifyListeners();

    // update the database
    try {
      await _db.toggleLikeInFirebase(postId);
    } catch (e) {
      print(e);
      // revert back to initial state
      _likedPosts = likedPostsOriginal;
      _likeCounts = likeCountsOriginal;
      notifyListeners();
    }
  }
}
