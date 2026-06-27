import 'package:flutter_test/flutter_test.dart';
import 'package:erp_alianca_dev/core/constants/pagination_constants.dart';
import 'package:erp_alianca_dev/shared/models/paginated_result.dart';
import 'package:erp_alianca_dev/shared/utils/list_pagination_helper.dart';

void main() {
  group('ListPaginationHelper', () {
    test('applyFirstPage preenche destino e metadados', () {
      final helper = ListPaginationHelper();
      final dest = <String>[];
      helper.applyFirstPage(
        const PaginatedResult<String>(
          items: ['a', 'b'],
          page: 1,
          limit: 20,
          total: 2,
          hasMore: false,
        ),
        dest,
      );
      expect(dest, ['a', 'b']);
      expect(helper.total, 2);
      expect(helper.hasMore, isFalse);
    });

    test('loadMoreFromCache expande lista paginada localmente', () {
      final helper = ListPaginationHelper();
      final dest = <int>[];
      helper.setFullCache(
        List.generate(25, (i) => i),
        dest,
      );
      expect(dest.length, PaginationConstants.defaultLimit);
      expect(helper.hasMore, isTrue);

      final loaded = helper.loadMoreFromCache(dest);
      expect(loaded, isTrue);
      expect(dest.length, 25);
      expect(helper.hasMore, isFalse);
    });
  });
}
