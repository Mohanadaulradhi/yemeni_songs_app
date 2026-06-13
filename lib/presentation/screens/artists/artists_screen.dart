import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/cubits/content/content_cubit.dart';
import '../../../domain/cubits/content/content_state.dart';
import '../../../widgets/artist_card.dart';

class ArtistsScreen extends StatelessWidget {
  const ArtistsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('الفنانين')),
      body: BlocBuilder<ContentCubit, ContentState>(
        builder: (context, state) {
          if (state.artists.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.person_search, size: 64, color: Colors.grey[400]),
                  SizedBox(height: 16),
                  Text('لا يوجد فنانين بعد'),
                ],
              ),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.85,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: state.artists.length,
            itemBuilder: (context, index) {
              return ArtistCard(artist: state.artists[index]);
            },
          );
        },
      ),
    );
  }
}
