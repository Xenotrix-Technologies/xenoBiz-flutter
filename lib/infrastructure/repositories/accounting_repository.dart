import 'dart:convert';
import '../../domain/entities/accounting_entities.dart';
import '../storage/hive_service.dart';

class AccountingRepository {
  final HiveService _hiveService;

  static const String _journalBoxKey = 'journal_entries';
  static const String _contraBoxKey = 'contra_entries';

  final List<JournalEntryEntity> _memoryJournals = [];
  final List<ContraEntryEntity> _memoryContras = [];

  AccountingRepository(this._hiveService) {
    _loadFromHive();
  }

  void _loadFromHive() {
    try {
      final box = _hiveService.getBox(HiveService.boxBusiness);
      final rawJournals = box.get(_journalBoxKey);
      if (rawJournals != null) {
        final List list = jsonDecode(rawJournals.toString());
        _memoryJournals.clear();
        _memoryJournals.addAll(list.map((e) => JournalEntryEntity.fromJson(Map<String, dynamic>.from(e))));
      }

      final rawContras = box.get(_contraBoxKey);
      if (rawContras != null) {
        final List list = jsonDecode(rawContras.toString());
        _memoryContras.clear();
        _memoryContras.addAll(list.map((e) => ContraEntryEntity.fromJson(Map<String, dynamic>.from(e))));
      }

      if (_memoryJournals.isEmpty) {
        _seedDefaultJournalEntries();
      }
      if (_memoryContras.isEmpty) {
        _seedDefaultContraEntries();
      }
    } catch (e) {
      if (_memoryJournals.isEmpty) _seedDefaultJournalEntries();
      if (_memoryContras.isEmpty) _seedDefaultContraEntries();
    }
  }

  void _saveToHive() {
    try {
      final box = _hiveService.getBox(HiveService.boxBusiness);
      box.put(_journalBoxKey, jsonEncode(_memoryJournals.map((j) => j.toJson()).toList()));
      box.put(_contraBoxKey, jsonEncode(_memoryContras.map((c) => c.toJson()).toList()));
    } catch (_) {}
  }

  void _seedDefaultJournalEntries() {
    final now = DateTime.now();
    _memoryJournals.addAll([
      JournalEntryEntity(
        id: 'jv-1',
        date: now.subtract(const Duration(days: 2)),
        referenceNumber: 'JV-2026-001',
        narration: 'Depreciation adjustment for store furniture & office equipment',
        items: const [
          JournalLineItem(accountName: 'Depreciation Expense', accountType: 'Expense', debit: 2500.0, credit: 0.0),
          JournalLineItem(accountName: 'Accumulated Depreciation', accountType: 'Asset', debit: 0.0, credit: 2500.0),
        ],
        createdAt: now.subtract(const Duration(days: 2)),
      ),
      JournalEntryEntity(
        id: 'jv-2',
        date: now.subtract(const Duration(days: 1)),
        referenceNumber: 'JV-2026-002',
        narration: 'Opening balance correction for petty cash fund',
        items: const [
          JournalLineItem(accountName: 'Petty Cash Account', accountType: 'Asset', debit: 1000.0, credit: 0.0),
          JournalLineItem(accountName: 'Capital Account', accountType: 'Equity', debit: 0.0, credit: 1000.0),
        ],
        createdAt: now.subtract(const Duration(days: 1)),
      ),
    ]);
  }

  void _seedDefaultContraEntries() {
    final now = DateTime.now();
    _memoryContras.addAll([
      ContraEntryEntity(
        id: 'cn-1',
        date: now.subtract(const Duration(days: 3)),
        referenceNumber: 'CN-2026-001',
        fromAccount: 'Cash Account',
        toAccount: 'HDFC Bank Main A/c',
        amount: 15000.0,
        paymentMode: 'Cash Deposit',
        narration: 'Cash deposited in HDFC Bank main business account',
        createdAt: now.subtract(const Duration(days: 3)),
      ),
      ContraEntryEntity(
        id: 'cn-2',
        date: now.subtract(const Duration(days: 1)),
        referenceNumber: 'CN-2026-002',
        fromAccount: 'SBI Current A/c',
        toAccount: 'Cash Account',
        amount: 5000.0,
        paymentMode: 'ATM Withdrawal',
        narration: 'Cash withdrawn for shop daily operations',
        createdAt: now.subtract(const Duration(days: 1)),
      ),
    ]);
  }

  // Journal Operations
  List<JournalEntryEntity> getJournalEntries() {
    return List.unmodifiable(_memoryJournals..sort((a, b) => b.date.compareTo(a.date)));
  }

  Future<void> saveJournalEntry(JournalEntryEntity entry) async {
    _memoryJournals.removeWhere((j) => j.id == entry.id);
    _memoryJournals.add(entry);
    _saveToHive();
  }

  // Contra Operations
  List<ContraEntryEntity> getContraEntries() {
    return List.unmodifiable(_memoryContras..sort((a, b) => b.date.compareTo(a.date)));
  }

