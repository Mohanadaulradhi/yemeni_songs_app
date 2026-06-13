import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../domain/cubits/content/content_cubit.dart';
import '../../../domain/cubits/content/content_state.dart';
import '../../../widgets/song_card.dart';

class ExploreScreen extends StatelessWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<ContentCubit>().state;
    final selectedGenre = state.selectedGenre;

    return Scaffold(
      appBar: AppBar(
        title: const Text('استكشف الأغاني'),
        actions: [
          IconButton(
            icon: const Icon(Icons.card_giftcard_outlined),
            onPressed: () => context.go('/plans'),
            tooltip: 'الاشتراك',
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              itemCount: AppConstants.genres.length,
              itemBuilder: (context, index) {
                final genre = AppConstants.genres[index];
                final isSelected = selectedGenre == genre;
                return Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: ChoiceChip(
                    label: Text(genre),
                    selected: isSelected,
                    onSelected: (sel) {
                      if (sel) {
                        context.read<ContentCubit>().filterByGenre(genre);
                      } else {
                        context.read<ContentCubit>().loadSongs();
                      }
                    },
                    selectedColor: AppTheme.primaryGreen,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : null,
                    ),
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: _buildSongsList(context, state),
          ),
        ],
      ),
    );
  }

  Widget _buildSongsList(BuildContext context, ContentState state) {
    if (state.status == ContentStatus.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.status == ContentStatus.error) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cloud_off, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            const Text('لا يوجد اتصال بالإنترنت'),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => context.read<ContentCubit>().loadSongs(),
              child: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      );
    }

    if (state.songs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.music_note, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            const Text('لا توجد أغانٍ بعد'),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: state.songs.length,
      itemBuilder: (context, index) {
        final song = state.songs[index];
        return SongCard(
          song: song,
          onTap: () => context.go('/song/${song.id}'),
        );
      },
    );
  }
}
