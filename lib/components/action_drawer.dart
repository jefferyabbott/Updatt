import 'package:flutter/material.dart';
import 'package:upddat/components/action_drawer_tile.dart';
import 'package:upddat/pages/profile_page.dart';

import '../pages/settings_page.dart';
import '../services/auth/auth_service.dart';

// left menu action drawer

class ActionDrawer extends StatelessWidget {
  ActionDrawer({super.key});

  // auth service
  final _auth = AuthService();

  void logout() {
    _auth.logout();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Theme.of(context).colorScheme.surface,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25.0),
          child: Column(
            children: [
              // logo
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 50.0),
                child: Icon(
                  Icons.person,
                  size: 72,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              Divider(
                color: Theme.of(context).colorScheme.secondary,
              ),
              const SizedBox(height: 10),
              // home
              ActionDrawerTile(
                title: "H O M E",
                icon: Icons.home,
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              // profile
              ActionDrawerTile(
                title: "P R O F I L E",
                icon: Icons.person,
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProfilePage(
                        uid: _auth.getCurrentUid(),
                      ),
                    ),
                  );
                },
              ),
              // search
              ActionDrawerTile(
                title: "S E A R C H",
                icon: Icons.search,
                onTap: () {},
              ),
              // settings
              ActionDrawerTile(
                title: "S E T T I N G S",
                icon: Icons.settings,
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SettingsPage(),
                    ),
                  );
                },
              ),
              const Spacer(),
              //logout
              ActionDrawerTile(
                title: "L O G O U T",
                icon: Icons.logout,
                onTap: logout,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
