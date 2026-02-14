import 'package:flutter/material.dart';

class TravelOfficeModel {
  final String id;
  final String name;
  final String description;
  final String location;
  final double rating;
  final int reviews;
  final String? imageUrl;
  final IconData? icon; // For fallback UI

  const TravelOfficeModel({
    required this.id,
    required this.name,
    this.description = '',
    required this.location,
    this.rating = 0.0,
    this.reviews = 0,
    this.imageUrl,
    this.icon,
  });

  String get formattedRating => rating.toStringAsFixed(1);
}
