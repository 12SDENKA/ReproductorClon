import 'package:flutter/foundation.dart';

import '../data/sample_data.dart';
import '../models/album.dart';
import '../models/artist.dart';
import '../models/playlist.dart';
import '../models/song.dart';

class LibraryProvider extends ChangeNotifier {
  List<Album> _albums = [];
  List<Artist> _artists = [];
  List<Playlist> _playlists = [];
  List<Song> _recentlyPlayed = [];
  List<Song> _likedSongs = [];
  List<String> _downloadedIds = [];
  List<String> _followedArtistIds = [];
  String _searchQuery = '';

  List<Album> get albums => List.unmodifiable(_albums);
  List<Artist> get artists => List.unmodifiable(_artists);
  List<Playlist> get playlists => List.unmodifiable(_playlists);
  List<Song> get recentlyPlayed => List.unmodifiable(_recentlyPlayed);
  List<Song> get likedSongs => List.unmodifiable(_likedSongs);
  List<String> get downloadedIds => List.unmodifiable(_downloadedIds);
  List<String> get followedArtistIds => List.unmodifiable(_followedArtistIds);
  String get searchQuery => _searchQuery;

  void init() {
    _albums = SampleData.featuredAlbums;
    _artists = SampleData.artists;
    _playlists = SampleData.curatedPlaylists;
    notifyListeners();
  }

  void setSearchQuery(String q) {
    _searchQuery = q;
    notifyListeners();
  }

  List<Song> searchSongs(String query) {
    if (query.trim().isEmpty) return [];
    final lower = query.toLowerCase();
    final all = <Song>[
      ...SampleData.trendingSongs,
      ..._albums.expand((a) => a.tracks),
    ];
    final seen = <String>{};
    final result = <Song>[];
    for (final s in all) {
      if (!seen.contains(s.id) &&
          (s.title.toLowerCase().contains(lower) ||
              s.artist.toLowerCase().contains(lower) ||
              s.album.toLowerCase().contains(lower))) {
        seen.add(s.id);
        result.add(s);
      }
    }
    return result;
  }

  List<Album> searchAlbums(String query) {
    if (query.trim().isEmpty) return [];
    final lower = query.toLowerCase();
    return _albums
        .where((a) =>
            a.title.toLowerCase().contains(lower) ||
            a.artist.toLowerCase().contains(lower))
        .toList();
  }

  List<Artist> searchArtists(String query) {
    if (query.trim().isEmpty) return [];
    final lower = query.toLowerCase();
    return _artists
        .where((a) => a.name.toLowerCase().contains(lower))
        .toList();
  }

  void addToRecentlyPlayed(Song song) {
    _recentlyPlayed.removeWhere((s) => s.id == song.id);
    _recentlyPlayed.insert(0, song);
    if (_recentlyPlayed.length > 20) {
      _recentlyPlayed = _recentlyPlayed.sublist(0, 20);
    }
    notifyListeners();
  }

  bool isLiked(Song song) => _likedSongs.any((s) => s.id == song.id);

  void toggleLike(Song song) {
    if (isLiked(song)) {
      _likedSongs.removeWhere((s) => s.id == song.id);
    } else {
      _likedSongs.insert(0, song);
    }
    notifyListeners();
  }

  bool isDownloaded(String id) => _downloadedIds.contains(id);
  void toggleDownload(String id) {
    if (isDownloaded(id)) {
      _downloadedIds.remove(id);
    } else {
      _downloadedIds.add(id);
    }
    notifyListeners();
  }

  bool isFollowing(String artistId) => _followedArtistIds.contains(artistId);
  void toggleFollow(String artistId) {
    if (isFollowing(artistId)) {
      _followedArtistIds.remove(artistId);
    } else {
      _followedArtistIds.add(artistId);
    }
    notifyListeners();
  }

  Album? albumById(String id) {
    try {
      return _albums.firstWhere((a) => a.id == id);
    } catch (_) {
      return null;
    }
  }

  Artist? artistById(String id) {
    try {
      return _artists.firstWhere((a) => a.id == id);
    } catch (_) {
      return null;
    }
  }

  Playlist? playlistById(String id) {
    try {
      return _playlists.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }
}