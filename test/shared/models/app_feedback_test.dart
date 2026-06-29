import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:erp_alianca_dev/core/theme/empresa_palettes.dart';
import 'package:erp_alianca_dev/shared/models/app_feedback.dart';
import 'package:erp_alianca_dev/shared/services/empresa_service.dart';
import 'package:erp_alianca_dev/shared/theme/app_colors.dart';

void main() {
  setUpAll(() {
    AppColors.setCurrent(EmpresaPalettes.getById(kDefaultIdEmpresa));
  });

  group('AppFeedbackDurations', () {
    test('forType retorna duração correta por tipo', () {
      expect(
        AppFeedbackDurations.forType(AppFeedbackType.success),
        AppFeedbackDurations.success,
      );
      expect(
        AppFeedbackDurations.forType(AppFeedbackType.error),
        AppFeedbackDurations.error,
      );
      expect(
        AppFeedbackDurations.forType(AppFeedbackType.info),
        AppFeedbackDurations.info,
      );
      expect(
        AppFeedbackDurations.forType(AppFeedbackType.warning),
        AppFeedbackDurations.warning,
      );
    });
  });

  group('AppFeedbackMessage', () {
    test('factories definem tipo e mensagem', () {
      expect(
        AppFeedbackMessage.success('Ok').type,
        AppFeedbackType.success,
      );
      expect(
        AppFeedbackMessage.error('Falhou').type,
        AppFeedbackType.error,
      );
      expect(
        AppFeedbackMessage.info('Info').type,
        AppFeedbackType.info,
      );
      expect(
        AppFeedbackMessage.warning('Atenção').type,
        AppFeedbackType.warning,
      );
    });

    test('displayDuration usa padrão ou override', () {
      const custom = Duration(seconds: 10);
      expect(
        AppFeedbackMessage.success('Ok').displayDuration,
        AppFeedbackDurations.success,
      );
      expect(
        AppFeedbackMessage.error('Erro', duration: custom).displayDuration,
        custom,
      );
    });

    test('título, ícone e cor de destaque variam por tipo', () {
      expect(AppFeedbackMessage.success('Ok').displayTitle, 'Sucesso');
      expect(AppFeedbackMessage.error('Erro').displayTitle, 'Erro');
      expect(
        AppFeedbackMessage.success('Ok').icon,
        Icons.check_rounded,
      );
      expect(
        AppFeedbackMessage.error('Erro').icon,
        Icons.close_rounded,
      );
      expect(
        AppFeedbackMessage.success('Ok').accentColor,
        AppColors.success,
      );
      expect(
        AppFeedbackMessage.error('Erro').accentColor,
        AppColors.error,
      );
    });

    test('título customizado sobrescreve padrão', () {
      expect(
        AppFeedbackMessage.error('Msg', title: 'Falha').displayTitle,
        'Falha',
      );
    });

    test('info aceita ação secundária opcional', () {
      var actionCalled = false;
      final feedback = AppFeedbackMessage.info(
        'Pedido #10',
        actionLabel: 'Ver pedido',
        onAction: () => actionCalled = true,
      );

      expect(feedback.actionLabel, 'Ver pedido');
      feedback.onAction?.call();
      expect(actionCalled, isTrue);
    });
  });
}
