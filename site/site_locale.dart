enum SiteLocale {
  ko,
  en;

  String get code => name;
}

SiteLocale resolveSiteLocale({
  required String? savedLocale,
  required String browserLanguage,
}) {
  final saved = SiteLocale.values.where(
    (locale) => locale.code == savedLocale,
  );
  if (saved.isNotEmpty) {
    return saved.first;
  }

  return browserLanguage.toLowerCase().startsWith('ko')
      ? SiteLocale.ko
      : SiteLocale.en;
}
