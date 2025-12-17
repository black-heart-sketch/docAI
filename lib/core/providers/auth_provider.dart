import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../utils/share_pref.dart';
import '../models/user.dart';
import '../services/api_service.dart';

class AuthProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
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
      _token = data['token'];
      _user = User.fromJson(data['user']);
      await _storage.write(key: 'auth_token', value: _token);
      if (_user != null) {
        await _spf.saveUser(_user!);
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Login failed: $e');
      rethrow; // Allow UI to handle error
    } finally {
      _setLoading(false);
    }
  }

  Future<void> register(String name, String email, String password) async {
    _setLoading(true);
    try {
      await _apiService.register(name, email, password);
      // Auto-login after registration? Or just let them login?
      // Let's auto-login for better UX
      await login(email, password);
    } catch (e) {
      debugPrint('Registration failed: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    _token = null;
    _user = null;
    await _storage.delete(key: 'auth_token');
    await _spf.removeUser();
    notifyListeners();
  }

  Future<void> tryAutoLogin() async {
    final token = await _storage.read(key: 'auth_token');
    if (token != null) {
      _token = token;
      // Try to load user from SharedPrefs
      _user = await _spf.getUser();
      notifyListeners();
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
    );
    notifyListeners();
  }
}
