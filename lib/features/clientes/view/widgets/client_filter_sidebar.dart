import 'package:flutter/material.dart';
import 'package:erp_alianca_dev/shared/theme/app_colors.dart';
import 'package:erp_alianca_dev/shared/widgets/app_tooltip.dart';

/// Item de filtro exibido na barra lateral de clientes.
class ClientFilterSidebarItem {
  const ClientFilterSidebarItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
    this.tooltip,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final String? tooltip;
}

/// Sidebar minimalista (60–80px): ícones de filtro com mesmo fundo dos itens da lista.
/// Agora é um widget puramente de UI: recebe os itens já prontos via parâmetro.
class ClientFilterSidebar extends StatelessWidget {
  const ClientFilterSidebar({
    super.key,
    required this.items,
  });

  static const double sidebarWidth = 200;

  /// Itens a serem exibidos (ícone + label + estado selecionado + callback).
  final List<ClientFilterSidebarItem> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      width: sidebarWidth,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < items.length; i++) ...[
            if (i > 0) const SizedBox(height: 6),
            _FilterIconButton(item: items[i]),
          ],
        ],
      ),
    );
  }
}

class _FilterIconButton extends StatefulWidget {
  const _FilterIconButton({
    required this.item,
  });

  final ClientFilterSidebarItem item;

  @override
  State<_FilterIconButton> createState() => _FilterIconButtonState();
}

class _FilterIconButtonState extends State<_FilterIconButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final tooltip = widget.item.tooltip;
    final content = _buildContent();

    if (tooltip == null || tooltip.isEmpty) {
      return content;
    }

    return AppTooltip(
      message: tooltip,
      child: content,
    );
  }

  /// Estilo do SVG: fundo preto, texto e ícone brancos, rx 12.
  Color get _backgroundColor {
    if (widget.item.selected) {
      return AppColors.toolPanelItemDarkBackground;
    }
    if (_hovered) {
      return const Color(0xFF1A1D21);
    }
    return AppColors.toolPanelItemDarkBackground;
  }

  Widget _buildContent() {
    return AppTooltip(
      message: widget.item.tooltip ?? widget.item.label,
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        cursor: SystemMouseCursors.click,
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          child: InkWell(
            onTap: widget.item.onTap,
            borderRadius: BorderRadius.circular(14),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutCubic,
              width: double.infinity,
              height: 44,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: _backgroundColor,
                borderRadius: BorderRadius.circular(12),
                border: widget.item.selected
                    ? Border.all(
                        color: AppColors.primary,
                        width: 2,
                      )
                    : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    widget.item.icon,
                    size: 20,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.item.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                        fontWeight:
                            widget.item.selected ? FontWeight.w600 : FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
