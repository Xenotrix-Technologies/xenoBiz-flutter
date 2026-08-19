import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../application/bloc/accounts_bloc.dart';
import '../../../application/bloc/purchase_bloc.dart';
import '../../../application/routing/route_names.dart';
import '../../../const/colors.dart';
import '../../../domain/entities/customer_entity.dart';
import '../../../domain/entities/purchase_entity.dart';
import '../../../infrastructure/services/account_import_service.dart';
import '../../widgets/app_card.dart';
import '../../widgets/status_chip.dart';
import '../../widgets/ui_state_widgets.dart';

class AccountsPage extends StatefulWidget {
  const AccountsPage({super.key});

  @override
  State<AccountsPage> createState() => _AccountsPageState();
}

class _AccountsPageState extends State<AccountsPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  int _salePurchaseSubTab = 0; // 0 = Sale Accounts (Customers), 1 = Purchase Accounts (Suppliers)

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    context.read<AccountsBloc>().add(const FetchAccountsEvent());
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _showAddAccountChoicesModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Add Account',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.darkBlueText,
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: const BorderSide(color: AppColors.border),
                ),
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.person_add_alt_1_rounded, color: AppColors.primaryBlue),
                ),
                title: const Text('Sale Account (Customer)', style: TextStyle(fontWeight: FontWeight.w700)),
                subtitle: const Text('Add a customer for sales and credit tracking', style: TextStyle(fontSize: 12)),
                onTap: () {
                  Navigator.pop(ctx);
                  context.push(RouteNames.createMaster, extra: 1);
                },
              ),
              const SizedBox(height: 12),
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: const BorderSide(color: AppColors.border),
                ),
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.business_outlined, color: AppColors.warning),
                ),
                title: const Text('Purchase Account (Supplier)', style: TextStyle(fontWeight: FontWeight.w700)),
                subtitle: const Text('Add a vendor/supplier for purchases and payables', style: TextStyle(fontSize: 12)),
                onTap: () {
                  Navigator.pop(ctx);
                  context.push(RouteNames.createMaster, extra: 2);
                },
              ),
              const SizedBox(height: 12),
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: const BorderSide(color: AppColors.border),
                ),
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.account_balance_rounded, color: AppColors.success),
                ),
                title: const Text('Expense Account', style: TextStyle(fontWeight: FontWeight.w700)),
                subtitle: const Text('Add an expense category account (Electricity, Rent, etc.)', style: TextStyle(fontSize: 12)),
                onTap: () {
                  Navigator.pop(ctx);
                  context.push(RouteNames.createMaster, extra: 3);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showImportAccountsDialog(BuildContext context, AccountsLoadedState state) {
    final textController = TextEditingController(text: AccountImportService.generateSampleCsvTemplate());
    DuplicateAccountStrategy strategy = DuplicateAccountStrategy.addBalance;

    final pBloc = context.read<PurchaseBloc>();
    final List<SupplierEntity> suppliers = (pBloc.state is PurchaseLoadedState) ? (pBloc.state as PurchaseLoadedState).suppliers : [];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (sheetCtx, setSheetState) {
            final analysis = AccountImportService.parseAndValidateCsv(
              csvContent: textController.text,
              existingCustomers: state.allCustomers,
              existingSuppliers: suppliers,
              existingExpenses: state.expenseAccounts,
            );

            return SafeArea(
              child: Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(sheetCtx).size.height * 0.88,
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Import Accounts (CSV / Excel)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.darkBlueText)),
                        IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(sheetCtx)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Import Sale (Customer), Purchase (Supplier), and Expense category accounts in bulk.',
                      style: TextStyle(fontSize: 12, color: AppColors.secondaryText),
                    ),
                    const SizedBox(height: 12),

                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primaryBlue,
                        side: const BorderSide(color: AppColors.primaryBlue),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: AccountImportService.generateSampleCsvTemplate()));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Sample CSV template copied to clipboard! Paste it into Excel or CSV file.'),
                            backgroundColor: AppColors.primaryBlue,
                          ),
                        );
                      },
                      icon: const Icon(Icons.download, size: 18),
                      label: const Text('Download / Copy Excel Template', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                    ),
                    const SizedBox(height: 12),

                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Paste or Edit CSV Account Data:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.darkBlueText)),
                            const SizedBox(height: 6),
                            TextField(
                              controller: textController,
                              maxLines: 5,
                              style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
                              decoration: InputDecoration(
                                hintText: 'Account Type,Account Name,Company Name,Phone,Email,Address,Category,Opening Balance,Notes',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                contentPadding: const EdgeInsets.all(10),
                              ),
                              onChanged: (_) => setSheetState(() {}),
                            ),
                            const SizedBox(height: 14),

                            const Text('Validation Results:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.darkBlueText)),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 6,
                              children: [
                                _AccountMetricChip(label: 'Total Rows', count: analysis.totalRows, color: AppColors.darkBlueText),
                                _AccountMetricChip(label: 'Valid', count: analysis.validRows, color: AppColors.success),
                                _AccountMetricChip(label: 'Invalid', count: analysis.invalidRows, color: analysis.invalidRows > 0 ? AppColors.danger : AppColors.secondaryText),
                                _AccountMetricChip(label: 'Duplicates', count: analysis.duplicateRows, color: analysis.duplicateRows > 0 ? AppColors.warning : AppColors.secondaryText),
                              ],
                            ),
                            const SizedBox(height: 12),

                            if (analysis.errorSummary.isNotEmpty) ...[
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: AppColors.errorContainer,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Row Errors:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.danger)),
                                    const SizedBox(height: 4),
                                    ...analysis.errorSummary.take(3).map((err) => Text('• $err', style: const TextStyle(fontSize: 11, color: AppColors.danger))),
                                    if (analysis.errorSummary.length > 3)
                                      Text('+ ${analysis.errorSummary.length - 3} more errors...', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.danger)),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 12),
                            ],

                            if (analysis.duplicateRows > 0) ...[
                              const Text('Duplicate Account Strategy:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.darkBlueText)),
                              const SizedBox(height: 6),
                              Column(
                                children: [
                                  ListTile(
                                    title: const Text('Add Balance (Recommended)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                                    subtitle: const Text('Add imported balance to existing account balance', style: TextStyle(fontSize: 11)),
                                    leading: Icon(
                                      strategy == DuplicateAccountStrategy.addBalance ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                                      color: strategy == DuplicateAccountStrategy.addBalance ? AppColors.primaryBlue : AppColors.secondaryText,
                                    ),
                                    onTap: () => setSheetState(() => strategy = DuplicateAccountStrategy.addBalance),
                                    contentPadding: EdgeInsets.zero,
                                    dense: true,
                                  ),
                                  ListTile(
                                    title: const Text('Update Existing', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                                    subtitle: const Text('Update contact details & overwrite opening balance', style: TextStyle(fontSize: 11)),
                                    leading: Icon(
                                      strategy == DuplicateAccountStrategy.updateExisting ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                                      color: strategy == DuplicateAccountStrategy.updateExisting ? AppColors.primaryBlue : AppColors.secondaryText,
                                    ),
                                    onTap: () => setSheetState(() => strategy = DuplicateAccountStrategy.updateExisting),
                                    contentPadding: EdgeInsets.zero,
                                    dense: true,
                                  ),
                                  ListTile(
                                    title: const Text('Skip Duplicates', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                                    subtitle: const Text('Ignore duplicate rows and do not import', style: TextStyle(fontSize: 11)),
                                    leading: Icon(
                                      strategy == DuplicateAccountStrategy.skip ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                                      color: strategy == DuplicateAccountStrategy.skip ? AppColors.primaryBlue : AppColors.secondaryText,
                                    ),
                                    onTap: () => setSheetState(() => strategy = DuplicateAccountStrategy.skip),
                                    contentPadding: EdgeInsets.zero,
                                    dense: true,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                            ],

                            const Text('Parsed Accounts Preview:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.darkBlueText)),
                            const SizedBox(height: 6),
                            Container(
                              height: 180,
                              decoration: BoxDecoration(
                                border: Border.all(color: AppColors.border),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: SingleChildScrollView(
                                scrollDirection: Axis.vertical,
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: DataTable(
                                    columnSpacing: 16,
                                    headingRowHeight: 32,
                                    dataRowMinHeight: 32,
                                    dataRowMaxHeight: 36,
                                    columns: const [
                                      DataColumn(label: Text('Row', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800))),
                                      DataColumn(label: Text('Type', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800))),
                                      DataColumn(label: Text('Account Name', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800))),
                                      DataColumn(label: Text('Phone', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800))),
                                      DataColumn(label: Text('Opening Balance', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800))),
                                      DataColumn(label: Text('Status', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800))),
                                    ],
                                    rows: analysis.rows.map((row) {
                                      return DataRow(
                                        cells: [
                                          DataCell(Text('#${row.rowIndex}', style: const TextStyle(fontSize: 11))),
                                          DataCell(Text(row.accountType, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700))),
                                          DataCell(Text(row.accountName, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700))),
                                          DataCell(Text(row.phone.isNotEmpty ? row.phone : '-', style: const TextStyle(fontSize: 11))),
                                          DataCell(Text('₹${row.openingBalance.toStringAsFixed(0)}', style: const TextStyle(fontSize: 11))),
                                          DataCell(
                                            Text(
                                              !row.isValid
                                                  ? 'INVALID'
                                                  : (row.isDuplicate ? 'DUPLICATE' : 'NEW'),
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.w800,
                                                color: !row.isValid
                                                    ? AppColors.danger
                                                    : (row.isDuplicate ? AppColors.warning : AppColors.success),
                                              ),
                                            ),
                                          ),
                                        ],
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryBlue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        onPressed: analysis.validRows == 0
                            ? null
                            : () {
                                int importedCount = 0;
                                for (var r in analysis.rows) {
                                  if (!r.isValid) continue;

                                  if (r.isDuplicate && strategy == DuplicateAccountStrategy.skip) {
                                    continue;
                                  }

                                  if (r.accountType == 'Sale Account') {
                                    final cust = CustomerEntity(
                                      id: 'CUST-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}-$importedCount',
                                      name: r.accountName,
                                      phone: r.phone,
                                      email: r.email,
                                      address: r.address,
                                      outstandingBalance: r.openingBalance,
                                      createdAt: DateTime.now(),
                                    );
                                    context.read<AccountsBloc>().add(CreateCustomerAccountEvent(cust));
                                    importedCount++;
                                  } else if (r.accountType == 'Purchase Account') {
                                    final sup = SupplierEntity(
                                      id: 'sup_${DateTime.now().millisecondsSinceEpoch}_$importedCount',
                                      name: r.accountName,
                                      companyName: r.companyName.isNotEmpty ? r.companyName : r.accountName,
                                      phone: r.phone,
                                      email: r.email,
                                      address: r.address,
                                      payableBalance: r.openingBalance,
                                      createdAt: DateTime.now(),
                                    );
                                    context.read<PurchaseBloc>().add(CreateSupplierSubmittedEvent(sup));
                                    importedCount++;
                                  } else if (r.accountType == 'Expense Account') {
                                    context.read<AccountsBloc>().add(
                                          CreateExpenseAccountEvent(
                                            title: r.accountName,
                                            category: r.category,
                                            openingBalance: r.openingBalance,
                                          ),
                                        );
                                    importedCount++;
                                  }
                                }

                                Navigator.pop(sheetCtx);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Successfully imported $importedCount accounts into Hive!'),
                                    backgroundColor: AppColors.success,
                                  ),
                                );
                              },
                        child: Text('Confirm Import (${analysis.validRows} Accounts)', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showAddCustomerDialog(BuildContext context, {CustomerEntity? customerToEdit}) {
    final isEditing = customerToEdit != null;
    final nameCtrl = TextEditingController(text: customerToEdit?.name ?? '');
    final phoneCtrl = TextEditingController(text: customerToEdit?.phone ?? '');
    final emailCtrl = TextEditingController(text: customerToEdit?.email ?? '');
    final addressCtrl = TextEditingController(text: customerToEdit?.address ?? '');
    final openingBalanceCtrl = TextEditingController(
      text: isEditing ? customerToEdit.outstandingBalance.toStringAsFixed(0) : '',
    );

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(isEditing ? 'Edit Customer Account' : 'Add Customer Account', style: const TextStyle(fontWeight: FontWeight.w800)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: 'Customer Name *', prefixIcon: Icon(Icons.person_outline)),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: phoneCtrl,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(labelText: 'Phone Number', prefixIcon: Icon(Icons.phone_outlined)),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(labelText: 'Email Address', prefixIcon: Icon(Icons.email_outlined)),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: addressCtrl,
                  decoration: const InputDecoration(labelText: 'Address', prefixIcon: Icon(Icons.location_on_outlined)),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: openingBalanceCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Outstanding Balance (₹)', prefixIcon: Icon(Icons.currency_rupee)),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryBlue, foregroundColor: Colors.white),
              onPressed: () {
                if (nameCtrl.text.trim().isNotEmpty) {
                  final balance = double.tryParse(openingBalanceCtrl.text.trim()) ?? 0.0;
                  final cust = CustomerEntity(
                    id: isEditing ? customerToEdit.id : 'CUST-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
                    name: nameCtrl.text.trim(),
                    phone: phoneCtrl.text.trim(),
                    email: emailCtrl.text.trim(),
                    address: addressCtrl.text.trim(),
                    outstandingBalance: balance,
                    createdAt: isEditing ? customerToEdit.createdAt : DateTime.now(),
                  );

                  if (isEditing) {
                    context.read<AccountsBloc>().add(UpdateCustomerAccountEvent(cust));
                  } else {
                    context.read<AccountsBloc>().add(CreateCustomerAccountEvent(cust));
                  }
                  Navigator.pop(ctx);
                }
              },
              child: Text(isEditing ? 'Update Account' : 'Save Customer'),
            ),
          ],
        );
      },
    );
  }

  void _showAddExpenseAccountDialog(BuildContext context, {ExpenseAccountSummary? accountToEdit}) {
    final isEditing = accountToEdit != null;
    final titleCtrl = TextEditingController(text: accountToEdit?.title ?? '');
    final balanceCtrl = TextEditingController(text: isEditing ? accountToEdit.outstandingBalance.toStringAsFixed(0) : '');
    String selectedCat = accountToEdit?.category ?? 'Electricity';

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (dialogCtx, setDialogState) {
            return AlertDialog(
              title: Text(isEditing ? 'Edit Expense Account' : 'Add Expense Account', style: const TextStyle(fontWeight: FontWeight.w800)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      initialValue: selectedCat,
                      decoration: const InputDecoration(labelText: 'Expense Category *', prefixIcon: Icon(Icons.category_outlined)),
                      items: AccountsBloc.defaultExpenseCategories
                          .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) setDialogState(() => selectedCat = val);
                      },
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: titleCtrl,
                      decoration: const InputDecoration(labelText: 'Account Title', prefixIcon: Icon(Icons.label_outlined)),
                    ),
                    if (!isEditing) ...[
                      const SizedBox(height: 10),
                      TextField(
                        controller: balanceCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Opening Balance Due (₹)', prefixIcon: Icon(Icons.currency_rupee)),
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(dialogCtx), child: const Text('Cancel')),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryBlue, foregroundColor: Colors.white),
                  onPressed: () {
                    final title = titleCtrl.text.trim().isNotEmpty ? titleCtrl.text.trim() : selectedCat;
                    final balance = double.tryParse(balanceCtrl.text.trim()) ?? 0.0;

                    if (isEditing) {
                      context.read<AccountsBloc>().add(
                            UpdateExpenseAccountEvent(
                              oldCategory: accountToEdit.category,
                              newTitle: title,
                              newCategory: selectedCat,
                            ),
                          );
                    } else {
                      context.read<AccountsBloc>().add(
                            CreateExpenseAccountEvent(
                              title: title,
                              category: selectedCat,
                              openingBalance: balance,
                            ),
                          );
                    }
                    Navigator.pop(dialogCtx);
                  },
                  child: Text(isEditing ? 'Update Account' : 'Save Account'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showFilterBottomSheet(BuildContext context, AccountsLoadedState state) {
    String tempFilter = state.selectedFilterStatus;
    String tempSort = state.sortBy;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (sheetCtx, setSheetState) {
            return SafeArea(
              child: Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(sheetCtx).size.height * 0.85,
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Filter & Sort Accounts', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.darkBlueText)),
                        IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(sheetCtx)),
                      ],
                    ),
                    const SizedBox(height: 14),

                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Filter Status', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              children: ['All', 'With Due', 'Paid'].map((st) {
                                final isSelected = tempFilter == st;
                                return ChoiceChip(
                                  label: Text(st),
                                  selected: isSelected,
                                  selectedColor: AppColors.primaryBlue,
                                  labelStyle: TextStyle(color: isSelected ? Colors.white : AppColors.darkBlueText, fontWeight: FontWeight.w700),
                                  onSelected: (val) {
                                    if (val) setSheetState(() => tempFilter = st);
                                  },
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 16),

                            const Text('Sort By', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              children: ['Name', 'Highest Due'].map((sortOpt) {
                                final isSelected = tempSort == sortOpt;
                                return ChoiceChip(
                                  label: Text(sortOpt),
                                  selected: isSelected,
                                  selectedColor: AppColors.primaryBlue,
                                  labelStyle: TextStyle(color: isSelected ? Colors.white : AppColors.darkBlueText, fontWeight: FontWeight.w700),
                                  onSelected: (val) {
                                    if (val) setSheetState(() => tempSort = sortOpt);
                                  },
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryBlue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        onPressed: () {
                          context.read<AccountsBloc>().add(
                                FetchAccountsEvent(
                                  query: state.searchQuery,
                                  filterStatus: tempFilter,
                                  sortBy: tempSort,
                                ),
                              );
                          Navigator.pop(sheetCtx);
                        },
                        child: const Text('Apply Filter', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _confirmDeleteCustomer(BuildContext context, CustomerEntity customer) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Customer Account'),
        content: Text('Are you sure you want to delete "${customer.name}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger, foregroundColor: Colors.white),
            onPressed: () {
              context.read<AccountsBloc>().add(DeleteCustomerAccountEvent(customer.id));
              Navigator.pop(ctx);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteExpenseAccount(BuildContext context, ExpenseAccountSummary account) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Expense Account'),
        content: Text('Are you sure you want to delete the "${account.title}" expense account?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger, foregroundColor: Colors.white),
            onPressed: () {
              context.read<AccountsBloc>().add(DeleteExpenseAccountEvent(account.category));
              Navigator.pop(ctx);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  String _formatCurrency(double amount) {
    final formatter = NumberFormat.currency(symbol: '₹', decimalDigits: 0, locale: 'en_IN');
    return formatter.format(amount);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Accounts'),
        backgroundColor: AppColors.deepNavy,
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          labelStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
          tabs: const [
            Tab(text: 'Sale / Purchase Accounts'),
            Tab(text: 'Expense Accounts'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: null,
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
        onPressed: () => _showAddAccountChoicesModal(context),
        icon: const Icon(Icons.add),
        label: const Text('Add Account', style: TextStyle(fontWeight: FontWeight.w700)),
      ),

      body: BlocBuilder<AccountsBloc, AccountsState>(
        builder: (context, state) {
          if (state is AccountsLoadingState || state is AccountsInitialState) {
            return const LoadingState(message: 'Loading accounts...');
          }

          if (state is AccountsErrorState) {
            return ErrorState(
              message: state.message,
              onRetry: () => context.read<AccountsBloc>().add(const FetchAccountsEvent()),
            );
          }

          if (state is AccountsLoadedState) {
            return Column(
              children: [
                // Overview Summary Header Bar
                _buildTopSummaryBar(state),
                const Divider(height: 1, color: AppColors.border),

                // Search Bar + Filter Button Row
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          onChanged: (val) {
                            context.read<AccountsBloc>().add(
                                  FetchAccountsEvent(
                                    query: val,
                                    filterStatus: state.selectedFilterStatus,
                                    sortBy: state.sortBy,
                                  ),
                                );
                          },
                          decoration: InputDecoration(
                            hintText: 'Search accounts by name, phone, or category...',
                            hintStyle: const TextStyle(fontSize: 13, color: AppColors.secondaryText),
                            prefixIcon: const Icon(Icons.search, color: AppColors.secondaryText, size: 20),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: AppColors.border),
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        style: IconButton.styleFrom(
                          backgroundColor: AppColors.primaryBlue.withValues(alpha: 0.1),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        icon: const Icon(Icons.file_upload_outlined, color: AppColors.primaryBlue),
                        onPressed: () => _showImportAccountsDialog(context, state),
                        tooltip: 'Import Accounts (CSV/Excel)',
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        style: IconButton.styleFrom(
                          backgroundColor: state.selectedFilterStatus != 'All'
                              ? AppColors.primaryBlue.withValues(alpha: 0.15)
                              : AppColors.surfaceContainerLow,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        icon: Icon(
                          Icons.filter_list,
                          color: state.selectedFilterStatus != 'All' ? AppColors.primaryBlue : AppColors.darkBlueText,
                        ),
                        onPressed: () => _showFilterBottomSheet(context, state),
                        tooltip: 'Filter & Sort Accounts',
                      ),
                    ],
                  ),
                ),

                // Tab Bar View Content
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      // TAB 1: SALE / PURCHASE ACCOUNTS
                      _buildSalePurchaseAccountsTab(context, state),

                      // TAB 2: EXPENSE ACCOUNTS
                      _buildExpenseAccountsTab(context, state),
                    ],
                  ),
                ),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  // TOP OVERVIEW SUMMARY BAR
  Widget _buildTopSummaryBar(AccountsLoadedState state) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: _SummaryBox(
              label: 'Customer Due',
              value: _formatCurrency(state.customerDueTotal),
              subText: '${state.customerCount} Accounts',
              valueColor: state.customerDueTotal > 0 ? AppColors.danger : AppColors.success,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _SummaryBox(
              label: 'Expense Due',
              value: _formatCurrency(state.expenseDueTotal),
              subText: '${state.expenseAccountCount} Accounts',
              valueColor: state.expenseDueTotal > 0 ? AppColors.warning : AppColors.secondaryText,
            ),
          ),
        ],
      ),
    );
  }

  // TAB 1: SALE / PURCHASE ACCOUNTS VIEW WITH SUB-TOGGLE
  Widget _buildSalePurchaseAccountsTab(BuildContext context, AccountsLoadedState state) {
    return Column(
      children: [
        Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: ChoiceChip(
                  padding: EdgeInsets.zero,
                  labelPadding: const EdgeInsets.symmetric(horizontal: 4),
                  label: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.person_outline, size: 15),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            'Sale Accounts (${state.customerCount})',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  selected: _salePurchaseSubTab == 0,
                  selectedColor: AppColors.primaryBlue,
                  labelStyle: TextStyle(
                    color: _salePurchaseSubTab == 0 ? Colors.white : AppColors.darkBlueText,
                    fontWeight: FontWeight.w700,
                    fontSize: 11.5,
                  ),
                  onSelected: (val) {
                    if (val) setState(() => _salePurchaseSubTab = 0);
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: BlocBuilder<PurchaseBloc, PurchaseState>(
                  builder: (context, pState) {
                    final supCount = (pState is PurchaseLoadedState) ? pState.suppliers.length : 0;
                    return ChoiceChip(
                      padding: EdgeInsets.zero,
                      labelPadding: const EdgeInsets.symmetric(horizontal: 4),
                      label: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.business_outlined, size: 15),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                'Purchase Accounts ($supCount)',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      selected: _salePurchaseSubTab == 1,
                      selectedColor: AppColors.primaryBlue,
                      labelStyle: TextStyle(
                        color: _salePurchaseSubTab == 1 ? Colors.white : AppColors.darkBlueText,
                        fontWeight: FontWeight.w700,
                        fontSize: 11.5,
                      ),
                      onSelected: (val) {
                        if (val) setState(() => _salePurchaseSubTab = 1);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1, color: AppColors.border),

        Expanded(
          child: _salePurchaseSubTab == 0
              ? _buildCustomerAccountsList(context, state)
              : _buildSupplierAccountsList(context),
        ),
      ],
    );
  }

  Widget _buildCustomerAccountsList(BuildContext context, AccountsLoadedState state) {
    if (state.filteredCustomers.isEmpty) {
      return const EmptyState(
        title: 'No Customer Accounts',
        message: 'Use the + Add Account button below to start tracking customer credit and sales.',
        icon: Icons.people_outline,
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: state.filteredCustomers.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (ctx, idx) {
        final cust = state.filteredCustomers[idx];
        final isDue = cust.outstandingBalance > 0;

        return AppCard(
          onTap: () {
            context.push(RouteNames.customerDetails, extra: cust);
          },
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: AppColors.primaryBlue.withValues(alpha: 0.12),
                child: Text(
                  cust.name.isNotEmpty ? cust.name.substring(0, 1).toUpperCase() : 'C',
                  style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.primaryBlue),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            cust.name,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: AppColors.darkBlueText,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        if (isDue)
                          StatusChip.unpaid(label: 'Due')
                        else
                          StatusChip.paid(label: 'Paid'),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'ID: ${cust.id} ${cust.phone.isNotEmpty ? "• ${cust.phone}" : ""}',
                      style: const TextStyle(fontSize: 12, color: AppColors.secondaryText),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('Outstanding', style: TextStyle(fontSize: 11, color: AppColors.secondaryText)),
                  const SizedBox(height: 2),
                  Text(
                    _formatCurrency(cust.outstandingBalance),
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: isDue ? AppColors.danger : AppColors.success,
                    ),
                  ),
                ],
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, size: 20, color: AppColors.secondaryText),
                onSelected: (val) {
                  if (val == 'edit') {
                    _showAddCustomerDialog(context, customerToEdit: cust);
                  } else if (val == 'delete') {
                    _confirmDeleteCustomer(context, cust);
                  }
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit, size: 18), SizedBox(width: 8), Text('Edit Account')])),
                  PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete_outline, size: 18, color: Colors.red), SizedBox(width: 8), Text('Delete Account', style: TextStyle(color: Colors.red))])),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSupplierAccountsList(BuildContext context) {
    return BlocBuilder<PurchaseBloc, PurchaseState>(
      builder: (context, pState) {
        if (pState is PurchaseLoadingState) {
          return const LoadingState(message: 'Loading purchase accounts...');
        }
        if (pState is PurchaseLoadedState) {
          if (pState.suppliers.isEmpty) {
            return const EmptyState(
              title: 'No Purchase Accounts',
              message: 'Add supplier accounts to manage purchase orders, stock bills, and vendor payables.',
              icon: Icons.business_outlined,
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: pState.suppliers.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (ctx, idx) {
              final sup = pState.suppliers[idx];
              final isDue = sup.payableBalance > 0;

              return AppCard(
                onTap: () {
                  context.push(RouteNames.supplierDetails, extra: sup);
                },
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: AppColors.warning.withValues(alpha: 0.12),
                      child: Text(
                        sup.name.isNotEmpty ? sup.name.substring(0, 1).toUpperCase() : 'S',
                        style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.warning),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  sup.name,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.darkBlueText,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 6),
                              if (isDue)
                                StatusChip.unpaid(label: 'Payable')
                              else
                                StatusChip.paid(label: 'Clear'),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Company: ${sup.companyName} ${sup.phone.isNotEmpty ? "• ${sup.phone}" : ""}',
                            style: const TextStyle(fontSize: 12, color: AppColors.secondaryText),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          _formatCurrency(sup.payableBalance),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: isDue ? AppColors.warning : AppColors.secondaryText,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          isDue ? 'Payable Due' : 'No Due',
                          style: TextStyle(
                            fontSize: 11,
                            color: isDue ? AppColors.warning : AppColors.secondaryText,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  // TAB 2: EXPENSE ACCOUNTS LIST (ONLY FAB FOR ADDING ACCOUNTS)
  Widget _buildExpenseAccountsTab(BuildContext context, AccountsLoadedState state) {
    if (state.filteredExpenseAccounts.isEmpty) {
      return const EmptyState(
        title: 'No Expense Accounts',
        message: 'Use the + Add Account button below to create expense accounts such as Electricity, Rent, or Salary.',
        icon: Icons.account_balance_outlined,
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: state.filteredExpenseAccounts.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (ctx, idx) {
        final expAcc = state.filteredExpenseAccounts[idx];
        final isDue = expAcc.outstandingBalance > 0;

        return AppCard(
          onTap: () {
            context.push(RouteNames.expenseAccountDetails, extra: expAcc);
          },
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.account_balance_wallet_outlined, color: AppColors.warning, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      expAcc.title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppColors.darkBlueText,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${expAcc.transactionCount} transactions • Month: ${_formatCurrency(expAcc.currentMonthTotal)}',
                      style: const TextStyle(fontSize: 12, color: AppColors.secondaryText),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(isDue ? 'Due' : 'Month Total', style: const TextStyle(fontSize: 11, color: AppColors.secondaryText)),
                  const SizedBox(height: 2),
                  Text(
                    _formatCurrency(isDue ? expAcc.outstandingBalance : expAcc.currentMonthTotal),
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: isDue ? AppColors.warning : AppColors.darkBlueText,
                    ),
                  ),
                ],
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, size: 20, color: AppColors.secondaryText),
                onSelected: (val) {
                  if (val == 'edit') {
                    _showAddExpenseAccountDialog(context, accountToEdit: expAcc);
                  } else if (val == 'delete') {
                    _confirmDeleteExpenseAccount(context, expAcc);
                  }
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit, size: 18), SizedBox(width: 8), Text('Edit Account')])),
                  PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete_outline, size: 18, color: Colors.red), SizedBox(width: 8), Text('Delete Account', style: TextStyle(color: Colors.red))])),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

// SUMMARY BOX WIDGET
class _SummaryBox extends StatelessWidget {
  final String label;
  final String value;
  final String subText;
  final Color valueColor;

  const _SummaryBox({
    required this.label,
    required this.value,
    required this.subText,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.secondaryText)),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: valueColor),
            ),
          ),
          const SizedBox(height: 2),
          Text(subText, style: const TextStyle(fontSize: 11, color: AppColors.secondaryText)),
        ],
      ),
    );
  }
}

class _AccountMetricChip extends StatelessWidget {
  final String label;
  final int count;
  final Color color;

  const _AccountMetricChip({
    required this.label,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: color),
          ),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '$count',
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
