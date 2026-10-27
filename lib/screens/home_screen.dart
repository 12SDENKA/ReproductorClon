import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/sample_data.dart';
import '../models/song.dart';
import '../providers/audio_provider.dart';
import '../providers/library_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/album_card.dart';
import '../widgets/playlist_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final library = context.watch<LibraryProvider>();

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          floating: true,
          backgroundColor: AppColors.darkBg,
          elevation: 0,
          title: const Text(
            'Escuchar ahora',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w800,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.account_circle_outlined),
              onPressed: () {},
            ),
          ],
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Container(
                height: 220,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.pink.shade400,
                      Colors.purple.shade700,
                      Colors.deepPurple.shade900,
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: -20,
                      bottom: -20,
                      child: Icon(
                        Icons.album,
                        size: 220,
                        color: Colors.white.withOpacity(0.15),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'PARA TI',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                          const Spacer(),
                          const Text(
                            'Mezcla diaria',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Tu música favorita renovada cada día',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton.icon(
                            onPressed: () =>
                                _playDailyMix(context, library),
                            icon: const Icon(Icons.play_arrow,
                                color: AppColors.accent, size: 18),
                            label: const Text(
                              'Reproducir',
                              style: TextStyle(
                                color: AppColors.accent,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: AppColors.accent,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: _SectionTitle('Álbumes destacados'),
        ),
        SliverToBoxAdapter(
          child: SizedBox(
            height: 240,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemBuilder: (_, i) => AlbumCard(
                album: library.albums[i],
                onTap: () {
                  Navigator.of(context).pushNamed('/album',
                      arguments: library.albums[i]);
                },
              ),
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemCount: library.albums.length,
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: _SectionTitle('Playlists seleccionadas'),
        ),
        SliverToBoxAdapter(
          child: SizedBox(
            height: 240,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemBuilder: (_, i) => PlaylistCard(
                playlist: library.playlists[i],
                onTap: () {
                  Navigator.of(context).pushNamed('/playlist',
                      arguments: library.playlists[i]);
                },
              ),
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemCount: library.playlists.length,
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: _SectionTitle('Tendencias'),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (_, i) {
              final song = SampleData.trendingSongs[i];
              return _TrendingTile(song: song, index: i + 1);
            },
            childCount: SampleData.trendingSongs.length,
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }

  void _playDailyMix(BuildContext context, LibraryProvider library) {
    final songs = SampleData.trendingSongs;
    context.read<AudioProvider>().setQueue(songs);
    library.addToRecentlyPlayed(songs.first);
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _TrendingTile extends StatelessWidget {
  final Song song;
  final int index;
  const _TrendingTile({required this.song, required this.index});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        children: [
          Text(
            '$index',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 24,
              fontWeight: FontWeight.w300,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Image.network(
                song.artworkUrl ?? '',
                width: 48,
                height: 48,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 48,
                  height: 48,
                  color: AppColors.darkCard,
                  child: const Icon(Icons.music_note, color: Colors.white54),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 4,
            child: GestureDetector(
              onTap: () {
                context.read<AudioProvider>().playSong(
                      song,
                      contextList: SampleData.trendingSongs,
                    );
                context.read<LibraryProvider>().addToRecentlyPlayed(song);
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    song.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    song.artist,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Icon(Icons.more_horiz, color: AppColors.textSecondary),
          const SizedBox(width: 8),
        ],
      ),
    );
  }
}
