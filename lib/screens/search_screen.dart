import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/sample_data.dart';
import '../providers/audio_provider.dart';
import '../providers/library_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/song_tile.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();
  final _focus = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final library = context.watch<LibraryProvider>();
    final audio = context.read<AudioProvider>();
    final query = library.searchQuery;

    return Column(
      children: [
        SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                const Text(
                  'Buscar',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.mic_none),
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.darkCard,
              borderRadius: BorderRadius.circular(10),
            ),
            child: TextField(
              controller: _controller,
              focusNode: _focus,
              onChanged: library.setSearchQuery,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: 'Artistas, canciones, letras y más',
                hintStyle: TextStyle(color: AppColors.textSecondary),
                prefixIcon: Icon(Icons.search, color: AppColors.textSecondary),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ),
        Expanded(
          child: query.trim().isEmpty
              ? _BrowseGenres()
              : _SearchResults(query: query, audio: audio, library: library),
        ),
      ],
    );
  }
}

class _BrowseGenres extends StatelessWidget {
  final List<Color> colors = const [
    Color(0xFFFF8A65),
    Color(0xFFBA68C8),
    Color(0xFF4FC3F7),
    Color(0xFF81C784),
    Color(0xFFFFD54F),
    Color(0xFFE57373),
    Color(0xFF7986CB),
    Color(0xFFA1887F),
    Color(0xFF4DB6AC),
    Color(0xFFF06292),
    Color(0xFFAED581),
    Color(0xFFFFB74D),
  ];

  _BrowseGenres();

  @override
  Widget build(BuildContext context) {
    final genres = SampleData.allGenres;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Explora por géneros',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: genres.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 2.2,
            ),
            itemBuilder: (_, i) => Container(
              decoration: BoxDecoration(
                color: colors[i % colors.length],
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.all(12),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Text(
                  genres[i],
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

class _SearchResults extends StatelessWidget {
  final String query;
  final AudioProvider audio;
  final LibraryProvider library;

  const _SearchResults({
    required this.query,
    required this.audio,
    required this.library,
  });

  @override
  Widget build(BuildContext context) {
    final songs = library.searchSongs(query);
    final albums = library.searchAlbums(query);
    final artists = library.searchArtists(query);

    if (songs.isEmpty && albums.isEmpty && artists.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off,
                size: 64, color: AppColors.textSecondary),
            const SizedBox(height: 16),
            Text(
              'Sin resultados para "$query"',
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.only(bottom: 100),
      children: [
        if (songs.isNotEmpty) ...[
          const _Header('Canciones'),
          ...songs.map((s) => SongTile(
                song: s,
                onTap: () {
                  audio.playSong(s, contextList: songs);
                  library.addToRecentlyPlayed(s);
                },
              )),
        ],
        if (albums.isNotEmpty) ...[
          const _Header('Álbumes'),
          ...albums.map((a) => ListTile(
                onTap: () => Navigator.of(context).pushNamed('/album',
                    arguments: a),
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Image.network(
                    a.artworkUrl ?? '',
                    width: 48,
                    height: 48,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 48,
                      height: 48,
                      color: AppColors.darkCard,
                      child: const Icon(Icons.album,
                          color: Colors.white54),
                    ),
                  ),
                ),
                title: Text(a.title,
                    style: const TextStyle(color: Colors.white)),
                subtitle: Text('${a.artist} • ${a.year}',
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 12)),
              )),
        ],
        if (artists.isNotEmpty) ...[
          const _Header('Artistas'),
          ...artists.map((a) => ListTile(
                onTap: () => Navigator.of(context).pushNamed('/artist',
                    arguments: a),
                leading: ClipOval(
                  child: Image.network(
                    a.imageUrl ?? '',
                    width: 48,
                    height: 48,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 48,
                      height: 48,
                      color: AppColors.darkCard,
                      child: const Icon(Icons.person,
                          color: Colors.white54),
                    ),
                  ),
                ),
                title: Text(a.name,
                    style: const TextStyle(color: Colors.white)),
                subtitle: Text(a.genre ?? 'Artista',
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 12)),
              )),
        ],
      ],
    );
  }
}

class _Header extends StatelessWidget {
  final String text;
  const _Header(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
