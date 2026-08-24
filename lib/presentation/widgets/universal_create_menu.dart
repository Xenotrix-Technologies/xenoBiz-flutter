import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../application/routing/route_names.dart';
import '../../const/colors.dart';
import '../../domain/entities/invoice_entity.dart';
import '../invoices/pages/return_voucher_screen.dart';

class UniversalCreateOverlay extends StatefulWidget {
  final VoidCallback onDismiss;

  const UniversalCreateOverlay({
    super.key,
    required this.onDismiss,
  });

  @override
  State<UniversalCreateOverlay> createState() => _UniversalCreateOverlayState();
}

class _UniversalCreateOverlayState extends State<UniversalCreateOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<double> _scaleAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );

    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );

    _scaleAnim = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: Curves.easeOutBack,
      ),
    );

    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animController,
        curve: Curves.easeOutCubic,
      ),
    );

    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _handleDismiss() {
    _animController.reverse().then((_) {
      if (mounted) {
        widget.onDismiss();
      }
    });
  }

  void _onActionTap(VoidCallback action) {
    // _animController.reverse().then((_) {
    //   if (mounted) {
    //     widget.onDismiss();
    //     action();
    //   }
    // });
    widget.onDismiss();
    action();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom + 70;

    return Stack(
      children: [
        // Backdrop Blur & Dim
        GestureDetector(
          onTap: _handleDismiss,
          child: FadeTransition(
            opacity: _fadeAnim,
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Container(
                color: Colors.black.withValues(alpha: 0.45),
              ),
            ),
          ),
        ),

        // Animated Popup Card
        Positioned(
          left: 16,
          right: 16,
          bottom: bottomInset,
          child: SlideTransition(
            position: _slideAnim,
            child: ScaleTransition(
              scale: _scaleAnim,
              alignment: Alignment.bottomCenter,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  constraints: const BoxConstraints(maxHeight: 520),
                  padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 25,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Row(
                            children: [
                              Icon(
                                Icons.add_circle_outline_rounded,
                                color: AppColors.primaryBlue,
                                size: 22,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Create',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.darkBlueText,
                                  letterSpacing: -0.3,
                                ),
                              ),
                            ],
                          ),
                          InkWell(
                            onTap: _handleDismiss,
                            borderRadius: BorderRadius.circular(14),
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF3F4F6),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Icon(
                                Icons.close_rounded,
                                size: 18,
                                color: AppColors.secondaryText,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Grid of 9 Actions (3 columns x 3 rows)
                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 3,
                        childAspectRatio: 1.0,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 10,
                        children: [
                          // Row 1
                          // 1. Invoice
                          _ActionCard(
                            title: 'Invoice',
                            subtitle: 'Sales & Docs',
                            icon: Icons.receipt_long_rounded,
                            iconColor: AppColors.primaryBlue,
                            bgColor:
                                AppColors.primaryBlue.withValues(alpha: 0.1),
                            onTap: () => _onActionTap(() {
                              context.push(
                                RouteNames.createInvoice,
                                extra: {'invoiceType': InvoiceType.sale},
                              );
                            }),
                          ),
                          // 2. Purchase Invoice
                          _ActionCard(
                            title: 'Purchase Invoice',
                            subtitle: 'Supplier Bill',
                            icon: Icons.shopping_bag_outlined,
                            iconColor: const Color(0xFF0D9488),
                            bgColor:
                                const Color(0xFF0D9488).withValues(alpha: 0.1),
                            onTap: () => _onActionTap(() {
                              context.push(
                                RouteNames.createInvoice,
                                extra: {'invoiceType': InvoiceType.purchase},
                              );
                            }),
                          ),
                          // 3. Quotation
                          _ActionCard(
                            title: 'Quotation',
                            subtitle: 'Estimate',
                            icon: Icons.request_quote_rounded,
                            iconColor: const Color(0xFF0284C7),
                            bgColor:
                                const Color(0xFF0284C7).withValues(alpha: 0.1),
                            onTap: () => _onActionTap(() {
                              context.push(
                                RouteNames.createInvoice,
                                extra: {
                                  'invoiceType': InvoiceType.sale,
                                  'isQuotation': true,
                                },
                              );
                            }),
                          ),
                          // Row 2
                          // 4. Payment
                          _ActionCard(
                            title: 'Payment',
                            subtitle: 'Money Out',
                            icon: Icons.arrow_upward_rounded,
                            iconColor: AppColors.danger,
                            bgColor: AppColors.danger.withValues(alpha: 0.1),
                            onTap: () => _onActionTap(() {
                              context.push(RouteNames.expense);
                            }),
                          ),
                          // 5. Receipt
                          _ActionCard(
                            title: 'Receipt',
                            subtitle: 'Money In',
                            icon: Icons.arrow_downward_rounded,
                            iconColor: AppColors.success,
                            bgColor: AppColors.success.withValues(alpha: 0.1),
                            onTap: () => _onActionTap(() {
                              context.push(RouteNames.income);
                            }),
                          ),
                          // 6. Party
                          _ActionCard(
                            title: 'Party',
                            subtitle: 'Customer / Supplier',
                            icon: Icons.people_alt_outlined,
                            iconColor: AppColors.deepNavy,
                            bgColor: AppColors.deepNavy.withValues(alpha: 0.1),
                            onTap: () => _onActionTap(() {
                              context.push(RouteNames.createMaster, extra: 1);
                            }),
                          ),
                          // Row 3
                          // 7. Item
                          _ActionCard(
                            title: 'Item',
                            subtitle: 'Product / Service',
                            icon: Icons.inventory_2_outlined,
                            iconColor: AppColors.warning,
                            bgColor: AppColors.warning.withValues(alpha: 0.1),
                            onTap: () => _onActionTap(() {
                              context.push(RouteNames.createMaster, extra: 0);
                            }),
                          ),
                          // 8. Sales Return
                          _ActionCard(
                            title: 'Sales Return',
                            subtitle: 'Credit Note',
                            icon: Icons.assignment_return_outlined,
                            iconColor: const Color(0xFF7C3AED),
                            bgColor:
                                const Color(0xFF7C3AED).withValues(alpha: 0.1),
                            onTap: () => _onActionTap(() {
                              context.push(
                                RouteNames.createReturn,
                                extra: {'returnType': ReturnType.salesReturn},
                              );
                            }),
                          ),
                          // 9. Purchase Return
                          _ActionCard(
                            title: 'Purchase Return',
                            subtitle: 'Debit Note',
                            icon: Icons.settings_backup_restore_rounded,
                            iconColor: const Color(0xFFD97706),
                            bgColor:
                                const Color(0xFFD97706).withValues(alpha: 0.1),
                            onTap: () => _onActionTap(() {
                              context.push(
                                RouteNames.createReturn,
                                extra: {
                                  'returnType': ReturnType.purchaseReturn
                                },
                              );
                            }),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final Color bgColor;
  final VoidCallback onTap;

  const _ActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.bgColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        splashColor: iconColor.withValues(alpha: 0.15),
        highlightColor: iconColor.withValues(alpha: 0.05),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFFE5E7EB),
              width: 1.0,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Icon(
                    icon,
                    color: iconColor,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                title,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.darkBlueText,
                  height: 1.15,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w500,
                  color: AppColors.secondaryText,
                  height: 1.15,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
