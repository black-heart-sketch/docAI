import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/models/user.dart';

class CustomSharePref {
  static const String _isLoggedInKey = 'is_logged_in';
  static const String _userKey = 'user';
  static const String _tokenKey = 'auth_token';

  // Save login status and user info
  Future<void> saveUser(User user) async {
    debugPrint('📝 Saving user to SharedPreferences...');
    debugPrint('User object to save: ${user.toJson()}');
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isLoggedInKey, true);
    final jsonString = jsonEncode(user.toJson());
    debugPrint('JSON string to save: $jsonString');
    await prefs.setString(_userKey, jsonString);
    debugPrint('✅ User saved successfully');
  }

  // Remove login status and user info (Logout)
  Future<void> removeUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_isLoggedInKey);
    await prefs.remove(_userKey);
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isLoggedInKey) ?? false;
  }

  // Retrieve user info
  Future<User?> getUser() async {
    debugPrint('📖 Loading user from SharedPreferences...');
    final prefs = await SharedPreferences.getInstance();
    final userStr = prefs.getString(_userKey);
    debugPrint('Stored JSON string: $userStr');
    if (userStr != null) {
      try {
        final jsonData = jsonDecode(userStr);
        debugPrint('Decoded JSON data: $jsonData');
        final user = User.fromJson(jsonData);
        debugPrint('✅ User loaded successfully:');
        debugPrint('  - ID: ${user.id}');
        debugPrint('  - Email: ${user.email}');
        debugPrint('  - Phone: ${user.phone ?? "NULL"}');
        debugPrint('  - Bio: ${user.bio ?? "NULL"}');
        debugPrint('  - ClassName: ${user.className ?? "NULL"}');
        return user;
      } catch (e) {
        debugPrint('❌ Error loading user from preferences: $e');
        debugPrint('Stack trace: ${StackTrace.current}');
        return null;
      }
    }
    debugPrint('⚠️ No user data found in SharedPreferences');
    return null;
  }

  // Save auth token
  Future<void> saveToken(String token) async {
    debugPrint('🔑 Saving token to SharedPreferences...');
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    debugPrint('✅ Token saved successfully');
  }

  // Get auth token
  Future<String?> getToken() async {
    debugPrint('🔑 Reading token from SharedPreferences...');
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    debugPrint(token != null ? '✅ Token found' : '⚠️ No token found');
    return token;
  }

  // Remove auth token
  Future<void> removeToken() async {
    debugPrint('🔑 Removing token from SharedPreferences...');
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    debugPrint('✅ Token removed successfully');
  }
}
