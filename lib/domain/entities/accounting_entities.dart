enum JournalEntryStatus { draft, posted }

class JournalLineItem {
  final String accountName;
  final String accountType; // e.g. Expense, Asset, Liability, Income, Equity
  final double debit;
  final double credit;

  const JournalLineItem({
    required this.accountName,
    required this.accountType,
    this.debit = 0.0,
    this.credit = 0.0,
  });

  Map<String, dynamic> toJson() => {
        'accountName': accountName,
        'accountType': accountType,
        'debit': debit,
        'credit': credit,
      };

  factory JournalLineItem.fromJson(Map<String, dynamic> json) => JournalLineItem(
        accountName: json['accountName'] ?? '',
        accountType: json['accountType'] ?? 'General',
        debit: (json['debit'] as num?)?.toDouble() ?? 0.0,
        credit: (json['credit'] as num?)?.toDouble() ?? 0.0,
      );
}

class JournalEntryEntity {
  final String id;
  final DateTime date;
  final String referenceNumber;
  final String narration;
  final List<JournalLineItem> items;
  final JournalEntryStatus status;
  final DateTime createdAt;

  const JournalEntryEntity({
    required this.id,
    required this.date,
    required this.referenceNumber,
    required this.narration,
    required this.items,
    this.status = JournalEntryStatus.posted,
    required this.createdAt,
  });

  double get totalDebit => items.fold(0.0, (sum, item) => sum + item.debit);
  double get totalCredit => items.fold(0.0, (sum, item) => sum + item.credit);
  bool get isBalanced => (totalDebit - totalCredit).abs() < 0.01;

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date.toIso8601String(),
        'referenceNumber': referenceNumber,
        'narration': narration,
        'items': items.map((i) => i.toJson()).toList(),
        'status': status.name,
        'createdAt': createdAt.toIso8601String(),
      };

  factory JournalEntryEntity.fromJson(Map<String, dynamic> json) => JournalEntryEntity(
        id: json['id'] ?? '',
        date: DateTime.tryParse(json['date'] ?? '') ?? DateTime.now(),
        referenceNumber: json['referenceNumber'] ?? '',
        narration: json['narration'] ?? '',
        items: (json['items'] as List<dynamic>?)
                ?.map((e) => JournalLineItem.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
        status: json['status'] == 'draft' ? JournalEntryStatus.draft : JournalEntryStatus.posted,
        createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      );
}

class ContraEntryEntity {
  final String id;
  final DateTime date;
  final String referenceNumber;
  final String fromAccount;
  final String toAccount;
  final double amount;
  final String paymentMode; // e.g. Cash, NEFT/RTGS, UPI, Cheque
  final String narration;
  final JournalEntryStatus status;
  final DateTime createdAt;

  const ContraEntryEntity({
    required this.id,
    required this.date,
    required this.referenceNumber,
    required this.fromAccount,
    required this.toAccount,
    required this.amount,
    required this.paymentMode,
    required this.narration,
    this.status = JournalEntryStatus.posted,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date.toIso8601String(),
        'referenceNumber': referenceNumber,
        'fromAccount': fromAccount,
        'toAccount': toAccount,
        'amount': amount,
        'paymentMode': paymentMode,
        'narration': narration,
        'status': status.name,
        'createdAt': createdAt.toIso8601String(),
      };

  factory ContraEntryEntity.fromJson(Map<String, dynamic> json) => ContraEntryEntity(
        id: json['id'] ?? '',
        date: DateTime.tryParse(json['date'] ?? '') ?? DateTime.now(),
        referenceNumber: json['referenceNumber'] ?? '',
        fromAccount: json['fromAccount'] ?? '',
        toAccount: json['toAccount'] ?? '',
        amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
        paymentMode: json['paymentMode'] ?? 'Cash',
        narration: json['narration'] ?? '',
        status: json['status'] == 'draft' ? JournalEntryStatus.draft : JournalEntryStatus.posted,
        createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      );
}

enum AccountingTxType {
  sale,
  purchase,
  payment,
  receipt,
  journal,
  contra,
  salesReturn,
  purchaseReturn,
}

extension AccountingTxTypeExt on AccountingTxType {
  String get displayName {
    switch (this) {
      case AccountingTxType.sale:
        return 'Sale';
      case AccountingTxType.purchase:
        return 'Purchase';
      case AccountingTxType.payment:
        return 'Payment';
      case AccountingTxType.receipt:
        return 'Receipt';
      case AccountingTxType.journal:
        return 'Journal';
      case AccountingTxType.contra:
        return 'Contra';
      case AccountingTxType.salesReturn:
        return 'Sales Return';
      case AccountingTxType.purchaseReturn:
        return 'Purchase Return';
    }
  }
}

class DailyBookTransactionEntity {
  final String id;
  final DateTime date;
  final AccountingTxType type;
  final String referenceNumber;
  final String partyOrAccount;
  final double debit;
  final double credit;
  final double runningBalance;
  final String narration;

  const DailyBookTransactionEntity({
    required this.id,
    required this.date,
    required this.type,
    required this.referenceNumber,
    required this.partyOrAccount,
    required this.debit,
    required this.credit,
    required this.runningBalance,
    this.narration = '',
  });
}

class LedgerTransactionEntity {
  final String id;
  final DateTime date;
  final String particulars;
  final String referenceNumber;
  final String voucherType;
  final double debit;
  final double credit;
  final double runningBalance;

  const LedgerTransactionEntity({
    required this.id,
    required this.date,
    required this.particulars,
    required this.referenceNumber,
    required this.voucherType,
    required this.debit,
    required this.credit,
    required this.runningBalance,
  });
}

class LedgerAccountSummary {
  final String accountName;
  final String category; // Customer, Supplier, Cash, Bank, Expense, Income, Asset, Liability
  final double openingBalance;
  final double totalDebit;
  final double totalCredit;
  final double closingBalance;

  const LedgerAccountSummary({
    required this.accountName,
    required this.category,
    required this.openingBalance,
    required this.totalDebit,
    required this.totalCredit,
    required this.closingBalance,
  });
}
