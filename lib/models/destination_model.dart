import 'package:flutter/material.dart';

class DestinationModel {
  final String id;
  final String title;
  final String description;
  final String? imageUrl;
  final double rating;
  final int reviews;
  final String? location;
  final Color? color; // For UI placeholders
  final DateTime? savedDate; // For Profile "Saved Destinations"

  const DestinationModel({
    required this.id,
    required this.title,
    this.description = '',
    this.imageUrl,
    this.rating = 0.0,
    this.reviews = 0,
    this.location,
    this.color,
    this.savedDate,
  });
}
