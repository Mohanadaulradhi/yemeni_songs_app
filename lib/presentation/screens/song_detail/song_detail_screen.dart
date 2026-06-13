import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/song_model.dart';
import '../../../domain/cubits/content/content_cubit.dart';
import '../../../domain/cubits/player/player_cubit.dart';
import '../../../domain/cubits/player/player_state.dart';
import '../../../domain/cubits/auth/auth_cubit.dart';

class SongDetailScreen extends StatefulWidget {
  final String songId;

  const SongDetailScreen({super.key, required this.songId});

  @override
  State<SongDetailScreen> createState() => _SongDetailScreenState();
}

class _SongDetailScreenState extends State<SongDetailScreen> {
  SongModel? _song;
  bool _isLoading = true;
  bool _isDownloaded = false;
  bool _isDownloading = false;

  @override
  void initState() {
    super.initState();
    _loadSong();
  }

  Future<void> _loadSong() async {
    final contentCubit = context.read<ContentCubit>();
    final state = contentCubit.state;

    _song = state.songs.where((s) => s.id == widget.songId).firstOrNull
        ?? state.offlineSongs.where((s) => s.id == widget.songId).firstOrNull;

    if (_song == null) {
      _song = await contentCubit.getSongDetail(widget.songId);
    }

    _isDownloaded = _song != null
        && await contentCubit.isDownloaded(widget.songId);
    setState(() => _isLoading = false);
  }

  Future<void> _toggleDownload() async {
    if (_isDownloaded) {
      await context.read<ContentCubit>().removeDownload(widget.songId);
      setState(() => _isDownloaded = false);
    } else {
      setState(() => _isDownloading = true);
      await context.read<ContentCubit>().downloadSong(
        url: _song!.audioUrl,
        songId: widget.songId,
        fileName: '${_song!.title}.mp3',
      );
      setState(() {
        _isDownloading = false;
        _isDownloaded = true;
      });
    }
  }

  Future<void> _playSong() async {
    final playerCubit = context.read<PlayerCubit>();
    final localPath = context.read<ContentCubit>().getLocalPath(widget.songId);

    if (localPath != null) {
      await playerCubit.playSong(_song!, isOffline: true, localPath: localPath);
    } else {
      await playerCubit.playSong(_song!);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        appBar: null,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_song == null || _song!.id.isEmpty) {
      return const Scaffold(
        appBar: null,
        body: Center(child: Text('الأغنية غير موجودة')),
      );
    }

    final isPremium = _song!.isPremium;
    final authState = context.watch<AuthCubit>().state;
    final isUserPremium = authState.user?.isPremium ?? false;
    final isLocked = isPremium && !isUserPremium;

    return Scaffold(
      appBar: AppBar(
        title: Text(_song!.title),
        actions: [
          if (isLocked)
            IconButton(
              icon: Icon(Icons.lock_outline, color: AppTheme.accentGold),
              onPressed: () => context.go('/plans'),
              tooltip: 'اشترك للاستماع',
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Container(
                width: double.infinity,
                height: 250,
                color: AppTheme.primaryGreen.withValues(alpha: 0.1),
                child: const Center(
                  child: Icon(
                    Icons.music_note,
                    size: 80,
                    color: AppTheme.primaryGreen,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              _song!.title,
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              _song!.artistName,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Chip(label: Text(_song!.genre)),
                const SizedBox(width: 8),
                Chip(label: Text(_song!.formattedDuration)),
              ],
            ),
            const SizedBox(height: 32),
            if (isLocked)
              Column(
                children: [
                  const Icon(Icons.lock, size: 48, color: AppTheme.accentGold),
                  const SizedBox(height: 16),
                  Text(
                    'هذه الأغنية لمشتركينا فقط',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () => context.go('/plans'),
                    child: const Text('اشترك الآن'),
                  ),
                ],
              )
            else
              _buildPlayerControls(),
            const SizedBox(height: 24),
            if (!isLocked)
              _buildProgressBar(),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: _isDownloading ? null : _toggleDownload,
              icon: Icon(
                _isDownloaded
                    ? Icons.delete_outline
                    : _isDownloading
                        ? Icons.hourglass_top
                        : Icons.download_outlined,
              ),
              label: Text(
                _isDownloaded
                    ? 'حذف من الجهاز'
                    : _isDownloading
                        ? 'جاري التحميل...'
                        : 'تحميل للاستماع بدون نت',
              ),
            ),
            if (_song!.lyrics != null && _song!.lyrics!.isNotEmpty) ...[
              const SizedBox(height: 32),
              const Divider(),
              const SizedBox(height: 16),
              Text(
                'الكلمات',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              Text(
                _song!.lyrics!,
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPlayerControls() {
    final playerCubit = context.watch<PlayerCubit>();
    final playerState = playerCubit.state;
    final isPlaying = playerState.currentSong?.id == widget.songId &&
        playerState.status == PlayerStatus.playing;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          iconSize: 48,
          icon: const Icon(Icons.skip_previous),
          onPressed: () => context.read<PlayerCubit>().previous(),
        ),
        const SizedBox(width: 16),
        CircleAvatar(
          radius: 36,
          backgroundColor: AppTheme.primaryGreen,
          child: IconButton(
            iconSize: 36,
            icon: Icon(
              isPlaying ? Icons.pause : Icons.play_arrow,
              color: Colors.white,
            ),
            onPressed: () {
              if (isPlaying) {
                context.read<PlayerCubit>().togglePlayPause();
              } else {
                _playSong();
              }
            },
          ),
        ),
        const SizedBox(width: 16),
        IconButton(
          iconSize: 48,
          icon: const Icon(Icons.skip_next),
          onPressed: () => context.read<PlayerCubit>().next(),
        ),
      ],
    );
  }

  Widget _buildProgressBar() {
    final playerState = context.watch<PlayerCubit>().state;

    if (playerState.currentSong?.id != widget.songId) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: AppTheme.primaryGreen,
            thumbColor: AppTheme.primaryGreen,
          ),
          child: Slider(
            value: playerState.position.inSeconds.toDouble(),
            max: playerState.duration.inSeconds > 0
                ? playerState.duration.inSeconds.toDouble()
                : 1,
            onChanged: (value) {
              context.read<PlayerCubit>().seek(
                Duration(seconds: value.toInt()),
              );
            },
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(_formatDuration(playerState.position)),
            Text(_formatDuration(playerState.duration)),
          ],
        ),
      ],
    );
  }

  String _formatDuration(Duration d) {
    return '${d.inMinutes.toString().padLeft(2, '0')}:${(d.inSeconds % 60).toString().padLeft(2, '0')}';
  }
}
