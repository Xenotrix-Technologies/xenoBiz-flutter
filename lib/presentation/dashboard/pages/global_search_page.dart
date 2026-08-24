import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../application/bloc/global_search_bloc.dart';
import '../../../application/routing/route_names.dart';
import '../../../const/colors.dart';
import '../../../domain/entities/customer_entity.dart';
import '../../../domain/entities/expense_entity.dart';
import '../../../domain/entities/invoice_entity.dart';
import '../../../domain/entities/product_entity.dart';
import '../../../domain/entities/purchase_entity.dart';
import '../../widgets/app_card.dart';
import '../../widgets/status_chip.dart';
import '../../widgets/ui_state_widgets.dart';

class GlobalSearchPage extends StatefulWidget {
  const GlobalSearchPage({super.key});

  @override
  State<GlobalSearchPage> createState() => _GlobalSearchPageState();
}

class _GlobalSearchPageState extends State<GlobalSearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    // Load recent search queries from storage
    context.read<GlobalSearchBloc>().add(LoadRecentSearchesEvent());
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      final category = (context.read<GlobalSearchBloc>().state is GlobalSearchLoadedState)
          ? (context.read<GlobalSearchBloc>().state as GlobalSearchLoadedState).categoryFilter
          : 'All';
      context.read<GlobalSearchBloc>().add(
            PerformGlobalSearchEvent(query: query, categoryFilter: category),
          );
    });
  }

  void _submitSearch(String query) {
    if (query.trim().isEmpty) return;
    context.read<GlobalSearchBloc>().add(AddRecentSearchQueryEvent(query));
    _onSearchChanged(query);
  }

  String _formatCurrency(double amount) {
    final formatter = NumberFormat.currency(symbol: '₹', decimalDigits: 0, locale: 'en_IN');
    return formatter.format(amount);
  }

  String _formatDate(DateTime date) {
    return DateFormat('d MMM yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.deepNavy,
        foregroundColor: Colors.white,
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: Container(
            height: 42,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextField(
              controller: _searchController,
              focusNode: _searchFocusNode,
              autofocus: true,
              textInputAction: TextInputAction.search,
              onChanged: _onSearchChanged,
              onSubmitted: _submitSearch,
              style: const TextStyle(fontSize: 14, color: AppColors.darkBlueText),
              decoration: InputDecoration(
                hintText: 'Search customers, invoices, products...',
                hintStyle: const TextStyle(fontSize: 13, color: AppColors.secondaryText),
                prefixIcon: const Icon(Icons.search, size: 20, color: AppColors.primaryBlue),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          context.read<GlobalSearchBloc>().add(ClearGlobalSearchEvent());
                        },
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
        ),
      ),
      body: BlocBuilder<GlobalSearchBloc, GlobalSearchState>(
        builder: (context, state) {
          return Column(
            children: [
              // Category Filter Chips
              _buildCategoryFiltersRow(context, state),

              // Main Body Content
              Expanded(
                child: _buildBodyContent(context, state),
              ),
            ],
          );
        },
      ),
    );
  }

  // CATEGORY FILTER CHIPS ROW
  Widget _buildCategoryFiltersRow(BuildContext context, GlobalSearchState state) {
    final categories = ['All', 'Customers', 'Invoices', 'Products', 'Expenses', 'Purchases'];
    String currentCategory = 'All';
    if (state is GlobalSearchLoadedState) {
      currentCategory = state.categoryFilter;
    } else if (state is GlobalSearchLoadingState) {
      currentCategory = state.categoryFilter;
    }

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: categories.map((cat) {
            final isSelected = currentCategory == cat;
            return Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: ChoiceChip(
                label: Text(cat),
                selected: isSelected,
                selectedColor: AppColors.primaryBlue,
                backgroundColor: AppColors.background,
                side: BorderSide(
                  color: isSelected ? AppColors.primaryBlue : AppColors.border,
                ),
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : AppColors.darkBlueText,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                  fontSize: 12,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                onSelected: (val) {
                  if (val) {
                    context.read<GlobalSearchBloc>().add(ChangeSearchCategoryFilterEvent(cat));
                    if (_searchController.text.trim().isNotEmpty) {
                      context.read<GlobalSearchBloc>().add(
                            PerformGlobalSearchEvent(
                              query: _searchController.text.trim(),
                              categoryFilter: cat,
                            ),
                          );
                    }
                  }
                },
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  // BODY CONTENT SWITCHER
  Widget _buildBodyContent(BuildContext context, GlobalSearchState state) {
    if (state is GlobalSearchInitialState) {
      return _buildRecentSearchesView(context, state.recentSearches);
    }

    if (state is GlobalSearchLoadingState) {
      return const InvoiceListSkeleton();
    }

    if (state is GlobalSearchErrorState) {
      return ErrorState(
        message: state.message,
        onRetry: () {
          if (_searchController.text.isNotEmpty) {
            _onSearchChanged(_searchController.text);
          }
        },
      );
    }

    if (state is GlobalSearchLoadedState) {
      if (state.isEmpty) {
        return _buildNoResultsView(state.query);
      }
      return _buildSearchResultsList(context, state);
    }

    return const SizedBox.shrink();
  }

  // RECENT SEARCHES VIEW
  Widget _buildRecentSearchesView(BuildContext context, List<String> recentSearches) {
    if (recentSearches.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.search_rounded, size: 64, color: AppColors.border),
            SizedBox(height: 16),
            Text(
              'Search Anything Across Your Business',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.darkBlueText),
            ),
            SizedBox(height: 6),
            Text(
              'Search for customers, invoices, products, expenses, & purchases.',
              style: TextStyle(fontSize: 13, color: AppColors.secondaryText),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recent Searches',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.darkBlueText),
              ),
              TextButton(
                onPressed: () {
                  context.read<GlobalSearchBloc>().add(ClearRecentSearchesEvent());
                },
                child: const Text('Clear All', style: TextStyle(color: AppColors.danger, fontSize: 13, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: recentSearches.map((term) {
              return ActionChip(
                avatar: const Icon(Icons.history, size: 16, color: AppColors.secondaryText),
                label: Text(term),
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: const BorderSide(color: AppColors.border),
                ),
                onPressed: () {
                  _searchController.text = term;
                  _submitSearch(term);
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // NO RESULTS VIEW
  Widget _buildNoResultsView(String query) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.search_off_rounded, size: 48, color: AppColors.primaryBlue),
            ),
            const SizedBox(height: 16),
            Text(
              'No results found for "$query"',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.darkBlueText),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Check spelling or try searching for another customer name, invoice #, or product.',
              style: TextStyle(fontSize: 13, color: AppColors.secondaryText, height: 1.4),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // SEARCH RESULTS CATEGORIZED LIST
  Widget _buildSearchResultsList(BuildContext context, GlobalSearchLoadedState state) {
    final cat = state.categoryFilter;

    final showCustomers = (cat == 'All' || cat == 'Customers') && state.customers.isNotEmpty;
    final showInvoices = (cat == 'All' || cat == 'Invoices') && state.invoices.isNotEmpty;
    final showProducts = (cat == 'All' || cat == 'Products') && state.products.isNotEmpty;
    final showExpenses = (cat == 'All' || cat == 'Expenses') && state.expenses.isNotEmpty;
    final showPurchases = (cat == 'All' || cat == 'Purchases') && state.purchases.isNotEmpty;

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        if (showCustomers) ...[
          _buildCategoryHeader('CUSTOMERS (${state.customers.length})', Icons.person_outline),
          const SizedBox(height: 8),
          ...state.customers.map((cust) => _buildCustomerResultCard(context, cust)),
          const SizedBox(height: 16),
        ],

        if (showInvoices) ...[
          _buildCategoryHeader('INVOICES (${state.invoices.length})', Icons.receipt_long_outlined),
          const SizedBox(height: 8),
          ...state.invoices.map((inv) => _buildInvoiceResultCard(context, inv)),
          const SizedBox(height: 16),
        ],

        if (showProducts) ...[
          _buildCategoryHeader('PRODUCTS (${state.products.length})', Icons.inventory_2_outlined),
          const SizedBox(height: 8),
          ...state.products.map((prod) => _buildProductResultCard(context, prod)),
          const SizedBox(height: 16),
        ],

        if (showExpenses) ...[
          _buildCategoryHeader('EXPENSES (${state.expenses.length})', Icons.account_balance_wallet_outlined),
          const SizedBox(height: 8),
          ...state.expenses.map((exp) => _buildExpenseResultCard(context, exp)),
          const SizedBox(height: 16),
        ],

        if (showPurchases) ...[
          _buildCategoryHeader('PURCHASES (${state.purchases.length})', Icons.local_shipping_outlined),
          const SizedBox(height: 8),
          ...state.purchases.map((pur) => _buildPurchaseResultCard(context, pur)),
          const SizedBox(height: 16),
        ],
      ],
    );
  }

  Widget _buildCategoryHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primaryBlue),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.0,
            color: AppColors.secondaryText,
          ),
        ),
      ],
    );
  }

  // CUSTOMER RESULT CARD
  Widget _buildCustomerResultCard(BuildContext context, CustomerEntity cust) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: AppCard(
        onTap: () {
          context.read<GlobalSearchBloc>().add(AddRecentSearchQueryEvent(cust.name));
          context.push(RouteNames.customerDetails, extra: cust);
        },
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.person, color: AppColors.primaryBlue, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(cust.name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                  if (cust.phone.isNotEmpty)
                    Text(cust.phone, style: const TextStyle(fontSize: 12, color: AppColors.secondaryText)),
                ],
              ),
            ),
            if (cust.outstandingBalance > 0)
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(_formatCurrency(cust.outstandingBalance), style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.danger, fontSize: 13)),
                  const Text('Due', style: TextStyle(fontSize: 10, color: AppColors.danger, fontWeight: FontWeight.w600)),
                ],
              ),
          ],
        ),
      ),
    );
  }

  // INVOICE RESULT CARD
  Widget _buildInvoiceResultCard(BuildContext context, InvoiceEntity inv) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: AppCard(
        onTap: () {
          context.read<GlobalSearchBloc>().add(AddRecentSearchQueryEvent(inv.invoiceNumber));
          context.push(RouteNames.invoiceDetails, extra: inv);
        },
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.deepNavy.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.description, color: AppColors.deepNavy, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(inv.invoiceNumber, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                  Text('${inv.customerName} • ${_formatDate(inv.issueDate)}', style: const TextStyle(fontSize: 12, color: AppColors.secondaryText)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(_formatCurrency(inv.grandTotal), style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.primaryBlue, fontSize: 14)),
                const SizedBox(height: 2),
                inv.status == InvoiceStatus.paid
                    ? StatusChip.paid()
                    : inv.status == InvoiceStatus.partiallyPaid
                        ? StatusChip.partiallyPaid()
                        : StatusChip.unpaid(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // PRODUCT RESULT CARD
  Widget _buildProductResultCard(BuildContext context, ProductEntity prod) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: AppCard(
        onTap: () {
          context.read<GlobalSearchBloc>().add(AddRecentSearchQueryEvent(prod.name));
          context.push(RouteNames.productDetails, extra: prod);
        },
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.inventory_2, color: AppColors.warning, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(prod.name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                  Text('SKU: ${prod.sku.isNotEmpty ? prod.sku : "N/A"} • Stock: ${prod.stockQuantity}', style: const TextStyle(fontSize: 12, color: AppColors.secondaryText)),
                ],
              ),
            ),
            Text(_formatCurrency(prod.sellingPrice), style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.darkBlueText, fontSize: 14)),
          ],
        ),
      ),
    );
  }

  // EXPENSE RESULT CARD
  Widget _buildExpenseResultCard(BuildContext context, ExpenseEntity exp) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: AppCard(
        onTap: () {
          context.read<GlobalSearchBloc>().add(AddRecentSearchQueryEvent(exp.title));
          context.push(RouteNames.expenseAccountDetails);
        },
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.danger.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.account_balance_wallet, color: AppColors.danger, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(exp.title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                  Text('${exp.category} • ${_formatDate(exp.expenseDate)}', style: const TextStyle(fontSize: 12, color: AppColors.secondaryText)),
                ],
              ),
            ),
            Text(_formatCurrency(exp.amount), style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.danger, fontSize: 14)),
          ],
        ),
      ),
    );
  }

  // PURCHASE RESULT CARD
  Widget _buildPurchaseResultCard(BuildContext context, PurchaseEntity pur) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: AppCard(
        onTap: () {
          context.read<GlobalSearchBloc>().add(AddRecentSearchQueryEvent(pur.poNumber));
          context.push(RouteNames.purchaseManagement);
        },
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primaryContainer,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.local_shipping, color: AppColors.primaryBlue, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(pur.poNumber, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                  Text('${pur.supplierName} • ${_formatDate(pur.orderDate)}', style: const TextStyle(fontSize: 12, color: AppColors.secondaryText)),
                ],
              ),
            ),
            Text(_formatCurrency(pur.totalAmount), style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.darkBlueText, fontSize: 14)),
          ],
        ),
      ),
    );
  }
}
