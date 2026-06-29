import 'package:flutter/material.dart';

/// Atalho de navegação exibido na Home (sem dados de API).
class HomeNavItem {
  const HomeNavItem({
    required this.title,
    required this.actionLabel,
    required this.icon,
    required this.color,
    required this.route,
    this.visible = true,
  });

  final String title;
  final String actionLabel;
  final IconData icon;
  final Color color;
  final String route;
  final bool visible;
}

/// Seção do menu de navegação da Home.
class HomeNavSection {
  const HomeNavSection({
    required this.title,
    required this.items,
  });

  final String title;
  final List<HomeNavItem> items;
}
