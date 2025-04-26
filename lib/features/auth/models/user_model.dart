class User {
  final int id;
  final String name;
  final String email;
  final String? image;
  final String? phone;
  final String? role;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.image,
    this.phone,
    this.role,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      image: json['image'],
      phone: json['phone'],
      role: json['role'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'image': image,
      'phone': phone,
      'role': role,
    };
  }
}
