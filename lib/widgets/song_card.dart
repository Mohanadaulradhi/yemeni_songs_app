import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../data/models/song_model.dart';

class SongCard extends StatelessWidget {
  final SongModel song;
  final bool isOffline;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const SongCard({
    super.key,
    required this.song,
    this.isOffline = false,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        onTap: onTap,
        leading: Stack(
          children: [
            CircleAvatar(
              backgroundColor: AppTheme.primaryGreen.withValues(alpha: 0.1),
              child: Icon(
                song.isVideo ? Icons.videocam : Icons.music_note,
                color: AppTheme.primaryGreen,
              ),
            ),
            if (song.isPremium)
              Positioned(
                right: 0,
                child: Icon(
                  Icons.star,
                  size: 16,
                  color: AppTheme.accentGold,
                ),
              ),
          ],
        ),
        title: Text(
          song.title,
          style: const TextStyle(fontWeight: FontWeight.w500),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Row(
          children: [
            Text(
              song.artistName,
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
            const SizedBox(width: 8),
            Text(
              '•',
              style: TextStyle(color: Colors.grey[400]),
            ),
            const SizedBox(width: 8),
            Text(
              song.formattedDuration,
              style: TextStyle(color: Colors.grey[500], fontSize: 12),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isOffline)
              Icon(
                Icons.download_done,
                size: 18,
                color: AppTheme.primaryGreen,
              ),
            if (song.isPremium)
              const Padding(
                padding: EdgeInsets.only(left: 4),
                child: Icon(Icons.star, size: 14, color: AppTheme.accentGold),
              ),
            if (onDelete != null)
              IconButton(
                icon: Icon(Icons.delete_outline, size: 18),
                onPressed: onDelete,
              ),
          ],
        ),
      ),
    );
  }
}
