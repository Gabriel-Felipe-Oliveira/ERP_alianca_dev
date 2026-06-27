import 'package:flutter/material.dart';
import 'package:erp_alianca_dev/shared/theme/app_colors.dart';

/// Tipo visual do feedback exibido ao usuário.
enum AppFeedbackType {
  success,
  error,
  info,
  warning,
}

/// Duração padrão do feedback na tela (por tipo).
abstract final class AppFeedbackDurations {
  static const Duration success = Duration(seconds: 3);
  static const Duration error = Duration(seconds: 4);
  static const Duration info = Duration(seconds: 3);
  static const Duration warning = Duration(seconds: 3);

  static Duration forType(AppFeedbackType type) => switch (type) {
        AppFeedbackType.success => success,
        AppFeedbackType.error => error,
        AppFeedbackType.info => info,
        AppFeedbackType.warning => warning,
      };
}

/// Mensagem de feedback padronizada (sucesso, erro, etc.).
class AppFeedbackMessage {
  const AppFeedbackMessage({
    required this.message,
    required this.type,
    this.duration,
    this.title,
  });

  final String message;
  final AppFeedbackType type;
  final Duration? duration;
  final String? title;

  Duration get displayDuration => duration ?? AppFeedbackDurations.forType(type);

  String get displayTitle => title ?? switch (type) {
        AppFeedbackType.success => 'Sucesso',
        AppFeedbackType.error => 'Erro',
        AppFeedbackType.info => 'Informação',
        AppFeedbackType.warning => 'Atenção',
      };

  factory AppFeedbackMessage.success(
    String message, {
    Duration? duration,
    String? title,
  }) =>
      AppFeedbackMessage(
        message: message,
        type: AppFeedbackType.success,
        duration: duration,
        title: title,
      );

  factory AppFeedbackMessage.error(
    String message, {
    Duration? duration,
    String? title,
  }) =>
      AppFeedbackMessage(
        message: message,
        type: AppFeedbackType.error,
        duration: duration,
        title: title,
      );

  factory AppFeedbackMessage.info(
    String message, {
    Duration? duration,
    String? title,
  }) =>
      AppFeedbackMessage(
        message: message,
        type: AppFeedbackType.info,
        duration: duration,
        title: title,
      );

  factory AppFeedbackMessage.warning(
    String message, {
    Duration? duration,
    String? title,
  }) =>
      AppFeedbackMessage(
        message: message,
        type: AppFeedbackType.warning,
        duration: duration,
        title: title,
      );

  /// Ícone branco dentro do círculo colorido.
  IconData get icon => switch (type) {
        AppFeedbackType.success => Icons.check_rounded,
        AppFeedbackType.error => Icons.close_rounded,
        AppFeedbackType.info => Icons.info_outline_rounded,
        AppFeedbackType.warning => Icons.priority_high_rounded,
      };

  /// Cor de destaque (círculo do ícone e botão OK).
  Color get accentColor => switch (type) {
        AppFeedbackType.success => AppColors.success,
        AppFeedbackType.error => AppColors.error,
        AppFeedbackType.info => AppColors.primary,
        AppFeedbackType.warning => AppColors.primaryLight,
      };
}
