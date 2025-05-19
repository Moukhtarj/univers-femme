class User {
  final int? id;
  final String firstName;
  final String lastName;
  final String phone;
  final String? email;
  final String? role;

  User({
    this.id,
    required this.firstName,
    required this.lastName,
    required this.phone,
    this.email,
    this.role = 'utilisateur',
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      phone: json['phone'],
      email: json['email'],
      role: json['role'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'first_name': firstName,
      'last_name': lastName,
      'phone': phone,
      'email': email,
      'role': role,
    };
  }

  String get fullName => '$firstName $lastName';
} 