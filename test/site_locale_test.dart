import 'package:test/test.dart';

import '../site/site_locale.dart';

void main() {
  group('resolveSiteLocale', () {
    test('saved selection takes priority over browser language', () {
      expect(
        resolveSiteLocale(savedLocale: 'en', browserLanguage: 'ko-KR'),
        SiteLocale.en,
      );
      expect(
        resolveSiteLocale(savedLocale: 'ko', browserLanguage: 'en-US'),
        SiteLocale.ko,
      );
    });

    test('browser language is used without a saved selection', () {
      expect(
        resolveSiteLocale(savedLocale: null, browserLanguage: 'ko-KR'),
        SiteLocale.ko,
      );
      expect(
        resolveSiteLocale(savedLocale: null, browserLanguage: 'en-US'),
        SiteLocale.en,
      );
    });

    test('invalid saved selection falls back to browser language', () {
      expect(
        resolveSiteLocale(savedLocale: 'ja', browserLanguage: 'ko-KR'),
        SiteLocale.ko,
      );
    });
  });
}
