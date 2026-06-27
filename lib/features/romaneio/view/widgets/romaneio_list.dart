import 'package:flutter/material.dart';
import 'package:erp_alianca_dev/features/romaneio/model/romaneio_model.dart';
import 'package:erp_alianca_dev/shared/theme/app_colors.dart';
import 'package:erp_alianca_dev/shared/theme/app_spacing.dart';
import 'package:erp_alianca_dev/shared/theme/app_text_styles.dart';
import 'package:erp_alianca_dev/shared/utils/listagem_id_range_group.dart';
import 'package:erp_alianca_dev/shared/widgets/listagem_letter_section_header.dart';
import 'package:erp_alianca_dev/shared/widgets/listagem_list_card.dart';
import 'package:intl/intl.dart';

/// Largura do ícone e da coluna Romaneio na listagem.
const double kRomaneioListIconWidth = 40;
const double kRomaneioListColumnWidth = 100;

String formatarMoedaRomaneioList(double value) {
  return NumberFormat.currency(
    locale: 'pt_BR',
    symbol: 'R\$ ',
    decimalDigits: 2,
  ).format(value);
}

/// Lista de romaneios agrupada por faixa de ID (0–10, 20–30, …).
class RomaneioList extends StatelessWidget {
  const RomaneioList({
    super.key,
    required this.romaneios,
    required this.onTap,
    this.scrollController,
    this.footer,
  });

  final List<RomaneioModel> romaneios;
  final void Function(RomaneioModel romaneio) onTap;
  final ScrollController? scrollController;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    if (romaneios.isEmpty) {
      return const SizedBox.shrink();
    }

    final items = ListagemIdRangeGroup.build<RomaneioModel>(
      items: romaneios,
      id: (r) => r.id ?? 0,
    );

    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      itemCount: items.length + (footer != null ? 1 : 0),
      itemBuilder: (context, index) {
        if (footer != null && index == items.length) return footer!;
        final entry = items[index];
        if (entry.isHeader) {
          return ListagemLetterSectionHeader(letter: entry.letter!);
        }
        final romaneio = entry.item!;
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: RomaneioListItem(
            romaneio: romaneio,
            onTap: () => onTap(romaneio),
          ),
        );
      },
    );
  }
}

class RomaneioListItem extends StatelessWidget {
  const RomaneioListItem({
    super.key,
    required this.romaneio,
    this.onTap,
  });

  final RomaneioModel romaneio;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final numeroTexto = RomaneioModel.nomeExibicao(romaneio);
    final motoristaTexto = (romaneio.nomeMotorista?.trim().isNotEmpty == true)
        ? romaneio.nomeMotorista!.trim()
        : 'Motorista não informado';
    return ListagemListItem(
      onTap: onTap,
      child: Row(
        children: [
          SizedBox(
            width: kRomaneioListIconWidth,
            child: Icon(
              Icons.local_shipping_outlined,
              size: 20,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(
            width: kRomaneioListColumnWidth,
            child: Text(
              numeroTexto,
              style: AppTextStyles.bodySmall.copyWith(
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              motoristaTexto,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            'Faturado: ${formatarMoedaRomaneioList(romaneio.totalFaturado)}',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
