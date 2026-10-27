import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'streamer_provider.dart';
import 'streamer_screen.dart';

class _GenreStyle {
  final Color a;
  final Color b;
  final IconData icon;
  const _GenreStyle(this.a, this.b, this.icon);
}

const _styles = <String, _GenreStyle>{
  'Tendencias': _GenreStyle(Color(0xFFFC3C44), Color(0xFFFF7A59), Icons.trending_up),
  'Reggaetón': _GenreStyle(Color(0xFFFF8A00), Color(0xFFFFC837), Icons.speaker),
  'Bachata': _GenreStyle(Color(0xFFE91E63), Color(0xFFFF6090), Icons.favorite),
  'Baladas': _GenreStyle(Color(0xFF5C6BC0), Color(0xFF9FA8DA), Icons.nightlight),
  'Rap': _GenreStyle(Color(0xFF8E24AA), Color(0xFFCE93D8), Icons.mic),
  'Cumbia': _GenreStyle(Color(0xFF00ACC1), Color(0xFF80DEEA), Icons.music_note),
  'Salsa': _GenreStyle(Color(0xFFD84315), Color(0xFFFF8A65), Icons.celebration),
  'Merengue': _GenreStyle(Color(0xFF2E7D32), Color(0xFF81C784), Icons.queue_music),
  'Pop': _GenreStyle(Color(0xFFFF7043), Color(0xFFFFAB91), Icons.star),
  'Rock': _GenreStyle(Color(0xFF424242), Color(0xFF9E9E9E), Icons.electric_bolt),
  'Electrónica': _GenreStyle(Color(0xFF1E88E5), Color(0xFF64B5F6), Icons.graphic_eq),
  'Lo-fi': _GenreStyle(Color(0xFF6D4C41), Color(0xFFBCAAA4), Icons.headphones),
  'Folklore': _GenreStyle(Color(0xFF558B2F), Color(0xFFC5E1A5), Icons.landscape),
};

/// Pestaña "Buscar" con streaming real: cada género abre una lista que suena.
class GenreGridScreen extends StatelessWidget {
  const GenreGridScreen({super.key});

  void _open(BuildContext context, {String? genre, bool focus = false}) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => StreamerScreen(initialGenre: genre, focusSearch: focus),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final genres = kStreamGenres.keys.toList();
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        const Text('Buscar',
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800)),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: () => _open(context, focus: true),
          child: Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: AppColors.darkSurface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(children: [
              Icon(Icons.search, color: AppColors.textSecondary),
              SizedBox(width: 10),
              Text('Artistas, canciones y más',
                  style: TextStyle(color: AppColors.textSecondary)),
            ]),
          ),
        ),
        const SizedBox(height: 20),
        const Text('Explora por géneros',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: genres.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.6,
          ),
          itemBuilder: (_, i) {
            final g = genres[i];
            final s = _styles[g] ??
                const _GenreStyle(Color(0xFF616161), Color(0xFF9E9E9E), Icons.music_note);
            return GestureDetector(
              onTap: () => _open(context, genre: g),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  gradient: LinearGradient(
                    colors: [s.a, s.b],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Stack(children: [
                  Positioned(
                    right: -6,
                    bottom: -6,
                    child: Icon(s.icon,
                        size: 72, color: Colors.white.withOpacity(0.35)),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Align(
                      alignment: Alignment.bottomLeft,
                      child: Text(g,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.w700)),
                    ),
                  ),
                ]),
              ),
            );
          },
        ),
      ],
    );
  }
}
