import 'package:flutter/material.dart';
import 'package:upddat/components/post_tile.dart';
import 'package:upddat/helper/navigate_pages.dart';
import 'package:upddat/models/post.dart';

class PostPage extends StatefulWidget {
  final Post post;

  const PostPage({super.key, required this.post});

  @override
  State<PostPage> createState() => _PostPageState();
}

class _PostPageState extends State<PostPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        foregroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: ListView(
        children: [
          PostTile(
            post: widget.post,
            onUserTap: () => goToUserPage(context, widget.post.uid),
            onPostTap: () {},
          ),
        ],
      ),
    );
  }
}
