import 'package:flutter/material.dart';

class UserModel {
  final String id;
  final String name;
  final String email;
  final String location;
  final DateTime memberSince;
  final String? profileImageUrl;
  final int destinationsCount;
  final int plansCount;
  final int bookmarksCount;
  final Color? avatarBackgroundColor;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.location,
    required this.memberSince,
    this.profileImageUrl,
    this.destinationsCount = 0,
    this.plansCount = 0,
    this.bookmarksCount = 0,
    this.avatarBackgroundColor,
  });

  String get initials {
    if (name.isEmpty) return '';
    final names = name.split(' ');
    if (names.length == 1) return names[0][0].toUpperCase();
    return '${names[0][0]}${names[1][0]}'.toUpperCase();
  }
}
