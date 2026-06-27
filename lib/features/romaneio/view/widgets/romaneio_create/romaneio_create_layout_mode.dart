import 'package:erp_alianca_dev/shared/theme/app_spacing.dart';

/// Modo de layout conforme largura da tela.
enum RomaneioCreateLayoutMode {
  /// Coluna única: informações, motorista, resumo, pedidos, barra de ação.
  small,

  /// Duas colunas com padding e proporções reduzidas.
  medium,

  /// Duas colunas com padding normal.
  large,
}

RomaneioCreateLayoutMode romaneioCreateLayoutMode(double width) {
  if (width < AppSpacing.layoutBreakpointSmall) {
    return RomaneioCreateLayoutMode.small;
  }
  if (width < AppSpacing.layoutBreakpointTwoColumns) {
    return RomaneioCreateLayoutMode.medium;
  }
  return RomaneioCreateLayoutMode.large;
}

double romaneioCreateScreenPadding(RomaneioCreateLayoutMode mode) {
  switch (mode) {
    case RomaneioCreateLayoutMode.small:
      return AppSpacing.screenPaddingSmall;
    case RomaneioCreateLayoutMode.medium:
      return AppSpacing.screenPaddingMedium;
    case RomaneioCreateLayoutMode.large:
      return AppSpacing.lg;
  }
}
