import 'address.dart';
import 'bank.dart';
import 'company.dart';
import 'hair.dart';

class User {
  final int id;
  final String firstName;
  final String lastName;
  final String? maidenName;
  final int age;
  final String gender;
  final String email;
  final String phone;
  final String username;
  final String password;
  final String birthDate;
  final String avatar;
  final String bloodGroup;
  final double height;
  final double weight;
  final String eyeColor;
  final Hair? hair;
  final String ip;
  final Address? address;
  final String macAddress;
  final String university;
  final Bank? bank;
  final Company? company;

  String get name => '$firstName $lastName';

  User({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.maidenName,
    required this.age,
    required this.gender,
    required this.email,
    required this.phone,
    required this.username,
    required this.password,
    required this.birthDate,
    required this.avatar,
    required this.bloodGroup,
    required this.height,
    required this.weight,
    required this.eyeColor,
    this.hair,
    required this.ip,
    this.address,
    required this.macAddress,
    required this.university,
    this.bank,
    this.company,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      maidenName: json['maidenName'],
      age: json['age'] != null ? int.parse(json['age'].toString()) : 0,
      gender: json['gender'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      username: json['username'] ?? '',
      password: json['password'] ?? '',
      birthDate: json['birthDate'] ?? '',
      avatar: json['image'] ?? 'https://via.placeholder.com/150',
      bloodGroup: json['bloodGroup'] ?? '',
      height:
          json['height'] != null
              ? double.parse(json['height'].toString())
              : 0.0,
      weight:
          json['weight'] != null
              ? double.parse(json['weight'].toString())
              : 0.0,
      eyeColor: json['eyeColor'] ?? '',
      hair: json['hair'] != null ? Hair.fromJson(json['hair']) : null,
      ip: json['ip'] ?? '',
      address:
          json['address'] != null ? Address.fromJson(json['address']) : null,
      macAddress: json['macAddress'] ?? '',
      university: json['university'] ?? '',
      bank: json['bank'] != null ? Bank.fromJson(json['bank']) : null,
      company:
          json['company'] != null ? Company.fromJson(json['company']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'maidenName': maidenName,
      'age': age,
      'gender': gender,
      'email': email,
      'phone': phone,
      'username': username,
      'password': password,
      'birthDate': birthDate,
      'image': avatar,
      'bloodGroup': bloodGroup,
      'height': height,
      'weight': weight,
      'eyeColor': eyeColor,
      'hair': hair?.toJson(),
      'ip': ip,
      'address': address?.toJson(),
      'macAddress': macAddress,
      'university': university,
      'bank': bank?.toJson(),
      'company': company?.toJson(),
    };
  }
}
