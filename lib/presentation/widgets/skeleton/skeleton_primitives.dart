import 'package:flutter/material.dart';
import '../../../const/colors.dart';
import '../../../const/sizes.dart';

/// Fundamental atomic skeleton components for building consistent skeleton placeholders across XenoBiz.

/// A basic rectangular or rounded skeleton container.
class SkeletonBox extends StatelessWidget {
  final double? width;
  final double? height;
  final double borderRadius;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final BoxShape shape;
  final Color? color;
  final Widget? child;

  const SkeletonBox({
    super.key,
    this.width,
    this.height,
    this.borderRadius = AppSizes.radiusSmall,
    this.margin,
    this.padding,
    this.shape = BoxShape.rectangle,
    this.color,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    final defaultColor = color ?? AppColors.shimmerBase;

    return Container(
      width: width,
      height: height,
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: defaultColor,
        shape: shape,
        borderRadius: shape == BoxShape.rectangle
            ? BorderRadius.circular(borderRadius)
            : null,
      ),
      child: child,
    );
  }
}

/// Skeleton text placeholder representing single or multi-line text blocks.
class SkeletonText extends StatelessWidget {
  final double? width;
  final double height;
  final int lines;
  final double lineSpacing;
  final double borderRadius;

  const SkeletonText({
    super.key,
    this.width,
    this.height = 14,
    this.lines = 1,
    this.lineSpacing = 6,
    this.borderRadius = 4,
  });

  @override
  Widget build(BuildContext context) {
    if (lines == 1) {
      return SkeletonBox(
        width: width,
        height: height,
        borderRadius: borderRadius,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: List.generate(lines, (index) {
        // Vary width for natural multiline paragraph look
        double lineFraction = 1.0;
        if (index == lines - 1 && lines > 1) {
          lineFraction = 0.65;
        } else if (index % 2 == 1) {
          lineFraction = 0.85;
        }

        final effectiveWidth = width != null ? width! * lineFraction : null;

        return Padding(
          padding: EdgeInsets.only(bottom: index < lines - 1 ? lineSpacing : 0),
          child: SkeletonBox(
            width: effectiveWidth,
            height: height,
            borderRadius: borderRadius,
          ),
        );
      }),
    );
  }
}

/// Circular avatar / icon skeleton placeholder.
class SkeletonAvatar extends StatelessWidget {
  final double size;

  const SkeletonAvatar({
    super.key,
    this.size = 44,
  });

  @override
  Widget build(BuildContext context) {
    return SkeletonBox(
      width: size,
      height: size,
      shape: BoxShape.circle,
    );
  }
}

/// Skeleton card container matching the dimensions and border radius of AppCard.
class SkeletonCard extends StatelessWidget {
  final Widget? child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final double borderRadius;

  const SkeletonCard({
    super.key,
    this.child,
    this.padding = const EdgeInsets.all(16.0),
    this.margin,
    this.width,
    this.height,
    this.borderRadius = AppSizes.radiusMedium,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: child,
    );
  }
}

/// Skeleton representation of a standard XenoBiz list item tile.
class SkeletonListTile extends StatelessWidget {
  final bool hasLeading;
  final double leadingSize;
  final bool hasSubtitle;
  final bool hasTrailing;
  final double titleWidth;
  final double subtitleWidth;
  final double trailingWidth;
  final EdgeInsetsGeometry padding;

  const SkeletonListTile({
    super.key,
    this.hasLeading = true,
    this.leadingSize = 40,
    this.hasSubtitle = true,
    this.hasTrailing = true,
    this.titleWidth = 140,
    this.subtitleWidth = 90,
    this.trailingWidth = 60,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.6)),
      ),
      child: Row(
        children: [
          if (hasLeading) ...[
            SkeletonAvatar(size: leadingSize),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                SkeletonText(width: titleWidth, height: 14),
                if (hasSubtitle) ...[
                  const SizedBox(height: 6),
                  SkeletonText(width: subtitleWidth, height: 11),
                ],
              ],
            ),
          ),
          if (hasTrailing) ...[
            const SizedBox(width: 12),
            SkeletonBox(width: trailingWidth, height: 24, borderRadius: 6),
          ],
        ],
      ),
    );
  }
}

