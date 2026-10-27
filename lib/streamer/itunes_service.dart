import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/song.dart';

/// Catálogo enorme (reggaetón, bachata, cumbia, baladas, rap…) del API público
/// de iTunes. Ojo: solo entrega PREVIEWS de 30 segundos por canción.
class ItunesService {
  ItunesService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<List<Song>> search(String term, {int limit = 25}) async {
    final uri = Uri.parse('https://itunes.apple.com/search').replace(
      queryParameters: {
        'term': term,
        'media': 'music',
        'entity': 'song',
        'limit': '$limit',
      },
    );
    final res = await _client.get(uri).timeout(const Duration(seconds: 15));
    if (res.statusCode != 200) {
      throw Exception('iTunes respondió ${res.statusCode}');
    }
    final body = jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
    final results = (body['results'] as List?) ?? const [];
    return results
        .whereType<Map<String, dynamic>>()
        .where((j) => (j['previewUrl'] as String?)?.isNotEmpty ?? false)
        .map((j) => Song(
              id: 'itunes_${j['trackId']}',
              title: (j['trackName'] ?? 'Sin título').toString(),
              artist: (j['artistName'] ?? 'Desconocido').toString(),
              album: (j['collectionName'] ?? 'iTunes').toString(),
              duration: const Duration(seconds: 30),
              artworkUrl: (j['artworkUrl100'] as String?)
                  ?.replaceAll('100x100bb', '600x600bb'),
              audioUrl: j['previewUrl'] as String,
            ))
        .toList();
  }

  void dispose() => _client.close();
}
