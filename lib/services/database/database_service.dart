import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:upddat/models/post.dart';
import 'package:upddat/models/user.dart';
import 'package:upddat/services/auth/auth_service.dart';

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

  // update user bio
  Future<void> updateUserBioInFirebase(String bio) async {
    String uid = AuthService().getCurrentUid();
    try {
      await _db.collection("Users").doc(uid).update({'bio': bio});
    } catch (e) {
      print(e);
    }
  }

  // post message
  Future<void> postMessageInFirebase(String message) async {
    try {
      String uid = _auth.currentUser!.uid;
      UserProfile? user = await getUserFromFirebase(uid);
      Post newPost = Post(
        id: '', // firebase will generate the id
        uid: uid,
        name: user!.name,
        username: user!.username,
        message: message,
        timestamp: Timestamp.now(),
        likeCount: 0,
        likedBy: [],
      );

      // convert to map
      Map<String, dynamic> newPostMap = newPost.toMap();
      // add to firebase
      await _db.collection("Posts").add(newPostMap);
    } catch (e) {
      print(e);
    }
  }

  // delete post
  Future<void> deletePostFromFirebase(String postId) async {
    try {
      await _db.collection("Posts").doc(postId).delete();
    } catch (e) {
      print(e);
    }
  }

  // get all posts
  Future<List<Post>> getAllPostsFromFirebase() async {
    try {
      QuerySnapshot snapshot = await _db
          .collection("Posts")
          .orderBy('timestamp', descending: true)
          .get();
      return snapshot.docs.map((doc) => Post.fromDocument(doc)).toList();
    } catch (e) {
      print(e);
      return [];
    }
  }

  // get individual post

  // likes
  Future<void> toggleLikeInFirebase(String postId) async {
    try {
      String uid = _auth.currentUser!.uid;
      DocumentReference postDoc = _db.collection("Posts").doc(postId);
      await _db.runTransaction((transaction) async {
        // get post data
        DocumentSnapshot postSnapshot = await transaction.get(postDoc);

        // get list of users who like this post
        List<String> likedBy = List<String>.from(postSnapshot['likedBy'] ?? []);
        int currentLikeCount = postSnapshot['likes'];

        // if user has not liked already, then like
        if (!likedBy.contains(uid)) {
          likedBy.add(uid);
          currentLikeCount++;
        } else {
          likedBy.remove(uid);
          currentLikeCount--;
        }

        // update the database
        transaction.update(postDoc, {
          'likes': currentLikeCount,
          'likedBy': likedBy,
        });
      });
    } catch (e) {
      print(e);
    }
  }

  // comments

  // account management

  // follow
}
