import 'package:equatable/equatable.dart';

class DailySalesExpenseData extends Equatable {
  final String dayName; // 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'
  final double sales;
  final double expenses;
  final DateTime date;

  const DailySalesExpenseData({
    required this.dayName,
    required this.sales,
    required this.expenses,
    required this.date,
  });

  @override
  List<Object?> get props => [dayName, sales, expenses, date];
}
