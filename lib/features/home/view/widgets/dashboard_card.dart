import 'package:flutter/material.dart';
import 'package:erp_alianca_dev/features/home/view/widgets/dashboard_card_constants.dart';
import 'package:erp_alianca_dev/features/home/view/widgets/dashboard_card_content.dart';

class DashboardCard extends StatefulWidget {
  const DashboardCard({
    super.key,
    required this.title,
    required this.icon,
    required this.total,
    required this.color,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final String total;
  final Color color;
  final VoidCallback onTap;

  @override
  State<DashboardCard> createState() => _DashboardCardState();
}

class _DashboardCardState extends State<DashboardCard> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(
        minWidth: DashboardCardConstants.minWidth,
        minHeight: DashboardCardConstants.minHeight,
      ),
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovering = true),
        onExit: (_) => setState(() => _hovering = false),
        child: AnimatedContainer(
          duration: DashboardCardConstants.hoverDuration,
          transform: _hovering
              ? (Matrix4.identity()
                ..scaleByDouble(
                  DashboardCardConstants.hoverScale,
                  DashboardCardConstants.hoverScale,
                  1.0,
                  1.0,
                ))
              : Matrix4.identity(),
          child: InkWell(
            borderRadius:
                BorderRadius.circular(DashboardCardConstants.cardRadius),
            onTap: widget.onTap,
            child: Container(
              padding: const EdgeInsets.all(DashboardCardConstants.padding),
              decoration: DashboardCardConstants.decoration(hovering: _hovering),
              child: DashboardCardContent(
                title: widget.title,
                total: widget.total,
                icon: widget.icon,
                iconColor: widget.color,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
