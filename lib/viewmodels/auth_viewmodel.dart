import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';

class AuthViewModel extends ChangeNotifier {
  final _service = AuthService();

  bool isLoading = false;
  String? error;

  Stream<User?> get authStateChanges => _service.authStateChanges;
  User? get currentUser => FirebaseAuth.instance.currentUser;

  Future<void> login(String email, String password) async {
    isLoading = true; error = null; notifyListeners();
    try {
      await _service.login(email, password);
    } on FirebaseAuthException catch (e) {
      error = e.message;
    } finally {
      isLoading = false; notifyListeners();
    }
  }

  Future<void> register(String email, String password) async {
    isLoading = true; error = null; notifyListeners();
    try {
      await _service.register(email, password);
    } on FirebaseAuthException catch (e) {
      error = e.message;
    } finally {
      isLoading = false; notifyListeners();
    }
  }

  Future<void> logout() => _service.logout();
}
