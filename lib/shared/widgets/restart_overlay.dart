import 'package:flutter/material.dart';
import 'package:erp_alianca_dev/shared/theme/app_colors.dart';

/// Overlay de reinício do app: tela inteira azul com
/// [CircularProgressIndicator] branco no centro.
///
/// Usado quando o usuário segura o botão Atualizar por 3s;
/// após o restart o app abre na Home sem histórico.
class RestartOverlay extends StatelessWidget {
  const RestartOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primary,
      child: const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          strokeWidth: 3,
        ),
      ),
    );
  }
}
