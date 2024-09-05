import 'package:flutter/material.dart';

class ProfileStats extends StatelessWidget {
  final int postCount;
  final int followCount;
  final int followingCount;
  final void Function()? onTap;

  const ProfileStats({
    super.key,
    required this.postCount,
    required this.followCount,
    required this.followingCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // textstyle for count
    var textStyleForCount = TextStyle(
      fontSize: 20,
      color: Theme.of(context).colorScheme.inversePrimary,
    );

    var textStyleForText = TextStyle(
      color: Theme.of(context).colorScheme.primary,
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // posts
        SizedBox(
          width: 100,
          child: Column(
            children: [
              Text(postCount.toString(), style: textStyleForCount),
              Text('posts', style: textStyleForText)
            ],
          ),
        ),
        // follows
        GestureDetector(
          onTap: onTap,
          child: SizedBox(
            width: 100,
            child: Column(
              children: [
                Text(followCount.toString(), style: textStyleForCount),
                Text('followers', style: textStyleForText)
              ],
            ),
          ),
        ),
        // following
        GestureDetector(
          onTap: onTap,
          child: SizedBox(
            width: 100,
            child: Column(
              children: [
                Text(followingCount.toString(), style: textStyleForCount),
                Text('following', style: textStyleForText)
              ],
            ),
          ),
        ),
      ],
    );
  }
}
