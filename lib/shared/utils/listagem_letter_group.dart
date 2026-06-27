/// Entrada plana de lista agrupada por letra (header ou item).
class ListagemGroupedEntry<T> {
  const ListagemGroupedEntry._({this.letter, this.item});

  const ListagemGroupedEntry.header(String letter)
      : this._(letter: letter, item: null);

  const ListagemGroupedEntry.data(T item) : this._(letter: null, item: item);

  final String? letter;
  final T? item;

  bool get isHeader => letter != null;
}

/// Agrupa itens pela primeira letra do rótulo (ordenado A–Z).
abstract final class ListagemLetterGroup {
  static String letterFor(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return '?';
    if (RegExp(r'[A-Za-zÀ-ú]').hasMatch(trimmed[0])) {
      return trimmed[0].toUpperCase();
    }
    return '#';
  }

  static List<ListagemGroupedEntry<T>> build<T>({
    required List<T> items,
    required String Function(T item) label,
  }) {
    if (items.isEmpty) return [];

    final sorted = List<T>.from(items)
      ..sort(
        (a, b) => label(a).trim().toLowerCase().compareTo(
              label(b).trim().toLowerCase(),
            ),
      );

    final groups = <String, List<T>>{};
    for (final item in sorted) {
      final letter = letterFor(label(item));
      groups.putIfAbsent(letter, () => []).add(item);
    }

    final letters = groups.keys.toList()..sort();
    final result = <ListagemGroupedEntry<T>>[];
    for (final letter in letters) {
      result.add(ListagemGroupedEntry.header(letter));
      for (final item in groups[letter]!) {
        result.add(ListagemGroupedEntry.data(item));
      }
    }
    return result;
  }
}
