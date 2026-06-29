import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:erp_alianca_dev/features/home/model/home_nav_item.dart';
import 'package:erp_alianca_dev/features/home/view/home_constants.dart';
import 'package:erp_alianca_dev/features/home/view/widgets/home_nav_card.dart';
import 'package:erp_alianca_dev/features/home/view/widgets/home_nav_card_constants.dart';
import 'package:erp_alianca_dev/features/home/view/widgets/home_nav_menu.dart';
import 'package:erp_alianca_dev/shared/services/auth_service.dart';
import 'package:erp_alianca_dev/shared/theme/app_spacing.dart';

/// Grade fixa de 2 colunas; atalhos lado a lado dentro de cada seção.
class HomeNavMenuWidget extends StatelessWidget {
  const HomeNavMenuWidget({super.key});

  static const int _columnCount = 2;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();
    final sections = HomeNavMenu.sectionsFor(auth);

    return SizedBox(
      width: HomeConstants.menuGridWidth,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var row = 0; row < sections.length; row += _columnCount) ...[
            if (row > 0) const SizedBox(height: HomeNavCardConstants.rowGap),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var col = 0; col < _columnCount; col++) ...[
                  if (col > 0)
                    const SizedBox(width: HomeNavCardConstants.columnGap),
                  SizedBox(
                    width: HomeNavCardConstants.sectionWidth,
                    child: row + col < sections.length
                        ? _HomeNavSection(section: sections[row + col])
                        : const SizedBox.shrink(),
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _HomeNavSection extends StatelessWidget {
  const _HomeNavSection({required this.section});

  final HomeNavSection section;

  @override
  Widget build(BuildContext context) {
    final visibleItems =
        section.items.where((item) => item.visible).toList(growable: false);
    if (visibleItems.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (section.title.isNotEmpty) ...[
          Text(
            section.title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var i = 0; i < visibleItems.length; i++) ...[
              if (i > 0) const SizedBox(width: HomeNavCardConstants.cardGap),
              HomeNavCard(
                item: visibleItems[i],
                onTap: () => context.go(visibleItems[i].route),
              ),
            ],
          ],
        ),
      ],
    );
  }
}
