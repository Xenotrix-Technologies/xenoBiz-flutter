import 'package:flutter/material.dart';
import '../../const/colors.dart';

class XenoBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final bool isCreateMenuOpen;
  final ValueChanged<int> onTap;
  final VoidCallback onToggleCreateMenu;

  const XenoBottomNavigationBar({
    super.key,
    required this.currentIndex,
    this.isCreateMenuOpen = false,
    required this.onTap,
    required this.onToggleCreateMenu,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.cardSurface,
        border: Border(
          top: BorderSide(
            color: AppColors.border,
            width: 1.0,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Container(
          height: 64,
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // 1. Home
              _NavItem(
                index: 0,
                currentIndex: currentIndex,
                icon: Icons.home_outlined,
                activeIcon: Icons.home_rounded,
                label: 'Home',
                onTap: () => onTap(0),
              ),

              // 2. Sales
              _NavItem(
                index: 1,
                currentIndex: currentIndex,
                icon: Icons.shopping_bag_outlined,
                activeIcon: Icons.shopping_bag_rounded,
                label: 'Sales',
                onTap: () => onTap(1),
              ),

              // 3. Center Universal Create Button (+)
              Expanded(
                child: GestureDetector(
                  onTap: onToggleCreateMenu,
                  behavior: HitTestBehavior.opaque,
                  child: Center(
                    child: Transform.translate(
                      offset: const Offset(0, -10),
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isCreateMenuOpen
                              ? AppColors.deepNavy
                              : AppColors.primaryBlue,
                          boxShadow: [
                            BoxShadow(
                              color: (isCreateMenuOpen
                                      ? AppColors.deepNavy
                                      : AppColors.primaryBlue)
                                  .withValues(alpha: 0.35),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Center(
                          child: AnimatedRotation(
                            turns: isCreateMenuOpen ? 0.125 : 0.0, // 45 degrees rotation for + -> x
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.easeInOutCubic,
                            child: Icon(
                              Icons.add_rounded,
                              size: 28,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // 4. Inventory (Stock)
              _NavItem(
                index: 3,
                currentIndex: currentIndex,
                icon: Icons.inventory_2_outlined,
                activeIcon: Icons.inventory_2_rounded,
                label: 'Inventory',
                onTap: () => onTap(3),
              ),

              // 5. More
              _NavItem(
                index: 4,
                currentIndex: currentIndex,
                icon: Icons.more_horiz_rounded,
                activeIcon: Icons.more_horiz_rounded,
                label: 'More',
                onTap: () => onTap(4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final int index;
  final int currentIndex;
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final VoidCallback onTap;

  const _NavItem({
    required this.index,
    required this.currentIndex,
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = index == currentIndex;
    const activeColor = AppColors.deepNavy;
    const inactiveColor = AppColors.secondaryText;

    return Expanded(
      child: InkWell(
        onTap: onTap,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 52,
              height: 28,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.blueTint : Colors.transparent,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Icon(
                  isSelected ? activeIcon : icon,
                  size: 21,
                  color: isSelected ? activeColor : inactiveColor,
                ),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? activeColor : inactiveColor,
                letterSpacing: -0.1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
