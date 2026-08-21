import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../application/bloc/accounts_bloc.dart';
import '../../../application/di/injection.dart';
import '../../../const/colors.dart';
import '../../../domain/entities/business_entity.dart';
import '../../../domain/entities/customer_entity.dart';
import '../../../domain/entities/expense_entity.dart';
import '../../../domain/repositories/auth_repository.dart';
import '../../../domain/repositories/expense_repository.dart';
import '../../../infrastructure/pdf/pdf_statement_service.dart';
import '../../../application/routing/route_names.dart';
import '../../widgets/app_card.dart';
import '../../widgets/ui_state_widgets.dart';

class ExpenseAccountDetailsPage extends StatefulWidget {
  final ExpenseAccountSummary? account;

  const ExpenseAccountDetailsPage({super.key, this.account});

  @override
  State<ExpenseAccountDetailsPage> createState() => _ExpenseAccountDetailsPageState();
}

class _ExpenseAccountDetailsPageState extends State<ExpenseAccountDetailsPage> {
  late ExpenseAccountSummary _account;
  List<ExpenseEntity> _accountExpenses = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _account = widget.account ??
        const ExpenseAccountSummary(
          id: 'EXP_ELECTRICITY',
          title: 'Electricity',
          category: 'Electricity',
          transactionCount: 5,
          currentMonthTotal: 1500,
          outstandingBalance: 500,
        );

