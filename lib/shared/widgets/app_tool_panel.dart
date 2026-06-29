import 'package:flutter/material.dart';
import 'package:erp_alianca_dev/shared/theme/app_colors.dart';
import 'package:erp_alianca_dev/shared/theme/app_spacing.dart';
import 'package:erp_alianca_dev/shared/widgets/app_tool_item.dart';

/// Variante visual do item no painel: identifica a ação de relance (cor de fundo + ícone/texto).
enum AppToolPanelItemVariant {
  /// Padrão (azul primário ou texto neutro conforme [isPrimary]).
  primary,
  /// Ação positiva: faturar, editar — fundo verde + ícone/texto verde.
  success,
  /// Ação destrutiva: cancelar, excluir — fundo vermelho + ícone/texto vermelho.
  danger,
  /// Ação neutra: visualizar/gerar PDF — fundo branco, ícone e texto azul.
  neutral,
  /// Ação principal em destaque: Faturar — fundo preto, ícone e texto azul.
  primaryOnDark,
  /// Botão azul preenchido com ícone e texto brancos (ex.: Criar pedido).
  primaryFilled,
}

/// Configuração de um item do [AppToolPanel].
class AppToolPanelItemConfig {
  const AppToolPanelItemConfig({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isPrimary = false,
    this.isDestructive = false,
    this.enabled = true,
    this.accentColor,
    this.variant,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isPrimary;
  final bool isDestructive;
  final bool enabled;
  /// Cor de destaque (ex.: verde para "Criar pedido"). Quando definida, o item fica destacado no painel.
  final Color? accentColor;
  /// Variante visual (success=verde, danger=vermelho, neutral=branco). Tem precedência sobre [isPrimary]/[isDestructive]/[accentColor].
  final AppToolPanelItemVariant? variant;
}

/// Painel vertical de ferramentas (ícones + labels ou só ícones).
/// Se [compact] for null, decide automaticamente pela largura disponível
/// via [LayoutBuilder]. Use [compact] explícito quando a view já souber
/// a largura real (ex.: dentro de um shell com sidebar).
class AppToolPanel extends StatelessWidget {
  const AppToolPanel({
    super.key,
    required this.items,
    this.compact,
  });

  final List<AppToolPanelItemConfig> items;

  /// Se null, o painel decide sozinho via LayoutBuilder.
  final bool? compact;

  @override
  Widget build(BuildContext context) {
    if (compact != null) {
      return _buildPanel(compact!);
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < AppSpacing.toolPanelBreakpoint;
        return _buildPanel(isCompact);
      },
    );
  }

  Widget _buildPanel(bool isCompact) {
    final panelWidth = isCompact
        ? AppSpacing.toolPanelWidthCompact
        : AppSpacing.toolPanelWidth;

    return Container(
      width: panelWidth,
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.actionBarBackground,
        borderRadius: BorderRadius.circular(AppSpacing.toolPanelBorderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.04),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: items
            .map(
              (item) => AppToolItem(
                icon: item.icon,
                label: item.label,
                onTap: item.onTap,
                isPrimary: item.isPrimary,
                isDestructive: item.isDestructive,
                enabled: item.enabled,
                showLabel: !isCompact,
                accentColor: item.accentColor,
                variant: item.variant,
              ),
            )
            .toList(),
      ),
    );
  }
}
