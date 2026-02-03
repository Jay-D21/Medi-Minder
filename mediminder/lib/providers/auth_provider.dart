import 'package:flutter/material.dart';

class AuthProvider with ChangeNotifier {
  bool _isGuest = false;
  String? _localUserEmail;
  String? _error;

  bool get isAuthenticated => _localUserEmail != null;
  bool get isGuest => _isGuest;
  bool get isLoading => false;
  String? get error => _error;
  String? get userEmail => _localUserEmail;

  Future<bool> signInWithEmail(String email, String password) async {
    try {
      _error = null;
      await Future.delayed(const Duration(milliseconds: 500));
      if (password.length < 4) {
        _error = 'Password too short';
        notifyListeners();
        return false;
      }
      _localUserEmail = email;
      _isGuest = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> signUpWithEmail(String email, String password) async {
    try {
      _error = null;
      await Future.delayed(const Duration(milliseconds: 500));
      if (password.length < 4) {
        _error = 'Password must be at least 4 characters';
        notifyListeners();
        return false;
      }
      _localUserEmail = email;
      _isGuest = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> continueAsGuest() async {
    _isGuest = true;
    _localUserEmail = null;
    notifyListeners();
  }

  Future<void> signOut() async {
    _localUserEmail = null;
    _isGuest = true;
    _error = null;
    notifyListeners();
  }
}
