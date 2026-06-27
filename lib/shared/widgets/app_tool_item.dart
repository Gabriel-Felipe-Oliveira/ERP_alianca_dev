import 'package:flutter/material.dart';
import 'package:erp_alianca_dev/shared/theme/app_colors.dart';
import 'package:erp_alianca_dev/shared/theme/app_spacing.dart';
import 'package:erp_alianca_dev/shared/theme/app_text_styles.dart';
import 'package:erp_alianca_dev/shared/widgets/app_tool_panel.dart';

/// Item interativo do painel de ferramentas: ícone, opcional barra lateral e label.
/// Usado dentro de [AppToolPanel]. Hover, animação e tooltip com [label].
/// [variant] define o estilo: success=verde, danger=vermelho com fundo, neutral=branco.
class AppToolItem extends StatefulWidget {
  const AppToolItem({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.isPrimary = false,
    this.isDestructive = false,
    this.enabled = true,
    this.showLabel = true,
    this.accentColor,
    this.variant,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isPrimary;
  final bool isDestructive;
  final bool enabled;
  final bool showLabel;
  final Color? accentColor;
  final AppToolPanelItemVariant? variant;

  @override
  State<AppToolItem> createState() => _AppToolItemState();
}

class _AppToolItemState extends State<AppToolItem> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final Color color;
    final Color backgroundColor;
    final bool hasAccent;

    switch (widget.variant) {
      case AppToolPanelItemVariant.success:
        color = AppColors.success;
        hasAccent = true;
        backgroundColor = widget.enabled
            ? (_hovering
                ? AppColors.success.withOpacity(0.35)
                : AppColors.success.withOpacity(0.22))
            : AppColors.success.withOpacity(0.08);
        break;
      case AppToolPanelItemVariant.danger:
        hasAccent = true;
        if (widget.enabled && _hovering) {
          color = AppColors.error;
          backgroundColor = AppColors.textPrimary;
        } else {
          color = AppColors.textPrimary;
          backgroundColor = widget.enabled
              ? AppColors.toolPanelItemDangerBackground
              : AppColors.toolPanelItemDangerBackground.withOpacity(0.5);
        }
        break;
      case AppToolPanelItemVariant.neutral:
        color = AppColors.primary;
        hasAccent = true;
        backgroundColor = widget.enabled
            ? (_hovering
                ? AppColors.primary.withOpacity(0.12)
                : AppColors.toolPanelItemLightBackground)
            : AppColors.toolPanelItemLightBackground.withOpacity(0.5);
        break;
      case AppToolPanelItemVariant.primary:
        color = AppColors.primary;
        hasAccent = true;
        backgroundColor = widget.enabled
            ? (_hovering
                ? AppColors.primary.withOpacity(0.35)
                : AppColors.primary.withOpacity(0.22))
            : AppColors.primary.withOpacity(0.08);
        break;
      case AppToolPanelItemVariant.primaryOnDark:
        color = AppColors.primary;
        hasAccent = true;
        backgroundColor = widget.enabled
            ? (_hovering
                ? AppColors.primary.withOpacity(0.2)
                : AppColors.toolPanelItemDarkBackground)
            : AppColors.toolPanelItemDarkBackground.withOpacity(0.6);
        break;
      case AppToolPanelItemVariant.primaryFilled:
        hasAccent = true;
        if (widget.enabled && _hovering) {
          color = AppColors.primary;
          backgroundColor = AppColors.textPrimary;
        } else {
          color = AppColors.textPrimary;
          backgroundColor = widget.enabled
              ? AppColors.primary
              : AppColors.primary.withOpacity(0.5);
        }
        break;
      case null:
        color = widget.accentColor ??
            (widget.isPrimary
                ? AppColors.primary
                : widget.isDestructive
                    ? AppColors.error
                    : AppColors.textPrimary);
        hasAccent = widget.accentColor != null;
        backgroundColor = hasAccent
            ? (widget.enabled
                ? (_hovering
                    ? (widget.accentColor!).withOpacity(0.35)
                    : (widget.accentColor!).withOpacity(0.22))
                : (widget.accentColor!).withOpacity(0.08))
            : (_hovering ? AppColors.actionBarHover : Colors.transparent);
        break;
    }

    final borderColor = hasAccent && widget.enabled ? color.withOpacity(0.5) : null;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      cursor: widget.enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.enabled ? widget.onTap : null,
        child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: EdgeInsets.symmetric(
          horizontal: widget.showLabel ? AppSpacing.md : 4,
          vertical: 6,
        ),
        padding: EdgeInsets.symmetric(
          horizontal: widget.showLabel ? 12 : 0,
          vertical: 12,
        ),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(10),
          border: borderColor != null
              ? Border.all(color: borderColor, width: 1)
              : null,
        ),
        child: SizedBox(
          width: double.infinity,
          child: Tooltip(
            message: widget.label,
            child: widget.showLabel
                ? _buildExpandedContent(color)
                : _buildIconOnly(color),
          ),
        ),
      ),
    ),
    );
  }

  Widget _buildExpandedContent(Color color) {
    final barColor = widget.enabled
        ? color
        : AppColors.textSecondary.withOpacity(0.4);
    return Row(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 4,
          height: 28,
          decoration: BoxDecoration(
            color: barColor,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 12),
        Icon(
          widget.icon,
          size: 20,
          color: widget.enabled
              ? color
              : AppColors.textSecondary.withOpacity(0.4),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            widget.label,
            style: AppTextStyles.bodyMedium.copyWith(
              color: widget.enabled
                  ? color
                  : AppColors.textSecondary.withOpacity(0.4),
              fontWeight: widget.isPrimary ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildIconOnly(Color color) {
    return Center(
      child: Icon(
        widget.icon,
        size: 20,
        color: widget.enabled
            ? color
            : AppColors.textSecondary.withOpacity(0.4),
      ),
    );
  }
}
