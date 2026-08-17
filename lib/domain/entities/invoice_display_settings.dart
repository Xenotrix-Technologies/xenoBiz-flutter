import 'package:equatable/equatable.dart';

class InvoiceDisplaySettingsEntity extends Equatable {
  final bool showLogo;
  final bool showBusinessAddress;
  final bool showPhone;
  final bool showEmail;
  final bool showGstin;
  final bool showInvoiceDate;
  final bool showInvoiceTime;
  final bool showInvoiceNumber;
  final bool showCustomerInfo;
  final bool showCustomerPhone;
  final bool showCustomerAddress;
  final bool showPreviousBalance;
  final bool showPaymentMethod;
  final bool showQuantity;
  final bool showUnitPrice;
  final bool showDiscount;
  final bool showTax;
  final bool showAmountPaid;
  final bool showBalanceDue;
  final bool showNotes;
  final bool showFooterMessage;
  final String footerMessage;

  const InvoiceDisplaySettingsEntity({
    this.showLogo = true,
    this.showBusinessAddress = true,
    this.showPhone = true,
    this.showEmail = true,
    this.showGstin = true,
    this.showInvoiceDate = true,
    this.showInvoiceTime = true,
    this.showInvoiceNumber = true,
    this.showCustomerInfo = true,
    this.showCustomerPhone = true,
    this.showCustomerAddress = true,
    this.showPreviousBalance = true,
    this.showPaymentMethod = true,
    this.showQuantity = true,
    this.showUnitPrice = true,
    this.showDiscount = true,
    this.showTax = true,
    this.showAmountPaid = true,
    this.showBalanceDue = true,
    this.showNotes = true,
    this.showFooterMessage = true,
    this.footerMessage = 'Thank you for your business!',
  });

  InvoiceDisplaySettingsEntity copyWith({
    bool? showLogo,
    bool? showBusinessAddress,
    bool? showPhone,
    bool? showEmail,
    bool? showGstin,
    bool? showInvoiceDate,
    bool? showInvoiceTime,
    bool? showInvoiceNumber,
    bool? showCustomerInfo,
    bool? showCustomerPhone,
    bool? showCustomerAddress,
    bool? showPreviousBalance,
    bool? showPaymentMethod,
    bool? showQuantity,
    bool? showUnitPrice,
    bool? showDiscount,
    bool? showTax,
    bool? showAmountPaid,
    bool? showBalanceDue,
    bool? showNotes,
    bool? showFooterMessage,
    String? footerMessage,
  }) {
    return InvoiceDisplaySettingsEntity(
      showLogo: showLogo ?? this.showLogo,
      showBusinessAddress: showBusinessAddress ?? this.showBusinessAddress,
      showPhone: showPhone ?? this.showPhone,
      showEmail: showEmail ?? this.showEmail,
      showGstin: showGstin ?? this.showGstin,
      showInvoiceDate: showInvoiceDate ?? this.showInvoiceDate,
      showInvoiceTime: showInvoiceTime ?? this.showInvoiceTime,
      showInvoiceNumber: showInvoiceNumber ?? this.showInvoiceNumber,
      showCustomerInfo: showCustomerInfo ?? this.showCustomerInfo,
      showCustomerPhone: showCustomerPhone ?? this.showCustomerPhone,
      showCustomerAddress: showCustomerAddress ?? this.showCustomerAddress,
      showPreviousBalance: showPreviousBalance ?? this.showPreviousBalance,
      showPaymentMethod: showPaymentMethod ?? this.showPaymentMethod,
      showQuantity: showQuantity ?? this.showQuantity,
      showUnitPrice: showUnitPrice ?? this.showUnitPrice,
      showDiscount: showDiscount ?? this.showDiscount,
      showTax: showTax ?? this.showTax,
      showAmountPaid: showAmountPaid ?? this.showAmountPaid,
      showBalanceDue: showBalanceDue ?? this.showBalanceDue,
      showNotes: showNotes ?? this.showNotes,
      showFooterMessage: showFooterMessage ?? this.showFooterMessage,
      footerMessage: footerMessage ?? this.footerMessage,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'showLogo': showLogo,
      'showBusinessAddress': showBusinessAddress,
      'showPhone': showPhone,
      'showEmail': showEmail,
      'showGstin': showGstin,
      'showInvoiceDate': showInvoiceDate,
      'showInvoiceTime': showInvoiceTime,
      'showInvoiceNumber': showInvoiceNumber,
      'showCustomerInfo': showCustomerInfo,
      'showCustomerPhone': showCustomerPhone,
      'showCustomerAddress': showCustomerAddress,
      'showPreviousBalance': showPreviousBalance,
      'showPaymentMethod': showPaymentMethod,
      'showQuantity': showQuantity,
      'showUnitPrice': showUnitPrice,
      'showDiscount': showDiscount,
      'showTax': showTax,
      'showAmountPaid': showAmountPaid,
      'showBalanceDue': showBalanceDue,
      'showNotes': showNotes,
      'showFooterMessage': showFooterMessage,
      'footerMessage': footerMessage,
    };
  }

  factory InvoiceDisplaySettingsEntity.fromJson(Map<String, dynamic> json) {
    return InvoiceDisplaySettingsEntity(
      showLogo: json['showLogo'] ?? true,
      showBusinessAddress: json['showBusinessAddress'] ?? true,
      showPhone: json['showPhone'] ?? true,
      showEmail: json['showEmail'] ?? true,
      showGstin: json['showGstin'] ?? true,
      showInvoiceDate: json['showInvoiceDate'] ?? true,
      showInvoiceTime: json['showInvoiceTime'] ?? true,
      showInvoiceNumber: json['showInvoiceNumber'] ?? true,
      showCustomerInfo: json['showCustomerInfo'] ?? true,
      showCustomerPhone: json['showCustomerPhone'] ?? true,
      showCustomerAddress: json['showCustomerAddress'] ?? true,
      showPreviousBalance: json['showPreviousBalance'] ?? true,
      showPaymentMethod: json['showPaymentMethod'] ?? true,
      showQuantity: json['showQuantity'] ?? true,
      showUnitPrice: json['showUnitPrice'] ?? true,
      showDiscount: json['showDiscount'] ?? true,
      showTax: json['showTax'] ?? true,
      showAmountPaid: json['showAmountPaid'] ?? true,
      showBalanceDue: json['showBalanceDue'] ?? true,
      showNotes: json['showNotes'] ?? true,
      showFooterMessage: json['showFooterMessage'] ?? true,
      footerMessage: json['footerMessage'] ?? 'Thank you for your business!',
    );
  }

  @override
  List<Object?> get props => [
        showLogo,
        showBusinessAddress,
        showPhone,
        showEmail,
        showGstin,
        showInvoiceDate,
        showInvoiceTime,
        showInvoiceNumber,
        showCustomerInfo,
        showCustomerPhone,
        showCustomerAddress,
        showPreviousBalance,
        showPaymentMethod,
        showQuantity,
        showUnitPrice,
        showDiscount,
        showTax,
        showAmountPaid,
        showBalanceDue,
        showNotes,
        showFooterMessage,
        footerMessage,
      ];
}
