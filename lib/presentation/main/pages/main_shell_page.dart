import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../dashboard/pages/dashboard_page.dart';
import '../../widgets/xeno_bottom_navigation_bar.dart';

class MainShellPage extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MainShellPage({
    super.key,
    required this.navigationShell,
  });

  void _onTap(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          if (navigationShell.currentIndex != 0) {
            _onTap(0);
          } else {
            DashboardPage.showCloseShopDialog(context);
          }
        }
      },
      child: Scaffold(
        body: navigationShell,
        bottomNavigationBar: XenoBottomNavigationBar(
          currentIndex: navigationShell.currentIndex,
          onTap: _onTap,
        ),
      ),
    );
  }
}
