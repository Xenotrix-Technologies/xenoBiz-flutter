import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../application/di/injection.dart';
import '../../../const/colors.dart';
import '../../../domain/entities/accounting_entities.dart';
import '../../../infrastructure/repositories/accounting_repository.dart';

class NewJournalEntryPage extends StatefulWidget {
  final JournalEntryEntity? entryToEdit;

  const NewJournalEntryPage({super.key, this.entryToEdit});

  @override
  State<NewJournalEntryPage> createState() => _NewJournalEntryPageState();
}

class _NewJournalEntryPageState extends State<NewJournalEntryPage> {
  DateTime _entryDate = DateTime.now();
  late TextEditingController _refNoController;
  late TextEditingController _narrationController;

  final List<_JournalLineInput> _lines = [];

  final List<String> _accountOptions = [
    'Cash Account',
    'HDFC Bank Main A/c',
    'SBI Current A/c',
    'Petty Cash Account',
    'Capital Account',
    'Depreciation Expense',
    'Accumulated Depreciation',
    'Rent Expense',
    'Electricity Expense',
    'Salaries & Wages',
    'Discount Allowed',
    'Discount Received',
    'Bad Debts Expense',
    'Suspense Account',
    'Opening Balance Adjustments',
  ];

  @override
  void initState() {
    super.initState();
    final edit = widget.entryToEdit;
    if (edit != null) {
      _entryDate = edit.date;
      _refNoController = TextEditingController(text: edit.referenceNumber);
      _narrationController = TextEditingController(text: edit.narration);

      for (var itm in edit.items) {
        final isDebit = itm.debit > 0;
        final amt = isDebit ? itm.debit : itm.credit;
        _lines.add(_JournalLineInput(
          accountName: itm.accountName,
          accountType: itm.accountType,
          isDebit: isDebit,
          amountController: TextEditingController(text: amt.toStringAsFixed(2)),
        ));
      }
    } else {
      final randomSuffix = (100 + (DateTime.now().millisecondsSinceEpoch % 899)).toString();
      _refNoController = TextEditingController(text: 'JV-2026-$randomSuffix');
      _narrationController = TextEditingController();

      // Default two lines: 1 Debit, 1 Credit
      _lines.add(_JournalLineInput(
        accountName: 'Depreciation Expense',
        accountType: 'Expense',
        isDebit: true,
        amountController: TextEditingController(text: '1000'),
      ));
      _lines.add(_JournalLineInput(
        accountName: 'Accumulated Depreciation',
        accountType: 'Asset',
        isDebit: false,
        amountController: TextEditingController(text: '1000'),
      ));
    }
  }

  @override
  void dispose() {
    _refNoController.dispose();
    _narrationController.dispose();
    for (var line in _lines) {
      line.amountController.dispose();
    }
    super.dispose();
  }

  double get _totalDebit {
    return _lines
        .where((l) => l.isDebit)
        .fold(0.0, (sum, l) => sum + (double.tryParse(l.amountController.text.trim()) ?? 0.0));
  }

  double get _totalCredit {
    return _lines
        .where((l) => !l.isDebit)
        .fold(0.0, (sum, l) => sum + (double.tryParse(l.amountController.text.trim()) ?? 0.0));
  }

  bool get _isBalanced {
    return (_totalDebit - _totalCredit).abs() < 0.01 && _totalDebit > 0;
  }

  void _addLine(bool isDebit) {
    setState(() {
      _lines.add(_JournalLineInput(
        accountName: _accountOptions.first,
        accountType: isDebit ? 'Expense' : 'Asset',
        isDebit: isDebit,
        amountController: TextEditingController(text: '0'),
      ));
    });
  }

