class User {
  final String id;
  final String email;
  final String name;
  final String role;
  final String? phone;
  final String? bio;
  final String? className;

  User({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    this.phone,
    this.bio,
    this.className,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      role: json['role'] ?? '',
      phone: json['phone'] ?? '',
      bio: json['bio'] ?? '',
      className: json['class_name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'role': role,
      'phone': phone,
      'bio': bio,
      'class_name': className,
    };
  }
}
