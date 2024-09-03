import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:upddat/components/comment_tile.dart';
import 'package:upddat/components/post_tile.dart';
import 'package:upddat/helper/navigate_pages.dart';
import 'package:upddat/models/post.dart';
import 'package:upddat/services/database/database_provider.dart';

class PostPage extends StatefulWidget {
  final Post post;

  const PostPage({super.key, required this.post});

  @override
  State<PostPage> createState() => _PostPageState();
}

class _PostPageState extends State<PostPage> {
  // provider
  late final listeningProvider = Provider.of<DatabaseProvider>(context);
  late final databaseProvider =
      Provider.of<DatabaseProvider>(context, listen: false);

  @override
  Widget build(BuildContext context) {
    final allComments = listeningProvider.getComments(widget.post.id);
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
          // comments on this post
          allComments.isEmpty
              ? const Center(
                  child: Text("No comments yet."),
                )
              : ListView.builder(
                  itemCount: allComments.length,
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    final comment = allComments[index];
                    return CommentTile(
                      comment: comment,
                      onUserTap: () => goToUserPage(context, comment.uid),
                    );
                  })
        ],
      ),
    );
  }
}
