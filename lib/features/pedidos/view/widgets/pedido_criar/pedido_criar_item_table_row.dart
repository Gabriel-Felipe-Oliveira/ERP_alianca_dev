import 'package:flutter/material.dart';
import 'package:erp_alianca_dev/features/pedidos/view/widgets/pedido_criar/pedido_criar_tabela_row_layout.dart';
import 'package:erp_alianca_dev/shared/theme/app_colors.dart';
import 'package:erp_alianca_dev/shared/theme/app_text_styles.dart';
import 'package:erp_alianca_dev/shared/widgets/pedido_item/pedido_item_inline_qtd_field.dart';
import 'package:erp_alianca_dev/shared/widgets/pedido_item/pedido_item_inline_valor_field.dart';

/// Linha de item no formato tabela (Criar Pedido).
class PedidoCriarItemTableRow extends StatefulWidget {
  const PedidoCriarItemTableRow({
    super.key,
    required this.nome,
    required this.quantidade,
    required this.valorUnitario,
    required this.totalLinha,
    required this.index,
    required this.onQuantidadeChanged,
    required this.onValorChanged,
    required this.onRemover,
  });

  final String nome;
  final int quantidade;
  final double valorUnitario;
  final double totalLinha;
  final int index;
  final void Function(int index, int novaQuantidade) onQuantidadeChanged;
  final void Function(int index, double novoValor) onValorChanged;
  final VoidCallback onRemover;

  @override
  State<PedidoCriarItemTableRow> createState() =>
      _PedidoCriarItemTableRowState();
}

class _PedidoCriarItemTableRowState extends State<PedidoCriarItemTableRow> {
  late TextEditingController _qtdController;
  late TextEditingController _valorController;
  late FocusNode _valorFocusNode;

  static String _doubleToMoeda(double v) {
    if (v.isNaN || v.isInfinite || v < 0) return '0,00';
    final cents = (v * 100).round();
    final reais = cents ~/ 100;
    final centavos = cents % 100;
    return '$reais,${centavos.toString().padLeft(2, '0')}';
  }

  static double? _parseValorBr(String s) {
    final t = s.trim().replaceAll('.', '').replaceAll(',', '.');
    return double.tryParse(t);
  }

  @override
  void initState() {
    super.initState();
    _qtdController = TextEditingController(text: '${widget.quantidade}');
    _qtdController.addListener(_onQtdChanged);
    _valorController =
        TextEditingController(text: _doubleToMoeda(widget.valorUnitario));
    _valorController.addListener(_onValorChanged);
    _valorFocusNode = FocusNode();
  }

  @override
  void didUpdateWidget(PedidoCriarItemTableRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.quantidade != widget.quantidade &&
        _qtdController.text != '${widget.quantidade}') {
      _qtdController
        ..removeListener(_onQtdChanged)
        ..text = '${widget.quantidade}';
      _qtdController.addListener(_onQtdChanged);
    }
    if ((oldWidget.valorUnitario - widget.valorUnitario).abs() > 0.001) {
      final parsed = _parseValorBr(_valorController.text);
      if (parsed == null ||
          (parsed - widget.valorUnitario).abs() > 0.001) {
        _valorController
          ..removeListener(_onValorChanged)
          ..text = _doubleToMoeda(widget.valorUnitario);
        _valorController.addListener(_onValorChanged);
      }
    }
  }

  void _onQtdChanged() {
    final qtd = int.tryParse(_qtdController.text.trim());
    if (qtd != null && qtd >= 1) {
      widget.onQuantidadeChanged(widget.index, qtd);
    }
  }

  void _onValorChanged() {
    final parsed = _parseValorBr(_valorController.text);
    if (parsed != null && parsed >= 0) {
      widget.onValorChanged(widget.index, parsed);
    }
  }

  @override
  void dispose() {
    _qtdController.removeListener(_onQtdChanged);
    _valorController.removeListener(_onValorChanged);
    _qtdController.dispose();
    _valorController.dispose();
    _valorFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.listagemItemBackground.withValues(alpha: 0.18),
        border: Border(
          bottom: BorderSide(
            color: AppColors.cardBorder.withValues(alpha: 0.35),
            width: 1,
          ),
        ),
      ),
      child: PedidoCriarTabelaRowLayout(
        produto: Text(
          widget.nome,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w500,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        qtd: PedidoItemInlineQtdField(
          controller: _qtdController,
          fontSize: 13,
          textAlign: TextAlign.start,
          horizontalPadding: 6,
        ),
        precoUnit: PedidoItemInlineValorField(
          controller: _valorController,
          focusNode: _valorFocusNode,
          autoFitFontSize: true,
          compact: true,
          baseFontSize: 13,
          minFontSize: 9,
        ),
        total: Text(
          'R\$ ${_doubleToMoeda(widget.totalLinha)}',
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.end,
        ),
        acoes: IconButton(
          onPressed: widget.onRemover,
          icon: Icon(
            Icons.delete_outline,
            color: AppColors.error,
            size: 20,
          ),
          tooltip: 'Remover',
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
        ),
      ),
    );
  }
}
