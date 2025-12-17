class Document {
  final String id;
  final String filename;
  final String analysisStatus;
  final String paymentStatus;
  final Map<String, dynamic>? analysisResult;

  Document({
    required this.id,
    required this.filename,
    required this.analysisStatus,
    required this.paymentStatus,
    this.analysisResult,
  });

  factory Document.fromJson(Map<String, dynamic> json) {
    return Document(
      id: json['id'],
      filename: json['filename'],
      analysisStatus: json['analysis_status'] ?? 'pending',
      paymentStatus: json['payment_status'] ?? 'unpaid',
      analysisResult: json['analysis_result'],
    );
  }
}