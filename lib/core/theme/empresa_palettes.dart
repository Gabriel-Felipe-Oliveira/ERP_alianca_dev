import 'package:flutter/material.dart';
import 'package:erp_alianca_dev/shared/models/empresa_palette_model.dart';

/// Único lugar das cores por empresa. Troque de empresa em [EmpresaService.idEmpresa] (main usa isso).
class EmpresaPalettes {
  EmpresaPalettes._();

  /// Empresa 1 — padrão. Sidebar escura (0xFF0F172A); área de conteúdo mais clara (0xFF1E293B).
  static const EmpresaPalette empresa1 = EmpresaPalette(
    background: Color(0xFF1E293B),
    sidebarBackground: Color(0xFF0F172A),
    primary: Color(0xFF1E88E5),
    textPrimary: Color(0xCCFFFFFF),
    error: Color(0xFFE53935),
    success: Color(0xFF4CAF50),
    toolPanelItemDangerBackground: Color(0xFF7F1D1D),
    toolPanelItemLightBackground: Color(0xFFF8FAFC),
    toolPanelItemDarkBackground: Color(0xFF0D1117),
    logoPath: null,
  );

  /// Empresa 2.
  static const EmpresaPalette empresa2 = EmpresaPalette(
    background: Color(0xFF1E293B),
    sidebarBackground: Color(0xFF111827),
    primary: Color(0xFF2563EB),
    textPrimary: Color(0xFFFFFFFF),
    error: Color(0xFFB91C1C),
    success: Color(0xFF16A34A),
    toolPanelItemDangerBackground: Color(0xFF7F1D1D),
    toolPanelItemLightBackground: Color(0xFFF8FAFC),
    toolPanelItemDarkBackground: Color(0xFF0D1117),
    logoPath: null,
  );

  /// Empresa 3 usa as mesmas cores da empresa 1 (tema escuro padrão).
  static EmpresaPalette getById(int id) {
    switch (id) {
      case 1:
        return empresa1;
      case 2:
        return empresa2;
      case 3:
        return empresa1;
      default:
        return empresa1;
    }
  }
}
