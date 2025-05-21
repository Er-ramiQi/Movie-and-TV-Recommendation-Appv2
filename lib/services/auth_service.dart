import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/user_profile.dart';
import 'local_storage_service.dart';

class AuthService with ChangeNotifier {
  final LocalStorageService _storageService;
  UserProfile? _currentUser;
  bool _isLoading = false;

  AuthService(this._storageService);

  UserProfile? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool get isLoading => _isLoading;

  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      final userData = await _storageService.getUserProfile();
      if (userData != null) {
        _currentUser = userData;
      }
    } catch (e) {
      debugPrint('Error initializing auth service: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> signIn(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      await Future.delayed(const Duration(seconds: 2));

      _currentUser = UserProfile(
        id: 'user123',
        username: email.split('@')[0],
        email: email,
        createdAt: DateTime.now(),
        lastLogin: DateTime.now(),
      );

      await _storageService.saveUserProfile(_currentUser!);
      return true;
    } catch (e) {
      debugPrint('Sign in error: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> signUp(String username, String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      await Future.delayed(const Duration(seconds: 2));

      _currentUser = UserProfile(
        id: 'user${DateTime.now().millisecondsSinceEpoch}',
        username: username,
        email: email,
        createdAt: DateTime.now(),
        lastLogin: DateTime.now(),
      );

      await _storageService.saveUserProfile(_currentUser!);
      return true;
    } catch (e) {
      debugPrint('Sign up error: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();

    try {
      _currentUser = null;
      await _storageService.clearUserProfile();
    } catch (e) {
      debugPrint('Sign out error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateProfile({
    String? username,
    String? email,
    String? avatarUrl,
    String? bio,
  }) async {
    if (_currentUser == null) return false;

    _isLoading = true;
    notifyListeners();

    try {
      _currentUser = _currentUser!.copyWith(
        username: username ?? _currentUser!.username,
        email: email ?? _currentUser!.email,
        avatarUrl: avatarUrl ?? _currentUser!.avatarUrl,
        bio: bio ?? _currentUser!.bio,
      );

      await _storageService.saveUserProfile(_currentUser!);
      return true;
    } catch (e) {
      debugPrint('Update profile error: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
