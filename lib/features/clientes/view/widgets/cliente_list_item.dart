import 'package:flutter/material.dart';
import 'package:erp_alianca_dev/features/clientes/model/cliente_model.dart';
import 'package:erp_alianca_dev/shared/theme/app_colors.dart';
import 'package:erp_alianca_dev/shared/theme/app_text_styles.dart';
import 'package:erp_alianca_dev/shared/widgets/app_tooltip.dart';
import 'package:erp_alianca_dev/shared/widgets/listagem_list_card.dart';

/// Largura fixa da coluna Id para alinhar com o cabeçalho da listagem.
const double kClienteListIdColumnWidth = 90;

/// Item compacto da lista de clientes: ID (badge), nome em destaque, telefone/documento secundário.
/// [compact] reduz padding e fonte para telas menores.
/// Callback ao tocar em "Novo pedido" para este cliente (recebe o [ClienteModel]).
typedef OnNovoPedidoCliente = void Function(ClienteModel cliente);

class ClienteListItem extends StatelessWidget {
  const ClienteListItem({
    super.key,
    required this.cliente,
    this.onTap,
    this.onNovoPedido,
    this.compact = false,
  });

  final ClienteModel cliente;
  final VoidCallback? onTap;
  /// Se informado, exibe botão "Novo pedido" que chama este callback com o cliente.
  final OnNovoPedidoCliente? onNovoPedido;
  final bool compact;

  static const double _paddingVerticalCompact = 6;
  static const double _paddingVerticalNormal = 8;
  static const double _paddingHorizontalCompact = 8;
  static const double _paddingHorizontalNormal = 12;

  EdgeInsets get _contentPadding => EdgeInsets.symmetric(
        horizontal: compact ? _paddingHorizontalCompact : _paddingHorizontalNormal,
        vertical: compact ? _paddingVerticalCompact : _paddingVerticalNormal,
      );

  @override
  Widget build(BuildContext context) {
    final codigo = cliente.id != null
        ? '#${cliente.id!.toString().padLeft(5, '0')}'
        : '—';
    final secundario = cliente.telefone.trim().isNotEmpty
        ? cliente.telefone
        : (cliente.documentoFormatado ?? '');

    final nomeStyle = (compact ? AppTextStyles.bodyMedium : AppTextStyles.bodyLarge)
        .copyWith(
          fontWeight: FontWeight.w600,
                          color: Colors.white,
        );
    final secundarioStyle = AppTextStyles.bodySmall.copyWith(
      color: AppColors.textSecondary,
    );
    final badgeStyle = AppTextStyles.tag.copyWith(
      color: AppColors.textSecondary,
      fontWeight: FontWeight.w500,
    );

    return ListagemListItem(
      onTap: onTap,
      contentPadding: _contentPadding,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: kClienteListIdColumnWidth,
            child: Text(
              codigo,
              style: badgeStyle,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            child: Text(
              cliente.nome,
              style: nomeStyle,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (secundario.isNotEmpty) ...[
                SizedBox(width: compact ? 4 : 6),
                SizedBox(
                  width: compact ? 72 : 84,
                  child: Text(
                    secundario,
                    style: secundarioStyle,
                    overflow: TextOverflow.ellipsis,
                    softWrap: false,
                  ),
                ),
              ],
              if (onNovoPedido != null && cliente.id != null) ...[
                SizedBox(width: compact ? 4 : 6),
                AppTooltip(
                  message: 'Novo pedido para este cliente',
                  child: Material(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(6),
                    child: InkWell(
                      onTap: () => onNovoPedido!(cliente),
                      borderRadius: BorderRadius.circular(6),
                      child: Padding(
                        padding: EdgeInsets.all(compact ? 5 : 6),
                        child: Icon(
                          Icons.add_shopping_cart,
                          size: compact ? 16 : 18,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
