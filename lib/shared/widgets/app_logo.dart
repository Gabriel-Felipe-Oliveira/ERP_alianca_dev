import 'package:flutter/material.dart';
import 'package:erp_alianca_dev/shared/theme/app_colors.dart';

/// Exibe o logo da empresa (quando [AppColors.logoPath] está definido) ou um ícone padrão.
/// Use em sidebar, header, login, etc. — o logo muda conforme a empresa (id_empresa).
class AppLogo extends StatelessWidget {
  const AppLogo({
    super.key,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.fallbackIcon = Icons.store_outlined,
    this.fallbackIconSize = 32,
  });

  final double? width;
  final double? height;
  final BoxFit fit;
  final IconData fallbackIcon;
  final double fallbackIconSize;

  @override
  Widget build(BuildContext context) {
    final path = AppColors.logoPath;
    if (path != null && path.isNotEmpty) {
      return Image.asset(
        path,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (_, __, ___) => _buildFallback(context),
      );
    }
    return _buildFallback(context);
  }

  Widget _buildFallback(BuildContext context) {
    return Icon(
      fallbackIcon,
      size: fallbackIconSize,
      color: AppColors.textPrimary,
    );
  }
}
