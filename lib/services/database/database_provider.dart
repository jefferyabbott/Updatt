import 'package:flutter/foundation.dart';
import 'package:upddat/services/auth/auth_service.dart';
import 'package:upddat/services/database/database_service.dart';

import '../../models/comment.dart';
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
    // get blocked user ids
    final blockedUserIds = await _db.getBlockedUsersFromFirebase();
    // filter out blocked users and update local data
    _allPosts =
        allPosts.where((post) => !blockedUserIds.contains(post.uid)).toList();
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

  // comments

  // local list of comments
  final Map<String, List<Comment>> _comments = {};

  // get comments locally
  List<Comment> getComments(String postId) => _comments[postId] ?? [];

  // fetch comments from the database for a post
  Future<void> loadComments(String postId) async {
    final allComments = await _db.getCommentsFromFirebase(postId);
    _comments[postId] = allComments;
    notifyListeners();
  }

  // add a comment
  Future<void> addComment(String postId, message) async {
    await _db.addCommentInFirebase(postId, message);
    await loadComments(postId);
  }

  // delete a comment
  Future<void> deleteComment(String commentId, String postId) async {
    await _db.deleteCommentInFirebase(commentId);
    await loadComments(postId);
  }

  // ACCOUNT MANAGEMENT

  // local list of blocked users
  List<UserProfile> _blockedUsers = [];

  // get list of blocked users
  List<UserProfile> get blockedUsers => _blockedUsers;

  // fetch blocked users from database
  Future<void> loadBlockedUsers() async {
    final blockedUserIds = await _db.getBlockedUsersFromFirebase();
    final blockedUsersData = await Future.wait(
        blockedUserIds.map((id) => _db.getUserFromFirebase(id)));
    _blockedUsers = blockedUsersData.whereType<UserProfile>().toList();
    notifyListeners();
  }

  // block user
  Future<void> blockUser(String userId) async {
    await _db.blockUserInFirebase(userId);
    loadBlockedUsers();
    loadAllPosts();
    notifyListeners();
  }

  // unblock user
  Future<void> unblockUser(String userId) async {
    await _db.unblockUserInFirebase(userId);
    loadBlockedUsers();
    loadAllPosts();
    notifyListeners();
  }

  // report user & post
  Future<void> reportUser(String postId, userId) async {
    await _db.reportUserInFirebase(postId, userId);
  }
}
