import 'package:flutter/material.dart';

class TravelPlanModel {
  final String id;
  final String title;
  final String description;
  final int durationDays;
  final double budget;
  final String currency;
  final DateTime createdDate;
  final IconData? icon;

  const TravelPlanModel({
    required this.id,
    required this.title,
    this.description = '',
    required this.durationDays,
    required this.budget,
    this.currency = '\$',
    required this.createdDate,
    this.icon,
  });

  String get formattedDuration => '$durationDays days';
  String get formattedBudget => '$currency${budget.toStringAsFixed(0)}';
}
