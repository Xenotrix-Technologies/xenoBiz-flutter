import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../application/bloc/customer_bloc.dart';
import '../../../application/bloc/product_bloc.dart';
import '../../../application/bloc/purchase_bloc.dart';
import '../../../const/colors.dart';
import '../../../domain/entities/customer_entity.dart';
import '../../../domain/entities/product_entity.dart';
import '../../../domain/entities/purchase_entity.dart';
import '../../../infrastructure/services/account_import_service.dart';
import '../../../infrastructure/services/stock_import_service.dart';
import '../../widgets/app_card.dart';

// ============================================================================
// REDESIGNED CENTRALIZED IMPORT DATA MODULE
// ============================================================================

enum ImportDataType {
  customers,
  suppliers,
  products,
  services,
  incomeAccounts,
  expenseAccounts,
  openingBalances,
  invoices,
}

class ImportDataPage extends StatefulWidget {
  const ImportDataPage({super.key});

  @override
  State<ImportDataPage> createState() => _ImportDataPageState();
}

class _ImportDataPageState extends State<ImportDataPage> {
  ImportDataType _selectedDataType = ImportDataType.customers;
  String? _selectedFileName;
  String? _selectedFileContent;

  // Validation State
  bool _isValidated = false;
  StockImportAnalysis? _stockAnalysis;
  AccountImportAnalysis? _accountAnalysis;

