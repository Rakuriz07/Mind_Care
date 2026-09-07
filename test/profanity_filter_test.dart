import 'package:flutter_test/flutter_test.dart';
import 'package:mindcare/constants/profanity_filter.dart';

void main() {
  group('ProfanityFilter Unit Tests', () {
    test('Detects Indonesian bad words accurately', () {
      expect(ProfanityFilter.containsProfanity('Halo, kamu anjing banget'), isTrue);
      expect(ProfanityFilter.containsProfanity('Dasar goblok!'), isTrue);
      expect(ProfanityFilter.containsProfanity('Jangan babi ya'), isTrue);
    });

    test('Detects English bad words accurately', () {
      expect(ProfanityFilter.containsProfanity('What the fuck is this'), isTrue);
      expect(ProfanityFilter.containsProfanity('You are a bitch'), isTrue);
    });

    test('Detects obfuscated bad words (@, 0, 1, \$, etc.)', () {
      expect(ProfanityFilter.containsProfanity('Dasar g0bl0k!'), isTrue);
      expect(ProfanityFilter.containsProfanity('Dasar t0l0l!'), isTrue);
      expect(ProfanityFilter.containsProfanity('b@bi'), isTrue);
    });

    test('Allows polite community posts and comments', () {
      expect(ProfanityFilter.containsProfanity('Saya sedang merasa cemas dengan ujian semester ini'), isFalse);
      expect(ProfanityFilter.containsProfanity('Tetap semangat kawan, kamu pasti bisa melewati ini! ❤️'), isFalse);
      expect(ProfanityFilter.containsProfanity('Terima kasih dukungannya semua.'), isFalse);
    });

    test('Censors bad words correctly with asterisks', () {
      final text = 'Kamu goblok banget';
      final censored = ProfanityFilter.censorText(text);
      expect(censored, equals('Kamu ****** banget'));
    });
  });
}
