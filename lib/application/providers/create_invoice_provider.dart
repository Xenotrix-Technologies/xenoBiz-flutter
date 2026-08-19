import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/customer_entity.dart';
import '../../domain/entities/invoice_entity.dart';
import '../../domain/entities/tax_settings_entity.dart';

class CreateInvoiceFormState {
  final List<InvoiceItemEntity> items;
  final CustomerEntity? selectedCustomer;
  final DateTime createdDateTime;
  final int? focusedItemIndex;

  // New Fields
  final bool gstEnabled;
  final double discountAmount;
  final bool discountIsPercentage;
  final double extraExpenseAmount;
  final String extraExpenseDescription;

  CreateInvoiceFormState({
    required this.items,
    this.selectedCustomer,
    required this.createdDateTime,
    this.focusedItemIndex,
    this.gstEnabled = true,
    this.discountAmount = 0.0,
    this.discountIsPercentage = false,
    this.extraExpenseAmount = 0.0,
    this.extraExpenseDescription = '',
  });

  CreateInvoiceFormState copyWith({
    List<InvoiceItemEntity>? items,
    CustomerEntity? selectedCustomer,
    DateTime? createdDateTime,
    int? focusedItemIndex,
    bool clearCustomer = false,
    bool? gstEnabled,
    double? discountAmount,
    bool? discountIsPercentage,
    double? extraExpenseAmount,
    String? extraExpenseDescription,
  }) {
    return CreateInvoiceFormState(
      items: items ?? this.items,
      selectedCustomer: clearCustomer ? null : (selectedCustomer ?? this.selectedCustomer),
      createdDateTime: createdDateTime ?? this.createdDateTime,
      focusedItemIndex: focusedItemIndex ?? this.focusedItemIndex,
      gstEnabled: gstEnabled ?? this.gstEnabled,
      discountAmount: discountAmount ?? this.discountAmount,
      discountIsPercentage: discountIsPercentage ?? this.discountIsPercentage,
      extraExpenseAmount: extraExpenseAmount ?? this.extraExpenseAmount,
      extraExpenseDescription: extraExpenseDescription ?? this.extraExpenseDescription,
    );
  }

  bool get isCashSale => selectedCustomer == null;

  bool isIgst(TaxSettingsEntity taxSettings) {
    if (selectedCustomer != null &&
        selectedCustomer!.state != null &&
        selectedCustomer!.state!.isNotEmpty) {
      return selectedCustomer!.state!.toLowerCase() != taxSettings.businessState.toLowerCase();
    }
    return taxSettings.taxCalculationType == 'IGST';
  }

  double get rawSubtotal =>
      items.fold(0.0, (sum, item) => sum + (item.quantity * item.unitPrice));

  double get calculatedDiscountTotal {
    if (rawSubtotal <= 0) return 0.0;
    if (discountIsPercentage) {
      return (rawSubtotal * (discountAmount / 100.0)).clamp(0.0, rawSubtotal);
    } else {
      return discountAmount.clamp(0.0, rawSubtotal);
    }
  }

  double get taxableAmount => max(0.0, rawSubtotal - calculatedDiscountTotal);

  double subtotal(TaxSettingsEntity taxSettings) => rawSubtotal;

  double taxTotal(TaxSettingsEntity taxSettings) {
    if (!taxSettings.isGstEnabled || !gstEnabled || taxableAmount <= 0) return 0.0;

    final baseRatio = rawSubtotal > 0 ? (taxableAmount / rawSubtotal) : 1.0;

    if (taxSettings.isTaxIncludedInPrice) {
      return items.fold(0.0, (sum, item) {
        final rate = item.taxPercentage > 0 ? item.taxPercentage : taxSettings.defaultGstRate;
        final itemTotal = (item.quantity * item.unitPrice) * baseRatio;
        final itemTaxable = itemTotal / (1 + (rate / 100));
        return sum + (itemTotal - itemTaxable);
      });
    } else {
      return items.fold(0.0, (sum, item) {
        final rate = item.taxPercentage > 0 ? item.taxPercentage : taxSettings.defaultGstRate;
        final itemBase = (item.quantity * item.unitPrice) * baseRatio;
        return sum + (itemBase * (rate / 100));
      });
    }
  }

  double grandTotal(TaxSettingsEntity taxSettings) {
    if (!taxSettings.isGstEnabled || !gstEnabled) {
      return taxableAmount + extraExpenseAmount;
    } else {
      if (taxSettings.isTaxIncludedInPrice) {
        return taxableAmount + extraExpenseAmount;
      } else {
        return taxableAmount + taxTotal(taxSettings) + extraExpenseAmount;
      }
    }
  }
}

class CreateInvoiceFormNotifier extends StateNotifier<CreateInvoiceFormState> {
  CreateInvoiceFormNotifier()
      : super(CreateInvoiceFormState(
          items: const [],
          createdDateTime: DateTime.now(),
        ));

  void setItems(List<InvoiceItemEntity> newItems) {
    state = state.copyWith(items: List.from(newItems), focusedItemIndex: null);
  }

  void updateItemPrice(int index, double newPrice) {
    if (index < 0 || index >= state.items.length) return;
    final list = List<InvoiceItemEntity>.from(state.items);
    list[index] = list[index].copyWith(unitPrice: max(0.0, newPrice));
    state = state.copyWith(items: list);
  }

  void updateQuantity(int index, int delta, void Function(String itemRemoved)? onItemRemoved) {
    final list = List<InvoiceItemEntity>.from(state.items);
    final currentQty = list[index].quantity;
    final newQty = currentQty + delta;

    if (newQty <= 0) {
      final removedName = list[index].productName;
      list.removeAt(index);
      state = state.copyWith(items: list, focusedItemIndex: null);
      if (onItemRemoved != null) onItemRemoved(removedName);
    } else {
      list[index] = list[index].copyWith(quantity: newQty);
      state = state.copyWith(items: list);
    }
  }

  void removeItem(int index, void Function(String itemRemoved)? onItemRemoved) {
    final list = List<InvoiceItemEntity>.from(state.items);
    final removedName = list[index].productName;
    list.removeAt(index);
    state = state.copyWith(items: list, focusedItemIndex: null);
    if (onItemRemoved != null) onItemRemoved(removedName);
  }

  void selectCustomer(CustomerEntity? customer) {
    state = state.copyWith(selectedCustomer: customer, clearCustomer: customer == null);
  }

  void updateDateTime(DateTime dateTime) {
    state = state.copyWith(createdDateTime: dateTime);
  }

  void toggleGst(bool enabled) {
    state = state.copyWith(gstEnabled: enabled);
  }

  void updateDiscount(double amount, bool isPercentage) {
    state = state.copyWith(
      discountAmount: max(0.0, amount),
      discountIsPercentage: isPercentage,
    );
  }

  void updateExtraExpense(double amount, String description) {
    state = state.copyWith(
      extraExpenseAmount: max(0.0, amount),
      extraExpenseDescription: description,
    );
  }

  void reset() {
    state = CreateInvoiceFormState(items: const [], createdDateTime: DateTime.now());
  }
}

final createInvoiceFormProvider =
    StateNotifierProvider<CreateInvoiceFormNotifier, CreateInvoiceFormState>(
        (ref) => CreateInvoiceFormNotifier());
