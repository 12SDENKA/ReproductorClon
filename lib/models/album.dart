import 'package:flutter/foundation.dart';
import 'song.dart';

@immutable
class Album {
  final String id;
  final String title;
  final String artist;
  final int year;
  final String? artworkUrl;
  final List<Song> tracks;

  const Album({
    required this.id,
    required this.title,
    required this.artist,
    required this.year,
    required this.tracks,
    this.artworkUrl,
  });

  Duration get totalDuration =>
      tracks.fold(Duration.zero, (a, b) => a + b.duration);
}