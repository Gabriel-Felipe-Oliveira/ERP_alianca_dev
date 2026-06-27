import 'package:erp_alianca_dev/shared/utils/listagem_letter_group.dart';

/// Agrupa itens por faixa numérica do ID (blocos de 10: 0–10, 20–30, 100–110…).
abstract final class ListagemIdRangeGroup {
  static const int rangeSize = 10;

  static int rangeStartForId(int id) {
    if (id < 0) return 0;
    return (id ~/ rangeSize) * rangeSize;
  }

  static String rangeLabelForId(int id) {
    final start = rangeStartForId(id);
    return '$start - ${start + rangeSize}';
  }

  static List<ListagemGroupedEntry<T>> build<T>({
    required List<T> items,
    required int Function(T item) id,
  }) {
    if (items.isEmpty) return [];

    final sorted = List<T>.from(items)..sort((a, b) => id(b).compareTo(id(a)));

    final groups = <int, List<T>>{};
    for (final item in sorted) {
      final start = rangeStartForId(id(item));
      groups.putIfAbsent(start, () => []).add(item);
    }

    final starts = groups.keys.toList()..sort((a, b) => b.compareTo(a));
    final result = <ListagemGroupedEntry<T>>[];
    for (final start in starts) {
      result.add(ListagemGroupedEntry.header('$start - ${start + rangeSize}'));
      for (final item in groups[start]!) {
        result.add(ListagemGroupedEntry.data(item));
      }
    }
    return result;
  }
}
