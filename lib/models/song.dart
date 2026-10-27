import 'package:flutter/foundation.dart';

@immutable
class Song {
  final String id;
  final String title;
  final String artist;
  final String album;
  final Duration duration;
  final String? artworkUrl;
  final String? audioUrl;
  final String? localAudioPath;

  const Song({
    required this.id,
    required this.title,
    required this.artist,
    required this.album,
    required this.duration,
    this.artworkUrl,
    this.audioUrl,
    this.localAudioPath,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'artist': artist,
        'album': album,
        'duration': duration.inSeconds,
        'artworkUrl': artworkUrl,
        'audioUrl': audioUrl,
        'localAudioPath': localAudioPath,
      };

  factory Song.fromJson(Map<String, dynamic> json) => Song(
        id: json['id'] as String,
        title: json['title'] as String,
        artist: json['artist'] as String,
        album: json['album'] as String,
        duration: Duration(seconds: json['duration'] as int),
        artworkUrl: json['artworkUrl'] as String?,
        audioUrl: json['audioUrl'] as String?,
        localAudioPath: json['localAudioPath'] as String?,
      );
}