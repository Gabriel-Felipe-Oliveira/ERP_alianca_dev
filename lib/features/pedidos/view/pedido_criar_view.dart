import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:erp_alianca_dev/features/pedidos/view/widgets/pedido_criar/pedido_criar_painel_cliente.dart';
import 'package:erp_alianca_dev/features/pedidos/view/widgets/pedido_criar/pedido_criar_painel_itens.dart';
import 'package:erp_alianca_dev/features/pedidos/viewmodel/pedido_criar_viewmodel.dart';
import 'package:erp_alianca_dev/routes/app_routes.dart';
import 'package:erp_alianca_dev/shared/theme/app_spacing.dart';
import 'package:erp_alianca_dev/shared/widgets/section_header.dart';

class PedidoCriarView extends StatelessWidget {
  const PedidoCriarView({super.key});

  static const double _breakpointDoisPaineis = 900;

  @override
  Widget build(BuildContext context) {
    return Consumer<PedidoCriarViewModel>(
      builder: (context, vm, _) {
        return Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SectionHeader(
                title: 'Criar Pedido',
                icon: Icons.receipt_long_outlined,
                onBack: () => context.go(AppRoutes.pedidos),
              ),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final doisPaineis =
                        constraints.maxWidth >= _breakpointDoisPaineis;
                    if (doisPaineis) {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            flex: 5,
                            child: SingleChildScrollView(
                              child: PedidoCriarPainelCliente(vm: vm),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.lg),
                          Expanded(
                            flex: 6,
                            child: PedidoCriarPainelItens(
                              vm: vm,
                              expandirCorpo: true,
                            ),
                          ),
                        ],
                      );
                    }
                    return SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          PedidoCriarPainelCliente(vm: vm),
                          const SizedBox(height: AppSpacing.lg),
                          PedidoCriarPainelItens(vm: vm),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
