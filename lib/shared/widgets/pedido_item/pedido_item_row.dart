import 'package:flutter/material.dart';
import 'package:erp_alianca_dev/shared/theme/app_colors.dart';
import 'package:erp_alianca_dev/shared/theme/app_spacing.dart';
import 'package:erp_alianca_dev/shared/theme/app_text_styles.dart';
import 'package:erp_alianca_dev/shared/widgets/pedido_item/pedido_item_inline_qtd_field.dart';
import 'package:erp_alianca_dev/shared/widgets/pedido_item/pedido_item_inline_text.dart';
import 'package:erp_alianca_dev/shared/widgets/pedido_item/pedido_item_inline_valor_field.dart';
import 'package:erp_alianca_dev/shared/widgets/pedido_item/pedido_item_row_actions.dart';
import 'package:erp_alianca_dev/shared/widgets/app_tooltip.dart';

/// Uma linha de item do pedido em formato compacto:
/// Linha 1: Nome: ____ , valor: ___ (editável se [valorEditavel] e [onValorChanged] forem fornecidos)
/// Linha 2: quantidade: ___ , total: ___
/// Se [onQuantidadeChanged] e [index] forem fornecidos, a quantidade fica sempre editável.
class PedidoItemRow extends StatefulWidget {
  const PedidoItemRow({
    super.key,
    required this.nome,
    required this.valorTexto,
    required this.quantidadeTexto,
    required this.totalTexto,
    this.index,
    this.onQuantidadeChanged,
    this.valorEditavel = false,
    this.valorEditavelInicial = 0,
    this.onValorChanged,
    this.estaEmEdicao = false,
    this.quantidadeEdicaoController,
    this.onEditar,
    this.onRemover,
    this.onConfirmar,
    this.onCancelar,
  });

  final String nome;
  final String valorTexto;
  final String quantidadeTexto;
  final String totalTexto;
  final int? index;
  final void Function(int index, int novaQuantidade)? onQuantidadeChanged;
  final bool valorEditavel;
  final double valorEditavelInicial;
  final void Function(int index, double novoValor)? onValorChanged;
  final bool estaEmEdicao;
  final TextEditingController? quantidadeEdicaoController;
  final VoidCallback? onEditar;
  final VoidCallback? onRemover;
  final VoidCallback? onConfirmar;
  final VoidCallback? onCancelar;

  @override
  State<PedidoItemRow> createState() => _PedidoItemRowState();
}

class _PedidoItemRowState extends State<PedidoItemRow> {
  late TextEditingController _qtdController;
  TextEditingController? _valorController;
  FocusNode? _valorFocusNode;

  bool get _quantidadeSempreEditavel =>
      widget.index != null && widget.onQuantidadeChanged != null;

  bool get _valorSempreEditavel =>
      widget.valorEditavel &&
      widget.index != null &&
      widget.onValorChanged != null;

  /// Converte double para o mesmo formato do [CurrencyInputFormatter]: "0,00" ou "1234,56".
  static String _doubleToMoeda(double v) {
    if (v.isNaN || v.isInfinite || v < 0) return '0,00';
    final cents = (v * 100).round();
    final reais = cents ~/ 100;
    final centavos = cents % 100;
    return '$reais,${centavos.toString().padLeft(2, '0')}';
  }

  /// Parse do texto do campo moeda (formato "0,00" ou "1234,56") para double.
  static double? _parseValorBr(String s) {
    final t = s.trim().replaceAll('.', '').replaceAll(',', '.');
    return double.tryParse(t);
  }

  @override
  void initState() {
    super.initState();
    if (_quantidadeSempreEditavel) {
      _qtdController = TextEditingController(text: widget.quantidadeTexto);
      _qtdController.addListener(_onQtdChanged);
    } else {
      _qtdController = TextEditingController();
    }
    if (_valorSempreEditavel) {
      _valorController = TextEditingController(
        text: _doubleToMoeda(widget.valorEditavelInicial),
      );
      _valorController!.addListener(_onValorChanged);
      _valorFocusNode = FocusNode();
      _valorFocusNode!.addListener(_onValorFocusChange);
    }
  }

