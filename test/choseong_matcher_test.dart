import 'package:hangul_choseong_search/src/choseong_matcher.dart';
import 'package:test/test.dart';

void main() {
  group('choseong matcher', () {
    test('matches syllables literally and initials as exact wildcards', () {
      expect(matchesChoseong('라면', '라'), isTrue);
      expect(matchesChoseong('리모컨', '라'), isFalse);
      expect(matchesChoseong('라면', 'ㄹ'), isTrue);
      expect(matchesChoseong('리모컨', 'ㄹ'), isTrue);
      expect(matchesChoseong('까', 'ㄱ'), isFalse);
      expect(matchesChoseong('가', 'ㄲ'), isFalse);
    });

    test('matches equivalent standalone initial forms', () {
      for (final query in ['ㄹ', 'ᄅ', 'ﾩ']) {
        expect(matchesChoseong('라', query), isTrue);
        expect(matchesChoseong('ㄹ', query), isTrue);
        expect(matchesChoseong('ᄅ', query), isTrue);
        expect(matchesChoseong('ﾩ', query), isTrue);
      }
    });

    test('matches equivalent complete modern syllable forms', () {
      const spellings = ['가', '가', 'ㄱㅏ', 'ﾡￂ'];

      for (final candidate in spellings) {
        for (final query in spellings) {
          expect(matchesChoseong(candidate, query), isTrue);
        }
      }
    });

    test('requires every query unit to be contiguous and significant', () {
      expect(matchesChoseong('사과Apple', 'ㅅㄱa'), isTrue);
      expect(matchesChoseong('사과 Apple', 'ㅅㄱa'), isFalse);
      expect(matchesChoseong('김 치', 'ㄱ ㅊ'), isTrue);
      expect(matchesChoseong('김치', 'ㄱ ㅊ'), isFalse);
      expect(matchesChoseong('김-치', 'ㄱ-ㅊ'), isTrue);
      expect(matchesChoseong('김_치', 'ㄱ-ㅊ'), isFalse);
    });

    test('folds ASCII case only and compares every other unit literally', () {
      expect(matchesChoseong('Apple 12😀', 'aPPle 12😀'), isTrue);
      expect(matchesChoseong('Straße', 'strasse'), isFalse);
      expect(matchesChoseong('ＡＢＣ', 'abc'), isFalse);
      expect(matchesChoseong('Ä', 'ä'), isFalse);
    });

    test('matches an empty query without special-casing candidate text', () {
      expect(matchesChoseong('', ''), isTrue);
      expect(matchesChoseong('라면', ''), isTrue);
      expect(matchesChoseong('', 'ㄹ'), isFalse);
    });
  });
}
