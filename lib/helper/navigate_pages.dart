import 'package:flutter/material.dart';
import 'package:upddat/pages/profile_page.dart';

import '../models/post.dart';
import '../pages/post_page.dart';

void goToUserPage(BuildContext context, String uid) {
  // navigate to the user profile page
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => ProfilePage(uid: uid),
    ),
  );
}

void goToPostPage(BuildContext context, Post post) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => PostPage(post: post),
    ),
  );
}
