class Template {
  final String id;
  final String name;
  final List<Map<String, dynamic>> structure;

  Template({required this.id, required this.name, required this.structure});

  factory Template.fromJson(Map<String, dynamic> json) {
    return Template(
      id: json['id'],
      name: json['name'],
      structure: List<Map<String, dynamic>>.from(json['structure'] ?? []),
    );
  }
}
