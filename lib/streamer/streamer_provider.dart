import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/song.dart';
import 'audius_service.dart';
import 'itunes_service.dart';

enum StreamSource { itunes, audius }

/// Géneros: etiqueta que se ve -> término de búsqueda.
const Map<String, String> kStreamGenres = {
  'Tendencias': '',
  'Reggaetón': 'reggaeton',
  'Bachata': 'bachata',
  'Baladas': 'baladas romanticas',
  'Rap': 'rap',
  'Cumbia': 'cumbia',
  'Salsa': 'salsa',
  'Merengue': 'merengue',
  'Pop': 'pop',
  'Rock': 'rock',
  'Electrónica': 'electronic',
  'Lo-fi': 'lofi',
  'Folklore': 'folklore boliviano',
};

class StreamerProvider extends ChangeNotifier {
  StreamerProvider({AudiusService? audius, ItunesService? itunes})
      : _audius = audius ?? AudiusService(),
        _itunes = itunes ?? ItunesService();

  final AudiusService _audius;
  final ItunesService _itunes;
  Timer? _debounce;
  int _requestId = 0;

  List<Song> _results = [];
  bool _loading = false;
  String? _error;
  String _query = '';
  String _genre = 'Tendencias';
  StreamSource _source = StreamSource.itunes;

  List<Song> get results => List.unmodifiable(_results);
  bool get loading => _loading;
  String? get error => _error;
  String get genre => _genre;
  StreamSource get source => _source;

  /// Primera carga (si aún no hay nada).
  Future<void> init() => _results.isEmpty ? _load() : Future.value();

  /// Botón recargar: repite la búsqueda actual.
  Future<void> reload() => _load();

  void selectGenre(String label) {
    _genre = label;
    _query = '';
    _load();
  }

  void setSource(StreamSource s) {
    if (s == _source) return;
    _source = s;
    _load();
  }

  void onQueryChanged(String q) {
    _query = q;
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), _load);
  }

  Future<void> _load() async {
    final id = ++_requestId; // descarta respuestas viejas
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final typed = _query.trim();
      final term = typed.isNotEmpty ? typed : (kStreamGenres[_genre] ?? '');
      final List<Song> songs;
      if (_source == StreamSource.audius) {
        songs = term.isEmpty
            ? await _audius.trending()
            : await _audius.search(term);
      } else {
        songs = await _itunes.search(term.isEmpty ? 'top hits' : term);
      }
      if (id != _requestId) return;
      _results = songs;
      if (songs.isEmpty) _error = 'Sin resultados. Prueba otro género o la otra fuente.';
    } catch (e) {
      if (id != _requestId) return;
      _error = 'No se pudo conectar. Revisa tu internet o cambia de fuente.';
      debugPrint('Streamer error: $e');
    }
    _loading = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _audius.dispose();
    _itunes.dispose();
    super.dispose();
  }
}
