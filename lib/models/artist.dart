import 'package:flutter/foundation.dart';

@immutable
class Artist {
  final String id;
  final String name;
  final String? imageUrl;
  final String? genre;

  const Artist({
    required this.id,
    required this.name,
    this.imageUrl,
    this.genre,
  });
}