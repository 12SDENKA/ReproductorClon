import 'package:flutter/foundation.dart';
import 'song.dart';

@immutable
class Playlist {
  final String id;
  final String name;
  final String description;
  final String curator;
  final String? artworkUrl;
  final List<Song> songs;

  const Playlist({
    required this.id,
    required this.name,
    required this.description,
    required this.curator,
    required this.songs,
    this.artworkUrl,
  });

  Duration get totalDuration =>
      songs.fold(Duration.zero, (a, b) => a + b.duration);
}