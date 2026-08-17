import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Riverpod StateProvider for Theme Mode (Light / Dark / System)
final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.light);

/// Riverpod StateProvider for Currency Symbol (Default: ₹ INR)
final currencySymbolProvider = StateProvider<String>((ref) => '₹');

/// Riverpod StateProvider for Global Date Range Filter (e.g. 'Today', 'This Week', 'This Month', 'All Time')
final analyticsDateFilterProvider = StateProvider<String>((ref) => 'This Month');

/// Riverpod StateProvider for Selected Category Filter in Reports/Expenses
final selectedCategoryFilterProvider = StateProvider<String>((ref) => 'All');

/// Riverpod StateProviders for Automated WhatsApp Reminders
final reminderRule3DaysBeforeProvider = StateProvider<bool>((ref) => true);
final reminderRuleOverdue1DayProvider = StateProvider<bool>((ref) => true);
final reminderRuleOverdue7DaysProvider = StateProvider<bool>((ref) => false);

/// Riverpod StateProvider for Active WhatsApp Message Templates List
final whatsappTemplatesProvider = StateProvider<List<Map<String, String>>>((ref) => [
  {
    'id': 'tpl_1',
    'title': 'Invoice Payment Reminder',
    'body': 'Dear {CustomerName}, your invoice #{InvoiceNumber} of ₹{Amount} is due on {DueDate}. Pay easily via UPI link: {PaymentLink}',
    'status': 'Approved',
  },
  {
    'id': 'tpl_2',
    'title': 'Overdue Payment Notice',
    'body': 'Dear {CustomerName}, your payment of ₹{Amount} for invoice #{InvoiceNumber} is overdue by 3 days. Please settle at your earliest convenience.',
    'status': 'Approved',
  },
  {
    'id': 'tpl_3',
    'title': 'New Invoice Shared',
    'body': 'Hi {CustomerName}, thank you for your business! Here is your invoice #{InvoiceNumber} for ₹{Amount}. Download PDF: {PdfLink}',
    'status': 'Approved',
  },
]);
