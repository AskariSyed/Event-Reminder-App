import 'package:flutter/material.dart';
import 'package:event_reminder_app/models/app_user.dart';

class UserProvider with ChangeNotifier {
  AppUser? _user;

  AppUser? get user => _user;

  void setUser(AppUser user) {
    _user = user;
    notifyListeners();
  }

  void clearUser() {
    _user = null;
    notifyListeners();
  }
}
