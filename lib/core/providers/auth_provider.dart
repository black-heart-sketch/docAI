import 'package:flutter/material.dart';
import '../../utils/share_pref.dart';
import '../models/user.dart';
import '../services/api_service.dart';

class AuthProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  final CustomSharePref _spf = CustomSharePref();

  User? _user;
  bool _isLoading = false;
  String? _token;

  User? get user => _user;
  bool get isAuthenticated => _token != null;
  bool get isLoading => _isLoading;

  Future<void> login(String email, String password) async {
    _setLoading(true);
    try {
      final data = await _apiService.login(email, password);

      // Parse response data
      debugPrint('Login response successful, parsing data');
      debugPrint('Full API response: $data');

      _token = data['token'] as String?;
      debugPrint(
        'Token extracted: ${_token != null ? "exists (${_token!.substring(0, 10)}...)" : "NULL"}',
      );

      // Debug: Print the user data to see what we're parsing
      debugPrint('Raw user data from API: ${data['user']}');

      try {
        _user = User.fromJson(data['user'] as Map<String, dynamic>);
        debugPrint('✅ User object created successfully');
        debugPrint('User details:');
        debugPrint('  - ID: ${_user!.id}');
        debugPrint('  - Email: ${_user!.email}');
        debugPrint('  - Name: ${_user!.name}');
        debugPrint('  - Role: ${_user!.role}');
        debugPrint('  - Phone: ${_user!.phone ?? "NULL"}');
        debugPrint('  - Bio: ${_user!.bio ?? "NULL"}');
        debugPrint('  - ClassName: ${_user!.className ?? "NULL"}');
      } catch (parseError) {
        debugPrint('❌ Error parsing user: $parseError');
        debugPrint('Stack trace: ${StackTrace.current}');
        rethrow;
      }

      if (_token != null && _token!.isNotEmpty) {
        try {
          debugPrint('Saving token to SharedPreferences...');
          debugPrint('Token value: ${_token!.substring(0, 20)}...');
          await _spf.saveToken(_token!);
          debugPrint('✅ Token saved successfully');
        } catch (storageError) {
          debugPrint('❌ Error saving token: $storageError');
          rethrow;
        }
      } else {
        debugPrint('⚠️ Token is null or empty, skipping save');
      }

      if (_user != null) {
        try {
          debugPrint('Saving user to SharedPreferences...');
          debugPrint('User JSON to save: ${_user!.toJson()}');
          await _spf.saveUser(_user!);
          debugPrint('✅ User saved to preferences successfully');
        } catch (prefError) {
          debugPrint('❌ Error saving user to preferences: $prefError');
          rethrow;
        }
      } else {
        debugPrint('⚠️ User is null, skipping save');
      }

      debugPrint('Calling notifyListeners()...');
      notifyListeners();
      debugPrint('🎉 Login completed successfully for user: ${_user?.email}');
    } catch (e) {
      debugPrint('Login failed: $e');
      // Preserve the original error message for UI display
      if (e.toString().contains('Failed to login:')) {
        // Extract just the error message part
        final errorMsg = e.toString().replaceFirst(
          RegExp(r'Exception: Failed to login: '),
          '',
        );
        throw Exception('$errorMsg');
      } else if (e.toString().contains('SocketException') ||
          e.toString().contains('Connection')) {
        throw Exception(
          'Network error: Cannot connect to server. Check your internet connection.',
        );
      } else if (e.toString().contains('Server response incomplete')) {
        throw Exception('Server not responding properly. Please try again.');
      }
      rethrow; // Preserve original error if not matched
    } finally {
      _setLoading(false);
    }
  }

  Future<void> register(
    String name,
    String email,
    String password, {
    String? className,
  }) async {
    _setLoading(true);
    try {
      await _apiService.register(name, email, password, className: className);
      // Auto-login after registration for better UX
      await login(email, password);
    } catch (e) {
      debugPrint('Registration failed: $e');
      // Preserve the original error message for UI display
      if (e.toString().contains('Failed to register:')) {
        // Extract just the error message part
        final errorMsg = e.toString().replaceFirst(
          RegExp(r'Exception: Failed to register: '),
          '',
        );
        throw Exception('$errorMsg');
      } else if (e.toString().contains('SocketException') ||
          e.toString().contains('Connection')) {
        throw Exception(
          'Network error: Cannot connect to server. Check your internet connection.',
        );
      }
      rethrow; // Preserve original error if not matched
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    _token = null;
    _user = null;
    await _spf.removeToken();
    await _spf.removeUser();
    notifyListeners();
  }

  Future<void> tryAutoLogin() async {
    debugPrint('🔄 Attempting auto-login...');
    final token = await _spf.getToken();
    debugPrint(
      'Token from storage: ${token != null ? "exists (${token.substring(0, 10)}...)" : "NULL"}',
    );
    if (token != null) {
      _token = token;
      // Try to load user from SharedPrefs
      debugPrint('Loading user from SharedPreferences...');
      _user = await _spf.getUser();
      if (_user != null) {
        debugPrint('✅ User loaded from preferences:');
        debugPrint('  - ID: ${_user!.id}');
        debugPrint('  - Email: ${_user!.email}');
        debugPrint('  - Name: ${_user!.name}');
        debugPrint('  - Role: ${_user!.role}');
        debugPrint('  - Phone: ${_user!.phone ?? "NULL"}');
        debugPrint('  - Bio: ${_user!.bio ?? "NULL"}');
        debugPrint('  - ClassName: ${_user!.className ?? "NULL"}');
      } else {
        debugPrint('⚠️ User is NULL after loading from preferences');
      }
      notifyListeners();
    } else {
      debugPrint('❌ No token found, auto-login failed');
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<void> updateUserProfile(Map<String, dynamic> updates) async {
    if (_user == null) return;

    _setLoading(true);
    try {
      // Call API to update user
      await _apiService.updateUser(_user!.id, updates);

      // Update local user object
      _user = User(
        id: _user!.id,
        email: updates['email'] ?? _user!.email,
        name: updates['name'] ?? _user!.name,
        role: _user!.role,
        phone: updates['phone'] ?? _user!.phone,
        bio: updates['bio'] ?? _user!.bio,
        className: updates['class_name'] ?? _user!.className,
      );

      // Persist to SharedPreferences
      await _spf.saveUser(_user!);
      notifyListeners();
    } catch (e) {
      debugPrint('Profile update failed: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  void toggleAdminRole() {
    if (_user == null) return;
    final newRole = _user!.role == 'admin' ? 'student' : 'admin';
    _user = User(
      id: _user!.id,
      email: _user!.email,
      name: _user!.name,
      role: newRole,
      phone: _user!.phone,
      bio: _user!.bio,
      className: _user!.className,
    );
    notifyListeners();
  }
}
