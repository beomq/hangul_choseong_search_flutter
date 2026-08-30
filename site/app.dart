import 'dart:js_interop';

import 'package:hangul_choseong_search/hangul_choseong_search.dart';
import 'package:web/web.dart' as web;

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
  _SearchItem('김민수', '연락처', '디자인 팀 · 010-2849-1138', '김'),
  _SearchItem('박서준', '연락처', '개발 팀 · 010-5931-8420', '박'),
  _SearchItem('이도현', '연락처', '프로덕트 팀 · 010-7412-0098', '이'),
  _SearchItem('성수 카페 오월', '장소', '서울 성동구 · 카페', '오'),
  _SearchItem('사과Apple', '상품', '신선 식품 · 국내산', 'A'),
  _SearchItem('라면 연구소', '장소', '서울 마포구 · 음식점', '라'),
  _SearchItem('리모컨', '상품', '생활 가전 · 액세서리', '리'),
  _SearchItem('봄날의 기억', '음악', '윤하 · 재생 시간 03:42', '봄'),
];

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

  void render(String query) {
    final results = filterByChoseongKey(
      _items,
      query,
      (item) => item.title,
    );

    while (resultContainer.firstChild != null) {
      resultContainer.removeChild(resultContainer.firstChild!);
    }
    resultStatus.textContent = query.isEmpty
        ? '전체 데이터 · ${results.length}개'
        : '"$query" 검색 결과 · ${results.length}개';

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
          _element('strong', text: '일치하는 결과가 없어요.'),
        )
        ..appendChild(
          _element('span', text: '다른 초성이나 완성형 단어로 검색해 보세요.'),
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
            text: '${item.category} · ${item.description}',
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

  _bindCopyButton('#copy-install', _installCommand, '.copy-label');
  _bindCopyButton('#copy-code', _quickStartCode, '#copy-code span');
  render(input.value);
}

void _bindCopyButton(
  String buttonSelector,
  String text,
  String labelSelector,
) {
  final button =
      web.document.querySelector(buttonSelector) as web.HTMLButtonElement;
  final label = web.document.querySelector(labelSelector)!;
  final originalLabel = label.textContent;

  button.addEventListener(
    'click',
    ((web.Event _) {
      web.window.navigator.clipboard.writeText(text).toDart.then((_) {
        label.textContent = '완료';
        button.classList.add('copied');

        Future<void>.delayed(const Duration(milliseconds: 1400), () {
          label.textContent = originalLabel;
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

class _SearchItem {
  const _SearchItem(
    this.title,
    this.category,
    this.description,
    this.icon,
  );

  final String title;
  final String category;
  final String description;
  final String icon;
}
