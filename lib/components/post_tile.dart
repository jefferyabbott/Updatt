import 'package:flutter/material.dart';

import '../models/post.dart';

class PostTile extends StatefulWidget {
  final Post post;

  const PostTile({
    super.key,
    required this.post,
  });

  @override
  State<PostTile> createState() => _PostTileState();
}

class _PostTileState extends State<PostTile> {
  @override
  Widget build(BuildContext context) {
    return Container(
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
          Row(
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
                style: TextStyle(color: Theme.of(context).colorScheme.primary),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // post message
          Text(
            widget.post.message,
            style:
                TextStyle(color: Theme.of(context).colorScheme.inversePrimary),
          ),
        ],
      ),
    );
  }
}
