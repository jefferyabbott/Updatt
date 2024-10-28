import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:upddat/components/bio_box.dart';
import 'package:upddat/components/follow_button.dart';
import 'package:upddat/components/input_alert_box.dart';
import 'package:upddat/components/post_tile.dart';
import 'package:upddat/components/profile_stats.dart';
import 'package:upddat/services/auth/auth_service.dart';
import 'package:upddat/services/database/database_provider.dart';

import 'follow_list_page.dart';
import '../helper/navigate_pages.dart';
import '../models/user.dart';

class ProfilePage extends StatefulWidget {
  final String uid;

  const ProfilePage({
    super.key,
    required this.uid,
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // providers
  late final listeningProvider = Provider.of<DatabaseProvider>(context);
  late final databaseProvider =
      Provider.of<DatabaseProvider>(context, listen: false);

  // user info
  UserProfile? user;
  String currentUserId = AuthService().getCurrentUid();

  // loading
  bool _isLoading = true;

  // following state
  bool _isFollowing = false;

  Future<void> toggleFollow() async {
    // unfollow
    if (_isFollowing) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('unfollow'),
          content: const Text('Are you sure you want to unfollow?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                await databaseProvider.unfollowUser(widget.uid);
              },
              child: const Text('yes'),
            ),
          ],
        ),
      );
    } else {
      // follow
      await databaseProvider.followUser(widget.uid);
    }

    setState(() {
      _isFollowing = !_isFollowing;
    });
  }

  @override
  void initState() {
    super.initState();
    // load the user profile from the database
    loadUser();
  }

  Future<void> loadUser() async {
    user = await databaseProvider.userProfile(widget.uid);
    // load followers & following for this user
    await databaseProvider.loadUserFollowing(widget.uid);
    await databaseProvider.loadUserFollowers(widget.uid);
    // update following state
    _isFollowing = databaseProvider.isFollowing(widget.uid);
    setState(() {
      _isLoading = false;
    });
  }

  // text controller for bio box:
  final bioTextController = TextEditingController();
  void _showEditBioBox() {
    showDialog(
      context: context,
      builder: (context) => InputAlertBox(
        textController: bioTextController,
        hintText: 'enter a stunning bio...',
        onPressed: saveBio,
        onPressedText: 'save bio',
      ),
    );
  }

  Future<void> saveBio() async {
    setState(() {
      _isLoading = true;
    });
    await databaseProvider.updateBio(bioTextController.text);
    await loadUser();
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // get user posts
    final allUserPosts = listeningProvider.filterUserPosts(widget.uid);
    _isFollowing = listeningProvider.isFollowing(widget.uid);
    final followerCount = listeningProvider.getFollowerCount(widget.uid);
    final followingCount = listeningProvider.getFollowingCount(widget.uid);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
          title: Text(_isLoading ? 'P R O F I L E' : user!.name),
          foregroundColor: Theme.of(context).colorScheme.primary,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => goToHomePage(context),
          )),
      body: Center(
        child: ListView(
          children: [
            // username
            Center(
              child: Text(
                _isLoading ? '' : '@${user!.username}',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(height: 25),
            // profile pic
            Center(
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondary,
                  borderRadius: BorderRadius.circular(25),
                ),
                padding: const EdgeInsets.all(25),
                child: Icon(
                  Icons.person,
                  size: 72,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(height: 25),
            // profile stats
            ProfileStats(
              postCount: allUserPosts.length,
              followCount: followerCount,
              followingCount: followingCount,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FollowListPage(uid: widget.uid),
                ),
              ),
            ),
            const SizedBox(height: 25),
            // follow/unfollow (only show on other people's profiles
            if (user != null && user!.uid != currentUserId)
              FollowButton(
                onPressed: toggleFollow,
                isFollowing: _isFollowing,
              ),
            // edit bio
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Bio',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  // only show edit button if looking at your own profile
                  if (user != null && user!.uid == currentUserId)
                    GestureDetector(
                      onTap: _showEditBioBox,
                      child: Icon(
                        Icons.settings,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            // bio
            BioBox(text: _isLoading ? '...' : user!.bio),
            Padding(
              padding: const EdgeInsets.only(left: 25.0, top: 25.0),
              child: Text(
                'Posts',
                style: TextStyle(color: Theme.of(context).colorScheme.primary),
              ),
            ),
            // list of posts from user
            allUserPosts.isEmpty
                ? const Center(
                    child: Text('No posts yet...'),
                  )
                : ListView.builder(
                    itemCount: allUserPosts.length,
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      final post = allUserPosts[index];
                      return PostTile(
                        post: post,
                        onUserTap: () {},
                        onPostTap: () => goToPostPage(context, post),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }
}
