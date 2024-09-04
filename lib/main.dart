import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:upddat/firebase_options.dart';
import 'package:upddat/services/auth/auth_gate.dart';
import 'package:upddat/services/database/database_provider.dart';
import 'package:upddat/themes/theme_provider.dart';

void main() async {
  // Firebase setup
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    MultiProvider(
      providers: [
        // theme provider
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        // database provider
        ChangeNotifierProvider(create: (context) => DatabaseProvider()),
      ],
      child: const Upddat(),
    ),
  );
}

class Upddat extends StatelessWidget {
  const Upddat({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const AuthGate(),
      },
      theme: Provider.of<ThemeProvider>(context).themeData,
    );
  }
}
