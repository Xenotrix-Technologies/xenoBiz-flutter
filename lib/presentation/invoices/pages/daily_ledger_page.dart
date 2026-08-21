import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../application/bloc/daily_ledger_bloc.dart';
import '../../../application/bloc/invoice_bloc.dart';
import '../../../application/di/injection.dart';
import '../../../application/routing/route_names.dart';
import '../../../const/colors.dart';
import '../../../domain/entities/business_entity.dart';
import '../../../domain/repositories/auth_repository.dart';
import '../../../infrastructure/pdf/pdf_ledger_service.dart';
import '../../widgets/app_card.dart';
import '../../widgets/ui_state_widgets.dart';

class DailyLedgerPage extends StatefulWidget {
  final int initialTab; // 0 for Cash In, 1 for Cash Out
  final DateTime? initialDate;

  const DailyLedgerPage({
    super.key,
    this.initialTab = 0,
    this.initialDate,
  });

  @override
  State<DailyLedgerPage> createState() => _DailyLedgerPageState();
}

class _DailyLedgerPageState extends State<DailyLedgerPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this, initialIndex: widget.initialTab);
    _selectedDate = widget.initialDate ?? DateTime.now();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DailyLedgerBloc>().add(FetchDailyLedgerDataEvent(_selectedDate));
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _changeDate(DateTime newDate) {
    setState(() => _selectedDate = newDate);
    context.read<DailyLedgerBloc>().add(ChangeLedgerDateEvent(newDate));
  }

  Future<void> _selectCustomDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      _changeDate(picked);
    }
  }

  Future<void> _showEditOpeningBalanceDialog(BuildContext context, double currentBalance) async {
    final controller = TextEditingController(text: currentBalance.toInt().toString());
    await showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Edit Opening Balance', style: TextStyle(fontWeight: FontWeight.w800)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Set starting cash balance for the selected business day:'),
              const SizedBox(height: 14),
              TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: 'Opening Balance (₹)',
                  prefixText: '₹ ',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                final val = double.tryParse(controller.text.trim()) ?? 0.0;
                context.read<DailyLedgerBloc>().add(
                      UpdateOpeningBalanceEvent(
                        selectedDate: _selectedDate,
                        newOpeningBalance: val,
                      ),
                    );
                Navigator.pop(ctx);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _generatePdfReport(DailyLedgerLoadedState state) async {
    try {
      final authRepo = getIt<AuthRepository>();
      final business = await authRepo.getBusinessProfile() ??
          BusinessEntity(
            id: 'biz',
            name: 'XenoBiz Store',
            phone: '',
            address: '',
            category: 'Retail Store',
            createdAt: DateTime.now(),
          );

      final salesPdfItems = state.salesTransactions.map((tx) {
        return PdfLedgerTransactionItem(
          time: DateFormat('h:mm a').format(tx.time),
          title: tx.title,
          type: tx.subTitle,
          paymentMethod: tx.paymentMethod,
          amount: tx.amount,
          isIncome: true,
        );
      }).toList();

      final expPdfItems = state.expenseTransactions.map((exp) {
        return PdfLedgerTransactionItem(
          time: DateFormat('h:mm a').format(exp.expenseDate),
          title: exp.title.isNotEmpty ? exp.title : exp.category,
          type: exp.category,
          paymentMethod: exp.paymentMode,
          amount: exp.amount,
          isIncome: false,
        );
      }).toList();

      await PdfLedgerService.shareLedgerReport(
        date: state.selectedDate,
        business: business,
        openingBalance: state.openingBalance,
        cashIn: state.cashIn,
        cashOut: state.cashOut,
        closingBalance: state.closingBalance,
        totalSales: state.totalSales,
        cashSales: state.cashSales,
        upiCardSales: state.upiCardSales,
        totalExpenses: state.totalExpenses,
        cashExpenses: state.cashExpenses,
        accountExpenses: state.accountExpenses,
        salesTransactions: salesPdfItems,
        expenseTransactions: expPdfItems,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to generate PDF: $e'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }

  String _formatCurrency(double amount) {
    final formatter = NumberFormat.currency(symbol: '₹', decimalDigits: 0, locale: 'en_IN');
    return formatter.format(amount);
  }

  String _formatDateHeader(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final checkDate = DateTime(date.year, date.month, date.day);

    if (checkDate == today) {
      return 'Today · ${DateFormat('d MMM yyyy').format(date)}';
    } else if (checkDate == yesterday) {
      return 'Yesterday · ${DateFormat('d MMM yyyy').format(date)}';
    } else {
      return DateFormat('EEEE, d MMM yyyy').format(date);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Financial Ledger'),
        backgroundColor: AppColors.deepNavy,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          BlocBuilder<DailyLedgerBloc, DailyLedgerState>(
            builder: (context, state) {
              if (state is DailyLedgerLoadedState) {
                return TextButton.icon(
                  onPressed: () => _generatePdfReport(state),
                  icon: const Icon(Icons.picture_as_pdf_outlined, color: Colors.white, size: 18),
                  label: const Text(
                    'PDF Report',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
          const SizedBox(width: 8),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          labelStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
          tabs: const [
            Tab(text: 'CASH IN'),
            Tab(text: 'CASH OUT'),
          ],
        ),
      ),
      body: BlocBuilder<DailyLedgerBloc, DailyLedgerState>(
        builder: (context, state) {
          if (state is DailyLedgerLoadingState || state is DailyLedgerInitialState) {
            return const DailyLedgerSkeleton();
          }

          if (state is DailyLedgerErrorState) {
            return ErrorState(
              message: state.message,
              onRetry: () =>
                  context.read<DailyLedgerBloc>().add(FetchDailyLedgerDataEvent(_selectedDate)),
            );
          }

          if (state is DailyLedgerLoadedState) {
            return Column(
              children: [
                // DATE SELECTOR BAR
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left_rounded, color: AppColors.darkBlueText),
                        onPressed: () => _changeDate(_selectedDate.subtract(const Duration(days: 1))),
                      ),
                      InkWell(
                        onTap: () => _selectCustomDate(context),
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          child: Row(
                            children: [
                              const Icon(Icons.calendar_today_outlined,
                                  size: 16, color: AppColors.primaryBlue),
                              const SizedBox(width: 8),
                              Text(
                                _formatDateHeader(state.selectedDate),
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.darkBlueText,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(Icons.arrow_drop_down, color: AppColors.secondaryText),
                            ],
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.chevron_right_rounded, color: AppColors.darkBlueText),
                        onPressed: () => _changeDate(_selectedDate.add(const Duration(days: 1))),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1, color: AppColors.border),

                // TAB BAR VIEW CONTENT
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      // TAB 1: CASH IN (Sales Income + Other Income)
                      _buildCashInTab(context, state),

                      // TAB 2: CASH OUT (Purchase Expense + Other Expense)
                      _buildCashOutTab(context, state),
                    ],
                  ),
                ),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  // PHYSICAL CASH BALANCE CARD WIDGET
  Widget _buildCashBalanceCard(BuildContext context, DailyLedgerLoadedState state) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.account_balance_wallet_outlined,
                      size: 18, color: AppColors.primaryBlue),
                  SizedBox(width: 8),
                  Text(
                    'Cash Balance Summary',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: AppColors.darkBlueText,
                    ),
                  ),
                ],
              ),
              InkWell(
                onTap: () => _showEditOpeningBalanceDialog(context, state.openingBalance),
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Row(
                    children: const [
                      Icon(Icons.edit_outlined, size: 14, color: AppColors.primaryBlue),
                      SizedBox(width: 4),
                      Text(
                        'Edit Opening',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryBlue,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Opening Balance', style: TextStyle(fontSize: 13, color: AppColors.secondaryText)),
              Text(_formatCurrency(state.openingBalance), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 6),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total Cash In', style: TextStyle(fontSize: 13, color: AppColors.secondaryText)),
              Text('+ ${_formatCurrency(state.cashIn)}',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.success)),
            ],
          ),
          const SizedBox(height: 6),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total Cash Out', style: TextStyle(fontSize: 13, color: AppColors.secondaryText)),
              Text('- ${_formatCurrency(state.cashOut)}',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.danger)),
            ],
          ),
          const Divider(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Closing Balance', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
              Text(
                _formatCurrency(state.closingBalance),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.darkBlueText,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // CASH IN TAB UI (Sales Income + Other Income)
  Widget _buildCashInTab(BuildContext context, DailyLedgerLoadedState state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCashBalanceCard(context, state),
          const SizedBox(height: 16),

          // Cash In Summary Breakdown
          AppCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Cash In Classification',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppColors.darkBlueText,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Sales Income', style: TextStyle(color: AppColors.secondaryText, fontSize: 13)),
                    Text(_formatCurrency(state.totalSales), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Other Income', style: TextStyle(color: AppColors.secondaryText, fontSize: 13)),
                    Text(_formatCurrency(state.otherIncomeTotal),
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.success)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          const Text(
            'Cash In Transactions',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: AppColors.darkBlueText,
            ),
          ),
          const SizedBox(height: 10),

          if (state.salesTransactions.isEmpty)
            const EmptyState(
              title: 'No Cash In records for this date',
              message: 'Sales Income and Other Income entries will appear here.',
              icon: Icons.arrow_downward_rounded,
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: state.salesTransactions.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (ctx, idx) {
                final tx = state.salesTransactions[idx];
                return AppCard(
                  onTap: () async {
                    if (tx.invoice != null) {
                      final bloc = context.read<InvoiceBloc>();
                      await context.push(
                        RouteNames.createInvoice,
                        extra: {
                          'invoiceType': tx.invoice!.type,
                          'invoiceToEdit': tx.invoice,
                        },
                      );
                      if (!mounted) return;
                      bloc.add(const FetchInvoicesEvent());
                    }
                  },
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.success.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.arrow_downward_rounded, color: AppColors.success, size: 20),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                tx.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 14,
                                  color: AppColors.darkBlueText,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${tx.subTitle} • ${DateFormat('h:mm a').format(tx.time)}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.secondaryText,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '+ ${_formatCurrency(tx.amount)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                              color: AppColors.success,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceContainerHigh,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              tx.paymentMethod,
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: AppColors.darkBlueText,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  // CASH OUT TAB UI (Purchase Expense + Other Expense)
  Widget _buildCashOutTab(BuildContext context, DailyLedgerLoadedState state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCashBalanceCard(context, state),
          const SizedBox(height: 16),

          // Cash Out Summary Breakdown
          AppCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Cash Out Classification',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppColors.darkBlueText,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total Cash Out', style: TextStyle(color: AppColors.secondaryText, fontSize: 13)),
                    Text(_formatCurrency(state.totalExpenses),
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: AppColors.warning)),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Other Expenses', style: TextStyle(color: AppColors.secondaryText, fontSize: 13)),
                    Text(_formatCurrency(state.cashExpenses),
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.danger)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          const Text(
            'Cash Out Transactions',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: AppColors.darkBlueText,
            ),
          ),
          const SizedBox(height: 10),

          if (state.expenseTransactions.isEmpty)
            const EmptyState(
              title: 'No Cash Out records for this date',
              message: 'Purchase Expenses and Other Expenses will appear here.',
              icon: Icons.money_off_outlined,
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: state.expenseTransactions.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (ctx, idx) {
                final exp = state.expenseTransactions[idx];
                return AppCard(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.danger.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.arrow_upward_rounded, color: AppColors.danger, size: 20),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                exp.title.isNotEmpty ? exp.title : exp.category,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 14,
                                  color: AppColors.darkBlueText,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Other Expense • ${exp.category} • ${DateFormat('h:mm a').format(exp.expenseDate)}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.secondaryText,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '- ${_formatCurrency(exp.amount)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                              color: AppColors.danger,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceContainerHigh,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              exp.paymentMode,
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: AppColors.darkBlueText,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
