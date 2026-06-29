import 'package:flutter/material.dart';
import 'package:erp_alianca_dev/features/home/view/home_constants.dart';
import 'package:erp_alianca_dev/features/home/view/widgets/home_nav_menu_widget.dart';
import 'package:erp_alianca_dev/features/home/view/widgets/home_welcome_header.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(HomeConstants.padding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const HomeWelcomeHeader(),
          Expanded(
            child: Align(
              alignment: Alignment.center,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SingleChildScrollView(
                  child: HomeNavMenuWidget(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
