import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/playlist.dart';
import '../providers/audio_provider.dart';
import '../providers/library_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/song_tile.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final library = context.watch<LibraryProvider>();

    return Column(
      children: [
        SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                const Text(
                  'Biblioteca',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ),
        TabBar(
          controller: _tab,
          isScrollable: true,
          indicatorColor: AppColors.accent,
          labelColor: AppColors.accent,
          unselectedLabelColor: AppColors.textSecondary,
          labelStyle: const TextStyle(fontWeight: FontWeight.w700),
          tabs: const [
            Tab(text: 'Playlists'),
            Tab(text: 'Álbumes'),
            Tab(text: 'Artistas'),
            Tab(text: 'Canciones'),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tab,
            children: [
              _PlaylistsTab(library: library),
              _AlbumsTab(library: library),
              _ArtistsTab(library: library),
              _SongsTab(library: library),
            ],
          ),
        ),
      ],
    );
  }
}

class _PlaylistsTab extends StatelessWidget {
  final LibraryProvider library;
  const _PlaylistsTab({required this.library});

  @override
  Widget build(BuildContext context) {
    final liked = library.likedSongs;
    return ListView(
      padding: const EdgeInsets.only(bottom: 100),
      children: [
        ListTile(
          leading: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFF6B6B), Color(0xFFFC3C44)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Icon(Icons.favorite, color: Colors.white),
          ),
          title: const Text('Me gusta',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
          subtitle: Text(
            'Playlist • ${liked.length} canciones',
            style: const TextStyle(
                color: AppColors.textSecondary, fontSize: 12),
          ),
          onTap: () {},
        ),
        ...library.playlists.map((p) => _PlaylistTile(playlist: p)),
      ],
    );
  }
}

class _PlaylistTile extends StatelessWidget {
  final Playlist playlist;
  const _PlaylistTile({required this.playlist});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Image.network(
          playlist.artworkUrl ?? '',
          width: 48,
          height: 48,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF8E2DE2), Color(0xFF4A00E0)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: const Icon(Icons.queue_music, color: Colors.white),
          ),
        ),
      ),
      title: Text(playlist.name,
          style:
              const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      subtitle: Text('Playlist • ${playlist.curator}',
          style:
              const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
      onTap: () =>
          Navigator.of(context).pushNamed('/playlist', arguments: playlist),
    );
  }
}

class _AlbumsTab extends StatelessWidget {
  final LibraryProvider library;
  const _AlbumsTab({required this.library});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16).copyWith(bottom: 100),
      itemCount: library.albums.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.7,
      ),
      itemBuilder: (_, i) {
        final album = library.albums[i];
        return GestureDetector(
          onTap: () =>
              Navigator.of(context).pushNamed('/album', arguments: album),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    album.artworkUrl ?? '',
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: AppColors.darkCard,
                      child:
                          const Icon(Icons.album, color: Colors.white54, size: 40),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(album.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w600)),
              Text(album.artist,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 12)),
            ],
          ),
        );
      },
    );
  }
}

class _ArtistsTab extends StatelessWidget {
  final LibraryProvider library;
  const _ArtistsTab({required this.library});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16).copyWith(bottom: 100),
      itemCount: library.artists.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.7,
      ),
      itemBuilder: (_, i) {
        final artist = library.artists[i];
        return GestureDetector(
          onTap: () =>
              Navigator.of(context).pushNamed('/artist', arguments: artist),
          child: Column(
            children: [
              Expanded(
                child: ClipOval(
                  child: Image.network(
                    artist.imageUrl ?? '',
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: AppColors.darkCard,
                      child: const Icon(Icons.person,
                          color: Colors.white54, size: 40),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(artist.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w600)),
              Text(artist.genre ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 12)),
            ],
          ),
        );
      },
    );
  }
}

class _SongsTab extends StatelessWidget {
  final LibraryProvider library;
  const _SongsTab({required this.library});

  @override
  Widget build(BuildContext context) {
    final liked = library.likedSongs;
    final audio = context.read<AudioProvider>();
    if (liked.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.favorite_border,
                size: 64, color: AppColors.textSecondary),
            const SizedBox(height: 16),
            const Text('Aún no tienes canciones favoritas',
                style: TextStyle(color: AppColors.textSecondary)),
            const SizedBox(height: 8),
            const Text('Toca el corazón para añadir',
                style: TextStyle(
                    color: AppColors.textSecondary, fontSize: 12)),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 100),
      itemCount: liked.length,
      itemBuilder: (_, i) {
        final s = liked[i];
        return SongTile(
          song: s,
          index: i + 1,
          onTap: () => audio.playSong(s, contextList: liked),
        );
      },
    );
  }
}
