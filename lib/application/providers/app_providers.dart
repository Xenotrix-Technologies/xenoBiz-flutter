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
