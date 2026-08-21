import 'package:hangul_choseong_search/hangul_choseong_search.dart';
import 'package:test/test.dart';

void main() {
  group('getChoseong preserved behavior', () {
    test('extracts all 19 initial consonants at their syllable boundaries', () {
      // Given
      const initials = [
        'ㄱ',
        'ㄲ',
        'ㄴ',
        'ㄷ',
        'ㄸ',
        'ㄹ',
        'ㅁ',
        'ㅂ',
        'ㅃ',
        'ㅅ',
        'ㅆ',
        'ㅇ',
        'ㅈ',
        'ㅉ',
        'ㅊ',
        'ㅋ',
        'ㅌ',
        'ㅍ',
        'ㅎ',
      ];
      final boundarySyllables = [
        for (var index = 0; index < initials.length; index++) ...[
          String.fromCharCode(0xac00 + index * 21 * 28),
          String.fromCharCode(0xac00 + index * 21 * 28 + 21 * 28 - 1),
        ],
      ].join();

      // When
      final result = getChoseong(boundarySyllables);

      // Then
      expect(result, initials.expand((initial) => [initial, initial]).join());
    });

    test('keeps doubled initials distinct', () {
      // Given
      const text = '가까나다따라마바빠사싸아자짜차카타파하';

      // When
      final result = getChoseong(text);

      // Then
      expect(result, 'ㄱㄲㄴㄷㄸㄹㅁㅂㅃㅅㅆㅇㅈㅉㅊㅋㅌㅍㅎ');
    });

    test('lowercases ASCII while preserving whitespace and punctuation', () {
      // Given
      const text = 'A B-C!';

      // When
      final result = getChoseong(text);

      // Then
      expect(result, 'a b-c!');
    });

    test('extracts equivalent initials from all modern Hangul forms', () {
      // Given
      const text = '가가ㄱㅏﾡￂ';

      // When
      final result = getChoseong(text);

      // Then
      expect(result, 'ㄱㄱㄱㄱ');
    });

    test('extracts all standalone modern leading forms', () {
      // Given
      const compatibility = 'ㄱㄲㄴㄷㄸㄹㅁㅂㅃㅅㅆㅇㅈㅉㅊㅋㅌㅍㅎ';
      const conjoining = 'ᄀᄁᄂᄃᄄᄅᄆᄇᄈᄉᄊᄋᄌᄍᄎᄏᄐᄑᄒ';
      const halfwidth = 'ﾡﾢﾤﾧﾨﾩﾱﾲﾳﾵﾶﾷﾸﾹﾺﾻﾼﾽﾾ';

      // When / Then
      expect(getChoseong(conjoining), compatibility);
      expect(getChoseong(halfwidth), compatibility);
    });

    test('folds only ASCII and preserves non-Hangul scalar values', () {
      // Given
      const text = 'AZÄİ😀';

      // When
      final result = getChoseong(text);

      // Then
      expect(result, 'azÄİ😀');
    });

    test('does not throw or broaden invalid and incomplete sequences', () {
      // Given
      final text = 'ㄳᄔᅡㄱㅏㄱㅅ${String.fromCharCode(0xd800)}';

      // When
      final result = getChoseong(text);

      // Then
      expect(result, 'ㄳᄔᅡㄱㅅ${String.fromCharCode(0xd800)}');
    });
  });
}

// Non-ASCII case folding intentionally changes in 0.1.0.
