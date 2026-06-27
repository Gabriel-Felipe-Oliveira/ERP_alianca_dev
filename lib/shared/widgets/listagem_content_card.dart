import 'package:flutter/material.dart';
import 'package:erp_alianca_dev/shared/theme/app_colors.dart';
import 'package:erp_alianca_dev/shared/theme/app_spacing.dart';

/// Card container reutilizável para telas de listagem.
class ListagemContentCard extends StatelessWidget {
  const ListagemContentCard({
    super.key,
    this.header,
    required this.body,
    this.padding,
  });

  final Widget? header;
  final Widget body;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final effectivePadding = padding ??
        const EdgeInsets.fromLTRB(
          AppSpacing.listagemScreenPadding,
          0,
          AppSpacing.listagemScreenPadding,
          AppSpacing.listagemScreenPadding,
        );

    final card = Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius:
            BorderRadius.circular(AppSpacing.listagemCardBorderRadius),
        border: Border.all(color: AppColors.cardBorder, width: 1),
        boxShadow: AppColors.isLightTheme ? AppColors.cardBoxShadow : null,
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.max,
        children: [
          if (header != null)
            Padding(
              padding: const EdgeInsets.only(
                left: AppSpacing.lg,
                right: AppSpacing.lg,
                top: AppSpacing.lg,
                bottom: AppSpacing.md,
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: header!,
              ),
            ),
          Expanded(child: body),
        ],
      ),
    );

    if (!AppColors.isLightTheme) {
      return Padding(
        padding: effectivePadding,
        child: Material(
          color: AppColors.listagemItemBackground,
          borderRadius:
              BorderRadius.circular(AppSpacing.listagemCardBorderRadius),
          elevation: AppSpacing.listagemContentCardElevation,
          shadowColor: AppColors.cardShadowColor,
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.max,
            children: [
              if (header != null)
                Padding(
                  padding: const EdgeInsets.only(
                    left: AppSpacing.listagemContentCardPadding,
                    right: AppSpacing.listagemContentCardPadding,
                    top: AppSpacing.listagemContentCardPadding,
                    bottom: AppSpacing.md,
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: header!,
                  ),
                ),
              Expanded(child: body),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: effectivePadding,
      child: card,
    );
  }
}
