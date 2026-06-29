import 'package:flutter/material.dart';
import 'package:erp_alianca_dev/features/home/model/home_nav_item.dart';
import 'package:erp_alianca_dev/features/home/view/widgets/home_nav_card_constants.dart';
import 'package:erp_alianca_dev/shared/theme/app_colors.dart';

/// Card quadrado fixo de atalho de navegação na Home.
class HomeNavCard extends StatelessWidget {
  const HomeNavCard({
    super.key,
    required this.item,
    required this.onTap,
  });

  final HomeNavItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: HomeNavCardConstants.cardSize,
      height: HomeNavCardConstants.cardSize,
      child: Material(
        color: AppColors.card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(HomeNavCardConstants.cardRadius),
          side: BorderSide(color: AppColors.cardBorder),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius:
              BorderRadius.circular(HomeNavCardConstants.cardRadius),
          hoverColor: AppColors.isLightTheme
              ? AppColors.cardHoverBackground
              : AppColors.cardHoverBackground.withValues(alpha: 0.15),
          child: Padding(
            padding: const EdgeInsets.all(HomeNavCardConstants.padding),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  item.icon,
                  size: HomeNavCardConstants.iconSize,
                  color: item.color,
                ),
                const SizedBox(height: HomeNavCardConstants.spaceBelowIcon),
                Text(
                  item.actionLabel,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: HomeNavCardConstants.labelStyle,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
