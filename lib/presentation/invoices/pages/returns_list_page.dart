import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../application/di/injection.dart';
import '../../../application/routing/route_names.dart';
import '../../../const/colors.dart';
import '../../../const/sizes.dart';
import '../../../domain/entities/invoice_entity.dart';
import '../../../domain/entities/invoice_return_entity.dart';
import '../../../domain/repositories/returns_repository.dart';
import '../../widgets/app_card.dart';
import '../../widgets/ui_state_widgets.dart';
import 'return_voucher_screen.dart';

class ReturnsListPage extends StatefulWidget {
  final InvoiceType type;

  const ReturnsListPage({super.key, required this.type});

  @override
  State<ReturnsListPage> createState() => _ReturnsListPageState();
}

class _ReturnsListPageState extends State<ReturnsListPage> {
  bool _isLoading = true;
  List<InvoiceReturnEntity> _returns = [];

  @override
  void initState() {
    super.initState();
    _fetchReturns();
  }

  Future<void> _fetchReturns() async {
    setState(() => _isLoading = true);
    try {
      final list = await getIt<ReturnsRepository>().getReturns(widget.type);
      if (mounted) {
        setState(() {
          _returns = list;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  ReturnType get _rType => widget.type == InvoiceType.sale ? ReturnType.salesReturn : ReturnType.purchaseReturn;

  @override
  Widget build(BuildContext context) {
    final title = widget.type == InvoiceType.sale ? 'Sales Returns' : 'Purchase Returns';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(title),
        backgroundColor: AppColors.deepNavy,
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: null,
        backgroundColor: AppColors.primary,
        onPressed: () async {
          await context.push(
            RouteNames.createReturn,
            extra: {
              'returnType': _rType,
            },
          );
          _fetchReturns();
        },
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          widget.type == InvoiceType.sale ? 'New Sales Return' : 'New Purchase Return',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
      ),
      body: _isLoading
          ? const ReturnsListSkeleton()
          : _returns.isEmpty
              ? EmptyState(
                  title: 'No Returns Recorded',
                  message: 'Create a return by selecting an existing invoice.',
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _returns.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (ctx, idx) {
                    final item = _returns[idx];
                    return AppCard(
                      onTap: () async {
                        await context.push(
                          RouteNames.createReturn,
                          extra: {
                            'returnType': _rType,
                            'existingReturn': item,
                          },
                        );
                        _fetchReturns();
                      },
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.warning.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                            ),
                            child: const Icon(Icons.assignment_return_outlined, color: AppColors.warning),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.returnNumber,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.onSurface,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Invoice: ${item.invoiceNumber}',
                                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  item.partyName,
                                  style: const TextStyle(fontSize: 12, color: AppColors.outline),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '₹${item.totalAmount.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.danger,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Text(
                                    '${item.returnDate.day}/${item.returnDate.month}/${item.returnDate.year}',
                                    style: const TextStyle(fontSize: 11, color: AppColors.outline),
                                  ),
                                  const SizedBox(width: 4),
                                  const Icon(Icons.edit_outlined, size: 16, color: AppColors.primary),
                                ],
                              ),
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
