import 'package:hangul_choseong_search/hangul_choseong_search.dart';
import 'package:test/test.dart';

final class Contact {
  const Contact(this.id, this.name);

  final int id;
  final String name;
}

void main() {
  group('matchesByChoseong', () {
    test('exposes the corrected matcher semantics for one candidate', () {
      expect(matchesByChoseong('라면', '라'), isTrue);
      expect(matchesByChoseong('리모컨', '라'), isFalse);
      expect(matchesByChoseong('리모컨', 'ㄹ'), isTrue);
      expect(matchesByChoseong('사과Apple', 'ㅅㄱa'), isTrue);
    });
  });

  group('filterByChoseongKey', () {
    const minji = Contact(1, '김민지');
    const minsu = Contact(2, '이민수');
    const duplicateMinji = Contact(3, '김민지');
    const contacts = [minji, minsu, duplicateMinji, minji];

    test(
        'infers and preserves the immutable domain type, order, and duplicates',
        () {
      final List<Contact> result =
          filterByChoseongKey(contacts, 'ㄱㅁ', (contact) => contact.name);

      expect(result, [minji, duplicateMinji, minji]);
      expect(identical(result[0], result[2]), isTrue);
    });

    test('invokes the key selector exactly once per candidate', () {
      var invocations = 0;

      final result = filterByChoseongKey(contacts, 'ㅁㅅ', (contact) {
        invocations++;
        return contact.name;
      });

      expect(result, [minsu]);
      expect(invocations, contacts.length);
    });

    test('returns an empty growable result for empty and unmatched inputs', () {
      final emptyResult = filterByChoseongKey<Contact>(
        const [],
        'ㄱ',
        (contact) => contact.name,
      );
      final unmatchedResult = filterByChoseongKey(
        contacts,
        'ㅎ',
        (contact) => contact.name,
      );

      expect(emptyResult, isEmpty);
      expect(() => emptyResult.add(const Contact(4, '한나')), returnsNormally);
      expect(unmatchedResult, isEmpty);
      expect(
          () => unmatchedResult.add(const Contact(5, '하나')), returnsNormally);
    });

    test('copies an empty-query iterable into a fresh growable list', () {
      var invocations = 0;

      final result = filterByChoseongKey(contacts, '', (contact) {
        invocations++;
        return contact.name;
      });

      expect(result, contacts);
      expect(identical(result, contacts), isFalse);
      expect(invocations, contacts.length);
      expect(() => result.add(const Contact(6, '박서준')), returnsNormally);
      expect(contacts, [minji, minsu, duplicateMinji, minji]);
    });

    test('isolates result mutation from a mutable source iterable', () {
      final source = <Contact>[minji, minsu];

      final result = filterByChoseongKey(source, '', (contact) => contact.name);
      result.removeAt(0);
      result.add(duplicateMinji);

      expect(source, [minji, minsu]);
      expect(result, [minsu, duplicateMinji]);
    });

    test('matches the legacy string facade without semantic drift', () {
      final items = ['라면', '리모컨', '로마', '사과Apple', '라면'];

      for (final query in ['ㄹ', '라', '라ㅁ', 'ㅅㄱa', '', '없는 값']) {
        expect(
          filterByChoseong(items, query),
          filterByChoseongKey(items, query, (item) => item),
        );
      }
    });
  });
}
