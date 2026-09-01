import 'dart:js_interop';

import 'package:hangul_choseong_search/hangul_choseong_search.dart';
import 'package:web/web.dart' as web;

import 'site_locale.dart';

const _localeStorageKey = 'hangul-search-locale';
const _installCommand = 'dart pub add hangul_choseong_search';
const _quickStartCode = '''
import 'package:hangul_choseong_search/hangul_choseong_search.dart';

final names = ['김민수', '박서준', '이도현'];

final result = filterByChoseong(
  names,
  'ㄱㅁㅅ',
);

// [김민수]
print(result);
''';

const _items = [
  _SearchItem(
    '김민수',
    categoryKo: '연락처',
    categoryEn: 'Contact',
    descriptionKo: '디자인 팀 · 010-2849-1138',
    descriptionEn: 'Design team · 010-2849-1138',
    icon: '김',
  ),
  _SearchItem(
    '박서준',
    categoryKo: '연락처',
    categoryEn: 'Contact',
    descriptionKo: '개발 팀 · 010-5931-8420',
    descriptionEn: 'Development team · 010-5931-8420',
    icon: '박',
  ),
  _SearchItem(
    '이도현',
    categoryKo: '연락처',
    categoryEn: 'Contact',
    descriptionKo: '프로덕트 팀 · 010-7412-0098',
    descriptionEn: 'Product team · 010-7412-0098',
    icon: '이',
  ),
  _SearchItem(
    '성수 카페 오월',
    categoryKo: '장소',
    categoryEn: 'Place',
    descriptionKo: '서울 성동구 · 카페',
    descriptionEn: 'Seongdong-gu, Seoul · Cafe',
    icon: '오',
  ),
  _SearchItem(
    '사과Apple',
    categoryKo: '상품',
    categoryEn: 'Product',
    descriptionKo: '신선 식품 · 국내산',
    descriptionEn: 'Fresh food · Grown in Korea',
    icon: 'A',
  ),
  _SearchItem(
    '라면 연구소',
    categoryKo: '장소',
    categoryEn: 'Place',
    descriptionKo: '서울 마포구 · 음식점',
    descriptionEn: 'Mapo-gu, Seoul · Restaurant',
    icon: '라',
  ),
  _SearchItem(
    '리모컨',
    categoryKo: '상품',
    categoryEn: 'Product',
    descriptionKo: '생활 가전 · 액세서리',
    descriptionEn: 'Home appliances · Accessory',
    icon: '리',
  ),
  _SearchItem(
    '봄날의 기억',
    categoryKo: '음악',
    categoryEn: 'Music',
    descriptionKo: '윤하 · 재생 시간 03:42',
    descriptionEn: 'Younha · Duration 03:42',
    icon: '봄',
  ),
];

SiteLocale _currentLocale = SiteLocale.ko;

const _pageCopy = {
  SiteLocale.ko: {
    'title': 'Hangul Choseong Search — 초성 검색, 단 1줄로',
    'description':
        'Dart와 Flutter를 위한 빠르고 정확한 한글 초성 검색 패키지, hangul_choseong_search를 직접 체험해 보세요.',
    'ogDescription': '한글 검색의 시작을 더 가볍게. 실행 의존성 없는 순수 Dart 초성 검색.',
    'ogLocale': 'ko_KR',
    'ogLocaleAlternate': 'en_US',
    'localeSelector': '언어 선택',
    'resultsAll': '전체 데이터 · {count}개',
    'resultsQuery': '"{query}" 검색 결과 · {count}개',
    'emptyTitle': '일치하는 결과가 없어요.',
    'emptyHint': '다른 초성이나 완성형 단어로 검색해 보세요.',
    'copied': '완료',
    'copy': '복사',
  },
  SiteLocale.en: {
    'title': 'Hangul Choseong Search — Choseong search in one line',
    'description':
        'Try hangul_choseong_search, a fast and accurate Korean choseong search package for Dart and Flutter.',
    'ogDescription':
        'Make Korean search simpler with pure Dart choseong search and zero runtime dependencies.',
    'ogLocale': 'en_US',
    'ogLocaleAlternate': 'ko_KR',
    'localeSelector': 'Select language',
    'resultsAllOne': 'All data · 1 item',
    'resultsAllOther': 'All data · {count} items',
    'resultsQueryOne': '1 result for "{query}"',
    'resultsQueryOther': '{count} results for "{query}"',
    'emptyTitle': 'No matching results.',
    'emptyHint': 'Try different initial consonants or a complete Hangul word.',
    'copied': 'Copied',
    'copy': 'Copy',
  },
};

