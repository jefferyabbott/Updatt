import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:upddat/themes/theme_provider.dart';

import '../components/settings_tile.dart';
import '../helper/navigate_pages.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('S E T T I N G S'),
        foregroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Column(
        children: [
          // light/dark mode
          SettingsTile(
            title: 'Dark Mode',
            action: CupertinoSwitch(
              onChanged: (value) =>
                  Provider.of<ThemeProvider>(context, listen: false)
                      .toggleTheme(),
              value:
                  Provider.of<ThemeProvider>(context, listen: false).isDarkMode,
            ),
          ),
          // block users
          SettingsTile(
            title: 'Blocked Users',
            action: IconButton(
              onPressed: () => goToBlockedUsersPage(context),
              icon: const Icon(Icons.arrow_forward),
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          // delete account
          SettingsTile(
            title: 'Account Settings',
            action: IconButton(
              onPressed: () => goToAccountSettingsPage(context),
              icon: Icon(
                Icons.settings,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
