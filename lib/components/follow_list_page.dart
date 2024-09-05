import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:upddat/components/user_list_tile.dart';
import 'package:upddat/models/user.dart';

import '../services/database/database_provider.dart';

class FollowListPage extends StatefulWidget {
  final String uid;

  const FollowListPage({
    super.key,
    required this.uid,
  });

  @override
  State<FollowListPage> createState() => _FollowListPageState();
}

class _FollowListPageState extends State<FollowListPage> {
  // providers
  late final listeningProvider = Provider.of<DatabaseProvider>(context);
  late final databaseProvider =
      Provider.of<DatabaseProvider>(context, listen: false);

  @override
  void initState() {
    super.initState();
    loadFollowerList();
    loadFollowingList();
  }

  // load followers
  Future<void> loadFollowerList() async {
    await databaseProvider.loadUserFollowerProfiles(widget.uid);
  }

  // load following
  Future<void> loadFollowingList() async {
    await databaseProvider.loadUserFollowingProfiles(widget.uid);
  }

  @override
  Widget build(BuildContext context) {
    final followers = listeningProvider.getListOfFollowersProfiles(widget.uid);
    final following = listeningProvider.getListOfFollowingProfiles(widget.uid);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        appBar: AppBar(
          foregroundColor: Theme.of(context).colorScheme.primary,
          bottom: TabBar(
            dividerColor: Colors.transparent,
            labelColor: Theme.of(context).colorScheme.inversePrimary,
            unselectedLabelColor: Theme.of(context).colorScheme.primary,
            indicatorColor: Theme.of(context).colorScheme.secondary,
            tabs: const [
              Tab(text: "followers"),
              Tab(text: "following"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildUserList(followers, "No followers"),
            _buildUserList(following, "No following"),
          ],
        ),
      ),
    );
  }

  // user list
  Widget _buildUserList(List<UserProfile> userList, String emptyMessage) {
    return userList.isEmpty
        ? Center(
            child: Text(emptyMessage),
          )
        : ListView.builder(
            itemCount: userList.length,
            itemBuilder: (context, index) {
              final user = userList[index];
              return UserListTile(user: user);
            },
          );
  }
}
