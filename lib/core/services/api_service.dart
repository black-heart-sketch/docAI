import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/document.dart';
import '../models/template.dart';
import '../models/user.dart';

class ApiService {
  // static const String _baseUrl = "http://13.62.49.69:5003/api";
  static const String _baseUrl = "http://192.168.137.87:5003/api";
  // static const String _baseUrl = "/api";

  // --- Auth ---
  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    print('Login response: ${response.statusCode} - ${response.body}');
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      // Parse error message from backend
      try {
        final errorData = jsonDecode(response.body);
        final errorMsg =
            errorData['error'] ?? errorData['message'] ?? 'Unknown error';
        throw Exception('Failed to login: $errorMsg');
      } catch (e) {
        // If parsing fails, throw generic error
        throw Exception('Failed to login: ${response.body}');
      }
    }
  }

  Future<void> register(
    String name,
    String email,
    String password, {
    String? className,
  }) async {
    final Map<String, dynamic> body = {
      'name': name,
      'email': email,
      'password': password,
    };

    if (className != null) {
      body['class_name'] = className;
    }

    final response = await http.post(
      Uri.parse('$_baseUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    print('Register response: ${response.statusCode} - ${response.body}');
    if (response.statusCode != 201) {
      // Parse error message from backend
      try {
        final errorData = jsonDecode(response.body);
        final errorMsg =
            errorData['error'] ?? errorData['message'] ?? 'Unknown error';
        throw Exception('Failed to register: $errorMsg');
      } catch (e) {
        // If already an exception or parsing fails, keep original
        if (e is Exception && e.toString().contains('Failed to register')) {
          rethrow;
        }
        throw Exception('Failed to register: ${response.body}');
      }
    }
  }

  Future<void> updateUser(String userId, Map<String, dynamic> updates) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/users/$userId'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(updates),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update user: ${response.body}');
    }
  }

  // --- Templates ---
  Future<List<Template>> getTemplates() async {
    final response = await http.get(Uri.parse('$_baseUrl/templates'));
    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      return body.map((dynamic item) => Template.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load templates');
    }
  }

  // --- Documents ---
  Future<String> uploadDocument(
    String filePath, // Changed from filename to filePath
    String templateId,
    String studentId,
  ) async {
    final uri = Uri.parse('$_baseUrl/documents/upload');
    final request = http.MultipartRequest('POST', uri);

    request.files.add(await http.MultipartFile.fromPath('file', filePath));
    request.fields['template_id'] = templateId;
    request.fields['student_id'] = studentId;

    final streamkiResponse = await request.send();
    final response = await http.Response.fromStream(streamkiResponse);

    if (response.statusCode == 202) {
      return jsonDecode(response.body)['document_id'];
    } else {
      throw Exception('Failed to upload document: ${response.body}');
    }
  }

  Future<List<Document>> getUserDocuments(String studentId) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/documents/user/$studentId'),
    );
    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      return body.map((dynamic item) => Document.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load user documents');
    }
  }

  Future<List<Map<String, dynamic>>> getAllDocuments() async {
    final response = await http.get(Uri.parse('$_baseUrl/documents/all'));
    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      return body.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Failed to load all documents');
    }
  }

  Future<Document> getAnalysisStatus(String documentId) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/analysis/status/$documentId'),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Document(
        id: documentId,
        filename: 'Mock Filename',
        analysisStatus: data['status'],
        paymentStatus: 'unpaid',
        analysisResult: data['result'],
      );
    } else {
      throw Exception('Failed to get analysis status');
    }
  }

  Future<Map<String, dynamic>> initiatePayment(
    String documentId,
    String phoneNumber,
    String operator,
  ) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/payments/initiate'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'document_id': documentId,
        'type': 'print',
        'phone_number': phoneNumber,
        'operator': operator,
      }),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to initiate payment: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> verifyPayment(
    String documentId,
    String messageId,
  ) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/payments/verify'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'document_id': documentId, 'message_id': messageId}),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to verify payment: ${response.body}');
    }
  }

  // --- Admin ---
  Future<Map<String, dynamic>> getSystemConfig() async {
    // Calling /config which returns { "price_cents": 500, "due_date": "2025-12-31" }
    final response = await http.get(Uri.parse('$_baseUrl/admin/config'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load system config');
    }
  }

  // Legacy support or alias
  Future<int> getSystemPrice() async {
    final config = await getSystemConfig();
    return config['price_cents'] ?? 500;
  }

  Future<void> updateSystemConfig({int? priceCents, String? dueDate}) async {
    final Map<String, dynamic> body = {};
    if (priceCents != null) body['price_cents'] = priceCents;
    if (dueDate != null) body['due_date'] = dueDate;

    final response = await http.post(
      Uri.parse('$_baseUrl/admin/config'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update system config');
    }
  }

  Future<void> updateSystemPrice(int priceCents) async {
    await updateSystemConfig(priceCents: priceCents);
  }

  // --- Pricing Tiers ---
  Future<List<Map<String, dynamic>>> getPricingTiers() async {
    final response = await http.get(Uri.parse('$_baseUrl/admin/pricing-tiers'));
    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load pricing tiers');
    }
  }

  Future<void> createPricingTier(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/admin/pricing-tiers'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to create pricing tier');
    }
  }

  Future<void> updatePricingTier(String id, Map<String, dynamic> data) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/admin/pricing-tiers/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update pricing tier');
    }
  }

  Future<void> deletePricingTier(String id) async {
    final response = await http.delete(
      Uri.parse('$_baseUrl/admin/pricing-tiers/$id'),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to delete pricing tier');
    }
  }

  Future<void> activatePricingTier(String id) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/admin/pricing-tiers/$id/activate'),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to activate pricing tier');
    }
  }

  Future<List<User>> getUsers() async {
    final response = await http.get(Uri.parse('$_baseUrl/admin/users'));
    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      return body.map((dynamic item) => User.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load users');
    }
  }

  Future<void> createTemplate(Template template) async {
    // Note: Template model needs toJson implementation for this to work perfectly,
    // or we construct map manually. Let's assume manual map for now to avoid model changes if unexpected.
    // Actually Template model usually has fromJson, let's check if it has toJson.
    // Use manual map construction to be safe if toJson is missing.
    final Map<String, dynamic> body = {
      'id': template.id,
      'name': template.name,
      'structure': template.structure,
    };

    final response = await http.post(
      Uri.parse('$_baseUrl/admin/templates'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to create template');
    }
  }

  Future<void> updateTemplate(Template template) async {
    final Map<String, dynamic> body = {
      'name': template.name,
      'structure': template.structure,
    };

    final response = await http.put(
      Uri.parse('$_baseUrl/admin/templates/${template.id}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update template');
    }
  }

  Future<void> deleteTemplate(String id) async {
    final response = await http.delete(
      Uri.parse('$_baseUrl/admin/templates/$id'),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to delete template');
    }
  }

  Future<void> mockPaymentSuccess(String paymentId) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/payments/mock-success/$paymentId'),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to mock payment success');
    }
  }

  // --- Chat ---
  Future<String> chatDocument(
    String documentId,
    String message,
    List<Map<String, dynamic>> history,
  ) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/chat/document'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'document_id': documentId,
        'message': message,
        'history': history,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['response'];
    } else {
      final error = jsonDecode(response.body)['error'] ?? 'Unknown chat error';
      throw Exception(error);
    }
  }

  Future<String> chatTemplate(
    String templateId,
    String message,
    List<Map<String, dynamic>> history,
  ) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/chat/template'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'template_id': templateId,
        'message': message,
        'history': history,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['response'];
    } else {
      final error = jsonDecode(response.body)['error'] ?? 'Unknown chat error';
      throw Exception(error);
    }
  }

  // --- Receipts ---
  Future<void> createReceipt(Map<String, dynamic> receiptData) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/receipts'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(receiptData),
    );
    if (response.statusCode != 201) {
      throw Exception('Failed to create receipt');
    }
  }

  Future<List<Map<String, dynamic>>> getUserReceipts(String userId) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/receipts/user/$userId'),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(data['receipts']);
    } else {
      throw Exception('Failed to load user receipts');
    }
  }

  Future<List<Map<String, dynamic>>> getAllReceipts({String? userClass}) async {
    final queryParams = userClass != null ? '?class=$userClass' : '';
    final response = await http.get(
      Uri.parse('$_baseUrl/receipts/all$queryParams'),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(data['receipts']);
    } else {
      throw Exception('Failed to load all receipts');
    }
  }

  Future<void> validateReceipt(String receiptId) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/receipts/$receiptId/validate'),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to validate receipt');
    }
  }

  Future<void> rejectReceipt(String receiptId) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/receipts/$receiptId/reject'),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to reject receipt');
    }
  }
}
