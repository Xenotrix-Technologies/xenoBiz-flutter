import 'package:flutter/material.dart';
import '../../../const/colors.dart';
import '../../../const/sizes.dart';

class CommonVoucherAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback onBackPressed;
  final VoidCallback onMorePressed;

  const CommonVoucherAppBar({
    super.key,
    required this.title,
    required this.onBackPressed,
    required this.onMorePressed,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.background,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      leadingWidth: 58,
      leading: Padding(
        padding: const EdgeInsets.only(left: 16.0, top: 6.0, bottom: 6.0),
        child: InkWell(
          onTap: onBackPressed,
          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
          child: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.surfaceCard,
              borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
              border: Border.all(color: AppColors.surfaceContainerHigh),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.06),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.chevron_left,
              color: AppColors.onSurface,
              size: 22,
            ),
          ),
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: AppColors.onSurface,
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16.0, top: 6.0, bottom: 6.0),
          child: InkWell(
            onTap: onMorePressed,
            borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppColors.surfaceCard,
                borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                border: Border.all(color: AppColors.surfaceContainerHigh),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.06),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.more_vert,
                color: AppColors.onSurface,
                size: 22,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