  void _onValorFocusChange() {
    if (_valorFocusNode?.hasFocus != true || _valorController == null) return;
    if (_valorController!.text.isEmpty) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _valorController == null) return;
      _valorController!.selection = TextSelection(
        baseOffset: 0,
        extentOffset: _valorController!.text.length,
      );
    });
  }

  @override
  void didUpdateWidget(PedidoItemRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_quantidadeSempreEditavel &&
        widget.quantidadeTexto != _qtdController.text) {
      _qtdController
        ..removeListener(_onQtdChanged)
        ..text = widget.quantidadeTexto;
      _qtdController.addListener(_onQtdChanged);
    }
    if (_valorSempreEditavel &&
        oldWidget.valorEditavelInicial != widget.valorEditavelInicial) {
      final currentParsed = _parseValorBr(_valorController!.text);
      final incoming = widget.valorEditavelInicial;
      if (currentParsed == null ||
          (currentParsed - incoming).abs() > 0.001) {
        _valorController!
          ..removeListener(_onValorChanged)
          ..text = _doubleToMoeda(incoming);
        _valorController!.selection = TextSelection.collapsed(
          offset: _valorController!.text.length,
        );
        _valorController!.addListener(_onValorChanged);
      }
    }
  }

  void _onQtdChanged() {
    final qtd = int.tryParse(_qtdController.text.trim());
    if (qtd != null && qtd >= 1 && widget.index != null) {
      widget.onQuantidadeChanged!(widget.index!, qtd);
    }
  }

  void _onValorChanged() {
    final parsed = _parseValorBr(_valorController!.text);
    if (parsed != null && parsed >= 0 && widget.index != null) {
      widget.onValorChanged!(widget.index!, parsed);
    }
  }

  @override
  void dispose() {
    if (_quantidadeSempreEditavel) {
      _qtdController.removeListener(_onQtdChanged);
      _qtdController.dispose();
    }
    if (_valorSempreEditavel && _valorController != null) {
      _valorController!.removeListener(_onValorChanged);
      _valorController!.dispose();
    }
    _valorFocusNode?.removeListener(_onValorFocusChange);
    _valorFocusNode?.dispose();
    super.dispose();
  }

  static const double _labelFontSize = 13;
  static const double _valueFontSize = 14;

  @override
  Widget build(BuildContext context) {
    final bool showQtdField = _quantidadeSempreEditavel ||
        (widget.estaEmEdicao && widget.quantidadeEdicaoController != null);

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Nome: ',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
                fontSize: _labelFontSize,
              ),
            ),
            Expanded(
              child: PedidoItemInlineText(
                value: widget.nome,
                fontSize: _valueFontSize,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              'valor: ',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
                fontSize: _labelFontSize,
              ),
            ),
            SizedBox(
              width: 110,
              child: _valorSempreEditavel && _valorController != null
                  ? PedidoItemInlineValorField(
                      controller: _valorController!,
                      focusNode: _valorFocusNode,
                    )
                  : PedidoItemInlineText(
                      value: widget.valorTexto,
                      fontSize: _valueFontSize,
                    ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'quantidade: ',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
                fontSize: _labelFontSize,
              ),
            ),
            SizedBox(
              width: 64,
              child: showQtdField
                  ? PedidoItemInlineQtdField(
                      controller: _quantidadeSempreEditavel
                          ? _qtdController
                          : widget.quantidadeEdicaoController!,
                      fontSize: _valueFontSize,
                    )
                  : PedidoItemInlineText(
                      value: widget.quantidadeTexto,
                      fontSize: _valueFontSize,
                    ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              'total: ',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
                fontSize: _labelFontSize,
              ),
            ),
            SizedBox(
              width: 100,
              child: PedidoItemInlineText(
                value: widget.totalTexto,
                fontSize: _valueFontSize,
              ),
            ),
          ],
        ),
        if (!_quantidadeSempreEditavel) ...[
          const SizedBox(height: 4),
          PedidoItemRowActions(
            estaEmEdicao: widget.estaEmEdicao,
            onConfirmar: widget.onConfirmar,
            onCancelar: widget.onCancelar,
            onEditar: widget.onEditar,
          ),
        ],
      ],
    );

    final child = widget.onRemover != null
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                onPressed: widget.onRemover,
                icon: Icon(
                  Icons.delete_outline,
                  color: Theme.of(context).colorScheme.error,
                  size: 22,
                ),
                style: IconButton.styleFrom(
                  minimumSize: const Size(40, 40),
                  padding: EdgeInsets.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                tooltip: windowsSafeTooltip('Remover item'),
              ),
              const SizedBox(width: 4),
              Expanded(child: content),
            ],
          )
        : content;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.cardBorder, width: 1),
      ),
      child: child,
    );
  }
}
