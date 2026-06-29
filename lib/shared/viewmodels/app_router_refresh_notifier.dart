import 'package:flutter/foundation.dart';

/// Dispara refresh do GoRouter quando o tema muda (sem recriar a árvore via key).
class AppRouterRefreshNotifier extends ChangeNotifier {
  AppRouterRefreshNotifier._();

  static final AppRouterRefreshNotifier instance = AppRouterRefreshNotifier._();
}
