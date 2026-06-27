import 'package:flutter/material.dart';
import 'package:erp_alianca_dev/shared/theme/app_colors.dart';
import 'package:erp_alianca_dev/features/dashboard/view/widgets/sidebar/sidebar_constants.dart';
import 'package:erp_alianca_dev/features/dashboard/view/widgets/sidebar/sidebar_sub_item.dart';

/// Container dos subitens com linhas |_ conectando (estilo Figma).
/// Estrutura: [espaço] [coluna |] [_ subsection] em cada linha.
/// A linha | termina no centro do último item, não continua para baixo.
class SidebarSubItemsConnector extends StatelessWidget {
  final List<SidebarSubItem> subItems;

  const SidebarSubItemsConnector({super.key, required this.subItems});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(width: SidebarConstants.connectorSpace),
        _buildVerticalLine(),
        Expanded(child: _buildSubItemsColumn()),
      ],
    );
  }

  Widget _buildVerticalLine() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < subItems.length; i++)
          Container(
            width: SidebarConstants.connectorVerticalWidth,
            height: _getSegmentHeight(i),
            color: AppColors.sidebarDivider,
          ),
      ],
    );
  }

  double _getSegmentHeight(int index) {
    if (index == subItems.length - 1) {
      return SidebarConstants.connectorRowHeight / 2 +
          SidebarConstants.connectorHorizontalHeight / 2;
    }
    return SidebarConstants.connectorRowHeight + SidebarConstants.connectorGap;
  }

  Widget _buildSubItemsColumn() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < subItems.length; i++) ...[
          SizedBox(
            height: SidebarConstants.connectorRowHeight,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: SidebarConstants.connectorHorizontalWidth,
                  height: SidebarConstants.connectorHorizontalHeight,
                  color: AppColors.sidebarDivider,
                ),
                Expanded(child: subItems[i]),
              ],
            ),
          ),
          if (i < subItems.length - 1)
            const SizedBox(height: SidebarConstants.connectorGap),
        ],
      ],
    );
  }
}
