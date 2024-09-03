import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:upddat/components/bio_box.dart';
import 'package:upddat/components/input_alert_box.dart';
import 'package:upddat/services/auth/auth_service.dart';
import 'package:upddat/services/database/database_provider.dart';

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
  late final databaseProvider =
      Provider.of<DatabaseProvider>(context, listen: false);

  // user info
  UserProfile? user;
  String currentUserId = AuthService().getCurrentUid();

  // loading
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // load the user profile from the database
    loadUser();
  }

  Future<void> loadUser() async {
    user = await databaseProvider.userProfile(widget.uid);
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
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(_isLoading ? "P R O F I L E" : user!.name),
        foregroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(25.0),
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
              // follow/unfollow
              // edit bio
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Bio",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  GestureDetector(
                    onTap: _showEditBioBox,
                    child: Icon(
                      Icons.settings,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // bio
              BioBox(text: _isLoading ? '...' : user!.bio),
              // list of posts from user
            ],
          ),
        ),
      ),
    );
  }
}