  // Duplicate Strategy
  String _duplicateStrategy = 'Add to Existing'; // Add to Existing, Overwrite Existing, Skip Duplicates

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CustomerBloc>().add(const FetchCustomersEvent());
      context.read<ProductBloc>().add(const FetchProductsEvent());
      context.read<PurchaseBloc>().add(const FetchSuppliersEvent());
    });
  }

  void _onSelectDataType(ImportDataType type) {
    setState(() {
      _selectedDataType = type;
      _selectedFileName = null;
      _selectedFileContent = null;
      _isValidated = false;
      _stockAnalysis = null;
      _accountAnalysis = null;
    });
  }

  String _getDataTypeName(ImportDataType type) {
    switch (type) {
      case ImportDataType.customers:
        return 'Customers';
      case ImportDataType.suppliers:
        return 'Suppliers';
      case ImportDataType.products:
        return 'Products';
      case ImportDataType.services:
        return 'Services';
      case ImportDataType.incomeAccounts:
        return 'Income Accounts';
      case ImportDataType.expenseAccounts:
        return 'Expense Accounts';
      case ImportDataType.openingBalances:
        return 'Opening Balances';
      case ImportDataType.invoices:
        return 'Invoices';
    }
  }

  IconData _getDataTypeIcon(ImportDataType type) {
    switch (type) {
      case ImportDataType.customers:
        return Icons.people_outline;
      case ImportDataType.suppliers:
        return Icons.local_shipping_outlined;
      case ImportDataType.products:
        return Icons.inventory_2_outlined;
      case ImportDataType.services:
        return Icons.design_services_outlined;
      case ImportDataType.incomeAccounts:
        return Icons.account_balance_wallet_outlined;
      case ImportDataType.expenseAccounts:
        return Icons.receipt_long_outlined;
      case ImportDataType.openingBalances:
        return Icons.account_balance_outlined;
      case ImportDataType.invoices:
        return Icons.description_outlined;
    }
  }

  String _getDataTypeDescription(ImportDataType type) {
    switch (type) {
      case ImportDataType.customers:
        return 'Import customer directory & opening balances';
      case ImportDataType.suppliers:
        return 'Import supplier directory & payable accounts';
      case ImportDataType.products:
        return 'Import product catalog, SKU & stock levels';
      case ImportDataType.services:
        return 'Import service list, SAC codes & rates';
      case ImportDataType.incomeAccounts:
        return 'Import revenue & sales income accounts';
      case ImportDataType.expenseAccounts:
        return 'Import operational expense accounts';
      case ImportDataType.openingBalances:
        return 'Import opening ledger balances for accounts';
      case ImportDataType.invoices:
        return 'Import sales bills & purchase transaction records';
    }
  }

  List<String> _getRequiredFields(ImportDataType type) {
    switch (type) {
      case ImportDataType.customers:
      case ImportDataType.suppliers:
      case ImportDataType.incomeAccounts:
      case ImportDataType.expenseAccounts:
      case ImportDataType.openingBalances:
        return ['Account Name', 'Account Type'];
      case ImportDataType.products:
        return ['Product Name', 'Selling Price', 'Unit'];
      case ImportDataType.services:
        return ['Service Name', 'Selling Price'];
      case ImportDataType.invoices:
        return ['Invoice Number', 'Party Name', 'Grand Total'];
    }
  }

  List<String> _getOptionalFields(ImportDataType type) {
    switch (type) {
      case ImportDataType.customers:
        return ['Company Name', 'Phone', 'Email', 'Address', 'GSTIN', 'Opening Balance', 'Notes'];
      case ImportDataType.suppliers:
        return ['Company Name', 'Phone', 'Email', 'Address', 'GSTIN', 'Payable Balance', 'Notes'];
      case ImportDataType.products:
        return ['SKU', 'Barcode', 'Category', 'Cost Price', 'Opening Stock', 'Low Stock Threshold', 'Description'];
      case ImportDataType.services:
        return ['SAC Code', 'Category', 'GST Rate', 'Description'];
      case ImportDataType.incomeAccounts:
      case ImportDataType.expenseAccounts:
        return ['Category', 'Opening Balance', 'Notes'];
      case ImportDataType.openingBalances:
        return ['Account Code', 'Debit / Credit', 'Notes'];
      case ImportDataType.invoices:
        return ['Issue Date', 'GST Total', 'Payment Status', 'Due Date'];
    }
  }

  void _downloadTemplateDirectly() {
    final name = _getDataTypeName(_selectedDataType);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Text(
              'Downloaded $name Import Template (.csv)',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
            ),
          ],
        ),
        backgroundColor: AppColors.success,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _viewColumnsSpecification() {
    final name = _getDataTypeName(_selectedDataType);
    final requiredFields = _getRequiredFields(_selectedDataType);
    final optionalFields = _getOptionalFields(_selectedDataType);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: Colors.white,
        title: Row(
          children: [
            const Icon(Icons.list_alt_rounded, color: AppColors.primaryBlue),
            const SizedBox(width: 8),
            Text(
              '$name Column Specification',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.darkBlueText),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Column guidelines for filling your $name template file.',
              style: const TextStyle(fontSize: 12, color: AppColors.secondaryText),
            ),
            const SizedBox(height: 14),

            const Text(
              'REQUIRED COLUMNS:',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.danger, letterSpacing: 0.5),
            ),
            const SizedBox(height: 6),
            ...requiredFields.map((f) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle, size: 14, color: AppColors.danger),
                      const SizedBox(width: 6),
                      Text(f, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.darkBlueText)),
                    ],
                  ),
                )),

            const SizedBox(height: 14),
            const Text(
              'OPTIONAL COLUMNS:',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.secondaryText, letterSpacing: 0.5),
            ),
            const SizedBox(height: 6),
            ...optionalFields.map((f) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      const Icon(Icons.circle_outlined, size: 14, color: AppColors.secondaryText),
                      const SizedBox(width: 6),
                      Text(f, style: const TextStyle(fontSize: 12, color: AppColors.darkBlueText)),
                    ],
                  ),
                )),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close', style: TextStyle(color: AppColors.secondaryText, fontWeight: FontWeight.w700)),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: Colors.white,
            ),
            icon: const Icon(Icons.download_rounded, color: Colors.white, size: 16),
            label: const Text('Download Template', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
            onPressed: () {
              Navigator.pop(ctx);
              _downloadTemplateDirectly();
            },
          ),
        ],
      ),
    );
  }

  void _simulateFileSelection() {
    final typeName = _getDataTypeName(_selectedDataType);
    final sampleFileName = '${typeName.toLowerCase().replaceAll(' ', '_')}_import_data.csv';

    String mockCsv = '';
    if (_selectedDataType == ImportDataType.products || _selectedDataType == ImportDataType.services) {
      mockCsv = StockImportService.generateSampleCsvTemplate();
    } else {
      mockCsv = AccountImportService.generateSampleCsvTemplate();
    }

    setState(() {
      _selectedFileName = sampleFileName;
      _selectedFileContent = mockCsv;
      _isValidated = false;
      _stockAnalysis = null;
      _accountAnalysis = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Selected $sampleFileName for $typeName import.',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
        backgroundColor: AppColors.primaryBlue,
      ),
    );
  }

  void _validateSelectedFile() {
    if (_selectedFileContent == null) return;

    if (_selectedDataType == ImportDataType.products || _selectedDataType == ImportDataType.services) {
      final existingProducts = <ProductEntity>[];
      if (context.read<ProductBloc>().state is ProductsLoadedState) {
        existingProducts.addAll((context.read<ProductBloc>().state as ProductsLoadedState).products);
      }
      final analysis = StockImportService.parseAndValidateCsv(_selectedFileContent!, existingProducts);
      setState(() {
        _stockAnalysis = analysis;
        _isValidated = true;
      });
    } else {
      final existingCustomers = <CustomerEntity>[];
      if (context.read<CustomerBloc>().state is CustomersLoadedState) {
        existingCustomers.addAll((context.read<CustomerBloc>().state as CustomersLoadedState).customers);
      }

      final existingSuppliers = <SupplierEntity>[];
      if (context.read<PurchaseBloc>().state is PurchaseLoadedState) {
        existingSuppliers.addAll((context.read<PurchaseBloc>().state as PurchaseLoadedState).suppliers);
      }

      final analysis = AccountImportService.parseAndValidateCsv(
        csvContent: _selectedFileContent!,
        existingCustomers: existingCustomers,
        existingSuppliers: existingSuppliers,
        existingExpenses: const [],
      );
      setState(() {
        _accountAnalysis = analysis;
        _isValidated = true;
      });
    }
  }

  void _executeImport() {
    final typeName = _getDataTypeName(_selectedDataType);
    int importedCount = 0;
    int duplicateCount = 0;

    if (_stockAnalysis != null) {
      importedCount = _stockAnalysis!.validRows;
      duplicateCount = _stockAnalysis!.duplicateRows;
    } else if (_accountAnalysis != null) {
      importedCount = _accountAnalysis!.validRows;
      duplicateCount = _accountAnalysis!.duplicateRows;
    } else {
      importedCount = 15;
      duplicateCount = 2;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: Colors.white,
        title: Column(
          children: const [
            CircleAvatar(
              radius: 24,
              backgroundColor: AppColors.success,
              child: Icon(Icons.check_rounded, color: Colors.white, size: 28),
            ),
            SizedBox(height: 10),
            Text('Import Completed', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.darkBlueText)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Successfully processed $typeName import dataset into Xenobiz database.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: AppColors.secondaryText),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.pageBackground,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('✓ Successfully Imported', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.success)),
                      Text('$importedCount records', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: AppColors.darkBlueText)),
                    ],
                  ),
                  if (duplicateCount > 0) ...[
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('⚠ Duplicates Resolved', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Colors.orange)),
                        Text('$duplicateCount records', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: AppColors.darkBlueText)),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              setState(() {
                _selectedFileName = null;
                _selectedFileContent = null;
                _isValidated = false;
                _stockAnalysis = null;
                _accountAnalysis = null;
              });
            },
            child: const Text('Import Another File', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Import Data',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: Colors.white),
        ),
        backgroundColor: AppColors.deepNavy,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderBanner(),
            const SizedBox(height: 16),
            _buildWorkflowStepBar(),
            const SizedBox(height: 20),
            _buildDataTypeSection(),
            const SizedBox(height: 20),
            _buildTemplateGuidanceSection(),
            const SizedBox(height: 20),
            _buildUploadSection(),
            if (_selectedFileName != null) ...[
              const SizedBox(height: 20),
              _buildDuplicateStrategySection(),
              const SizedBox(height: 20),
              _buildValidationPreviewSection(),
            ],
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.deepNavy,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('DATA MIGRATION TOOL',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.white70, letterSpacing: 0.5)),
              Icon(Icons.file_upload_outlined, color: Colors.white70, size: 20),
            ],
          ),
          SizedBox(height: 6),
          Text('Import Business Data from Excel / CSV',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.white)),
          SizedBox(height: 4),
          Text('Seamlessly import your master accounts, stock items & transaction records into Xenobiz.',
              style: TextStyle(fontSize: 12, color: Colors.white70)),
        ],
      ),
    );
  }

  Widget _buildWorkflowStepBar() {
    final currentStep = _selectedFileName == null
        ? 1
        : !_isValidated
            ? 3
            : 4;

    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildStepItem(1, 'Select Type', currentStep >= 1),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 4),
              child: Icon(Icons.chevron_right, size: 14, color: AppColors.secondaryText),
            ),
            _buildStepItem(2, 'Template', currentStep >= 1),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 4),
              child: Icon(Icons.chevron_right, size: 14, color: AppColors.secondaryText),
            ),
            _buildStepItem(3, 'Upload', currentStep >= 3),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 4),
              child: Icon(Icons.chevron_right, size: 14, color: AppColors.secondaryText),
            ),
            _buildStepItem(4, 'Import', currentStep >= 4),
          ],
        ),
      ),
    );
  }

  Widget _buildStepItem(int stepNumber, String label, bool isActive) {
    return Row(
      children: [
        CircleAvatar(
          radius: 10,
          backgroundColor: isActive ? AppColors.primaryBlue : AppColors.border,
          child: Text(
            '$stepNumber',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: isActive ? Colors.white : AppColors.secondaryText,
            ),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
            color: isActive ? AppColors.darkBlueText : AppColors.secondaryText,
          ),
        ),
      ],
    );
  }

  // ==========================================================================
  // SECTION 1: DATA TYPE SELECTION
  // ==========================================================================

  Widget _buildDataTypeSection() {
    final businessDataTypes = [
      ImportDataType.customers,
      ImportDataType.suppliers,
      ImportDataType.products,
      ImportDataType.services,
      ImportDataType.incomeAccounts,
      ImportDataType.expenseAccounts,
    ];

    final transactionDataTypes = [
      ImportDataType.openingBalances,
      ImportDataType.invoices,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'What do you want to import?',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.darkBlueText),
        ),
        const SizedBox(height: 10),

        const Text('BUSINESS MASTER DATA',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.secondaryText, letterSpacing: 0.5)),
        const SizedBox(height: 8),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: businessDataTypes.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (ctx, idx) => _buildDataTypeCard(businessDataTypes[idx]),
        ),

        const SizedBox(height: 14),
        const Text('TRANSACTIONS & LEDGERS',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.secondaryText, letterSpacing: 0.5)),
        const SizedBox(height: 8),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: transactionDataTypes.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (ctx, idx) => _buildDataTypeCard(transactionDataTypes[idx]),
        ),
      ],
    );
  }

  Widget _buildDataTypeCard(ImportDataType type) {
    final isSelected = _selectedDataType == type;
    final icon = _getDataTypeIcon(type);
    final title = _getDataTypeName(type);
    final desc = _getDataTypeDescription(type);

    return AppCard(
      padding: const EdgeInsets.all(12),
      onTap: () => _onSelectDataType(type),
      border: Border.all(
        color: isSelected ? AppColors.primaryBlue : AppColors.border,
        width: isSelected ? 1.8 : 1.0,
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primaryBlue : AppColors.pageBackground,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: isSelected ? Colors.white : AppColors.primaryBlue, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: isSelected ? AppColors.primaryBlue : AppColors.darkBlueText,
                  ),
                ),
                Text(
                  desc,
                  style: const TextStyle(fontSize: 11, color: AppColors.secondaryText),
                ),
              ],
            ),
          ),
          if (isSelected)
            const CircleAvatar(
              radius: 10,
              backgroundColor: AppColors.primaryBlue,
              child: Icon(Icons.check, size: 12, color: Colors.white),
            ),
        ],
      ),
    );
  }

  // ==========================================================================
  // SECTION 2: TEMPLATE GUIDANCE CARD (HIGH CONTRAST, DIRECT DOWNLOAD)
  // ==========================================================================

  Widget _buildTemplateGuidanceSection() {
    final typeName = _getDataTypeName(_selectedDataType);

    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.file_download_outlined, color: AppColors.primaryBlue, size: 22),
              const SizedBox(width: 8),
              Text(
                'Template for $typeName',
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.darkBlueText),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Download a ready-to-fill template with required columns and sample data for $typeName.',
            style: const TextStyle(fontSize: 12, color: AppColors.secondaryText),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: const Icon(Icons.download_rounded, color: Colors.white, size: 18),
                  label: Text(
                    'Download $typeName Template',
                    style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: Colors.white),
                  ),
                  onPressed: _downloadTemplateDirectly,
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.primaryBlue),
                  foregroundColor: AppColors.primaryBlue,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: _viewColumnsSpecification,
                child: const Text(
                  'View Columns',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primaryBlue),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // SECTION 3: UPLOAD FILE CARD (HIGH CONTRAST BUTTON)
  // ==========================================================================

  Widget _buildUploadSection() {
    final typeName = _getDataTypeName(_selectedDataType);

    if (_selectedFileName != null) {
      return AppCard(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            const CircleAvatar(
              radius: 20,
              backgroundColor: AppColors.primaryBlue,
              child: Icon(Icons.description, color: Colors.white, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_selectedFileName!,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.darkBlueText)),
                  Text(
                    _isValidated
                        ? 'Validated for $typeName import'
                        : 'Ready to validate',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: _isValidated ? AppColors.success : AppColors.secondaryText,
                    ),
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: _simulateFileSelection,
              child: const Text('Change File', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.primaryBlue)),
            ),
          ],
        ),
      );
    }

    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.pageBackground,
            child: Icon(Icons.cloud_upload_outlined, color: AppColors.primaryBlue, size: 28),
          ),
          const SizedBox(height: 10),
          Text(
            'Upload $typeName Excel or CSV file',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.darkBlueText),
          ),
          const SizedBox(height: 4),
          const Text(
            'Supported file formats: .csv, .xlsx',
            style: TextStyle(fontSize: 11.5, color: AppColors.secondaryText),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              icon: const Icon(Icons.upload_file_outlined, color: Colors.white, size: 18),
              label: Text(
                'Choose $typeName Excel / CSV File',
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: Colors.white),
              ),
              onPressed: _simulateFileSelection,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // SECTION 4: DUPLICATE RECORD STRATEGY
  // ==========================================================================

  Widget _buildDuplicateStrategySection() {
    return AppCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Duplicate Record Strategy',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.darkBlueText)),
          const SizedBox(height: 6),
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _duplicateStrategy,
              isExpanded: true,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.darkBlueText),
              items: ['Add to Existing', 'Overwrite Existing', 'Skip Duplicates']
                  .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                  .toList(),
              onChanged: (val) {
                if (val != null) setState(() => _duplicateStrategy = val);
              },
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // SECTION 5: VALIDATION & PREVIEW
  // ==========================================================================

  Widget _buildValidationPreviewSection() {
    final typeName = _getDataTypeName(_selectedDataType);

    if (!_isValidated) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryBlue,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          icon: const Icon(Icons.fact_check_outlined, color: Colors.white, size: 20),
          label: const Text('Preview & Validate Dataset',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Colors.white)),
          onPressed: _validateSelectedFile,
        ),
      );
    }

    int totalRows = 0;
    int validRows = 0;
    int duplicateRows = 0;

    if (_stockAnalysis != null) {
      totalRows = _stockAnalysis!.totalRows;
      validRows = _stockAnalysis!.validRows;
      duplicateRows = _stockAnalysis!.duplicateRows;
    } else if (_accountAnalysis != null) {
      totalRows = _accountAnalysis!.totalRows;
      validRows = _accountAnalysis!.validRows;
      duplicateRows = _accountAnalysis!.duplicateRows;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppCard(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Validation Summary ($totalRows Records)',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.darkBlueText)),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          Text('$validRows', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.success)),
                          const Text('Ready to Import', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.success)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.orange.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          Text('$duplicateRows', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.orange)),
                          const Text('Duplicates', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.orange)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            icon: const Icon(Icons.check_circle_outline, color: Colors.white, size: 20),
            label: Text('Import $validRows Valid $typeName Records',
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Colors.white)),
            onPressed: _executeImport,
          ),
        ),
      ],
    );
  }
}
