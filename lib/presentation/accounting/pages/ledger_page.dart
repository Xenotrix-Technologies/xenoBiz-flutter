import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../application/di/injection.dart';
import '../../../application/routing/route_names.dart';
import '../../../const/colors.dart';
import '../../../domain/entities/accounting_entities.dart';
import '../../../domain/entities/invoice_entity.dart';
import '../../../infrastructure/repositories/accounting_repository.dart';
import '../../invoices/pages/return_voucher_screen.dart';

class LedgerPage extends StatefulWidget {
  final String? initialAccount;
  const LedgerPage({super.key, this.initialAccount});

  @override
  State<LedgerPage> createState() => _LedgerPageState();
}

class _LedgerPageState extends State<LedgerPage> {
  late String _selectedAccount;
  String _selectedDateRange = 'This Month';
  String _selectedFinancialYear = 'FY 2026-27';
  String _selectedVoucherType = 'All';
  String _searchQuery = '';

  final List<String> _accountOptions = [
    'Capital Account',
    'Rahul Sharma (Customer)',
    'Metro Wholesalers (Supplier)',
    'Cash Account',
    'HDFC Bank Main A/c',
    'SBI Current A/c',
    'Shop Rent Expense',
    'Sales Revenue Account',
  ];

  final List<String> _dateRanges = [
    'This Month',
    'Today',
    'This Week',
    'Previous Month',
    'This Quarter',
    'This Year',
    'Custom Range',
  ];
  final List<String> _financialYears = ['FY 2026-27', 'FY 2025-26', 'FY 2024-25'];

  final List<String> _voucherTypeChips = [
    'All',
    'Sale',
    'Purchase',
    'Payment',
    'Receipt',
    'Journal',
    'Contra',
    'Sales Return',
    'Purchase Return',
  ];

  @override
  void initState() {
    super.initState();
    _selectedAccount = widget.initialAccount ?? _accountOptions.first;
  }

  String _formatCurrency(double amount) {
    final formatter =
        NumberFormat.currency(symbol: '₹', decimalDigits: 2, locale: 'en_IN');
    return formatter.format(amount);
  }

