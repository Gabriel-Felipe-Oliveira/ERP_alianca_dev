import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:erp_alianca_dev/features/romaneio/view/widgets/romaneio_create/romaneio_create_layout_mode.dart';
import 'package:erp_alianca_dev/features/romaneio/view/widgets/romaneio_create/romaneio_create_layout_single_column.dart';
import 'package:erp_alianca_dev/features/romaneio/view/widgets/romaneio_create/romaneio_create_layout_two_columns.dart';
import 'package:erp_alianca_dev/features/romaneio/viewmodel/romaneio_criar_viewmodel.dart';
import 'package:erp_alianca_dev/routes/app_routes.dart';
import 'package:erp_alianca_dev/shared/theme/app_spacing.dart';
import 'package:erp_alianca_dev/shared/widgets/section_header.dart';

class RomaneioCreateView extends StatelessWidget {
  const RomaneioCreateView({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final mode = romaneioCreateLayoutMode(width);
    final padding = romaneioCreateScreenPadding(mode);

    return Consumer<RomaneioCriarViewModel>(
      builder: (context, vm, _) {
        return Padding(
          padding: EdgeInsets.all(padding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SectionHeader(
                title: 'Criar Romaneio',
                icon: Icons.local_shipping_outlined,
                onBack: () => context.go(AppRoutes.romaneio),
              ),
              SizedBox(
                height: mode == RomaneioCreateLayoutMode.large
                    ? AppSpacing.sectionSpacingCompact
                    : AppSpacing.sm,
              ),
              Expanded(
                child: mode == RomaneioCreateLayoutMode.small
                    ? RomaneioCreateLayoutSingleColumn(vm: vm)
                    : RomaneioCreateLayoutTwoColumns(vm: vm, mode: mode),
              ),
            ],
          ),
        );
      },
    );
  }
}
