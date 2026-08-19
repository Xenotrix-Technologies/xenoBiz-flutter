class IncomeEntity {
  final String id;
  final String title;
  final String category;
  final String? categoryId;
  final double amount;
  final String paymentMode;
  final DateTime incomeDate;
  final String notes;
  final String? partyId;
  final String? partyName;

  IncomeEntity({
    required this.id,
    required this.title,
    required this.category,
    this.categoryId,
    required this.amount,
    required this.paymentMode,
    required this.incomeDate,
    required this.notes,
    this.partyId,
    this.partyName,
  });

  IncomeEntity copyWith({
    String? id,
    String? title,
    String? category,
    String? categoryId,
    double? amount,
    String? paymentMode,
    DateTime? incomeDate,
    String? notes,
    String? partyId,
    String? partyName,
  }) {
    return IncomeEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      categoryId: categoryId ?? this.categoryId,
      amount: amount ?? this.amount,
      paymentMode: paymentMode ?? this.paymentMode,
      incomeDate: incomeDate ?? this.incomeDate,
      notes: notes ?? this.notes,
      partyId: partyId ?? this.partyId,
      partyName: partyName ?? this.partyName,
    );
  }
}
