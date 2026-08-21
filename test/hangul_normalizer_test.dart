import 'package:hangul_choseong_search/src/hangul_normalizer.dart';
import 'package:test/test.dart';

void main() {
  group('modern Hangul unit normalization', () {
    test('normalizes equivalent spellings of ga to one syllable unit', () {
      const spellings = ['가', '가', 'ㄱㅏ', 'ﾡￂ'];

      for (final spelling in spellings) {
        expect(
          normalizeHangulUnits(spelling),
          const [ModernSyllableUnit(0xac00, 0)],
          reason: spelling.runes
              .map((rune) => 'U+${rune.toRadixString(16).toUpperCase()}')
              .join(' '),
        );
      }
    });

    test('normalizes the precomposed Hangul boundaries', () {
      expect(
        normalizeHangulUnits('\u{ac00}\u{d7a3}'),
        const [
          ModernSyllableUnit(0xac00, 0),
          ModernSyllableUnit(0xd7a3, 18),
        ],
      );
    });

    test('maps all modern leading consonant forms including doubles', () {
      const compatibility = 'ㄱㄲㄴㄷㄸㄹㅁㅂㅃㅅㅆㅇㅈㅉㅊㅋㅌㅍㅎ';
      const conjoining = 'ᄀᄁᄂᄃᄄᄅᄆᄇᄈᄉᄊᄋᄌᄍᄎᄏᄐᄑᄒ';
      const halfwidth = 'ﾡﾢﾤﾧﾨﾩﾱﾲﾳﾵﾶﾷﾸﾹﾺﾻﾼﾽﾾ';
      final expected = [
        for (var index = 0; index < 19; index++) ModernInitialUnit(index),
      ];

      expect(normalizeHangulUnits(compatibility), expected);
      expect(normalizeHangulUnits(conjoining), expected);
      expect(normalizeHangulUnits(halfwidth), expected);
    });

    test('maps all 21 modern vowels in every supported form', () {
      const compatibility = 'ㅏㅐㅑㅒㅓㅔㅕㅖㅗㅘㅙㅚㅛㅜㅝㅞㅟㅠㅡㅢㅣ';
      const conjoining = 'ᅡᅢᅣᅤᅥᅦᅧᅨᅩᅪᅫᅬᅭᅮᅯᅰᅱᅲᅳᅴᅵ';
      const halfwidth = 'ￂￃￄￅￆￇￊￋￌￍￎￏￒￓￔￕￖￗￚￛￜ';

      for (final vowels in [compatibility, conjoining, halfwidth]) {
        for (var index = 0; index < 21; index++) {
          expect(
            normalizeHangulUnits(
              'ㄱ${String.fromCharCode(vowels.runes.elementAt(index))}',
            ),
            [ModernSyllableUnit(0xac00 + index * 28, 0)],
          );
        }
      }
    });

    test('maps all 27 non-empty modern finals in every supported form', () {
      const compatibility = 'ㄱㄲㄳㄴㄵㄶㄷㄹㄺㄻㄼㄽㄾㄿㅀㅁㅂㅄㅅㅆㅇㅈㅊㅋㅌㅍㅎ';
      const conjoining = 'ᆨᆩᆪᆫᆬᆭᆮᆯᆰᆱᆲᆳᆴᆵᆶᆷᆸᆹᆺᆻᆼᆽᆾᆿᇀᇁᇂ';
      const halfwidth = 'ﾡﾢﾣﾤﾥﾦﾧﾩﾪﾫﾬﾭﾮﾯﾰﾱﾲﾴﾵﾶﾷﾸﾺﾻﾼﾽﾾ';

      for (final finals in [compatibility, conjoining, halfwidth]) {
        for (var index = 0; index < 27; index++) {
          expect(
            normalizeHangulUnits(
              'ㄱㅏ${String.fromCharCode(finals.runes.elementAt(index))}',
            ),
            [ModernSyllableUnit(0xac00 + index + 1, 0)],
          );
        }
      }
    });

    test('does not steal an ambiguous consonant from the next syllable', () {
      expect(
        normalizeHangulUnits('ㄱㅏㄴㅏ'),
        const [
          ModernSyllableUnit(0xac00, 0),
          ModernSyllableUnit(0xb098, 2),
        ],
      );
    });

    test('keeps incomplete, invalid, and archaic input literal or standalone',
        () {
      final highSurrogate = String.fromCharCode(0xd800);
      final lowSurrogate = String.fromCharCode(0xdc00);
      final input = 'ㄳᄔᅡㅏㄱㅏㄱㅅ${highSurrogate}x$lowSurrogate';

      expect(
        normalizeHangulUnits(input),
        const [
          LiteralScalarUnit(0x3133),
          LiteralScalarUnit(0x1114),
          LiteralScalarUnit(0x1161),
          LiteralScalarUnit(0x314f),
          ModernSyllableUnit(0xac01, 0),
          ModernInitialUnit(9),
          LiteralScalarUnit(0xd800),
          LiteralScalarUnit(0x78),
          LiteralScalarUnit(0xdc00),
        ],
      );
    });

    test('folds only ASCII uppercase and preserves supplementary scalars', () {
      expect(
        normalizeHangulUnits('AZÄİ😀'),
        const [
          LiteralScalarUnit(0x61),
          LiteralScalarUnit(0x7a),
          LiteralScalarUnit(0xc4),
          LiteralScalarUnit(0x130),
          LiteralScalarUnit(0x1f600),
        ],
      );
    });
  });
}