  void _removeLine(int index) {
    if (_lines.length <= 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('A journal entry must have at least 2 lines.')),
      );
      return;
    }
    setState(() {
      _lines[index].amountController.dispose();
      _lines.removeAt(index);
    });
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _entryDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() => _entryDate = picked);
    }
  }

  Future<void> _saveEntry({required bool isDraft}) async {
    if (!isDraft && !_isBalanced) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debit and credit totals must be equal.'),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    final entryItems = _lines.map((l) {
      final amt = double.tryParse(l.amountController.text.trim()) ?? 0.0;
      return JournalLineItem(
        accountName: l.accountName,
        accountType: l.accountType,
        debit: l.isDebit ? amt : 0.0,
        credit: !l.isDebit ? amt : 0.0,
      );
    }).toList();

    final entry = JournalEntryEntity(
      id: widget.entryToEdit?.id ?? 'jv-${DateTime.now().millisecondsSinceEpoch}',
      date: _entryDate,
      referenceNumber: _refNoController.text.trim().isNotEmpty
          ? _refNoController.text.trim()
          : 'JV-${DateTime.now().millisecondsSinceEpoch}',
      narration: _narrationController.text.trim(),
      items: entryItems,
      status: isDraft ? JournalEntryStatus.draft : JournalEntryStatus.posted,
      createdAt: widget.entryToEdit?.createdAt ?? DateTime.now(),
    );

    final repo = getIt<AccountingRepository>();
    await repo.saveJournalEntry(entry);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isDraft ? 'Journal entry saved as draft.' : 'Journal entry posted successfully!'),
          backgroundColor: AppColors.success,
        ),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(symbol: '₹', decimalDigits: 2);
    final diff = (_totalDebit - _totalCredit).abs();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('New Journal Entry'),
        backgroundColor: AppColors.deepNavy,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Metadata Card
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: _selectDate,
                            child: InputDecorator(
                              decoration: InputDecoration(
                                labelText: 'Date',
                                prefixIcon: const Icon(Icons.calendar_today, size: 18),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              child: Text(
                                DateFormat('dd MMM yyyy').format(_entryDate),
                                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: _refNoController,
                            decoration: InputDecoration(
                              labelText: 'Ref / Voucher No',
                              prefixIcon: const Icon(Icons.tag, size: 18),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _narrationController,
                      decoration: InputDecoration(
                        labelText: 'Narration / Description',
                        hintText: 'e.g. Expense correction or depreciation adjustment',
                        prefixIcon: const Icon(Icons.notes, size: 18),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Journal Lines Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Journal Lines',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppColors.darkBlueText,
                  ),
                ),
                Row(
                  children: [
                    TextButton.icon(
                      onPressed: () => _addLine(true),
                      icon: const Icon(Icons.add, size: 16, color: AppColors.danger),
                      label: const Text('+ Debit Line', style: TextStyle(color: AppColors.danger, fontSize: 12, fontWeight: FontWeight.w700)),
                    ),
                    TextButton.icon(
                      onPressed: () => _addLine(false),
                      icon: const Icon(Icons.add, size: 16, color: AppColors.success),
                      label: const Text('+ Credit Line', style: TextStyle(color: AppColors.success, fontSize: 12, fontWeight: FontWeight.w700)),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Lines List
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _lines.length,
              itemBuilder: (ctx, idx) {
                final line = _lines[idx];
                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: line.isDebit ? AppColors.danger.withValues(alpha: 0.3) : AppColors.success.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: line.isDebit ? AppColors.danger.withValues(alpha: 0.1) : AppColors.success.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                line.isDebit ? 'DEBIT (Dr.)' : 'CREDIT (Cr.)',
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 11,
                                  color: line.isDebit ? AppColors.danger : AppColors.success,
                                ),
                              ),
                            ),
                            const Spacer(),
                            IconButton(
                              onPressed: () => _removeLine(idx),
                              icon: const Icon(Icons.delete_outline, color: Colors.grey, size: 20),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: DropdownButtonFormField<String>(
                                initialValue: _accountOptions.contains(line.accountName) ? line.accountName : _accountOptions.first,
                                isExpanded: true,
                                decoration: InputDecoration(
                                  labelText: 'Account Name',
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                ),
                                items: _accountOptions.map((acc) {
                                  return DropdownMenuItem(
                                    value: acc,
                                    child: Text(acc, style: const TextStyle(fontSize: 13)),
                                  );
                                }).toList(),
                                onChanged: (val) {
                                  if (val != null) {
                                    setState(() => line.accountName = val);
                                  }
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              flex: 1,
                              child: TextField(
                                controller: line.amountController,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                onChanged: (_) => setState(() {}),
                                decoration: InputDecoration(
                                  labelText: 'Amount (₹)',
                                  prefixText: '₹ ',
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),

            // Live Validation & Balance Summary Box
            Card(
              elevation: 0,
              color: _isBalanced ? AppColors.success.withValues(alpha: 0.08) : AppColors.danger.withValues(alpha: 0.08),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: _isBalanced ? AppColors.success : AppColors.danger,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total Debit (Dr.):', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                        Text(currencyFormatter.format(_totalDebit), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: AppColors.danger)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total Credit (Cr.):', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                        Text(currencyFormatter.format(_totalCredit), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: AppColors.success)),
                      ],
                    ),
                    const Divider(height: 16),
                    Row(
                      children: [
                        Icon(
                          _isBalanced ? Icons.check_circle : Icons.warning_amber_rounded,
                          color: _isBalanced ? AppColors.success : AppColors.danger,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _isBalanced
                                ? 'Balanced Entry (Total Debit = Total Credit)'
                                : 'Unbalanced Entry (Difference: ${currencyFormatter.format(diff)})',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 13,
                              color: _isBalanced ? AppColors.success : AppColors.danger,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Save Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: AppColors.primaryBlue),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () => _saveEntry(isDraft: true),
                    child: const Text('Save Draft', style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.primaryBlue)),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isBalanced ? AppColors.primaryBlue : Colors.grey,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: _isBalanced ? () => _saveEntry(isDraft: false) : null,
                    child: const Text('Post Entry', style: TextStyle(fontWeight: FontWeight.w700, color: Colors.white)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _JournalLineInput {
  String accountName;
  String accountType;
  bool isDebit;
  TextEditingController amountController;

  _JournalLineInput({
    required this.accountName,
    required this.accountType,
    required this.isDebit,
    required this.amountController,
  });
}
