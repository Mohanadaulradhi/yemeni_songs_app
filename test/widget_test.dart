import 'package:flutter_test/flutter_test.dart';
import 'package:yemeni_songs_app/data/models/song_model.dart';
import 'package:yemeni_songs_app/data/models/user_model.dart';
import 'package:yemeni_songs_app/data/models/subscription_model.dart';
import 'package:yemeni_songs_app/data/models/payment_model.dart';

void main() {
  group('SongModel', () {
    test('toJson and fromJson round-trip', () {
      final song = SongModel(
        id: '123',
        title: 'يا ليل',
        artistId: 'artist1',
        artistName: 'فنان',
        genre: 'صنعاني',
        audioUrl: 'https://example.com/song.mp3',
        durationSeconds: 240,
        isPremium: true,
        createdAt: DateTime(2024, 1, 1),
      );

      final json = song.toJson();
      final restored = SongModel.fromJson(json);

      expect(restored.id, song.id);
      expect(restored.title, song.title);
      expect(restored.artistName, song.artistName);
      expect(restored.isPremium, song.isPremium);
      expect(restored.durationSeconds, song.durationSeconds);
    });

    test('formattedDuration returns correct format', () {
      final song = SongModel(
        id: '1',
        title: 'test',
        artistId: 'a1',
        artistName: 'artist',
        genre: 'genre',
        audioUrl: 'url',
        durationSeconds: 305,
        createdAt: DateTime.now(),
      );

      expect(song.formattedDuration, '05:05');
    });
  });

  group('UserModel', () {
    test('hasActiveSubscription returns correct value', () {
      final expiredUser = UserModel(
        id: '1',
        email: 'test@test.com',
        name: 'Test',
        subscriptionExpiry: DateTime(2020, 1, 1),
        createdAt: DateTime.now(),
      );

      expect(expiredUser.hasActiveSubscription, false);

      final activeUser = UserModel(
        id: '2',
        email: 'test2@test.com',
        name: 'Test2',
        subscriptionExpiry: DateTime.now().add(const Duration(days: 30)),
        createdAt: DateTime.now(),
      );

      expect(activeUser.hasActiveSubscription, true);
    });
  });

  group('SubscriptionPlan', () {
    test('tier parsing works', () {
      final json = {
        'name': 'مميز',
        'description': 'تجربة كاملة',
        'price': 7000,
        'durationDays': 30,
        'tier': 'premium',
        'features': ['فيديو', 'جودة عالية'],
        'isActive': true,
      };

      final plan = SubscriptionPlan.fromJson(json);
      expect(plan.tier, SubscriptionTier.premium);
      expect(plan.price, 7000.0);
    });
  });

  group('PaymentModel', () {
    test('isSuccess returns correct value', () {
      final completed = PaymentModel(
        id: '1',
        userId: 'u1',
        subscriptionPlanId: 'p1',
        amount: 3000,
        gateway: PaymentGateway.kuraimi,
        status: PaymentStatus.completed,
        createdAt: DateTime.now(),
      );

      expect(completed.isSuccess, true);

      final failed = PaymentModel(
        id: '2',
        userId: 'u1',
        subscriptionPlanId: 'p1',
        amount: 3000,
        gateway: PaymentGateway.kuraimi,
        status: PaymentStatus.failed,
        createdAt: DateTime.now(),
      );

      expect(failed.isSuccess, false);
    });
  });
}
