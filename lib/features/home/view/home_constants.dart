import 'package:erp_alianca_dev/features/home/view/widgets/home_nav_card_constants.dart';

/// Constantes de layout da Home.
class HomeConstants {
  HomeConstants._();

  static const int menuColumnCount = 2;
  static const double padding = 32;

  /// Largura total da grade (2 colunas fixas + espaço entre elas).
  static double get menuGridWidth =>
      HomeNavCardConstants.sectionWidth * menuColumnCount +
      HomeNavCardConstants.columnGap * (menuColumnCount - 1);

  static const double maxContentWidth = double.infinity;
}
