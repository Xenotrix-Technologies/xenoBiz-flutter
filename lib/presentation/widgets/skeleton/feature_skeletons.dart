import 'package:flutter/material.dart';
import '../../../const/sizes.dart';
import 'shimmer_effect.dart';
import 'skeleton_primitives.dart';

/// Screen-level and feature-specific composite skeleton loaders matching the exact visual designs of XenoBiz screens.

/// 1. DASHBOARD SKELETON
class DashboardSkeleton extends StatelessWidget {
  const DashboardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerEffect(
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Trial Status Banner Placeholder
            const SkeletonBox(height: 44, borderRadius: AppSizes.radiusMedium),
            const SizedBox(height: 16),

            // Top Banner Card: Today's Sales Card
            const SkeletonCard(
              height: 140,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SkeletonText(width: 120, height: 14),
                      SkeletonBox(width: 32, height: 32, shape: BoxShape.circle),
                    ],
                  ),
                  SkeletonText(width: 180, height: 28),
                  Row(
                    children: [
                      SkeletonText(width: 80, height: 12),
                      SizedBox(width: 12),
                      SkeletonText(width: 100, height: 12),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 2x2 Grid of Financial Summary Cards (Revenue, Sales, Receivables, Profit)
            Row(
              children: const [
                Expanded(
                  child: SkeletonCard(
                    height: 100,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SkeletonText(width: 70, height: 12),
                        SkeletonText(width: 90, height: 20),
                        SkeletonText(width: 60, height: 10),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: SkeletonCard(
                    height: 100,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SkeletonText(width: 70, height: 12),
                        SkeletonText(width: 90, height: 20),
                        SkeletonText(width: 60, height: 10),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: const [
                Expanded(
                  child: SkeletonCard(
                    height: 100,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SkeletonText(width: 70, height: 12),
                        SkeletonText(width: 90, height: 20),
                        SkeletonText(width: 60, height: 10),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: SkeletonCard(
                    height: 100,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SkeletonText(width: 70, height: 12),
                        SkeletonText(width: 90, height: 20),
                        SkeletonText(width: 60, height: 10),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Financial Analytics Chart Box Placeholder
            const SkeletonChart(height: 220, chartType: 'bar'),
            const SizedBox(height: 16),

            // Recent Invoices Section Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                SkeletonText(width: 130, height: 16),
                SkeletonText(width: 60, height: 12),
              ],
            ),
            const SizedBox(height: 12),

            // Recent Invoices List
            ...List.generate(
              3,
              (index) => const Padding(
                padding: EdgeInsets.only(bottom: 10),
                child: SkeletonListTile(
                  hasLeading: true,
                  hasSubtitle: true,
                  titleWidth: 120,
                  subtitleWidth: 80,
                  trailingWidth: 70,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 2. CRM DASHBOARD SKELETON
class CrmDashboardSkeleton extends StatelessWidget {
  const CrmDashboardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerEffect(
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // CRM Header banner
            const SkeletonCard(
              height: 90,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SkeletonText(width: 160, height: 16),
                  SizedBox(height: 8),
                  SkeletonText(width: 220, height: 12),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // CRM 2x2 Metric Cards
            Row(
              children: const [
                Expanded(child: SkeletonCard(height: 95)),
                SizedBox(width: 12),
                Expanded(child: SkeletonCard(height: 95)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: const [
                Expanded(child: SkeletonCard(height: 95)),
                SizedBox(width: 12),
                Expanded(child: SkeletonCard(height: 95)),
              ],
            ),
            const SizedBox(height: 16),

            // Lead Pipeline Funnel Chart Box
            const SkeletonChart(height: 200, chartType: 'bar'),
            const SizedBox(height: 16),

            // Priority Leads List Header
            const SkeletonText(width: 140, height: 16),
            const SizedBox(height: 12),
            ...List.generate(
              3,
              (_) => const Padding(
                padding: EdgeInsets.only(bottom: 10),
                child: SkeletonListTile(trailingWidth: 65),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 3. CUSTOMER LIST SKELETON
class CustomerListSkeleton extends StatelessWidget {
  final int itemCount;

  const CustomerListSkeleton({
    super.key,
    this.itemCount = 6,
  });

  @override
  Widget build(BuildContext context) {
    return ShimmerEffect(
      child: ListView.separated(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        itemCount: itemCount,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          return const SkeletonListTile(
            leadingSize: 44,
            titleWidth: 150,
            subtitleWidth: 110,
            trailingWidth: 70,
          );
        },
      ),
    );
  }
}

/// 4. CUSTOMER DETAILS SKELETON
class CustomerDetailsSkeleton extends StatelessWidget {
  const CustomerDetailsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerEffect(
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Card Header
            SkeletonCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      SkeletonAvatar(size: 60),
                      SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SkeletonText(width: 160, height: 18),
                            SizedBox(height: 6),
                            SkeletonText(width: 110, height: 12),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: const [
                      Expanded(child: SkeletonBox(height: 32, borderRadius: 8)),
                      SizedBox(width: 8),
                      Expanded(child: SkeletonBox(height: 32, borderRadius: 8)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Statistics Row Cards
            Row(
              children: const [
                Expanded(child: SkeletonCard(height: 80)),
                SizedBox(width: 12),
                Expanded(child: SkeletonCard(height: 80)),
                SizedBox(width: 12),
                Expanded(child: SkeletonCard(height: 80)),
              ],
            ),
            const SizedBox(height: 16),

            // Tab Bar Skeleton
            Row(
              children: const [
                SkeletonBox(width: 90, height: 36, borderRadius: 20),
                SizedBox(width: 8),
                SkeletonBox(width: 90, height: 36, borderRadius: 20),
                SizedBox(width: 8),
                SkeletonBox(width: 90, height: 36, borderRadius: 20),
              ],
            ),
            const SizedBox(height: 16),

            // Invoice/Payment History List
            ...List.generate(
              4,
              (_) => const Padding(
                padding: EdgeInsets.only(bottom: 10),
                child: SkeletonListTile(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 5. CRM CUSTOMER DETAILS SKELETON
class CrmCustomerDetailsSkeleton extends StatelessWidget {
  const CrmCustomerDetailsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const CustomerDetailsSkeleton();
  }
}

/// 6. OUTSTANDING CUSTOMERS SKELETON
class OutstandingCustomersSkeleton extends StatelessWidget {
  const OutstandingCustomersSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerEffect(
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: SkeletonCard(
              height: 90,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SkeletonText(width: 120, height: 12),
                      SizedBox(height: 8),
                      SkeletonText(width: 140, height: 22),
                    ],
                  ),
                  SkeletonBox(width: 50, height: 50, shape: BoxShape.circle),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView.separated(
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: 6,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, __) => const SkeletonListTile(trailingWidth: 80),
            ),
          ),
        ],
      ),
    );
  }
}

/// 7. INVOICE LIST SKELETON
class InvoiceListSkeleton extends StatelessWidget {
  final int itemCount;

  const InvoiceListSkeleton({
    super.key,
    this.itemCount = 6,
  });

  @override
  Widget build(BuildContext context) {
    return ShimmerEffect(
      child: ListView.separated(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        itemCount: itemCount,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          return const SkeletonCard(
            height: 90,
            padding: EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SkeletonText(width: 110, height: 14),
                    SkeletonBox(width: 60, height: 20, borderRadius: 6),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SkeletonText(width: 140, height: 12),
                    SkeletonText(width: 70, height: 16),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// 8. INVOICE DETAILS SKELETON
class InvoiceDetailsSkeleton extends StatelessWidget {
  const InvoiceDetailsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerEffect(
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Header card (Invoice #, Date, Status)
            const SkeletonCard(
              height: 110,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SkeletonText(width: 130, height: 18),
                      SkeletonBox(width: 70, height: 24, borderRadius: 12),
                    ],
                  ),
                  SkeletonText(width: 160, height: 12),
                  SkeletonText(width: 100, height: 12),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Customer Info card
            const SkeletonCard(
              height: 80,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SkeletonText(width: 120, height: 12),
                  SizedBox(height: 8),
                  SkeletonText(width: 180, height: 14),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Items Table
            const SkeletonTable(rows: 3, columns: 4),
            const SizedBox(height: 16),

            // Totals breakdown card
            const SkeletonCard(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SkeletonText(width: 80, height: 12),
                      SkeletonText(width: 60, height: 12),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SkeletonText(width: 70, height: 12),
                      SkeletonText(width: 50, height: 12),
                    ],
                  ),
                  Divider(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SkeletonText(width: 90, height: 16),
                      SkeletonText(width: 80, height: 18),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Bottom action buttons
            Row(
              children: const [
                Expanded(child: SkeletonButton(height: 46)),
                SizedBox(width: 12),
                Expanded(child: SkeletonButton(height: 46)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// 9. PRODUCT LIST SKELETON
class ProductListSkeleton extends StatelessWidget {
  final int itemCount;

  const ProductListSkeleton({
    super.key,
    this.itemCount = 6,
  });

  @override
  Widget build(BuildContext context) {
    return ShimmerEffect(
      child: ListView.separated(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        itemCount: itemCount,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          return const SkeletonCard(
            padding: EdgeInsets.all(12),
            child: Row(
              children: [
                SkeletonBox(width: 48, height: 48, borderRadius: 10),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SkeletonText(width: 140, height: 14),
                      SizedBox(height: 6),
                      SkeletonText(width: 90, height: 11),
                    ],
                  ),
                ),
                SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    SkeletonText(width: 60, height: 14),
                    SizedBox(height: 6),
                    SkeletonBox(width: 50, height: 18, borderRadius: 4),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// 10. STOCK MANAGEMENT SKELETON
class StockManagementSkeleton extends StatelessWidget {
  const StockManagementSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerEffect(
      child: Column(
        children: [
          // Header Metrics Summary Row
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: const [
                Expanded(child: SkeletonCard(height: 75)),
                SizedBox(width: 8),
                Expanded(child: SkeletonCard(height: 75)),
                SizedBox(width: 8),
                Expanded(child: SkeletonCard(height: 75)),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: 6,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, __) => const SkeletonListTile(),
            ),
          ),
        ],
      ),
    );
  }
}

/// 11. PRODUCT DETAILS SKELETON
class ProductDetailsSkeleton extends StatelessWidget {
  const ProductDetailsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerEffect(
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Image / Header Box
            const SkeletonCard(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  SkeletonBox(width: 60, height: 60, borderRadius: 14),
                  SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SkeletonText(width: 160, height: 18),
                        SizedBox(height: 8),
                        SkeletonText(width: 100, height: 12),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Stock Levels & Price Card
            const SkeletonCard(
              height: 120,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SkeletonText(width: 90, height: 12),
                      SkeletonText(width: 70, height: 16),
                    ],
                  ),
                  Divider(height: 1),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SkeletonText(width: 80, height: 12),
                      SkeletonText(width: 50, height: 14),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Movement History Header
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SkeletonText(width: 140, height: 16),
                SkeletonText(width: 50, height: 12),
              ],
            ),
            const SizedBox(height: 12),

            ...List.generate(
              3,
              (_) => const Padding(
                padding: EdgeInsets.only(bottom: 10),
                child: SkeletonListTile(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 12. LEAD PIPELINE / LIST SKELETON
class LeadPipelineSkeleton extends StatelessWidget {
  const LeadPipelineSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerEffect(
      child: Column(
        children: [
          // Pipeline Stage Tab Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const NeverScrollableScrollPhysics(),
              child: Row(
                children: List.generate(
                  4,
                  (_) => const Padding(
                    padding: EdgeInsets.only(right: 8.0),
                    child: SkeletonBox(width: 100, height: 36, borderRadius: 20),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.separated(
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: 6,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                return const SkeletonCard(
                  padding: EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SkeletonText(width: 140, height: 16),
                          SkeletonBox(width: 60, height: 20, borderRadius: 10),
                        ],
                      ),
                      SizedBox(height: 8),
                      SkeletonText(width: 100, height: 12),
                      SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SkeletonText(width: 80, height: 14),
                          SkeletonText(width: 90, height: 11),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// 13. LEAD DETAILS SKELETON
class LeadDetailsSkeleton extends StatelessWidget {
  const LeadDetailsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerEffect(
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Stage progress bar
            const SkeletonBox(height: 48, borderRadius: AppSizes.radiusMedium),
            const SizedBox(height: 16),

            // Lead Profile Card
            const SkeletonCard(
              height: 130,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      SkeletonAvatar(size: 50),
                      SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SkeletonText(width: 150, height: 18),
                          SizedBox(height: 6),
                          SkeletonText(width: 110, height: 12),
                        ],
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SkeletonText(width: 90, height: 12),
                      SkeletonText(width: 70, height: 14),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Activity Timeline Section
            const SkeletonText(width: 130, height: 16),
            const SizedBox(height: 12),

            ...List.generate(
              4,
              (_) => const Padding(
                padding: EdgeInsets.only(bottom: 10),
                child: SkeletonListTile(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 14. FOLLOWUPS PAGE SKELETON
class FollowupsPageSkeleton extends StatelessWidget {
  const FollowupsPageSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerEffect(
      child: ListView.separated(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        itemCount: 6,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (_, __) => const SkeletonListTile(
          hasLeading: true,
          titleWidth: 160,
          subtitleWidth: 110,
          trailingWidth: 75,
        ),
      ),
    );
  }
}

/// 15. SUPPLIER DIRECTORY SKELETON
class SupplierDirectorySkeleton extends StatelessWidget {
  const SupplierDirectorySkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const CustomerListSkeleton();
  }
}

/// 16. SUPPLIER DETAILS SKELETON
class SupplierDetailsSkeleton extends StatelessWidget {
  const SupplierDetailsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const CustomerDetailsSkeleton();
  }
}

/// 17. PURCHASE MANAGEMENT SKELETON
class PurchaseManagementSkeleton extends StatelessWidget {
  const PurchaseManagementSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const InvoiceListSkeleton();
  }
}

/// 18. SALES OVERVIEW SKELETON
class SalesOverviewSkeleton extends StatelessWidget {
  const SalesOverviewSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const DashboardSkeleton();
  }
}

/// 19. ANALYTICS & REPORTS SKELETON (Sales, Inventory, Financial Analytics)
class AnalyticsPageSkeleton extends StatelessWidget {
  const AnalyticsPageSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerEffect(
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Filter Bar
            const Row(
              children: [
                Expanded(child: SkeletonBox(height: 38, borderRadius: 8)),
                SizedBox(width: 10),
                SkeletonBox(width: 90, height: 38, borderRadius: 8),
              ],
            ),
            const SizedBox(height: 16),

            // KPI Cards Grid
            Row(
              children: const [
                Expanded(child: SkeletonCard(height: 90)),
                SizedBox(width: 10),
                Expanded(child: SkeletonCard(height: 90)),
              ],
            ),
            const SizedBox(height: 16),

            // Primary Analytics Chart Box
            const SkeletonChart(height: 230, chartType: 'bar'),
            const SizedBox(height: 16),

            // Breakdown Data Table
            const SkeletonTable(rows: 4, columns: 4),
          ],
        ),
      ),
    );
  }
}

/// 20. REPORTS PAGE SKELETON
class ReportsPageSkeleton extends StatelessWidget {
  const ReportsPageSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerEffect(
      child: ListView.separated(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        itemCount: 6,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, __) => const SkeletonCard(
          height: 75,
          child: Row(
            children: [
              SkeletonBox(width: 44, height: 44, borderRadius: 12),
              SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SkeletonText(width: 130, height: 14),
                    SizedBox(height: 6),
                    SkeletonText(width: 180, height: 11),
                  ],
                ),
              ),
              SkeletonBox(width: 18, height: 18, shape: BoxShape.circle),
            ],
          ),
        ),
      ),
    );
  }
}

/// 21. DAILY LEDGER SKELETON
class DailyLedgerSkeleton extends StatelessWidget {
  const DailyLedgerSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerEffect(
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: SkeletonCard(
              height: 100,
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SkeletonText(width: 80, height: 12),
                        SizedBox(height: 8),
                        SkeletonText(width: 110, height: 22),
                      ],
                    ),
                  ),
                  VerticalDivider(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SkeletonText(width: 80, height: 12),
                        SizedBox(height: 8),
                        SkeletonText(width: 110, height: 22),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView.separated(
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: 6,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, __) => const SkeletonListTile(),
            ),
          ),
        ],
      ),
    );
  }
}

/// 22. RETURNS LIST SKELETON
class ReturnsListSkeleton extends StatelessWidget {
  const ReturnsListSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const InvoiceListSkeleton();
  }
}

/// 23. ACCOUNTS PAGE SKELETON
class AccountsPageSkeleton extends StatelessWidget {
  const AccountsPageSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const CustomerListSkeleton();
  }
}

/// 24. SETTINGS FORM PAGES SKELETON (Tax, Profile, Backup, Categories)
class SettingsFormSkeleton extends StatelessWidget {
  const SettingsFormSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerEffect(
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ...List.generate(
              3,
              (_) => const Padding(
                padding: EdgeInsets.only(bottom: 16),
                child: SkeletonCard(
                  height: 120,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      SkeletonText(width: 140, height: 16),
                      SkeletonBox(height: 42, borderRadius: 8),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const SkeletonButton(height: 48),
          ],
        ),
      ),
    );
  }
}
