import 'address.dart';

class Company {
  final String department;
  final String name;
  final String title;
  final Address? address;

  Company({
    required this.department,
    required this.name,
    required this.title,
    this.address,
  });

  factory Company.fromJson(Map<String, dynamic> json) {
    return Company(
      department: json['department'] ?? '',
      name: json['name'] ?? '',
      title: json['title'] ?? '',
      address:
          json['address'] != null ? Address.fromJson(json['address']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'department': department,
      'name': name,
      'title': title,
      'address': address?.toJson(),
    };
  }
}
