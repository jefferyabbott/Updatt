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

  // FOLLOW

  // local map of followers and following
  final Map<String, List<String>> _followers = {};
  final Map<String, List<String>> _following = {};
  final Map<String, int> _followerCount = {};
  final Map<String, int> _followingCount = {};

  int getFollowerCount(String uid) => _followerCount[uid] ?? 0;
  int getFollowingCount(String uid) => _followingCount[uid] ?? 0;

  // load followers
  Future<void> loadUserFollowers(String uid) async {
    final listOfFollowerUids = await _db.getFollowersFromFirebase(uid);
    _followers[uid] = listOfFollowerUids;
    _followerCount[uid] = listOfFollowerUids.length;
    notifyListeners();
  }

  // load following
  Future<void> loadUserFollowing(String uid) async {
    final listOfFollowingUids = await _db.getFollowingFromFirebase(uid);
    _following[uid] = listOfFollowingUids;
    _followingCount[uid] = listOfFollowingUids.length;
    notifyListeners();
  }

  // follow user
  Future<void> followUser(String targetUid) async {
    final currentUserId = _auth.getCurrentUid();
    _following.putIfAbsent(currentUserId, () => []);
    _followers.putIfAbsent(targetUid, () => []);
    if (!_followers[targetUid]!.contains(currentUserId)) {
      _followers[targetUid]?.add(currentUserId);
      _followerCount[targetUid] = (_followerCount[targetUid] ?? 0) + 1;
      _following[currentUserId]?.add(targetUid);
      _followingCount[currentUserId] =
          (_followingCount[currentUserId] ?? 0) + 1;
      notifyListeners();
      // UI was optimistically updated, now try to update firebase
      try {
        // follow user in firebase
        await _db.followUserInFirebase(targetUid);
        // reload current user's followers
        await loadUserFollowers(currentUserId);
        // reload current user's following
        await loadUserFollowing(currentUserId);
      } catch (e) {
        // if writing to firestore fails, undo
        _followers[targetUid]?.remove(currentUserId);
        _followerCount[targetUid] = (_followerCount[targetUid] ?? 0) - 1;
        _following[currentUserId]?.remove(targetUid);
        _followingCount[currentUserId] =
            (_followingCount[currentUserId] ?? 0) - 1;
        notifyListeners();
      }
    }
  }

  // unfollow user
  Future<void> unfollowUser(String targetUid) async {
    final currentUserId = _auth.getCurrentUid();
    _following.putIfAbsent(currentUserId, () => []);
    _followers.putIfAbsent(targetUid, () => []);

    if (_followers[targetUid]!.contains(currentUserId)) {
      _followers[targetUid]?.remove(currentUserId);
      _followerCount[targetUid] = (_followerCount[targetUid] ?? 0) - 1;
      _following[currentUserId]?.remove(targetUid);
      _followingCount[currentUserId] =
          (_followingCount[currentUserId] ?? 0) - 1;
      notifyListeners();
      // UI was optimistically updated, now try to update firebase
      try {
        // unfollow user in firebase
        await _db.unfollowUserInFirebase(targetUid);
        // reload current user's followers
        await loadUserFollowers(currentUserId);
        // reload current user's following
        await loadUserFollowing(currentUserId);
      } catch (e) {
        // if writing to firestore fails, undo
        _followers[targetUid]?.add(currentUserId);
        _followerCount[targetUid] = (_followerCount[targetUid] ?? 0) + 1;
        _following[currentUserId]?.add(targetUid);
        _followingCount[currentUserId] =
            (_followingCount[currentUserId] ?? 0) + 1;
        notifyListeners();
      }
    }
  }

  // is current user following target user?
  bool isFollowing(String uid) {
    final currentUserId = _auth.getCurrentUid();
    return _followers[uid]?.contains(currentUserId) ?? false;
  }
}
