import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:upddat/components/action_drawer.dart';
import 'package:upddat/components/input_alert_box.dart';
import 'package:upddat/components/post_tile.dart';
import 'package:upddat/helper/navigate_pages.dart';
import 'package:upddat/services/database/database_provider.dart';

import '../models/post.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final databaseProvider =
      Provider.of<DatabaseProvider>(context, listen: false);

  late final listeningProvider = Provider.of<DatabaseProvider>(context);

  final _messageController = TextEditingController();
  void _openPostMessageBox() {
    showDialog(
      context: context,
      builder: (context) => InputAlertBox(
        textController: _messageController,
        hintText: "What's on your mind?",
        onPressed: () async {
          await postMessage(_messageController.text);
        },
        onPressedText: 'post',
      ),
    );
  }

  // post message
  Future<void> postMessage(String message) async {
    await databaseProvider.postMessage(message);
  }

  @override
  void initState() {
    super.initState();
    // load all the posts
    loadAllPosts();
  }

  Future<void> loadAllPosts() async {
    await databaseProvider.loadAllPosts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      drawer: ActionDrawer(),
      appBar: AppBar(
        title: const Text("H O M E"),
        foregroundColor: Theme.of(context).colorScheme.primary,
      ),

      // add new post
      floatingActionButton: FloatingActionButton(
        onPressed: _openPostMessageBox,
        child: const Icon(Icons.add),
      ),

      body: _buildPostList(listeningProvider.allPosts),
    );
  }

  Widget _buildPostList(List<Post> posts) {
    return posts.isEmpty
        ? const Center(
            child: Text("No posts"),
          )
        : ListView.builder(
            itemCount: posts.length,
            itemBuilder: (context, index) {
              // get each post
              final post = posts[index];
              // return in post tile
              return PostTile(
                post: post,
                onUserTap: () => goToUserPage(context, post.uid),
                onPostTap: () => goToPostPage(context, post),
              );
            });
  }
}
