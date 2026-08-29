class Appliance {
  final String id;
  final String code;
  final String name;
  final String category;

  Appliance({
    required this.id,
    required this.code,
    required this.name,
    required this.category,
  });

  factory Appliance.fromJson(Map<String, dynamic> json) {
    return Appliance(
      id: json['id'],
      code: json['code'],
      name: json['name'],
      category: json['category'],
    );
  }
}