void main() {
  final input =
      web.document.querySelector('#search-input') as web.HTMLInputElement;
  final clearButton =
      web.document.querySelector('#clear-search') as web.HTMLButtonElement;
  final resultContainer =
      web.document.querySelector('#search-results') as web.HTMLDivElement;
  final resultStatus =
      web.document.querySelector('#results-status') as web.HTMLParagraphElement;
  final presetButtonNodes =
      web.document.querySelectorAll('.query-presets button');
  final presetButtons = [
    for (var index = 0; index < presetButtonNodes.length; index++)
      presetButtonNodes.item(index) as web.HTMLButtonElement,
  ];
  final localeButtonNodes =
      web.document.querySelectorAll('.locale-switcher button');
  final localeButtons = [
    for (var index = 0; index < localeButtonNodes.length; index++)
      localeButtonNodes.item(index) as web.HTMLButtonElement,
  ];

  void render(String query) {
    final results = filterByChoseongKey(
      _items,
      query,
      (item) => item.title,
    );

    while (resultContainer.firstChild != null) {
      resultContainer.removeChild(resultContainer.firstChild!);
    }
    resultStatus.textContent = _formatResultStatus(query, results.length);

    for (final button in presetButtons) {
      button.classList.toggle(
        'active',
        button.getAttribute('data-query') == query,
      );
    }

    if (results.isEmpty) {
      final empty = web.document.createElement('div') as web.HTMLDivElement
        ..className = 'empty-results';
      empty
        ..appendChild(
          _element('strong', text: _copy('emptyTitle')),
        )
        ..appendChild(
          _element('span', text: _copy('emptyHint')),
        );
      resultContainer.appendChild(empty);
      return;
    }

    for (var index = 0; index < results.length; index++) {
      final item = results[index];
      final card = web.document.createElement('div') as web.HTMLDivElement
        ..className = 'result-card'
        ..style.animationDelay = '${index * 35}ms';
      final icon = web.document.createElement('div') as web.HTMLDivElement
        ..className = 'result-icon'
        ..textContent = item.icon;
      final copy = web.document.createElement('div') as web.HTMLDivElement
        ..className = 'result-copy';
      copy
        ..appendChild(_element('strong', text: item.title))
        ..appendChild(
          _element(
            'span',
            text: '${item.category(_currentLocale)} · '
                '${item.description(_currentLocale)}',
          ),
        );
      final choseong = web.document.createElement('span') as web.HTMLSpanElement
        ..className = 'result-choseong'
        ..textContent = getChoseong(item.title);

      card
        ..appendChild(icon)
        ..appendChild(copy)
        ..appendChild(choseong);
      resultContainer.appendChild(card);
    }
  }

  input.addEventListener(
    'input',
    ((web.Event _) => render(input.value)).toJS,
  );
  clearButton.addEventListener(
    'click',
    ((web.Event _) {
      input.value = '';
      input.focus();
      render('');
    }).toJS,
  );

  for (final button in presetButtons) {
    button.addEventListener(
      'click',
      ((web.Event _) {
        final query = button.getAttribute('data-query') ?? '';
        input.value = query;
        input.focus();
        render(query);
      }).toJS,
    );
  }

  for (final button in localeButtons) {
    button.addEventListener(
      'click',
      ((web.Event _) {
        final locale = SiteLocale.values.firstWhere(
          (candidate) => candidate.code == button.getAttribute('data-locale'),
        );
        web.window.localStorage.setItem(_localeStorageKey, locale.code);
        _applyLocale(locale, localeButtons);
        render(input.value);
      }).toJS,
    );
  }

  web.window.addEventListener(
    'keydown',
    ((web.Event rawEvent) {
      final event = rawEvent as web.KeyboardEvent;
      if ((event.metaKey || event.ctrlKey) && event.key.toLowerCase() == 'k') {
        event.preventDefault();
        input.focus();
        input.select();
      }
    }).toJS,
  );

  final initialLocale = resolveSiteLocale(
    savedLocale: web.window.localStorage.getItem(_localeStorageKey),
    browserLanguage: web.window.navigator.language,
  );
  _applyLocale(initialLocale, localeButtons);
  _bindCopyButton('#copy-install', _installCommand, '.copy-label');
  _bindCopyButton('#copy-code', _quickStartCode, '#copy-code span');
  render(input.value);
}

