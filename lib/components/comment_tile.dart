import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:upddat/services/database/database_provider.dart';

import '../models/comment.dart';
import '../services/auth/auth_service.dart';

class CommentTile extends StatelessWidget {
  final Comment comment;
  final void Function()? onUserTap;

  const CommentTile({
    super.key,
    required this.comment,
    required this.onUserTap,
  });

  void _showOptions(BuildContext context) {
    String currentUid = AuthService().getCurrentUid();
    final bool isOwnComment = comment.uid == currentUid;

    showModalBottomSheet(
        context: context,
        builder: (context) {
          return SafeArea(
            child: Wrap(
              children: [
                if (isOwnComment)
                  // delete message button
                  ListTile(
                    leading: const Icon(Icons.delete),
                    title: const Text("delete"),
                    onTap: () async {
                      Navigator.pop(context);
                      await Provider.of<DatabaseProvider>(context,
                              listen: false)
                          .deleteComment(comment.id, comment.postId);
                    },
                  )
                else ...[
                  // report comment button
                  ListTile(
                    leading: const Icon(Icons.flag),
                    title: const Text("Report"),
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                  // block comment button
                  ListTile(
                    leading: const Icon(Icons.block),
                    title: const Text("Block user"),
                    onTap: () {
                      Navigator.pop(context);
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

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 25, vertical: 5),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        // color of post title
        color: Theme.of(context).colorScheme.tertiary,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // top section of post
          GestureDetector(
            onTap: onUserTap,
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
                  comment.name,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 5),
                // username
                Text(
                  '@${comment.username}',
                  style:
                      TextStyle(color: Theme.of(context).colorScheme.primary),
                ),
                const Spacer(),
                // options
                GestureDetector(
                  onTap: () => _showOptions(context),
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
            comment.message,
            style:
                TextStyle(color: Theme.of(context).colorScheme.inversePrimary),
          ),
        ],
      ),
    );
  }
}