  void _showEditOpeningBalanceModal(BuildContext context) {
    final repo = getIt<AccountingRepository>();
    double currentAmt = repo.getOpeningBalance(_selectedAccount);
    bool isDebit = repo.isOpeningBalanceDebit(_selectedAccount);

    final amtCtrl =
        TextEditingController(text: currentAmt.toStringAsFixed(2));
    DateTime effDate = DateTime.now().subtract(const Duration(days: 30));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetCtx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Edit Opening Balance',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.darkBlueText,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(sheetCtx),
                      ),
                    ],
                  ),
                  const Divider(height: 16),
                  Text(
                    'Account: $_selectedAccount',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryBlue,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Balance Type (Debit / Credit)
                  const Text(
                    'Opening Balance Type',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.secondaryText,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: ChoiceChip(
                          label: const Center(
                              child: Text('Debit (Dr.)',
                                  style: TextStyle(fontWeight: FontWeight.w700))),
                          selected: isDebit,
                          selectedColor: AppColors.success,
                          labelStyle: TextStyle(
                              color: isDebit ? Colors.white : AppColors.darkBlueText),
                          onSelected: (val) {
                            if (val) setSheetState(() => isDebit = true);
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ChoiceChip(
                          label: const Center(
                              child: Text('Credit (Cr.)',
                                  style: TextStyle(fontWeight: FontWeight.w700))),
                          selected: !isDebit,
                          selectedColor: AppColors.danger,
                          labelStyle: TextStyle(
                              color: !isDebit ? Colors.white : AppColors.darkBlueText),
                          onSelected: (val) {
                            if (val) setSheetState(() => isDebit = false);
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Amount
                  TextField(
                    controller: amtCtrl,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: 'Opening Amount (₹)',
                      prefixIcon: const Icon(Icons.currency_rupee),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Effective Date
                  InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: effDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2030),
                      );
                      if (picked != null) {
                        setSheetState(() => effDate = picked);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade400),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Effective Date',
                              style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.secondaryText)),
                          Text(DateFormat('dd MMM yyyy').format(effDate),
                              style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.darkBlueText)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(sheetCtx),
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryBlue,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () {
                            final parsed =
                                double.tryParse(amtCtrl.text.trim()) ?? currentAmt;
                            repo.updateOpeningBalance(
                                _selectedAccount, parsed, isDebit);
                            Navigator.pop(sheetCtx);
                            setState(() {});
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    'Opening balance updated for $_selectedAccount'),
                                backgroundColor: AppColors.success,
                              ),
                            );
                          },
                          child: const Text('Update'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showAccountDetailsModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Account Information',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.darkBlueText,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const Divider(height: 16),
              _buildDetailRow('Account Name', _selectedAccount),
              _buildDetailRow(
                  'Account Group',
                  _selectedAccount.contains('Customer')
                      ? 'Debtors / Customers'
                      : _selectedAccount.contains('Supplier')
                          ? 'Creditors / Suppliers'
                          : _selectedAccount.contains('Bank')
                              ? 'Bank Accounts'
                              : _selectedAccount.contains('Cash')
                                  ? 'Cash-in-Hand'
                                  : 'General Ledger'),
              _buildDetailRow('Contact Phone', '+91 98765 43210'),
              _buildDetailRow('GSTIN', '27AAACG1234F1Z5'),
              _buildDetailRow('Current Status', 'Active'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String val) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.secondaryText)),
          Text(val,
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.darkBlueText)),
        ],
      ),
    );
  }

  void _showExportOptionsModal(BuildContext context, int count) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Export / Share Ledger',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.darkBlueText,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                Text(
                  'Exporting filtered ledger for "$_selectedAccount" ($count records matching criteria).',
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.secondaryText),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
                  title: const Text('PDF Statement (A4 Formatted)',
                      style: TextStyle(fontWeight: FontWeight.w700)),
                  subtitle: Text(
                      '${_selectedAccount.replaceAll(' ', '_')}_Ledger_Statement.pdf'),
                  onTap: () {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            'Generated ${_selectedAccount.replaceAll(' ', '_')}_Ledger_Statement.pdf'),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading:
                      const Icon(Icons.table_chart_outlined, color: Colors.green),
                  title: const Text('Excel / CSV Spreadsheet',
                      style: TextStyle(fontWeight: FontWeight.w700)),
                  subtitle: Text(
                      '${_selectedAccount.replaceAll(' ', '_')}_Ledger.csv'),
                  onTap: () {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            'Generated ${_selectedAccount.replaceAll(' ', '_')}_Ledger.csv'),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.share, color: AppColors.primaryBlue),
                  title: const Text('Share Statement',
                      style: TextStyle(fontWeight: FontWeight.w700)),
                  subtitle: const Text('Share via WhatsApp, Email or Drive'),
                  onTap: () {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Opening platform share sheet...'),
                        backgroundColor: AppColors.primaryBlue,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _navigateToTransactionView(
      BuildContext context, LedgerTransactionEntity tx) {
    final vType = tx.voucherType.toLowerCase();
    if (vType.contains('sale') && !vType.contains('return')) {
      context.push(RouteNames.createInvoice,
          extra: {'invoiceType': InvoiceType.sale});
    } else if (vType.contains('purchase') && !vType.contains('return')) {
      context.push(RouteNames.createInvoice,
          extra: {'invoiceType': InvoiceType.purchase});
    } else if (vType.contains('return')) {
      context.push(RouteNames.createReturn, extra: {
        'returnType': vType.contains('sale')
            ? ReturnType.salesReturn
            : ReturnType.purchaseReturn
      });
    } else if (vType.contains('journal')) {
      context.push(RouteNames.journal);
    } else if (vType.contains('contra')) {
      context.push(RouteNames.contra);
    } else {
      context.push(RouteNames.dailyBook);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormatter = DateFormat('dd MMM yyyy');

    final repo = getIt<AccountingRepository>();
    final rawTransactions = repo.getLedgerTransactions(_selectedAccount);
    final openingBal = repo.getOpeningBalance(_selectedAccount);
    final isOpeningDr = repo.isOpeningBalanceDebit(_selectedAccount);

    // Apply filtering
    final filtered = rawTransactions.where((tx) {
      if (_selectedVoucherType != 'All') {
        if (!tx.voucherType
            .toLowerCase()
            .contains(_selectedVoucherType.toLowerCase())) {
          return false;
        }
      }

      if (_searchQuery.trim().isEmpty) return true;
      final q = _searchQuery.toLowerCase();
      return tx.particulars.toLowerCase().contains(q) ||
          tx.referenceNumber.toLowerCase().contains(q) ||
          tx.voucherType.toLowerCase().contains(q);
    }).toList();

    // Sort Chronologically: Oldest -> Newest
    filtered.sort((a, b) => a.date.compareTo(b.date));

    double totalDebit = filtered.fold(0.0, (sum, tx) => sum + tx.debit);
    double totalCredit = filtered.fold(0.0, (sum, tx) => sum + tx.credit);
    double closingBal = isOpeningDr
        ? (openingBal + totalDebit - totalCredit)
        : (openingBal + totalCredit - totalDebit);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Account Ledger'),
        backgroundColor: AppColors.deepNavy,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf_outlined),
            onPressed: () => _showExportOptionsModal(context, filtered.length),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: (val) {
              if (val == 'export') {
                _showExportOptionsModal(context, filtered.length);
              } else if (val == 'edit_ob') {
                _showEditOpeningBalanceModal(context);
              } else if (val == 'details') {
                _showAccountDetailsModal(context);
              }
            },
            itemBuilder: (ctx) => [
              const PopupMenuItem(
                value: 'export',
                child: Row(
                  children: [
                    Icon(Icons.ios_share_outlined,
                        size: 18, color: AppColors.primaryBlue),
                    SizedBox(width: 8),
                    Text('Export / Share Ledger'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'edit_ob',
                child: Row(
                  children: [
                    Icon(Icons.edit_note,
                        size: 18, color: AppColors.primaryBlue),
                    SizedBox(width: 8),
                    Text('Edit Opening Balance'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'details',
                child: Row(
                  children: [
                    Icon(Icons.info_outline,
                        size: 18, color: AppColors.darkBlueText),
                    SizedBox(width: 8),
                    Text('Account Details'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter & Account Selector Card
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Prominent Account Selector Dropdown
                DropdownButtonFormField<String>(
                  initialValue: _accountOptions.contains(_selectedAccount)
                      ? _selectedAccount
                      : _accountOptions.first,
                  isExpanded: true,
                  decoration: InputDecoration(
                    labelText: 'Select Account Ledger',
                    labelStyle: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryBlue),
                    prefixIcon: const Icon(Icons.account_balance_wallet_outlined,
                        color: AppColors.primaryBlue),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(color: AppColors.primaryBlue, width: 1.5),
                    ),
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                  items: _accountOptions.map((acc) {
                    return DropdownMenuItem(
                      value: acc,
                      child: Text(
                        acc,
                        style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            color: AppColors.darkBlueText),
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedAccount = val);
                  },
                ),
                const SizedBox(height: 12),

                // Period & FY Filters
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _selectedDateRange,
                        isExpanded: true,
                        decoration: InputDecoration(
                          labelText: 'Period',
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 8),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        items: _dateRanges.map((r) {
                          return DropdownMenuItem(
                            value: r,
                            child: Text(r,
                                style: const TextStyle(
                                    fontSize: 12, fontWeight: FontWeight.w600)),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() => _selectedDateRange = val);
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _selectedFinancialYear,
                        isExpanded: true,
                        decoration: InputDecoration(
                          labelText: 'Financial Year',
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 8),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        items: _financialYears.map((fy) {
                          return DropdownMenuItem(
                            value: fy,
                            child: Text(fy,
                                style: const TextStyle(
                                    fontSize: 12, fontWeight: FontWeight.w600)),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() => _selectedFinancialYear = val);
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Search field
                TextField(
                  onChanged: (val) => setState(() => _searchQuery = val),
                  decoration: InputDecoration(
                    hintText: 'Search particulars, ref no...',
                    prefixIcon: const Icon(Icons.search,
                        size: 18, color: AppColors.secondaryText),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 16),
                            onPressed: () => setState(() => _searchQuery = ''),
                          )
                        : null,
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(height: 10),

                // Transaction Type Filter Chips Row
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _voucherTypeChips.map((type) {
                      final selected = _selectedVoucherType == type;
                      return Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: ChoiceChip(
                          label: Text(type),
                          selected: selected,
                          selectedColor: AppColors.primaryBlue,
                          backgroundColor: AppColors.pageBackground,
                          labelStyle: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: selected ? Colors.white : AppColors.darkBlueText,
                          ),
                          onSelected: (val) {
                            if (val) setState(() => _selectedVoucherType = type);
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),

          // Summary Banner Card (Opening Bal | Total Debit | Total Credit | Closing Bal)
          Container(
            margin: const EdgeInsets.all(14),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.deepNavy,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: AppColors.deepNavy.withValues(alpha: 0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSummaryColumn(
                    'Opening Bal',
                    '${_formatCurrency(openingBal)} ${isOpeningDr ? 'Dr' : 'Cr'}',
                    Colors.white70),
                _buildSummaryColumn(
                    'Total Debit', _formatCurrency(totalDebit), Colors.greenAccent),
                _buildSummaryColumn('Total Credit', _formatCurrency(totalCredit),
                    Colors.orangeAccent),
                _buildSummaryColumn('Closing Bal', _formatCurrency(closingBal),
                    Colors.white),
              ],
            ),
          ),

          // Ledger List / Table Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: const Color(0xFFF3F4F6),
            child: const Row(
              children: [
                Expanded(
                    flex: 3,
                    child: Text('DATE / VOUCHER',
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: AppColors.darkBlueText))),
                Expanded(
                    flex: 2,
                    child: Text('DEBIT (Dr.)',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: AppColors.success))),
                Expanded(
                    flex: 2,
                    child: Text('CREDIT (Cr.)',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: AppColors.danger))),
                Expanded(
                    flex: 2,
                    child: Text('BALANCE',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: AppColors.darkBlueText))),
              ],
            ),
          ),

          // Ledger Table Rows
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.receipt_long_outlined,
                              size: 48, color: AppColors.secondaryText),
                          const SizedBox(height: 12),
                          const Text(
                            'No transactions found',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: AppColors.darkBlueText),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'There\'s no ledger activity for "$_selectedAccount" during the selected period.',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                fontSize: 12, color: AppColors.secondaryText),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.separated(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: filtered.length,
                    separatorBuilder: (ctx, i) => const Divider(height: 1),
                    itemBuilder: (ctx, idx) {
                      final tx = filtered[idx];
                      return InkWell(
                        onTap: () =>
                            _navigateToTransactionView(context, tx),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      dateFormatter.format(tx.date),
                                      style: const TextStyle(
                                          fontSize: 11,
                                          color: AppColors.secondaryText,
                                          fontWeight: FontWeight.w600),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      tx.particulars,
                                      style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.darkBlueText),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      tx.referenceNumber,
                                      style: const TextStyle(
                                          fontSize: 11,
                                          color: AppColors.primaryBlue,
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  tx.debit > 0
                                      ? _formatCurrency(tx.debit)
                                      : '-',
                                  textAlign: TextAlign.right,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: tx.debit > 0
                                        ? AppColors.success
                                        : AppColors.secondaryText,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  tx.credit > 0
                                      ? _formatCurrency(tx.credit)
                                      : '-',
                                  textAlign: TextAlign.right,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: tx.credit > 0
                                        ? AppColors.danger
                                        : AppColors.secondaryText,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  _formatCurrency(tx.runningBalance),
                                  textAlign: TextAlign.right,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.darkBlueText,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryColumn(String label, String value, Color valueColor) {
    return Column(
      children: [
        Text(label,
            style: const TextStyle(fontSize: 10, color: Colors.white70)),
        const SizedBox(height: 3),
        Text(
          value,
          style: TextStyle(
              fontSize: 12, fontWeight: FontWeight.w800, color: valueColor),
        ),
      ],
    );
  }
}
