import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/song.dart';

/// Cliente del API público de Audius (audio completo).
/// Cada pista se convierte en tu modelo `Song` ya existente.
class AudiusService {
  AudiusService({http.Client? client}) : _client = client ?? http.Client();

  static const String baseUrl = 'https://discoveryprovider.audius.co';
  static const String appName = 'ReproductorClon';

  /// Si Audius te pide clave gratuita (api.audius.co), pégala aquí.
  static String? apiKey;

  final http.Client _client;

  Map<String, String> get _headers =>
      {if (apiKey != null) 'Authorization': 'Bearer $apiKey'};

  Future<List<Song>> trending() => _getTracks('/v1/tracks/trending', {});

  Future<List<Song>> search(String query) =>
      _getTracks('/v1/tracks/search', {'query': query});

  Future<List<Song>> _getTracks(String path, Map<String, String> params) async {
    final uri = Uri.parse('$baseUrl$path').replace(
        queryParameters: {...params, 'limit': '20', 'app_name': appName});
    final res = await _client
        .get(uri, headers: _headers)
        .timeout(const Duration(seconds: 15));
    if (res.statusCode != 200) {
      throw Exception('Audius respondió ${res.statusCode}');
    }
    final body = jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
    final items = ((body['data'] as List?) ?? const [])
        .whereType<Map<String, dynamic>>()
        .where((t) => t['is_streamable'] != false)
        .toList();

    // Se resuelve la URL REAL del audio antes de reproducir (más fiable que
    // depender de la redirección del navegador).
    return Future.wait(items.map((j) async {
      final id = j['id'].toString();
      return _toSong(j, await _resolveStream(id));
    }));
  }

  String _redirectUrl(String id) => Uri.parse('$baseUrl/v1/tracks/$id/stream')
      .replace(queryParameters: {'app_name': appName}).toString();

  Future<String> _resolveStream(String id) async {
    try {
      final uri = Uri.parse('$baseUrl/v1/tracks/$id/stream').replace(
          queryParameters: {'app_name': appName, 'no_redirect': 'true'});
      final res = await _client
          .get(uri, headers: _headers)
          .timeout(const Duration(seconds: 8));
      if (res.statusCode == 200) {
        final data = (jsonDecode(res.body) as Map<String, dynamic>)['data'];
        if (data is String && data.isNotEmpty) return data;
      }
    } catch (_) {}
    return _redirectUrl(id);
  }

  Song _toSong(Map<String, dynamic> j, String url) {
    final user = j['user'] as Map<String, dynamic>?;
    final art = j['artwork'] as Map<String, dynamic>?;
    return Song(
      id: 'audius_${j['id']}',
      title: (j['title'] ?? 'Sin título').toString(),
      artist: (user?['name'] ?? 'Desconocido').toString(),
      album: (j['genre'] ?? 'Audius').toString(),
      duration: Duration(seconds: (j['duration'] as num?)?.toInt() ?? 0),
      artworkUrl:
          (art?['480x480'] ?? art?['1000x1000'] ?? art?['150x150']) as String?,
      audioUrl: url,
    );
  }

  void dispose() => _client.close();
}
