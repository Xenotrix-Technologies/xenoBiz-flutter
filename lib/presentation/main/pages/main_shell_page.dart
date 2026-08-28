import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../dashboard/pages/dashboard_page.dart';
import '../../widgets/universal_create_menu.dart';
import '../../widgets/xeno_bottom_navigation_bar.dart';

class MainShellPage extends StatefulWidget {
  final StatefulNavigationShell navigationShell;

  const MainShellPage({
    super.key,
    required this.navigationShell,
  });

  @override
  State<MainShellPage> createState() => _MainShellPageState();
}

class _MainShellPageState extends State<MainShellPage> {
  bool _isCreateMenuOpen = false;

  void _onTap(int index) {
    if (_isCreateMenuOpen) {
      setState(() {
        _isCreateMenuOpen = false;
      });
    }
    widget.navigationShell.goBranch(
      index,
      initialLocation: index == 4 || index == widget.navigationShell.currentIndex,
    );
  }

  void _toggleCreateMenu() {
    setState(() {
      _isCreateMenuOpen = !_isCreateMenuOpen;
    });
  }

  void _closeCreateMenu() {
    if (_isCreateMenuOpen) {
      setState(() {
        _isCreateMenuOpen = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (_isCreateMenuOpen) {
          _closeCreateMenu();
          return;
        }
        if (!didPop) {
          if (widget.navigationShell.currentIndex != 0) {
            _onTap(0);
          } else {
            DashboardPage.showCloseShopDialog(context);
          }
        }
      },
      child: Stack(
        children: [
          Scaffold(
            body: widget.navigationShell,
            bottomNavigationBar: XenoBottomNavigationBar(
              currentIndex: widget.navigationShell.currentIndex,
              isCreateMenuOpen: _isCreateMenuOpen,
              onTap: _onTap,
              onToggleCreateMenu: _toggleCreateMenu,
            ),
          ),
          if (_isCreateMenuOpen)
            UniversalCreateOverlay(
              onDismiss: _closeCreateMenu,
            ),
        ],
      ),
    );
  }
}
