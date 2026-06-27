/// Resultado paginado de uma listagem da API.
class PaginatedResult<T> {
  const PaginatedResult({
    required this.items,
    required this.page,
    required this.limit,
    required this.total,
    required this.hasMore,
    this.serverPaginated = false,
    this.fullCache,
  });

  final List<T> items;
  final int page;
  final int limit;
  final int total;
  final bool hasMore;

  /// True quando a API retornou metadados de paginação (total/page).
  final bool serverPaginated;

  /// Lista completa em cache quando a API ignora page/limit (paginação client-side).
  final List<T>? fullCache;
}
