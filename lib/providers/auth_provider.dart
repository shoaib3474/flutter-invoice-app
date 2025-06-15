// ignore_for_file: unused_import

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../models/user/user_model.dart' hide User;
import '../services/auth/auth_service.dart';

class AuthProvider with ChangeNotifier {
  AuthProvider() {
    _initializeAuth();
  }
  final AuthService _authService = AuthService();

  User? _currentUser;
  UserModel? _userModel;
  bool _isLoading = false;
  String? _errorMessage;

  User? get currentUser => _currentUser;
  UserModel? get userModel => _userModel;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _currentUser != null;

  void _initializeAuth() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      _currentUser = user;
      if (user != null) {
        _loadUserModel(user.uid);
      } else {
        _userModel = null;
      }
      notifyListeners();
    });
  }

  Future<void> _loadUserModel(String uid) async {
    try {
      _userModel = await _authService.getUserModel(uid);
    } catch (e) {
      _errorMessage = e.toString();
    }
    notifyListeners();
  }

  Future<bool> signIn(String email, String password) async {
    _setLoading(true);
    try {
      final user =
          await _authService.signInWithEmailAndPassword(email, password);
      _currentUser = user as User?;

      _clearError();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> signUp(String email, String password, String name) async {
    _setLoading(true);
    try {
      final user = await _authService.createUserWithEmailAndPassword(
          email, password, name);
      _currentUser = user;
      if (user != null) {
        await _loadUserModel(user.uid);
      }
      _clearError();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signOut() async {
    _setLoading(true);
    try {
      await _authService.signOut();
      _currentUser = null;
      _userModel = null;
      _clearError();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> resetPassword(String email) async {
    _setLoading(true);
    try {
      await _authService.resetPassword(email);
      _clearError();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void clearError() {
    _clearError();
  }
}
