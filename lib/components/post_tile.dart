import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:upddat/components/input_alert_box.dart';
import 'package:upddat/services/auth/auth_service.dart';
import 'package:upddat/services/database/database_provider.dart';

import '../models/post.dart';

class PostTile extends StatefulWidget {
  final Post post;
  final void Function()? onUserTap;
  final void Function()? onPostTap;

  const PostTile({
    super.key,
    required this.post,
    required this.onUserTap,
    required this.onPostTap,
  });

  @override
  State<PostTile> createState() => _PostTileState();
}

class _PostTileState extends State<PostTile> {
  // providers
  late final listeningProvider = Provider.of<DatabaseProvider>(context);
  late final databaseProvider =
      Provider.of<DatabaseProvider>(context, listen: false);

  @override
  void initState() {
    super.initState();
    _loadComments();
  }

  void _toggleLikePost() async {
    try {
      await databaseProvider.toggleLike(widget.post.id);
    } catch (e) {
      print(e);
    }
  }

  final _commentController = TextEditingController();
  void _openNewCommentBox() {
    showDialog(
      context: context,
      builder: (context) => InputAlertBox(
          textController: _commentController,
          hintText: 'enter a comment',
          onPressed: () {
            // add comment in db
            _addComment();
          },
          onPressedText: "post"),
    );
  }

  Future<void> _addComment() async {
    if (_commentController.text.trim().isEmpty) return;

    try {
      await databaseProvider.addComment(
        widget.post.id,
        _commentController.text.trim(),
      );
    } catch (e) {
      print(e);
    }
  }

  Future<void> _loadComments() async {
    await databaseProvider.loadComments(widget.post.id);
  }

  // case 1: post belongs to current user, can delete and cancel
  // case 2: post doesn't belong to current user, can report, block and cancel

  void _showOptions() {
    String currentUid = AuthService().getCurrentUid();
    final bool isOwnPost = widget.post.uid == currentUid;

    showModalBottomSheet(
        context: context,
        builder: (context) {
          return SafeArea(
            child: Wrap(
              children: [
                if (isOwnPost)
                  // delete message button
                  ListTile(
                    leading: const Icon(Icons.delete),
                    title: const Text("delete"),
                    onTap: () async {
                      Navigator.pop(context);
                      await databaseProvider.deletePost(widget.post.id);
                    },
                  )
                else ...[
                  // report post button
                  ListTile(
                    leading: const Icon(Icons.flag),
                    title: const Text("Report"),
                    onTap: () {
                      Navigator.pop(context);
                      _reportPostConfirmationBox();
                    },
                  ),
                  // block post button
                  ListTile(
                    leading: const Icon(Icons.block),
                    title: const Text("Block user"),
                    onTap: () {
                      Navigator.pop(context);
                      _blockUserConfirmationBox();
                    },
                  ),
                ],

                // cancel button
                ListTile(
                  leading: const Icon(Icons.cancel),
                  title: const Text("cancel"),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          );
        });
  }

  // report a user confirmation box
  void _reportPostConfirmationBox() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Report Message"),
        content:
            const Text("Are you sure that you want to report this message?"),
        actions: [
          // cancel button
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("cancel"),
          ),
          // confirmation button
          TextButton(
            onPressed: () async {
              await databaseProvider.reportUser(
                  widget.post.id, widget.post.uid);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Message Reported!"),
                ),
              );
            },
            child: const Text("report"),
          ),
        ],
      ),
    );
  }

  // block a user confirmation box
  void _blockUserConfirmationBox() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Report Message"),
        content: const Text("Are you sure that you want to block this user?"),
        actions: [
          // cancel button
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("cancel"),
          ),
          // confirmation button
          TextButton(
            onPressed: () async {
              await databaseProvider.blockUser(widget.post.uid);
              final blockedUser = widget.post.name;
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("@$blockedUser blocked!"),
                ),
              );
            },
            child: const Text("block"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // does the current use like this post?
    bool likedByCurrentUser =
        listeningProvider.isPostLikedByCurrentUser(widget.post.id);

    // listen to like count
    int likeCount = listeningProvider.getLikeCount(widget.post.id);
    int commentCount = listeningProvider.getComments(widget.post.id).length;

    return GestureDetector(
      onTap: widget.onPostTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 25, vertical: 5),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          // color of post title
          color: Theme.of(context).colorScheme.secondary,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // top section of post
            GestureDetector(
              onTap: widget.onUserTap,
              child: Row(
                children: [
                  // profile pic
                  Icon(
                    Icons.person,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 10),
                  // name
                  Text(
                    widget.post.name,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 5),
                  // username
                  Text(
                    '@${widget.post.username}',
                    style:
                        TextStyle(color: Theme.of(context).colorScheme.primary),
                  ),
                  const Spacer(),
                  // options
                  GestureDetector(
                    onTap: _showOptions,
                    child: Icon(
                      Icons.more_horiz,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // post message
            Text(
              widget.post.message,
              style: TextStyle(
                  color: Theme.of(context).colorScheme.inversePrimary),
            ),
            const SizedBox(height: 20),
            // buttons -> like and comment
            Row(
              children: [
                SizedBox(
                  width: 60,
                  child: Row(
                    children: [
                      // likes
                      GestureDetector(
                        onTap: _toggleLikePost,
                        child: likedByCurrentUser
                            ? const Icon(Icons.favorite, color: Colors.red)
                            : Icon(Icons.favorite_border,
                                color: Theme.of(context).colorScheme.primary),
                      ),
                      const SizedBox(width: 5),
                      // like count
                      Text(
                        likeCount != 0 ? likeCount.toString() : '',
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.primary),
                      ),
                    ],
                  ),
                ),
                // comments
                Row(
                  children: [
                    // comment button
                    GestureDetector(
                      onTap: _openNewCommentBox,
                      child: Icon(
                        Icons.comment,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 5),
                    // comment count
                    Text(
                      commentCount != 0 ? commentCount.toString() : '',
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.primary),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
