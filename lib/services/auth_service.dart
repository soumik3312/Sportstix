import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

enum AuthStatus {
  initial,
  authenticated,
  unauthenticated,
  authenticating,
}

class AuthService extends ChangeNotifier {
  User? _currentUser;
  AuthStatus _status = AuthStatus.initial;
  String? _errorMessage;
  
  // Secure storage for sensitive data
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  
  // Keys for storage
  static const String _authTokenKey = 'auth_token';
  static const String _userIdKey = 'user_id';
  static const String _currentUserKey = 'currentUser';

  User? get currentUser => _currentUser;
  AuthStatus get status => _status;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _status == AuthStatus.authenticated;

  AuthService() {
    _initializeAuth();
  }

  Future<void> _initializeAuth() async {
    try {
      await _checkCurrentUser();
    } catch (e) {
      print('Error initializing auth: $e');
      _status = AuthStatus.unauthenticated;
      notifyListeners();
    }
  }

  Future<void> _checkCurrentUser() async {
    try {
      // First check if we have an auth token
      final authToken = await _secureStorage.read(key: _authTokenKey);
      final userId = await _secureStorage.read(key: _userIdKey);
      
      if (authToken == null || userId == null) {
        _status = AuthStatus.unauthenticated;
        notifyListeners();
        return;
      }
      
      // If we have a token, retrieve the user data
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString(_currentUserKey);
      
      if (userJson != null) {
        _currentUser = User.fromJson(jsonDecode(userJson));
        _status = AuthStatus.authenticated;
      } else {
        // Token exists but user data is missing, try to fetch user data
        final usersJson = prefs.getStringList('users') ?? [];
        
        for (final userJson in usersJson) {
          final userMap = jsonDecode(userJson);
          if (userMap['id'] == userId) {
            _currentUser = User.fromJson(userMap);
            await prefs.setString(_currentUserKey, jsonEncode(_currentUser!.toJson()));
            _status = AuthStatus.authenticated;
            break;
          }
        }
        
        // If we still don't have user data, clear tokens and set as unauthenticated
        if (_currentUser == null) {
          await _clearAuthData();
          _status = AuthStatus.unauthenticated;
        }
      }
    } catch (e) {
      print('Error checking current user: $e');
      _status = AuthStatus.unauthenticated;
      await _clearAuthData();
    }
    
    notifyListeners();
  }

  Future<void> _clearAuthData() async {
    try {
      await _secureStorage.delete(key: _authTokenKey);
      await _secureStorage.delete(key: _userIdKey);
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_currentUserKey);
    } catch (e) {
      print('Error clearing auth data: $e');
    }
  }

  Future<void> _saveAuthData(User user) async {
    try {
      // Generate a simple token (in a real app, this would be from your backend)
      final authToken = 'token_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(10000)}';
      
      // Save token and user ID in secure storage
      await _secureStorage.write(key: _authTokenKey, value: authToken);
      await _secureStorage.write(key: _userIdKey, value: user.id);
      
      // Save user data in shared preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_currentUserKey, jsonEncode(user.toJson()));
    } catch (e) {
      print('Error saving auth data: $e');
      throw Exception('Failed to save authentication data');
    }
  }

  Future<bool> signUp({
    required String name,
    required String email,
    required String password,
    required String phoneNumber,
  }) async {
    try {
      _status = AuthStatus.authenticating;
      _errorMessage = null;
      notifyListeners();

      // Simulate network delay
      await Future.delayed(const Duration(seconds: 2));

      // Check if email already exists
      final prefs = await SharedPreferences.getInstance();
      final usersJson = prefs.getStringList('users') ?? [];
      
      for (final userJson in usersJson) {
        final user = User.fromJson(jsonDecode(userJson));
        if (user.email.toLowerCase() == email.toLowerCase()) {
          _errorMessage = 'Email already in use';
          _status = AuthStatus.unauthenticated;
          notifyListeners();
          return false;
        }
      }

      // Create new user
      final newUser = User(
        id: 'user_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(10000)}',
        name: name,
        email: email,
        phoneNumber: phoneNumber,
      );

      // Save user to "database"
      final userMap = newUser.toJson();
      userMap['password'] = password; // In a real app, this would be hashed
      
      usersJson.add(jsonEncode(userMap));
      await prefs.setStringList('users', usersJson);

      // Set as current user and save auth data
      _currentUser = newUser;
      await _saveAuthData(newUser);
      
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'An error occurred during sign up';
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    try {
      _status = AuthStatus.authenticating;
      _errorMessage = null;
      notifyListeners();

      // Simulate network delay
      await Future.delayed(const Duration(seconds: 2));

      // Check credentials
      final prefs = await SharedPreferences.getInstance();
      final usersJson = prefs.getStringList('users') ?? [];
      
      for (final userJson in usersJson) {
        final userMap = jsonDecode(userJson);
        if (userMap['email'].toLowerCase() == email.toLowerCase() && 
            userMap['password'] == password) {
          
          final user = User.fromJson(userMap);
          _currentUser = user;
          
          // Save authentication data for persistent login
          await _saveAuthData(user);
          
          _status = AuthStatus.authenticated;
          notifyListeners();
          return true;
        }
      }

      _errorMessage = 'Invalid email or password';
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'An error occurred during sign in';
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    try {
      // Clear all authentication data
      await _clearAuthData();
      
      _currentUser = null;
      _status = AuthStatus.unauthenticated;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'An error occurred during sign out';
      notifyListeners();
    }
  }

  // Update the updateProfile method to properly handle profile image paths
  Future<bool> updateProfile({
    String? name,
    String? email,
    String? profileImagePath,
    String? phoneNumber,
    String? address,
  }) async {
    try {
      if (_currentUser == null) {
        _errorMessage = 'No user is currently logged in';
        return false;
      }

      // Update current user
      _currentUser = _currentUser!.copyWith(
        name: name ?? _currentUser!.name,
        email: email ?? _currentUser!.email,
        profileImageUrl: profileImagePath ?? _currentUser!.profileImagePath,
        phoneNumber: phoneNumber ?? _currentUser!.phoneNumber,
        address: address ?? _currentUser!.address,
      );

      // Save to shared preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_currentUserKey, jsonEncode(_currentUser!.toJson()));

      // Update in users list
      final usersJson = prefs.getStringList('users') ?? [];
      List<String> updatedUsersJson = [];
      
      for (final userJson in usersJson) {
        final userMap = jsonDecode(userJson);
        if (userMap['id'] == _currentUser!.id) {
          // Preserve password
          final password = userMap['password'];
          final updatedUserMap = _currentUser!.toJson();
          updatedUserMap['password'] = password;
          updatedUsersJson.add(jsonEncode(updatedUserMap));
        } else {
          updatedUsersJson.add(userJson);
        }
      }
      
      await prefs.setStringList('users', updatedUsersJson);
      
      notifyListeners();
      return true;
    } catch (e) {
      print('Error updating profile: $e');
      _errorMessage = 'Failed to update profile: $e';
      return false;
    }
  }
}

