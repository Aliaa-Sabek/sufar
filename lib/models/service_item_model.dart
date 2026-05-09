import 'package:flutter/material.dart';

class ServiceItemModel {
  final String title;
  final IconData icon;
  final Color color;
  final String? description;
  final Widget? destinationPage;
  final int? navigationIndex;

  const ServiceItemModel({
    required this.title,
    required this.icon,
    this.color = Colors.blue,
    this.description,
    this.destinationPage,
    this.navigationIndex,
  });
}