  Future<void> saveContraEntry(ContraEntryEntity entry) async {
    _memoryContras.removeWhere((c) => c.id == entry.id);
    _memoryContras.add(entry);
    _saveToHive();
  }

  // Daily Book Aggregated View
  List<DailyBookTransactionEntity> getDailyBookTransactions({
    DateTime? date,
    AccountingTxType? typeFilter,
    String? searchQuery,
  }) {
    final List<DailyBookTransactionEntity> list = [];
    final targetDate = date ?? DateTime.now();

    // Mock realistic daily book stream
    list.addAll([
      DailyBookTransactionEntity(
        id: 'db-1',
        date: targetDate.add(const Duration(hours: 9)),
        type: AccountingTxType.sale,
        referenceNumber: 'INV-2026-101',
        partyOrAccount: 'Rahul Sharma (Customer)',
        debit: 4500.0,
        credit: 0.0,
        runningBalance: 4500.0,
        narration: 'Retail sale invoice',
      ),
      DailyBookTransactionEntity(
        id: 'db-2',
        date: targetDate.add(const Duration(hours: 10, minutes: 30)),
        type: AccountingTxType.receipt,
        referenceNumber: 'RCT-2026-042',
        partyOrAccount: 'Ankit Traders',
        debit: 12000.0,
        credit: 0.0,
        runningBalance: 16500.0,
        narration: 'Payment received via UPI',
      ),
      DailyBookTransactionEntity(
        id: 'db-3',
        date: targetDate.add(const Duration(hours: 11, minutes: 15)),
        type: AccountingTxType.purchase,
        referenceNumber: 'PUR-2026-088',
        partyOrAccount: 'Metro Wholesalers (Supplier)',
        debit: 0.0,
        credit: 8500.0,
        runningBalance: 8000.0,
        narration: 'Inventory stock replenishment',
      ),
      DailyBookTransactionEntity(
        id: 'db-4',
        date: targetDate.add(const Duration(hours: 13, minutes: 0)),
        type: AccountingTxType.contra,
        referenceNumber: 'CN-2026-003',
        partyOrAccount: 'Cash → HDFC Bank',
        debit: 0.0,
        credit: 5000.0,
        runningBalance: 3000.0,
        narration: 'Cash deposit to bank',
      ),
      DailyBookTransactionEntity(
        id: 'db-5',
        date: targetDate.add(const Duration(hours: 15, minutes: 45)),
        type: AccountingTxType.payment,
        referenceNumber: 'PMT-2026-019',
        partyOrAccount: 'Shop Rent Expense',
        debit: 0.0,
        credit: 2500.0,
        runningBalance: 500.0,
        narration: 'Electricity and utility bill',
      ),
      DailyBookTransactionEntity(
        id: 'db-6',
        date: targetDate.add(const Duration(hours: 17, minutes: 20)),
        type: AccountingTxType.journal,
        referenceNumber: 'JV-2026-003',
        partyOrAccount: 'Discount Allowed Adjustment',
        debit: 200.0,
        credit: 200.0,
        runningBalance: 500.0,
        narration: 'Customer rounding discount adjustment',
      ),
    ]);

    // Apply type filter
    var filtered = list;
    if (typeFilter != null) {
      filtered = filtered.where((tx) => tx.type == typeFilter).toList();
    }

    // Apply search query
    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      final q = searchQuery.toLowerCase();
      filtered = filtered.where((tx) =>
        tx.referenceNumber.toLowerCase().contains(q) ||
        tx.partyOrAccount.toLowerCase().contains(q) ||
        tx.narration.toLowerCase().contains(q)
      ).toList();
    }

    return filtered;
  }

  // Account Ledger Entries
  List<LedgerTransactionEntity> getLedgerTransactions(String accountName) {
    final now = DateTime.now();
    return [
      LedgerTransactionEntity(
        id: 'l-1',
        date: now.subtract(const Duration(days: 15)),
        particulars: 'Opening Balance',
        referenceNumber: 'OB-001',
        voucherType: 'Opening',
        debit: 10000.0,
        credit: 0.0,
        runningBalance: 10000.0,
      ),
      LedgerTransactionEntity(
        id: 'l-2',
        date: now.subtract(const Duration(days: 10)),
        particulars: 'Sales Invoice INV-2026-089',
        referenceNumber: 'INV-2026-089',
        voucherType: 'Sale',
        debit: 15400.0,
        credit: 0.0,
        runningBalance: 25400.0,
      ),
      LedgerTransactionEntity(
        id: 'l-3',
        date: now.subtract(const Duration(days: 5)),
        particulars: 'Bank Payment Received RCT-034',
        referenceNumber: 'RCT-034',
        voucherType: 'Receipt',
        debit: 0.0,
        credit: 12000.0,
        runningBalance: 13400.0,
      ),
      LedgerTransactionEntity(
        id: 'l-4',
        date: now.subtract(const Duration(days: 1)),
        particulars: 'Sales Return Voucher SR-004',
        referenceNumber: 'SR-004',
        voucherType: 'Sales Return',
        debit: 0.0,
        credit: 1400.0,
        runningBalance: 12000.0,
      ),
    ];
  }
}
