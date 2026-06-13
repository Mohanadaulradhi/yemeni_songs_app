import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../domain/cubits/content/content_cubit.dart';
import '../../../domain/cubits/content/content_state.dart';
import '../../../widgets/song_card.dart';

class OfflineScreen extends StatelessWidget {
  const OfflineScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الأغاني المنزلة'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () => context.read<ContentCubit>().loadOfflineSongs(),
            tooltip: 'تحديث',
          ),
        ],
      ),
      body: BlocBuilder<ContentCubit, ContentState>(
        builder: (context, state) {
          final offlineSongs = state.offlineSongs;

          if (offlineSongs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.download_done, size: 80, color: Colors.grey[400]),
                  SizedBox(height: 16),
                  Text(
                    'لا توجد أغانٍ منزلة',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'قم بتنزيل الأغاني للاستماع بدون إنترنت',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => context.go('/home'),
                    icon: Icon(Icons.explore),
                    label: Text('استكشف الأغاني'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: offlineSongs.length,
            itemBuilder: (context, index) {
              final song = offlineSongs[index];
              return SongCard(
                song: song,
                isOffline: true,
                onTap: () => context.go('/song/${song.id}'),
                onDelete: () {
                  context.read<ContentCubit>().removeDownload(song.id);
                },
              );
            },
          );
        },
      ),
    );
  }
}
