import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/customer_entity.dart';
import '../../domain/entities/invoice_entity.dart';
import '../../domain/entities/tax_settings_entity.dart';

class CreateInvoiceFormState {
  final List<InvoiceItemEntity> items;
  final CustomerEntity? selectedCustomer;
  final DateTime createdDateTime;
  final int? focusedItemIndex;

  CreateInvoiceFormState({
    required this.items,
    this.selectedCustomer,
    required this.createdDateTime,
    this.focusedItemIndex,
  });

  CreateInvoiceFormState copyWith({
    List<InvoiceItemEntity>? items,
    CustomerEntity? selectedCustomer,
    DateTime? createdDateTime,
    int? focusedItemIndex,
    bool clearCustomer = false,
  }) {
    return CreateInvoiceFormState(
      items: items ?? this.items,
      selectedCustomer: clearCustomer ? null : (selectedCustomer ?? this.selectedCustomer),
      createdDateTime: createdDateTime ?? this.createdDateTime,
      focusedItemIndex: focusedItemIndex ?? this.focusedItemIndex,
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

  double subtotal(TaxSettingsEntity taxSettings) {
    if (!taxSettings.isGstEnabled) {
      return items.fold(0.0, (sum, item) => sum + (item.quantity * item.unitPrice));
    }
    if (taxSettings.isTaxIncludedInPrice) {
      return items.fold(0.0, (sum, item) {
        final rate = item.taxPercentage > 0 ? item.taxPercentage : taxSettings.defaultGstRate;
        final total = item.quantity * item.unitPrice;
        final taxable = total / (1 + (rate / 100));
        return sum + taxable;
      });
    } else {
      return items.fold(0.0, (sum, item) => sum + (item.quantity * item.unitPrice));
    }
  }

  double taxTotal(TaxSettingsEntity taxSettings) {
    if (!taxSettings.isGstEnabled) return 0.0;
    if (taxSettings.isTaxIncludedInPrice) {
      return items.fold(0.0, (sum, item) {
        final rate = item.taxPercentage > 0 ? item.taxPercentage : taxSettings.defaultGstRate;
        final total = item.quantity * item.unitPrice;
        final taxable = total / (1 + (rate / 100));
        return sum + (total - taxable);
      });
    } else {
      return items.fold(0.0, (sum, item) {
        final rate = item.taxPercentage > 0 ? item.taxPercentage : taxSettings.defaultGstRate;
        final base = item.quantity * item.unitPrice;
        return sum + (base * (rate / 100));
      });
    }
  }

  double grandTotal(TaxSettingsEntity taxSettings) {
    if (!taxSettings.isGstEnabled || taxSettings.isTaxIncludedInPrice) {
      return items.fold(0.0, (sum, item) => sum + (item.quantity * item.unitPrice));
    } else {
      return subtotal(taxSettings) + taxTotal(taxSettings);
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

  void reset() {
    state = CreateInvoiceFormState(items: const [], createdDateTime: DateTime.now());
  }
}

final createInvoiceFormProvider =
    StateNotifierProvider<CreateInvoiceFormNotifier, CreateInvoiceFormState>(
        (ref) => CreateInvoiceFormNotifier());
