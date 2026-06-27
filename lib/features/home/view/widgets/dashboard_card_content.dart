import 'package:flutter/material.dart';
import 'package:erp_alianca_dev/features/home/view/widgets/dashboard_card_constants.dart';

/// Conteúdo interno do card: valor (escala), título (posição fixa) e ícone.
class DashboardCardContent extends StatelessWidget {
  const DashboardCardContent({
    super.key,
    required this.title,
    required this.total,
    required this.icon,
    required this.iconColor,
  });

  final String title;
  final String total;
  final IconData icon;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final showFullContent =
            constraints.maxWidth >= DashboardCardConstants.minWidthForFullContent &&
                constraints.maxHeight >= DashboardCardConstants.minHeightForFullContent;

        if (!showFullContent) {
          return Center(
            child: Icon(
              icon,
              size: DashboardCardConstants.iconSize,
              color: iconColor,
            ),
          );
        }

        const iconSpace =
            DashboardCardConstants.iconSize + DashboardCardConstants.spaceBelowIcon;
        const titleHeight = DashboardCardConstants.titleAreaHeight;

        return Stack(
          alignment: Alignment.topLeft,
          children: [
            // Valor (texto forte): ocupa o meio e escala para caber — não trunca
            Positioned(
              left: 0,
              right: 0,
              top: iconSpace,
              bottom: titleHeight,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.center,
                child: Text(
                  total,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: DashboardCardConstants.totalTextStyle,
                ),
              ),
            ),
            // Título: posição fixa na parte de baixo, tamanho fixo
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: titleHeight,
              child: Center(
                child: Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: DashboardCardConstants.titleTextStyle,
                ),
              ),
            ),
            Positioned(
              top: 0,
              right: 0,
              child: Icon(
                icon,
                size: DashboardCardConstants.iconSize,
                color: iconColor,
              ),
            ),
          ],
        );
      },
    );
  }
}
