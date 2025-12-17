import 'package:flutter/material.dart';
import '../models/template.dart';
import '../services/api_service.dart';

class TemplateProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  List<Template> _templates = [];
  bool _isLoading = false;

  List<Template> get templates => _templates;
  bool get isLoading => _isLoading;

  Future<void> fetchTemplates() async {
    _isLoading = true;
    notifyListeners();
    try {
      _templates = await _apiService.getTemplates();
    } catch (e) {
      debugPrint('Failed to fetch templates: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}