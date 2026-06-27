import 'package:flutter/material.dart';
import 'package:erp_alianca_dev/features/clientes/model/cliente_model.dart';
import 'package:erp_alianca_dev/shared/theme/app_colors.dart';
import 'package:erp_alianca_dev/shared/theme/app_radius.dart';
import 'package:erp_alianca_dev/shared/theme/app_spacing.dart';
import 'package:erp_alianca_dev/shared/theme/app_text_styles.dart';

/// Item compacto da lista de clientes: layout horizontal alinhado (estilo ERP/SaaS).
/// Ícone | ID (70px) | Nome (Expanded) | Telefone (140px) | [🛒]. Altura ~52px, hover e foco suaves.
class ClientTile extends StatefulWidget {
  const ClientTile({
    super.key,
    required this.cliente,
    required this.onTap,
    this.onNovoPedido,
  });

  final ClienteModel cliente;
  final VoidCallback onTap;
  final void Function(ClienteModel)? onNovoPedido;

  /// Formata telefone para exibição: (XX) XXXXX-XXXX ou (XX) XXXX-XXXX.
  static String formatarTelefoneExibicao(String raw) {
    final digits = raw.replaceAll(RegExp(r'\D'), '');
    if (digits.length == 11) {
      return '(${digits.substring(0, 2)}) ${digits.substring(2, 7)}-${digits.substring(7)}';
    }
    if (digits.length == 10) {
      return '(${digits.substring(0, 2)}) ${digits.substring(2, 6)}-${digits.substring(6)}';
    }
    return raw.trim().isEmpty ? '—' : raw;
  }

  @override
  State<ClientTile> createState() => _ClientTileState();
}

class _ClientTileState extends State<ClientTile> {
  static const double _iconSize = 20;
  static const double _iconWidth = 40;
  static const double _idWidth = 70;
  static const double _telefoneWidth = 140;
  static const Duration _hoverDuration = Duration(milliseconds: 200);

  bool _hovered = false;
  bool _focused = false;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  bool get _highlight => _hovered || _focused;

  static bool _clienteEhAtivo(ClienteModel c) =>
      c.status.trim().toLowerCase() != 'inativo';

  @override
  Widget build(BuildContext context) {
    final codigo = widget.cliente.id != null
        ? '#${widget.cliente.id!.toString().padLeft(5, '0')}'
        : '—';
    final telefone = ClientTile.formatarTelefoneExibicao(widget.cliente.telefone);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.tileGap),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        child: SizedBox(
          width: double.infinity,
          child: Focus(
        focusNode: _focusNode,
        onFocusChange: (hasFocus) => setState(() => _focused = hasFocus),
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          onEnter: (_) => setState(() => _hovered = true),
          onExit: (_) => setState(() => _hovered = false),
          child: AnimatedContainer(
            duration: _hoverDuration,
            curve: Curves.easeOut,
            padding: const EdgeInsets.symmetric(
              vertical: AppSpacing.tilePaddingVertical,
              horizontal: AppSpacing.tilePaddingHorizontal,
            ),
            decoration: BoxDecoration(
              color: _highlight
                  ? AppColors.listagemItemHover
                  : AppColors.listagemItemBackground,
              borderRadius: BorderRadius.circular(AppRadius.tile),
              border: AppColors.isLightTheme && _highlight
                  ? Border.all(
                      color: _focused
                          ? AppColors.listagemItemSelectedBorder
                          : AppColors.cardBorder,
                      width: 1,
                    )
                  : null,
            ),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(AppRadius.tile),
              child: Row(
                children: [
                  SizedBox(
                    width: _iconWidth,
                    child: Icon(
                      Icons.person_outline,
                      size: _iconSize,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  SizedBox(
                    width: _idWidth,
                    child: Text(
                      codigo,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      widget.cliente.nome,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(
                    width: _telefoneWidth,
                    child: Text(
                      telefone,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.end,
                    ),
                  ),
                  if (widget.onNovoPedido != null &&
                      widget.cliente.id != null &&
                      _clienteEhAtivo(widget.cliente)) ...[
                    const SizedBox(width: AppSpacing.sm),
                    Tooltip(
                      message: 'Novo pedido',
                      child: Material(
                        color: AppColors.primary.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(AppRadius.small),
                        child: InkWell(
                          onTap: () => widget.onNovoPedido!(widget.cliente),
                          borderRadius: BorderRadius.circular(AppRadius.small),
                          splashColor: AppColors.primary.withOpacity(0.2),
                          highlightColor: AppColors.primary.withOpacity(0.1),
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: Icon(
                              Icons.add_shopping_cart,
                              size: 18,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    ),
    ),
    );
  }
}
