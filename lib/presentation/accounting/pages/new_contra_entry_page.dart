import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../application/di/injection.dart';
import '../../../const/colors.dart';
import '../../../domain/entities/accounting_entities.dart';
import '../../../infrastructure/repositories/accounting_repository.dart';

class NewContraEntryPage extends StatefulWidget {
  const NewContraEntryPage({super.key});

  @override
  State<NewContraEntryPage> createState() => _NewContraEntryPageState();
}

class _NewContraEntryPageState extends State<NewContraEntryPage> {
  DateTime _entryDate = DateTime.now();
  late TextEditingController _refNoController;
  late TextEditingController _amountController;
  late TextEditingController _narrationController;

  String _fromAccount = 'Cash Account';
  String _toAccount = 'HDFC Bank Main A/c';
  String _paymentMode = 'Cash Deposit';

  final List<String> _cashBankAccounts = [
    'Cash Account',
    'Petty Cash Account',
    'HDFC Bank Main A/c',
    'SBI Current A/c',
    'ICICI Business Account',
  ];

  final List<String> _transferModes = [
    'Cash Deposit',
    'ATM Withdrawal',
    'NEFT / RTGS Transfer',
    'UPI Transfer',
    'Cheque Deposit / Transfer',
  ];

  @override
  void initState() {
    super.initState();
    final randomSuffix = (100 + (DateTime.now().millisecondsSinceEpoch % 899)).toString();
    _refNoController = TextEditingController(text: 'CN-2026-$randomSuffix');
    _amountController = TextEditingController(text: '5000');
    _narrationController = TextEditingController();
  }

  @override
  void dispose() {
    _refNoController.dispose();
    _amountController.dispose();
    _narrationController.dispose();
    super.dispose();
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

  Future<void> _saveContra({required bool isDraft}) async {
    final amt = double.tryParse(_amountController.text.trim()) ?? 0.0;
    if (amt <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid transfer amount.')),
      );
      return;
    }

    if (_fromAccount == _toAccount) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Source ("From Account") and Destination ("To Account") cannot be the same.'),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    final entry = ContraEntryEntity(
      id: 'cn-${DateTime.now().millisecondsSinceEpoch}',
      date: _entryDate,
      referenceNumber: _refNoController.text.trim().isNotEmpty
          ? _refNoController.text.trim()
          : 'CN-${DateTime.now().millisecondsSinceEpoch}',
      fromAccount: _fromAccount,
      toAccount: _toAccount,
      amount: amt,
      paymentMode: _paymentMode,
      narration: _narrationController.text.trim(),
      status: isDraft ? JournalEntryStatus.draft : JournalEntryStatus.posted,
      createdAt: DateTime.now(),
    );

    final repo = getIt<AccountingRepository>();
    await repo.saveContraEntry(entry);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isDraft ? 'Contra entry saved as draft.' : 'Contra transfer recorded successfully!'),
          backgroundColor: AppColors.success,
        ),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('New Contra Entry'),
        backgroundColor: AppColors.deepNavy,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Informative Banner
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primaryBlue.withValues(alpha: 0.3)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: AppColors.primaryBlue, size: 22),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Contra entries are exclusively used for internal transfers between Cash and Bank accounts (e.g., Cash → Bank, Bank → Cash, Bank → Bank).',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.darkBlueText,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Voucher Details Card
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                              labelText: 'Voucher No',
                              prefixIcon: const Icon(Icons.tag, size: 18),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // From Account Dropdown
                    DropdownButtonFormField<String>(
                      initialValue: _fromAccount,
                      decoration: InputDecoration(
                        labelText: 'From Account (Source)',
                        prefixIcon: const Icon(Icons.outbox_rounded, color: AppColors.danger),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      items: _cashBankAccounts.map((acc) {
                        return DropdownMenuItem(
                          value: acc,
                          child: Text(acc, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _fromAccount = val);
                      },
                    ),
                    const SizedBox(height: 14),

                    // To Account Dropdown
                    DropdownButtonFormField<String>(
                      initialValue: _toAccount,
                      decoration: InputDecoration(
                        labelText: 'To Account (Destination)',
                        prefixIcon: const Icon(Icons.inbox_rounded, color: AppColors.success),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      items: _cashBankAccounts.map((acc) {
                        return DropdownMenuItem(
                          value: acc,
                          child: Text(acc, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _toAccount = val);
                      },
                    ),
                    if (_fromAccount == _toAccount) ...[
                      const SizedBox(height: 6),
                      const Text(
                        'Source and Destination accounts must be different.',
                        style: TextStyle(color: AppColors.danger, fontSize: 11, fontWeight: FontWeight.w600),
                      ),
                    ],
                    const SizedBox(height: 16),

                    // Amount & Payment Mode
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _amountController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: InputDecoration(
                              labelText: 'Transfer Amount (₹)',
                              prefixText: '₹ ',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: _paymentMode,
                            decoration: InputDecoration(
                              labelText: 'Transfer Mode',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            items: _transferModes.map((m) {
                              return DropdownMenuItem(
                                value: m,
                                child: Text(m, style: const TextStyle(fontSize: 12)),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) setState(() => _paymentMode = val);
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    TextField(
                      controller: _narrationController,
                      decoration: InputDecoration(
                        labelText: 'Narration / Remark',
                        hintText: 'e.g. Cash deposited in HDFC business account',
                        prefixIcon: const Icon(Icons.notes, size: 18),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: AppColors.primaryBlue),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () => _saveContra(isDraft: true),
                    child: const Text('Save Draft', style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.primaryBlue)),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () => _saveContra(isDraft: false),
                    child: const Text('Post Contra Entry', style: TextStyle(fontWeight: FontWeight.w700, color: Colors.white)),
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
