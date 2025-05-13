class Identifier {
  final String? id;
  final String? name;

  Identifier({required this.id, required this.name});

  factory Identifier.fromJson(Map<String, dynamic> json) {
    return Identifier(
      id: json['id'] ?? json["_id"],
      name: json['name'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}
