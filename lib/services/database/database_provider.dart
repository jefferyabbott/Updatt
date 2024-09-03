import 'package:flutter/foundation.dart';
import 'package:upddat/services/auth/auth_service.dart';
import 'package:upddat/services/database/database_service.dart';

import '../../models/user.dart';

class DatabaseProvider extends ChangeNotifier {
  // final _auth = AuthService();
  final _db = DatabaseService();

  // user profile
  Future<UserProfile?> userProfile(String uid) => _db.getUserFromFirebase(uid);

  // update user bio
  Future<void> updateBio(String bio) => _db.updateUserBioInFirebase(bio);
}
