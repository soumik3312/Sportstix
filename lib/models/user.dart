import 'package:flutter/foundation.dart';

class User {
  final String id;
  final String name;
  final String email;
  final String phoneNumber;
  final String? profileImageUrl;
  final List<String> favoriteMatchIds;
  final Map<String, dynamic> preferences;
  String? address;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.phoneNumber,
    this.profileImageUrl,
    this.favoriteMatchIds = const [],
    this.preferences = const {},
    this.address,
  });

  String? get profileImagePath => profileImageUrl;

  User copyWith({
    String? id,
    String? name,
    String? email,
    String? phoneNumber,
    String? profileImageUrl,
    List<String>? favoriteMatchIds,
    Map<String, dynamic>? preferences,
    String? address,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      favoriteMatchIds: favoriteMatchIds ?? this.favoriteMatchIds,
      preferences: preferences ?? this.preferences,
      address: address ?? this.address,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'profileImagePath': profileImagePath,
      'favoriteMatchIds': favoriteMatchIds,
      'preferences': preferences,
      'address': address,
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      profileImageUrl: json['profileImagePath'],
      favoriteMatchIds: List<String>.from(json['favoriteMatchIds'] ?? []),
      preferences: Map<String, dynamic>.from(json['preferences'] ?? {}),
      address: json['address'],
    );
  }
}

