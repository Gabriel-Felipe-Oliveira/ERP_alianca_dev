import 'package:flutter/material.dart';
import 'package:erp_alianca_dev/core/constants/pagination_constants.dart';

/// Anexa listener de scroll para disparar [onLoadMore] perto do fim da lista.
void attachPaginationScrollListener({
  required ScrollController controller,
  required bool Function() hasMore,
  required bool Function() isLoadingMore,
  required VoidCallback onLoadMore,
}) {
  controller.addListener(() {
    if (!controller.hasClients) return;
    if (!hasMore() || isLoadingMore()) return;
    final position = controller.position;
    if (position.pixels >= position.maxScrollExtent - PaginationConstants.loadMoreThreshold) {
      onLoadMore();
    }
  });
}