void _applyLocale(
  SiteLocale locale,
  List<web.HTMLButtonElement> localeButtons,
) {
  _currentLocale = locale;
  final localeCode = locale.code;
  final copy = _pageCopy[locale]!;

  web.document.documentElement?.setAttribute('lang', localeCode);
  web.document.title = copy['title']!;
  web.document
      .querySelector('#meta-description')
      ?.setAttribute('content', copy['description']!);
  web.document
      .querySelector('#meta-og-description')
      ?.setAttribute('content', copy['ogDescription']!);
  web.document
      .querySelector('#meta-og-locale')
      ?.setAttribute('content', copy['ogLocale']!);
  web.document
      .querySelector('#meta-og-locale-alternate')
      ?.setAttribute('content', copy['ogLocaleAlternate']!);
  web.document
      .querySelector('.locale-switcher')
      ?.setAttribute('aria-label', copy['localeSelector']!);

  final localizedNodes = web.document.querySelectorAll('[data-ko][data-en]');
  for (var index = 0; index < localizedNodes.length; index++) {
    final element = localizedNodes.item(index) as web.Element;
    element.textContent = element.getAttribute('data-$localeCode');
  }

  for (final attribute in ['aria-label', 'title', 'placeholder']) {
    final nodes = web.document.querySelectorAll(
      '[data-ko-$attribute][data-en-$attribute]',
    );
    for (var index = 0; index < nodes.length; index++) {
      final element = nodes.item(index) as web.Element;
      element.setAttribute(
        attribute,
        element.getAttribute('data-$localeCode-$attribute')!,
      );
    }
  }

  for (final button in localeButtons) {
    button.setAttribute(
      'aria-pressed',
      '${button.getAttribute('data-locale') == localeCode}',
    );
  }
}

void _bindCopyButton(
  String buttonSelector,
  String text,
  String labelSelector,
) {
  final button =
      web.document.querySelector(buttonSelector) as web.HTMLButtonElement;
  final label = web.document.querySelector(labelSelector)!;

  button.addEventListener(
    'click',
    ((web.Event _) {
      web.window.navigator.clipboard.writeText(text).toDart.then((_) {
        label.textContent = _copy('copied');
        button.classList.add('copied');

        Future<void>.delayed(const Duration(milliseconds: 1400), () {
          label.textContent = _copy('copy');
          button.classList.remove('copied');
        });
      });
    }).toJS,
  );
}

web.HTMLElement _element(
  String tag, {
  required String text,
}) {
  final element = web.document.createElement(tag) as web.HTMLElement;
  element.textContent = text;
  return element;
}

String _copy(String key) => _pageCopy[_currentLocale]![key]!;

String _formatResultStatus(String query, int count) {
  if (_currentLocale == SiteLocale.ko) {
    final template =
        query.isEmpty ? _copy('resultsAll') : _copy('resultsQuery');
    return template
        .replaceAll('{count}', '$count')
        .replaceAll('{query}', query);
  }

  final template = query.isEmpty
      ? _copy(count == 1 ? 'resultsAllOne' : 'resultsAllOther')
      : _copy(count == 1 ? 'resultsQueryOne' : 'resultsQueryOther');
  return template.replaceAll('{count}', '$count').replaceAll('{query}', query);
}

class _SearchItem {
  const _SearchItem(
    this.title, {
    required this.categoryKo,
    required this.categoryEn,
    required this.descriptionKo,
    required this.descriptionEn,
    required this.icon,
  });

  final String title;
  final String categoryKo;
  final String categoryEn;
  final String descriptionKo;
  final String descriptionEn;
  final String icon;

  String category(SiteLocale locale) =>
      locale == SiteLocale.ko ? categoryKo : categoryEn;

  String description(SiteLocale locale) =>
      locale == SiteLocale.ko ? descriptionKo : descriptionEn;
}