/// Chart placeholder maintaining dimensions and showing bar/line structures.
class SkeletonChart extends StatelessWidget {
  final double height;
  final String chartType; // 'bar', 'line', 'pie'

  const SkeletonChart({
    super.key,
    this.height = 200,
    this.chartType = 'bar',
  });

  @override
  Widget build(BuildContext context) {
    return SkeletonCard(
      height: height,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Chart title & legend row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              SkeletonText(width: 120, height: 14),
              Row(
                children: [
                  SkeletonBox(width: 12, height: 12, borderRadius: 3),
                  SizedBox(width: 6),
                  SkeletonText(width: 40, height: 10),
                  SizedBox(width: 12),
                  SkeletonBox(width: 12, height: 12, borderRadius: 3),
                  SizedBox(width: 6),
                  SkeletonText(width: 40, height: 10),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Chart Body
          Expanded(
            child: chartType == 'pie'
                ? _buildPieChartSkeleton()
                : _buildBarChartSkeleton(),
          ),
          const SizedBox(height: 12),
          // Axis Labels Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(6, (_) => const SkeletonText(width: 28, height: 10)),
          ),
        ],
      ),
    );
  }

  Widget _buildBarChartSkeleton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _buildBarGroup(0.4, 0.6),
        _buildBarGroup(0.7, 0.3),
        _buildBarGroup(0.5, 0.8),
        _buildBarGroup(0.9, 0.4),
        _buildBarGroup(0.6, 0.7),
        _buildBarGroup(0.3, 0.5),
      ],
    );
  }

  Widget _buildBarGroup(double h1, double h2) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxHeight = constraints.maxHeight;
        return Row(
          children: [
            SkeletonBox(
              width: 14,
              height: maxHeight * h1,
              borderRadius: 4,
            ),
            const SizedBox(width: 4),
            SkeletonBox(
              width: 14,
              height: maxHeight * h2,
              borderRadius: 4,
            ),
          ],
        );
      },
    );
  }

  Widget _buildPieChartSkeleton() {
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          SkeletonBox(
            width: 120,
            height: 120,
            shape: BoxShape.circle,
          ),
          Container(
            width: 65,
            height: 65,
            decoration: const BoxDecoration(
              color: AppColors.surfaceCard,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }
}

/// Data table skeleton placeholder with header row and data rows.
class SkeletonTable extends StatelessWidget {
  final int rows;
  final int columns;

  const SkeletonTable({
    super.key,
    this.rows = 4,
    this.columns = 4,
  });

  @override
  Widget build(BuildContext context) {
    return SkeletonCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          // Header row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: AppColors.pageBackground,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(
                columns,
                (i) => Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: SkeletonText(
                      width: i == 0 ? 80 : 50,
                      height: 12,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const Divider(height: 1, color: AppColors.border),
          // Data rows
          ...List.generate(
            rows,
            (rIndex) => Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(
                      columns,
                      (cIndex) => Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: SkeletonText(
                            width: cIndex == 0 ? 90 : 45,
                            height: 12,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                if (rIndex < rows - 1)
                  const Divider(height: 1, color: AppColors.border),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Skeleton button placeholder matching AppButton.
class SkeletonButton extends StatelessWidget {
  final double? width;
  final double height;
  final double borderRadius;

  const SkeletonButton({
    super.key,
    this.width,
    this.height = 48,
    this.borderRadius = AppSizes.radiusMedium,
  });

  @override
  Widget build(BuildContext context) {
    return SkeletonBox(
      width: width,
      height: height,
      borderRadius: borderRadius,
    );
  }
}

/// Skeleton divider placeholder.
class SkeletonDivider extends StatelessWidget {
  final double height;

  const SkeletonDivider({super.key, this.height = 1});

  @override
  Widget build(BuildContext context) {
    return SkeletonBox(
      width: double.infinity,
      height: height,
    );
  }
}
