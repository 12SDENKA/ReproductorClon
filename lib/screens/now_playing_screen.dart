import 'package:flutter/material.dart' hide RepeatMode;
import 'package:provider/provider.dart';

import '../providers/audio_provider.dart';
import '../providers/library_provider.dart';
import '../theme/app_theme.dart';

class NowPlayingScreen extends StatelessWidget {
  const NowPlayingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final audio = context.watch<AudioProvider>();
    final library = context.watch<LibraryProvider>();
    final song = audio.currentSong;

    if (song == null) {
      return const Scaffold(
        backgroundColor: AppColors.darkBg,
        body: Center(child: Text('No hay canción')),
      );
    }

    final liked = library.isLiked(song);

    return Scaffold(
      backgroundColor: AppColors.darkBg,
      body: SafeArea(
        child: Column(
          children: [
            _Header(),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AspectRatio(
                      aspectRatio: 1,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          song.artworkUrl ?? '',
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: AppColors.darkCard,
                            child: const Icon(Icons.music_note,
                                color: Colors.white54, size: 80),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                song.title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                song.artist,
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            liked ? Icons.favorite : Icons.favorite_border,
                            color: liked ? AppColors.accent : Colors.white,
                            size: 28,
                          ),
                          onPressed: () => library.toggleLike(song),
                        ),
                        IconButton(
                          icon: Icon(
                            library.isDownloaded(song.id)
                                ? Icons.download_done
                                : Icons.download_outlined,
                            color: library.isDownloaded(song.id)
                                ? AppColors.accent
                                : Colors.white,
                          ),
                          onPressed: () => library.toggleDownload(song.id),
                        ),
                        const Icon(Icons.more_horiz,
                            color: AppColors.textSecondary),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _ProgressBar(),
                    const SizedBox(height: 16),
                    _Controls(audio: audio),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _CircleButton(
                          icon: Icons.shuffle,
                          active: audio.isShuffle,
                          onTap: audio.toggleShuffle,
                        ),
                        _CircleButton(
                          icon: Icons.equalizer,
                          onTap: () {},
                        ),
                        _CircleButton(
                          icon: Icons.repeat,
                          active: audio.repeatMode != RepeatMode.off,
                          onTap: audio.cycleRepeat,
                          badge: audio.repeatMode == RepeatMode.one ? '1' : null,
                        ),
                      ],
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.cast, color: Colors.white, size: 18),
                          SizedBox(width: 6),
                          Text('AirPlay y dispositivos',
                              style: TextStyle(color: Colors.white)),
                          SizedBox(width: 6),
                          Icon(Icons.chevron_right,
                              color: Colors.white, size: 18),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.keyboard_arrow_down, size: 32),
            onPressed: () => Navigator.of(context).pop(),
          ),
          const Spacer(),
          Column(
            children: const [
              Text('REPRODUCIENDO DEL ÁLBUM',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 10,
                    letterSpacing: 1,
                  )),
              Text('Mezcla diaria',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  )),
            ],
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.playlist_add),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final audio = context.watch<AudioProvider>();
    return StreamBuilder<Duration>(
      stream: audio.positionStream,
      builder: (_, snapPos) {
        return StreamBuilder<Duration?>(
          stream: audio.durationStream,
          builder: (_, snapDur) {
            final pos = snapPos.data ?? Duration.zero;
            final dur = snapDur.data ??
                context.read<AudioProvider>().currentSong?.duration ??
                Duration.zero;
            return Column(
              children: [
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 4,
                    thumbShape:
                        const RoundSliderThumbShape(enabledThumbRadius: 6),
                  ),
                  child: Slider(
                    value: pos.inMilliseconds
                        .clamp(0, dur.inMilliseconds)
                        .toDouble(),
                    min: 0,
                    max: dur.inMilliseconds == 0
                        ? 1
                        : dur.inMilliseconds.toDouble(),
                    onChanged: (v) {
                      audio.seek(Duration(milliseconds: v.toInt()));
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(_format(pos),
                          style: const TextStyle(
                              color: AppColors.textSecondary, fontSize: 11)),
                      Text(
                        '-${_format(dur - pos)}',
                        style: const TextStyle(
                            color: AppColors.textSecondary, fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  String _format(Duration d) {
    final m = d.inMinutes;
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }
}

class _Controls extends StatelessWidget {
  final AudioProvider audio;
  const _Controls({required this.audio});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        IconButton(
          icon: const Icon(Icons.skip_previous,
              color: Colors.white, size: 40),
          onPressed: audio.previous,
        ),
        GestureDetector(
          onTap: audio.togglePlayPause,
          child: Container(
            width: 70,
            height: 70,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(
              audio.isPlaying ? Icons.pause : Icons.play_arrow,
              color: AppColors.darkBg,
              size: 40,
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.skip_next, color: Colors.white, size: 40),
          onPressed: audio.next,
        ),
      ],
    );
  }
}

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool active;
  final String? badge;

  const _CircleButton({
    required this.icon,
    required this.onTap,
    this.active = false,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: active
              ? Colors.white.withOpacity(0.15)
              : Colors.white.withOpacity(0.05),
          shape: BoxShape.circle,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(icon,
                color: active ? AppColors.accent : Colors.white, size: 22),
            if (badge != null)
              Positioned(
                top: 8,
                child: Text(badge!,
                    style: const TextStyle(
                      color: AppColors.accent,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                    )),
              ),
          ],
        ),
      ),
    );
  }
}
