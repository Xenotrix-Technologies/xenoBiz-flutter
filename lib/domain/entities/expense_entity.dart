import 'package:equatable/equatable.dart';

class ExpenseEntity extends Equatable {
  final String id;
  final String title;
  final String category; // RENT, UTILITIES, SALARY, MARKETING, SUPPLIES, TRAVEL, OTHER
  final String? categoryId;
  final double amount;
  final String paymentMode;
  final DateTime expenseDate;
  final String notes;
  final String? partyId;
  final String? partyName;

  const ExpenseEntity({
    required this.id,
    required this.title,
    required this.category,
    this.categoryId,
    required this.amount,
    required this.paymentMode,
    required this.expenseDate,
    this.notes = '',
    this.partyId,
    this.partyName,
  });

  ExpenseEntity copyWith({
    String? id,
    String? title,
    String? category,
    String? categoryId,
    double? amount,
    String? paymentMode,
    DateTime? expenseDate,
    String? notes,
    String? partyId,
    String? partyName,
  }) {
    return ExpenseEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      categoryId: categoryId ?? this.categoryId,
      amount: amount ?? this.amount,
      paymentMode: paymentMode ?? this.paymentMode,
      expenseDate: expenseDate ?? this.expenseDate,
      notes: notes ?? this.notes,
      partyId: partyId ?? this.partyId,
      partyName: partyName ?? this.partyName,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        category,
        categoryId,
        amount,
        paymentMode,
        expenseDate,
        notes,
        partyId,
        partyName,
      ];
}
