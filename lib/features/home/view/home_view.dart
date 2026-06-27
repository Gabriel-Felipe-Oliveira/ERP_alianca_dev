import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:erp_alianca_dev/features/home/view/widgets/home_dashboard_cards.dart';
import 'package:erp_alianca_dev/features/home/viewmodel/home_viewmodel.dart';
import 'package:erp_alianca_dev/features/home/view/home_constants.dart';
import 'package:erp_alianca_dev/shared/widgets/section_header.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<HomeViewModel>().carregarDados();
    });
  }

  static int _getCrossAxisCount(double width) {
    final count = ((width + HomeConstants.gridSpacing) /
            (HomeConstants.minCardWidth + HomeConstants.gridSpacing))
        .floor();
    return count.clamp(1, HomeConstants.maxColumns);
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<HomeViewModel>();

    return Padding(
      padding: const EdgeInsets.all(HomeConstants.padding),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: HomeConstants.maxContentWidth),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionHeader(
                title: HomeConstants.pageTitle,
                description: HomeConstants.pageDescription,
              ),
              if (vm.errorMessage != null) ...[
                const SizedBox(height: 8),
                Material(
                  color: Theme.of(context).colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            vm.errorMessage!,
                            style: TextStyle(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onErrorContainer,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: vm.isLoading ? null : () => vm.carregarDados(),
                          child: const Text('Tentar novamente'),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ],
              Expanded(
                child: vm.isLoading &&
                        vm.totalClientes == 0 &&
                        vm.totalProdutos == 0 &&
                        vm.totalPedidos == 0
                    ? const Center(child: CircularProgressIndicator())
                    : LayoutBuilder(
                        builder: (context, constraints) {
                          return GridView.count(
                            crossAxisCount:
                                _getCrossAxisCount(constraints.maxWidth),
                            crossAxisSpacing: HomeConstants.gridSpacing,
                            mainAxisSpacing: HomeConstants.gridSpacing,
                            childAspectRatio: HomeConstants.childAspectRatio,
                            children: HomeDashboardCards.buildList(context, vm),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
