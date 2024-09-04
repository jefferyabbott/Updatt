import 'package:flutter/material.dart';
import 'package:upddat/pages/profile_page.dart';

import '../models/post.dart';
import '../pages/account_settings_page.dart';
import '../pages/blocked_users_page.dart';
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

void goToBlockedUsersPage(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => const BlockedUsersPage(),
    ),
  );
}

void goToAccountSettingsPage(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => const AccountSettingsPage(),
    ),
  );
}
