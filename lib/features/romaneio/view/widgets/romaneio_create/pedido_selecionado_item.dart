import 'package:flutter/material.dart';
import 'package:erp_alianca_dev/features/pedidos/model/pedido_model.dart';
import 'package:erp_alianca_dev/shared/theme/app_colors.dart';
import 'package:erp_alianca_dev/shared/utils/app_formatters.dart';

TextStyle get _pedidoChipId => TextStyle(
  fontSize: 9,
  fontWeight: FontWeight.w600,
  color: AppColors.textSecondary,
);

TextStyle get _pedidoChipNome => TextStyle(
  fontSize: 11,
  fontWeight: FontWeight.w500,
  color: AppColors.textPrimary,
);

TextStyle get _pedidoChipValor => TextStyle(
  fontSize: 11,
  fontWeight: FontWeight.w600,
  color: AppColors.textPrimary,
);

Color get _pedidoChipBackground => AppColors.primary.withValues(alpha: 0.22);

Color get _pedidoChipHoverBackground => AppColors.error.withValues(alpha: 0.35);

/// Chip compacto para a lista "Pedidos Selecionados".
class PedidoSelecionadoItem extends StatefulWidget {
  const PedidoSelecionadoItem({
    super.key,
    required this.pedido,
    required this.onTap,
    this.nomeCliente,
  });

  final PedidoListagemModel pedido;
  final VoidCallback onTap;
  final String? nomeCliente;

  @override
  State<PedidoSelecionadoItem> createState() => _PedidoSelecionadoItemState();
}

class _PedidoSelecionadoItemState extends State<PedidoSelecionadoItem> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final nome = (widget.nomeCliente != null &&
            widget.nomeCliente!.isNotEmpty &&
            widget.nomeCliente != '—')
        ? widget.nomeCliente!
        : '#${widget.pedido.idCliente}';
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(6),
          hoverColor: Colors.transparent,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            curve: Curves.easeOut,
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
            decoration: BoxDecoration(
              color: _hovering ? _pedidoChipHoverBackground : _pedidoChipBackground,
              border: Border.all(
                color: _hovering
                    ? AppColors.error.withValues(alpha: 0.7)
                    : AppColors.primary.withValues(alpha: 0.4),
                width: 1,
              ),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.check_circle,
                      size: 14,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text('#${widget.pedido.idPedido}', style: _pedidoChipId),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        nome,
                        style: _pedidoChipNome,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Center(
                  child: Text(
                    'R\$ ${formatarPreco(widget.pedido.total)}',
                    style: _pedidoChipValor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
