import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:upddat/components/user_list_tile.dart';
import 'package:upddat/services/database/database_provider.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // provider
    final databaseProvider =
        Provider.of<DatabaseProvider>(context, listen: false);
    final listeningProvider = Provider.of<DatabaseProvider>(context);

    return Scaffold(
        appBar: AppBar(
          title: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'search for users...',
              hintStyle: TextStyle(
                color: Theme.of(context).colorScheme.primary,
              ),
              border: InputBorder.none,
            ),
            onChanged: (value) {
              if (value.trim().isNotEmpty) {
                databaseProvider.searchUsers(value);
              } else {
                databaseProvider.searchUsers(' ');
              }
            },
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: listeningProvider.searchResults.isEmpty
            ? const Center(
                child: Text("No users found."),
              )
            : ListView.builder(
                itemCount: listeningProvider.searchResults.length,
                itemBuilder: (context, index) {
                  final user = listeningProvider.searchResults[index];
                  return UserListTile(user: user);
                }));
  }
}
