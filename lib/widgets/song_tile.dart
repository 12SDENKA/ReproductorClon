import 'package:flutter/material.dart';

import '../models/song.dart';
import '../theme/app_theme.dart';

class SongTile extends StatelessWidget {
  final Song song;
  final int? index;
  final VoidCallback onTap;
  final VoidCallback? onMore;
  final bool isPlaying;

  const SongTile({
    super.key,
    required this.song,
    required this.onTap,
    this.index,
    this.onMore,
    this.isPlaying = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              if (index != null)
                SizedBox(
                  width: 28,
                  child: Text(
                    '$index',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: isPlaying
                          ? AppColors.accent
                          : AppColors.textSecondary,
                      fontSize: 14,
                      fontWeight:
                          isPlaying ? FontWeight.w700 : FontWeight.w400,
                    ),
                  ),
                ),
              if (index == null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Image.network(
                    song.artworkUrl ?? '',
                    width: 44,
                    height: 44,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 44,
                      height: 44,
                      color: AppColors.darkCard,
                      child: const Icon(Icons.music_note,
                          color: Colors.white54, size: 20),
                    ),
                  ),
                ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      song.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: isPlaying ? AppColors.accent : Colors.white,
                        fontSize: 15,
                        fontWeight:
                            isPlaying ? FontWeight.w700 : FontWeight.w500,
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
              Text(
                _formatDuration(song.duration),
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
              if (onMore != null)
                IconButton(
                  icon: const Icon(Icons.more_horiz,
                      color: AppColors.textSecondary),
                  onPressed: onMore,
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDuration(Duration d) {
    final m = d.inMinutes;
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }
}