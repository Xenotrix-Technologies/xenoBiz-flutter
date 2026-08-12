import 'package:equatable/equatable.dart';

class ExpenseEntity extends Equatable {
  final String id;
  final String title;
  final String category; // RENT, UTILITIES, SALARY, MARKETING, SUPPLIES, TRAVEL, OTHER
  final double amount;
  final String paymentMode;
  final DateTime expenseDate;
  final String notes;

  const ExpenseEntity({
    required this.id,
    required this.title,
    required this.category,
    required this.amount,
    required this.paymentMode,
    required this.expenseDate,
    this.notes = '',
  });

  @override
  List<Object?> get props => [id, title, category, amount, paymentMode, expenseDate, notes];
}
