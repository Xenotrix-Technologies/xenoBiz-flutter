import 'package:equatable/equatable.dart';

class TaxSettingsEntity extends Equatable {
  final bool isGstEnabled;
  final String gstin;
  final String businessLegalName;
  final String gstRegistrationType; // Regular, Composition, Unregistered
  final double defaultGstRate; // 0, 5, 12, 18, 28, etc.
  final bool isTaxIncludedInPrice;
  final String taxCalculationType; // CGST + SGST, IGST
  final String businessState;
  final bool showTaxDetailsOnInvoice;

  const TaxSettingsEntity({
    this.isGstEnabled = true,
    this.gstin = '27AAAAA0000A1Z5',
    this.businessLegalName = 'XenoBiz Technologies Pvt Ltd',
    this.gstRegistrationType = 'Regular',
    this.defaultGstRate = 18.0,
    this.isTaxIncludedInPrice = false,
    this.taxCalculationType = 'CGST + SGST',
    this.businessState = 'Maharashtra',
    this.showTaxDetailsOnInvoice = true,
  });

  TaxSettingsEntity copyWith({
    bool? isGstEnabled,
    String? gstin,
    String? businessLegalName,
    String? gstRegistrationType,
    double? defaultGstRate,
    bool? isTaxIncludedInPrice,
    String? taxCalculationType,
    String? businessState,
    bool? showTaxDetailsOnInvoice,
  }) {
    return TaxSettingsEntity(
      isGstEnabled: isGstEnabled ?? this.isGstEnabled,
      gstin: gstin ?? this.gstin,
      businessLegalName: businessLegalName ?? this.businessLegalName,
      gstRegistrationType: gstRegistrationType ?? this.gstRegistrationType,
      defaultGstRate: defaultGstRate ?? this.defaultGstRate,
      isTaxIncludedInPrice: isTaxIncludedInPrice ?? this.isTaxIncludedInPrice,
      taxCalculationType: taxCalculationType ?? this.taxCalculationType,
      businessState: businessState ?? this.businessState,
      showTaxDetailsOnInvoice:
          showTaxDetailsOnInvoice ?? this.showTaxDetailsOnInvoice,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'isGstEnabled': isGstEnabled,
      'gstin': gstin,
      'businessLegalName': businessLegalName,
      'gstRegistrationType': gstRegistrationType,
      'defaultGstRate': defaultGstRate,
      'isTaxIncludedInPrice': isTaxIncludedInPrice,
      'taxCalculationType': taxCalculationType,
      'businessState': businessState,
      'showTaxDetailsOnInvoice': showTaxDetailsOnInvoice,
    };
  }

  factory TaxSettingsEntity.fromMap(Map<dynamic, dynamic> map) {
    return TaxSettingsEntity(
      isGstEnabled: map['isGstEnabled'] as bool? ?? true,
      gstin: map['gstin']?.toString() ?? '27AAAAA0000A1Z5',
      businessLegalName: map['businessLegalName']?.toString() ??
          'XenoBiz Technologies Pvt Ltd',
      gstRegistrationType: map['gstRegistrationType']?.toString() ?? 'Regular',
      defaultGstRate: (map['defaultGstRate'] as num?)?.toDouble() ?? 18.0,
      isTaxIncludedInPrice: map['isTaxIncludedInPrice'] as bool? ?? false,
      taxCalculationType:
          map['taxCalculationType']?.toString() ?? 'CGST + SGST',
      businessState: map['businessState']?.toString() ?? 'Maharashtra',
      showTaxDetailsOnInvoice:
          map['showTaxDetailsOnInvoice'] as bool? ?? true,
    );
  }

  @override
  List<Object?> get props => [
        isGstEnabled,
        gstin,
        businessLegalName,
        gstRegistrationType,
        defaultGstRate,
        isTaxIncludedInPrice,
        taxCalculationType,
        businessState,
        showTaxDetailsOnInvoice,
      ];
}
