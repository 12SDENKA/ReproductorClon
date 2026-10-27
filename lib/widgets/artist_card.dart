import 'package:flutter/material.dart';

import '../models/artist.dart';
import '../theme/app_theme.dart';

class ArtistCard extends StatelessWidget {
  final Artist artist;
  final VoidCallback onTap;
  final double size;

  const ArtistCard({
    super.key,
    required this.artist,
    required this.onTap,
    this.size = 120,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: size,
        child: Column(
          children: [
            ClipOval(
              child: Image.network(
                artist.imageUrl ?? '',
                width: size,
                height: size,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: size,
                  height: size,
                  color: AppColors.darkCard,
                  child: const Icon(Icons.person,
                      color: Colors.white54, size: 40),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              artist.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (artist.genre != null) ...[
              const SizedBox(height: 2),
              Text(
                artist.genre!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}