    _loadExpenseTransactions();
  }

  Future<void> _loadExpenseTransactions() async {
    try {
      final expRepo = getIt<ExpenseRepository>();
      final allExpenses = await expRepo.getExpenses(category: _account.category);
      allExpenses.sort((a, b) => b.expenseDate.compareTo(a.expenseDate));

      setState(() {
        _accountExpenses = allExpenses;
        _isLoading = false;
      });
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  void _showEditExpenseAccountDialog(BuildContext context) {
    context.push(RouteNames.createMaster, extra: _account);
  }


  void _confirmDeleteExpenseAccount(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Expense Account'),
        content: Text('Are you sure you want to delete the "${_account.title}" account?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger, foregroundColor: Colors.white),
            onPressed: () {
              context.read<AccountsBloc>().add(DeleteExpenseAccountEvent(_account.category));
              Navigator.pop(ctx);
              context.pop();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showPayAccountDialog(BuildContext context) {
    final amountCtrl = TextEditingController(text: _account.outstandingBalance > 0 ? _account.outstandingBalance.toInt().toString() : '');
    final noteCtrl = TextEditingController();
    String selectedMethod = 'Cash';

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (dialogCtx, setDialogState) {
            return AlertDialog(
              title: Text('Pay Account (${_account.title})', style: const TextStyle(fontWeight: FontWeight.w800)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Outstanding Account Balance: ${_formatCurrency(_account.outstandingBalance)}',
                      style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.warning),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: amountCtrl,
                      keyboardType: TextInputType.number,
                      autofocus: true,
                      decoration: InputDecoration(
                        labelText: 'Payment Amount (₹) *',
                        prefixText: '₹ ',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: selectedMethod,
                      decoration: InputDecoration(
                        labelText: 'Payment Method',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      items: ['Cash', 'GPay/UPI', 'Card', 'Account']
                          .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) setDialogState(() => selectedMethod = val);
                      },
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: noteCtrl,
                      decoration: InputDecoration(
                        labelText: 'Note / Reference',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(dialogCtx), child: const Text('Cancel')),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryBlue, foregroundColor: Colors.white),
                  onPressed: () {
                    final amt = double.tryParse(amountCtrl.text.trim()) ?? 0.0;
                    if (amt > 0) {
                      context.read<AccountsBloc>().add(
                            RecordExpensePaymentEvent(
                              category: _account.category,
                              amount: amt,
                              paymentMethod: selectedMethod,
                              note: noteCtrl.text.trim(),
                              date: DateTime.now(),
                            ),
                          );

                      setState(() {
                        final newDue = (_account.outstandingBalance - amt).clamp(0.0, double.infinity);
                        _account = ExpenseAccountSummary(
                          id: _account.id,
                          title: _account.title,
                          category: _account.category,
                          transactionCount: _account.transactionCount + 1,
                          currentMonthTotal: _account.currentMonthTotal + amt,
                          outstandingBalance: newDue,
                          lastTransactionDate: DateTime.now(),
                        );
                      });

                      _loadExpenseTransactions();
                      Navigator.pop(dialogCtx);
                    }
                  },
                  child: const Text('Record Payment'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _generatePdfStatement() async {
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

      double runningBalance = 0.0;
      final List<PdfStatementLedgerRow> rows = [];

      for (var exp in _accountExpenses.reversed) {
        runningBalance += exp.amount;
        rows.add(
          PdfStatementLedgerRow(
            date: DateFormat('MMM dd, yyyy').format(exp.expenseDate),
            description: exp.title.isNotEmpty ? exp.title : exp.category,
            reference: exp.paymentMode,
            debit: exp.amount,
            credit: 0.0,
            balance: runningBalance,
          ),
        );
      }

      final totalExp = _accountExpenses.fold(0.0, (sum, e) => sum + e.amount);

      await PdfStatementService.shareCustomerStatement(
        business: business,
        customer: CustomerEntity(
          id: _account.id,
          name: '${_account.title} Account',
          phone: '',
          email: '',
          address: 'Expense Category: ${_account.category}',
          outstandingBalance: _account.outstandingBalance,
          createdAt: DateTime.now(),
        ),
        totalPurchases: totalExp,
        totalPaid: 0.0,
        outstandingBalance: _account.outstandingBalance,
        ledgerRows: rows,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to generate PDF: $e'), backgroundColor: AppColors.danger),
        );
      }
    }
  }

  String _formatCurrency(double amount) {
    final formatter = NumberFormat.currency(symbol: '₹', decimalDigits: 0, locale: 'en_IN');
    return formatter.format(amount);
  }

  @override
  Widget build(BuildContext context) {
    final totalRecorded = _accountExpenses.fold(0.0, (sum, e) => sum + e.amount);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('${_account.title} Account'),
        backgroundColor: AppColors.deepNavy,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => _showEditExpenseAccountDialog(context),
            tooltip: 'Edit Account',
          ),
          IconButton(
            icon: const Icon(Icons.picture_as_pdf_outlined),
            onPressed: _generatePdfStatement,
            tooltip: 'PDF Statement',
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (val) {
              if (val == 'delete') _confirmDeleteExpenseAccount(context);
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete_outline, color: Colors.red, size: 18), SizedBox(width: 8), Text('Delete Account', style: TextStyle(color: Colors.red))])),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const CustomerDetailsSkeleton()
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Expense Account Header Card
                  AppCard(
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.warning.withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.account_balance_wallet_outlined, color: AppColors.warning, size: 28),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(_account.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.darkBlueText)),
                              const SizedBox(height: 2),
                              Text('Account ID: ${_account.id} • Category: ${_account.category}', style: const TextStyle(fontSize: 12, color: AppColors.secondaryText)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Financial Summary Cards
                  Row(
                    children: [
                      Expanded(
                        child: AppCard(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('This Month', style: TextStyle(fontSize: 11, color: AppColors.secondaryText)),
                              const SizedBox(height: 4),
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(_formatCurrency(_account.currentMonthTotal), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.darkBlueText)),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: AppCard(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Total Recorded', style: TextStyle(fontSize: 11, color: AppColors.secondaryText)),
                              const SizedBox(height: 4),
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(_formatCurrency(totalRecorded), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.warning)),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: AppCard(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Outstanding', style: TextStyle(fontSize: 11, color: AppColors.secondaryText)),
                              const SizedBox(height: 4),
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(_formatCurrency(_account.outstandingBalance), style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: _account.outstandingBalance > 0 ? AppColors.warning : AppColors.secondaryText)),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Actions Row
                  if (_account.outstandingBalance > 0)
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.warning,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        onPressed: () => _showPayAccountDialog(context),
                        icon: const Icon(Icons.payment_outlined),
                        label: const Text('+ Pay Account', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
                      ),
                    ),
                  const SizedBox(height: 24),

                  // Expense Transactions List
                  const Text(
                    'Expense Transactions',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.darkBlueText),
                  ),
                  const SizedBox(height: 10),

                  if (_accountExpenses.isEmpty)
                    const EmptyState(
                      title: 'No expenses for this account',
                      message: 'Expenses recorded under this category will appear here.',
                      icon: Icons.money_off_outlined,
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _accountExpenses.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (ctx, idx) {
                        final exp = _accountExpenses[idx];
                        return AppCard(
                          padding: const EdgeInsets.all(14),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(exp.title.isNotEmpty ? exp.title : exp.category, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                                  const SizedBox(height: 2),
                                  Text('${DateFormat('MMM dd, yyyy • h:mm a').format(exp.expenseDate)} • Mode: ${exp.paymentMode}', style: const TextStyle(fontSize: 12, color: AppColors.secondaryText)),
                                ],
                              ),
                              Text('- ${_formatCurrency(exp.amount)}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: AppColors.danger)),
                            ],
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
    );
  }
}
