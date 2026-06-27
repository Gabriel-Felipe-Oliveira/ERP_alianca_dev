import 'package:erp_alianca_dev/core/constants/pagination_constants.dart';
import 'package:erp_alianca_dev/shared/models/paginated_result.dart';

/// Estado de paginação reutilizável nas ViewModels de listagem.
class ListPaginationHelper {
  int page = 1;
  int total = 0;
  bool hasMore = false;
  bool isLoadingMore = false;
  List<Object>? _fullCache;

  void reset() {
    page = 1;
    total = 0;
    hasMore = false;
    isLoadingMore = false;
    _fullCache = null;
  }

  void applyFirstPage<T>(PaginatedResult<T> result, List<T> destination) {
    destination
      ..clear()
      ..addAll(result.items);
    page = result.page;
    total = result.total;
    hasMore = result.hasMore;
    _fullCache = result.fullCache?.cast<Object>();
  }

  void applyNextPage<T>(PaginatedResult<T> result, List<T> destination) {
    destination.addAll(result.items);
    page = result.page;
    hasMore = result.hasMore;
    total = result.total;
  }

  /// Carrega próxima página a partir do cache local (API sem paginação server-side).
  bool loadMoreFromCache<T>(List<T> destination) {
    final cache = _fullCache;
    if (cache == null || !hasMore) return false;
    page++;
    destination
      ..clear()
      ..addAll(cache.take(page * PaginationConstants.defaultLimit).cast<T>());
    total = cache.length;
    hasMore = destination.length < cache.length;
    return true;
  }

  /// Define cache completo (ex.: após filtro client-side em romaneios).
  void setFullCache<T>(List<T> items, List<T> destination) {
    _fullCache = items.cast<Object>();
    page = 1;
    total = items.length;
    destination
      ..clear()
      ..addAll(items.take(PaginationConstants.defaultLimit));
    hasMore = destination.length < items.length;
  }
}
