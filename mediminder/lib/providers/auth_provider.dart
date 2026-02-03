import 'package:flutter/material.dart';

class AuthProvider with ChangeNotifier {
  bool _isGuest = false;
  String? _localUserEmail;

  bool get isAuthenticated => _localUserEmail != null;
  bool get isGuest => _isGuest;
  bool get isLoading => false;
  String? get error => null;
  String? get userEmail => _localUserEmail;

  // Simple local-only authentication
  Future<void> signInWithEmail(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1)); // Simulate loading
    _localUserEmail = email;
    _isGuest = false;
    notifyListeners();
  }

  Future<void> signUpWithEmail(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1));
    _localUserEmail = email;
    _isGuest = false;
    notifyListeners();
  }

  Future<void> continueAsGuest() async {
    _isGuest = true;
    _localUserEmail = 'guest@local';
    notifyListeners();
  }

  Future<void> signOut() async {
    _localUserEmail = null;
    _isGuest = false;
    notifyListeners();
  }
}
