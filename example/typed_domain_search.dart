import 'package:hangul_choseong_search/hangul_choseong_search.dart';

final class DeliveryStop {
  const DeliveryStop(this.id, this.label);

  final int id;
  final String label;

  @override
  String toString() => 'DeliveryStop(id: $id, label: $label)';
}

void main() {
  const stops = <DeliveryStop>[
    DeliveryStop(101, '강남 Hub-A1'),
    DeliveryStop(102, '광명 Hub-B2'),
    DeliveryStop(103, '강남 Hub-A1'),
    DeliveryStop(104, 'Busan Center 3'),
  ];

  final List<DeliveryStop> matches = filterByChoseongKey(
    stops,
    'ㄱㄴ h',
    (stop) => stop.label,
  );
  final unmatched = filterByChoseongKey(
    stops,
    'ㅈㅈ c9',
    (stop) => stop.label,
  );

  print('Typed matches, in source order: $matches');
  print('Unmatched typed query: $unmatched');
}
