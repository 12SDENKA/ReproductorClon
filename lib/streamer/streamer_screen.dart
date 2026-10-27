import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/song.dart';
import '../providers/audio_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/mini_player.dart';
import 'streamer_provider.dart';

class StreamerScreen extends StatefulWidget {
  const StreamerScreen({super.key, this.initialGenre, this.focusSearch = false});

  final String? initialGenre;
  final bool focusSearch;

  @override
  State<StreamerScreen> createState() => _StreamerScreenState();
}

class _StreamerScreenState extends State<StreamerScreen> {
  final _ctrl = TextEditingController();
  StreamSubscription? _errSub;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final sp = context.read<StreamerProvider>();
      if (widget.initialGenre != null) {
        sp.selectGenre(widget.initialGenre!);
      } else {
        sp.init();
      }
    });
    // Avisa en pantalla cuando una canción no se puede reproducir.
    _errSub = context
        .read<AudioProvider>()
        .player
        .playbackEventStream
        .listen((_) {}, onError: (Object e, StackTrace st) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(
            'No se pudo reproducir esa canción. Prueba otra o cambia de fuente.'),
      ));
    });
  }

  @override
  void dispose() {
    _errSub?.cancel();
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final streamer = context.watch<StreamerProvider>();
    final audio = context.watch<AudioProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.initialGenre ?? 'Streaming en vivo'),
        actions: [
          IconButton(
            tooltip: 'Recargar',
            icon: const Icon(Icons.refresh),
            onPressed: streamer.loading ? null : streamer.reload,
          ),
        ],
      ),
      bottomNavigationBar: const SafeArea(child: MiniPlayer()),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: TextField(
              controller: _ctrl,
              autofocus: widget.focusSearch,
              onChanged: streamer.onQueryChanged,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'Buscar canción o artista',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: AppColors.darkSurface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          // Fuente: iTunes (30 s, muy fiable) o Audius (completa)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                ChoiceChip(
                  label: const Text('iTunes · 30 s'),
                  selected: streamer.source == StreamSource.itunes,
                  onSelected: (_) => streamer.setSource(StreamSource.itunes),
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('Audius · completa'),
                  selected: streamer.source == StreamSource.audius,
                  onSelected: (_) => streamer.setSource(StreamSource.audius),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 52,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              children: [
                for (final g in kStreamGenres.keys)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(g),
                      selected: streamer.genre == g,
                      onSelected: (_) {
                        _ctrl.clear();
                        streamer.selectGenre(g);
                      },
                    ),
                  ),
              ],
            ),
          ),
          if (streamer.loading) const LinearProgressIndicator(minHeight: 2),
          if (streamer.error != null)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(streamer.error!,
                  style: const TextStyle(color: AppColors.textSecondary)),
            ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: streamer.reload,
              child: ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: streamer.results.length,
                itemBuilder: (_, i) {
                  final song = streamer.results[i];
                  final isCurrent = audio.currentSong?.id == song.id;
                  return _StreamTile(
                    song: song,
                    isCurrent: isCurrent,
                    isPlaying: isCurrent && audio.isPlaying,
                    onTap: () =>
                        audio.playSong(song, contextList: streamer.results),
                  );
                },
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(8),
            child: Text('Fuentes: iTunes y Audius · crédito a los artistas',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
          ),
        ],
      ),
    );
  }
}

class _StreamTile extends StatelessWidget {
  const _StreamTile({
    required this.song,
    required this.isCurrent,
    required this.isPlaying,
    required this.onTap,
  });

  final Song song;
  final bool isCurrent;
  final bool isPlaying;
  final VoidCallback onTap;

  String _fmt(Duration d) =>
      '${d.inMinutes}:${(d.inSeconds % 60).toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: SizedBox(
          width: 48,
          height: 48,
          child: song.artworkUrl == null
              ? const ColoredBox(color: AppColors.darkCard)
              : Image.network(song.artworkUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      const ColoredBox(color: AppColors.darkCard)),
        ),
      ),
      title: Text(song.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(color: isCurrent ? AppColors.accent : null)),
      subtitle: Text(song.artist,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: AppColors.textSecondary)),
      trailing: isCurrent
          ? Icon(isPlaying ? Icons.graphic_eq : Icons.pause,
              color: AppColors.accent)
          : Text(_fmt(song.duration),
              style: const TextStyle(color: AppColors.textSecondary)),
    );
  }
}
