import 'package:hangul_choseong_search/hangul_choseong_search.dart';
import 'package:test/test.dart';

void main() {
  group('filterByChoseong preserved behavior', () {
    test('matches a mixed choseong and ASCII query case-insensitively', () {
      // Given
      final items = ['사과Apple', '사과banana', '수박Alpha'];

      // When
      final result = filterByChoseong(items, 'ㅅㄱa');

      // Then
      expect(result, ['사과Apple']);
    });

    test('preserves source order and duplicate values', () {
      // Given
      final items = ['나비', '가방', '가구', '가방', '다리'];

      // When
      final result = filterByChoseong(items, 'ㄱ');

      // Then
      expect(result, ['가방', '가구', '가방']);
      expect(identical(result, items), isFalse);
      expect(() => result.add('고기'), returnsNormally);
    });

    test('distinguishes doubled initial consonants', () {
      // Given
      final items = ['가', '까', '다', '따', '사', '싸'];

      // When
      final singleResults = filterByChoseong(items, 'ㄱ');
      final doubledResults = filterByChoseong(items, 'ㄲ');

      // Then
      expect(singleResults, ['가']);
      expect(doubledResults, ['까']);
    });

    test('treats whitespace as a significant contiguous character', () {
      // Given
      final items = ['김 치', '김치', '김  치'];

      // When
      final result = filterByChoseong(items, 'ㄱ ㅊ');

      // Then
      expect(result, ['김 치']);
    });

    test('treats punctuation as a significant contiguous character', () {
      // Given
      final items = ['김-치', '김치', '김_치'];

      // When
      final result = filterByChoseong(items, 'ㄱ-ㅊ');

      // Then
      expect(result, ['김-치']);
    });

    group('corrected matching semantics', () {
      const items = ['라면', '리모컨', '로마', '사과Apple'];

      test('treats a complete modern Hangul syllable as literal', () {
        expect(filterByChoseong(items, '라'), ['라면']);
      });

      test('treats a standalone choseong as an initial wildcard', () {
        expect(filterByChoseong(items, 'ㄹ'), ['라면', '리모컨', '로마']);
      });

      test('matches contiguous mixed literal syllable and choseong units', () {
        expect(filterByChoseong(items, '라ㅁ'), ['라면']);
      });

      test('matches contiguous choseong and ASCII case-insensitively', () {
        expect(filterByChoseong(items, 'ㅅㄱa'), ['사과Apple']);
      });

      test('returns a fresh growable list for an empty query', () {
        final source = ['라면'];

        final result = filterByChoseong(source, '');

        expect(result, source);
        expect(identical(result, source), isFalse);
        expect(() => result.add('로마'), returnsNormally);
        expect(source, ['라면']);
      });

      test('matches equivalent normalized modern Hangul spellings', () {
        const equivalentRamyeon = [
          '라면',
          '라면',
          'ㄹㅏㅁㅕㄴ',
          'ﾩￂﾱￆﾤ',
        ];

        for (final query in ['라', '라', 'ㄹㅏ', 'ﾩￂ']) {
          expect(filterByChoseong(equivalentRamyeon, query), equivalentRamyeon);
        }
      });
    });
  });
}
