import 'dart:async';
import 'package:flutter/material.dart';
import '../models/document.dart';
import '../services/api_service.dart';

class DocumentProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  List<Document> _documents = [];
  bool _isUploading = false;
  Document? _currentDocument;
  Timer? _pollingTimer;

  List<Document> get documents => _documents;
  bool get isUploading => _isUploading;
  Document? get currentDocument => _currentDocument;

  void setCurrentDocument(Document doc) {
    _currentDocument = doc;
    notifyListeners();
  }

  Future<void> uploadAndAnalyze(
    String filePath,
    String templateId,
    String studentId,
  ) async {
    _isUploading = true;
    notifyListeners();

    try {
      final docId = await _apiService.uploadDocument(
        filePath,
        templateId,
        studentId,
      );

      // Since backend analysis is synchronous, we can fetch the result immediately
      final updatedDoc = await _apiService.getAnalysisStatus(docId);

      _currentDocument = updatedDoc;
      _isUploading = false;
      notifyListeners();
    } catch (e) {
      debugPrint('Upload/Analysis failed: $e');
      _isUploading = false;
      notifyListeners();
    }
  }

  // Polling removed as per user request (backend is synchronous)

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }
}
