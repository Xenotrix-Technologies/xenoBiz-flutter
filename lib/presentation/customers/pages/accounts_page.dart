import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../application/bloc/accounts_bloc.dart';
import '../../../application/bloc/purchase_bloc.dart';
import '../../../application/routing/route_names.dart';
import '../../../const/colors.dart';
import '../../../domain/entities/customer_entity.dart';
import '../../../domain/entities/purchase_entity.dart';
import '../../widgets/ui_state_widgets.dart';

enum AccountTypeFilter { all, customers, suppliers }

class AccountItem {
  final String id;
  final String name;
  final String? companyName;
  final String phone;
  final String email;
  final String address;
  final bool isCustomer; // true = Customer, false = Supplier
  final DateTime createdAt;
  final double balance;
  final CustomerEntity? customer;
  final SupplierEntity? supplier;

  const AccountItem({
    required this.id,
    required this.name,
    this.companyName,
    required this.phone,
    required this.email,
    required this.address,
    required this.isCustomer,
    required this.createdAt,
    required this.balance,
    this.customer,
    this.supplier,
  });

  String get initials {
    final clean = name.trim();
    if (clean.isEmpty) return 'A';
    final parts = clean.split(' ').where((p) => p.isNotEmpty).toList();
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return clean.substring(0, clean.length >= 2 ? 2 : 1).toUpperCase();
  }
}

class AccountsPage extends StatefulWidget {
  final int initialTab;
  const AccountsPage({super.key, this.initialTab = 0});

  @override
  State<AccountsPage> createState() => _AccountsPageState();
}

class _AccountsPageState extends State<AccountsPage> {
  final TextEditingController _searchController = TextEditingController();
  late AccountTypeFilter _selectedFilter;
  String _sortBy = 'Created Date — Newest';

  @override
  void initState() {
    super.initState();
    _selectedFilter = widget.initialTab == 1
        ? AccountTypeFilter.suppliers
        : AccountTypeFilter.all;
    context.read<AccountsBloc>().add(const FetchAccountsEvent());
    context.read<PurchaseBloc>().add(const FetchPurchasesEvent());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _handleRefresh() async {
    context.read<AccountsBloc>().add(const FetchAccountsEvent());
    context.read<PurchaseBloc>().add(const FetchPurchasesEvent());
    await Future.delayed(const Duration(milliseconds: 600));
  }

  void _confirmDeleteAccount(BuildContext context, AccountItem item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Account?', style: TextStyle(fontWeight: FontWeight.w800)),
        content: Text('Are you sure you want to delete "${item.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              if (item.isCustomer) {
                context.read<AccountsBloc>().add(DeleteCustomerAccountEvent(item.id));
              } else {
                context.read<PurchaseBloc>().add(DeleteSupplierEvent(item.id));
              }
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Account "${item.name}" deleted.'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showFilterBottomSheet(BuildContext context) {
    AccountTypeFilter tempFilter = _selectedFilter;
    String tempSort = _sortBy;

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
                        const Text(
                          'Filter & Sort Accounts',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppColors.darkBlueText,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(sheetCtx),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Flexible(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'Account Type',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppColors.darkBlueText,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 6,
                              children: [
                                AccountTypeFilter.all,
                                AccountTypeFilter.customers,
                                AccountTypeFilter.suppliers,
                              ].map((f) {
                                final isSelected = tempFilter == f;
                                final labelText = f == AccountTypeFilter.all
                                    ? 'All'
                                    : f == AccountTypeFilter.customers
                                        ? 'Customers'
                                        : 'Suppliers';
                                return ChoiceChip(
                                  label: Text(labelText),
                                  selected: isSelected,
                                  selectedColor: AppColors.primaryBlue,
                                  labelStyle: TextStyle(
                                    color: isSelected
                                        ? Colors.white
                                        : AppColors.darkBlueText,
                                    fontWeight: FontWeight.w700,
                                  ),
                                  onSelected: (val) {
                                    if (val) {
                                      setSheetState(() => tempFilter = f);
                                    }
                                  },
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              'Sort By',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppColors.darkBlueText,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 6,
                              children: [
                                'Created Date — Newest',
                                'Created Date — Oldest',
                                'Name — A to Z',
                                'Name — Z to A',
                                'Highest Outstanding',
                                'Lowest Outstanding',
                              ].map((sortOpt) {
                                final isSelected = tempSort == sortOpt;
                                return ChoiceChip(
                                  label: Text(sortOpt),
                                  selected: isSelected,
                                  selectedColor: AppColors.primaryBlue,
                                  labelStyle: TextStyle(
                                    color: isSelected
                                        ? Colors.white
                                        : AppColors.darkBlueText,
                                    fontWeight: FontWeight.w700,
                                  ),
                                  onSelected: (val) {
                                    if (val) {
                                      setSheetState(() => tempSort = sortOpt);
                                    }
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
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: () {
                          setState(() {
                            _selectedFilter = tempFilter;
                            _sortBy = tempSort;
                          });
                          Navigator.pop(sheetCtx);
                        },
                        child: const Text(
                          'Apply Filter',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                        ),
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

  List<AccountItem> _getFilteredAndSortedAccounts(
    List<CustomerEntity> customers,
    List<SupplierEntity> suppliers,
  ) {
    final List<AccountItem> items = [];

    if (_selectedFilter == AccountTypeFilter.all ||
        _selectedFilter == AccountTypeFilter.customers) {
      for (var c in customers) {
        items.add(
          AccountItem(
            id: c.id,
            name: c.name,
            phone: c.phone,
            email: c.email,
            address: c.address,
            isCustomer: true,
            createdAt: c.createdAt,
            balance: c.outstandingBalance,
            customer: c,
          ),
        );
      }
    }

    if (_selectedFilter == AccountTypeFilter.all ||
        _selectedFilter == AccountTypeFilter.suppliers) {
      for (var s in suppliers) {
        items.add(
          AccountItem(
            id: s.id,
            name: s.name,
            companyName: s.companyName,
            phone: s.phone,
            email: s.email,
            address: s.address,
            isCustomer: false,
            createdAt: s.createdAt,
            balance: s.payableBalance,
            supplier: s,
          ),
        );
      }
    }

    // Filter by Search Query
    final query = _searchController.text.trim().toLowerCase();
    List<AccountItem> filtered = items;
    if (query.isNotEmpty) {
      filtered = items.where((item) {
        final matchName = item.name.toLowerCase().contains(query);
        final matchCompany = item.companyName?.toLowerCase().contains(query) ?? false;
        final matchPhone = item.phone.toLowerCase().contains(query);
        final matchEmail = item.email.toLowerCase().contains(query);
        final matchAddress = item.address.toLowerCase().contains(query);
        final matchId = item.id.toLowerCase().contains(query);
        return matchName || matchCompany || matchPhone || matchEmail || matchAddress || matchId;
      }).toList();
    }

    // Sort
    if (_sortBy == 'Created Date — Oldest') {
      filtered.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    } else if (_sortBy == 'Name — A to Z') {
      filtered.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    } else if (_sortBy == 'Name — Z to A') {
      filtered.sort((a, b) => b.name.toLowerCase().compareTo(a.name.toLowerCase()));
    } else if (_sortBy == 'Highest Outstanding') {
      filtered.sort((a, b) => b.balance.compareTo(a.balance));
    } else if (_sortBy == 'Lowest Outstanding') {
      filtered.sort((a, b) => a.balance.compareTo(b.balance));
    } else {
      // Default: Created Date — Newest
      filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Text(
              'Accounts',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 18,
                letterSpacing: -0.2,
              ),
            ),
            SizedBox(height: 1),
            Text(
              'Manage your customers and suppliers',
              style: TextStyle(
                fontSize: 11.5,
                color: Colors.white70,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.deepNavy,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: BlocBuilder<AccountsBloc, AccountsState>(
        builder: (context, accState) {
          return BlocBuilder<PurchaseBloc, PurchaseState>(
            builder: (context, purState) {
              if (accState is AccountsLoadingState ||
                  purState is PurchaseLoadingState ||
                  accState is AccountsInitialState) {
                return const AccountsPageSkeleton();
              }

              if (accState is AccountsErrorState) {
                return ErrorState(
                  message: accState.message,
                  onRetry: () {
                    context.read<AccountsBloc>().add(const FetchAccountsEvent());
                    context.read<PurchaseBloc>().add(const FetchPurchasesEvent());
                  },
                );
              }

              final customers = (accState is AccountsLoadedState)
                  ? accState.allCustomers
                  : <CustomerEntity>[];
              final suppliers = (purState is PurchaseLoadedState)
                  ? purState.suppliers
                  : <SupplierEntity>[];

              final processedAccounts =
                  _getFilteredAndSortedAccounts(customers, suppliers);

              return Column(
                children: [
                  // Search Bar + Filter Button Row
                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            onChanged: (_) => setState(() {}),
                            decoration: InputDecoration(
                              hintText: 'Search accounts by name or phone...',
                              hintStyle: const TextStyle(
                                fontSize: 13,
                                color: AppColors.secondaryText,
                              ),
                              prefixIcon: const Icon(
                                Icons.search,
                                color: AppColors.secondaryText,
                                size: 20,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: AppColors.border),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 10,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          style: IconButton.styleFrom(
                            backgroundColor: _selectedFilter != AccountTypeFilter.all ||
                                    _sortBy != 'Created Date — Newest'
                                ? AppColors.primaryBlue.withValues(alpha: 0.15)
                                : AppColors.surfaceContainerLow,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: Icon(
                            Icons.filter_list,
                            color: _selectedFilter != AccountTypeFilter.all ||
                                    _sortBy != 'Created Date — Newest'
                                ? AppColors.primaryBlue
                                : AppColors.darkBlueText,
                          ),
                          onPressed: () => _showFilterBottomSheet(context),
                          tooltip: 'Filter & Sort Accounts',
                        ),
                      ],
                    ),
                  ),

                  // Horizontally Scrollable Filter Chips Bar
                  _buildFilterChipsBar(customers.length, suppliers.length),

                  // Sort Sub-header
                  Container(
                    color: AppColors.background,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    child: Row(
                      children: [
                        const Icon(Icons.sort_rounded, size: 14, color: AppColors.secondaryText),
                        const SizedBox(width: 4),
                        Text(
                          'Sort by: $_sortBy',
                          style: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.secondaryText,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Main Account List View
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: _handleRefresh,
                      color: AppColors.primaryBlue,
                      child: _buildAccountListView(processedAccounts),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  // HORIZONTALLY SCROLLABLE FILTER CHIPS BAR
  Widget _buildFilterChipsBar(int customerCount, int supplierCount) {
    final totalCount = customerCount + supplierCount;

    final filterOptions = [
      {'type': AccountTypeFilter.all, 'label': 'All ($totalCount)'},
      {'type': AccountTypeFilter.customers, 'label': 'Customers ($customerCount)'},
      {'type': AccountTypeFilter.suppliers, 'label': 'Suppliers ($supplierCount)'},
    ];

    return Container(
      color: Colors.white,
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        itemCount: filterOptions.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (ctx, idx) {
          final option = filterOptions[idx];
          final fType = option['type'] as AccountTypeFilter;
          final isSelected = _selectedFilter == fType;

          return ChoiceChip(
            label: Text(option['label'] as String),
            selected: isSelected,
            selectedColor: AppColors.primaryBlue,
            backgroundColor: AppColors.surfaceContainerLow,
            labelStyle: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: isSelected ? Colors.white : AppColors.darkBlueText,
            ),
            onSelected: (val) {
              if (val) {
                setState(() => _selectedFilter = fType);
              }
            },
          );
        },
      ),
    );
  }

  // MAIN ACCOUNT LIST VIEW
  Widget _buildAccountListView(List<AccountItem> accounts) {
    if (accounts.isEmpty) {
      String title = 'No accounts yet';
      String msg = 'Create a customer or supplier to start managing your business accounts.';

      if (_selectedFilter == AccountTypeFilter.customers) {
        title = 'No customers yet';
        msg = 'Tap + in the bottom navigation bar to add a customer.';
      } else if (_selectedFilter == AccountTypeFilter.suppliers) {
        title = 'No suppliers yet';
        msg = 'Tap + in the bottom navigation bar to add a supplier.';
      }

      return SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Container(
          height: MediaQuery.of(context).size.height * 0.55,
          alignment: Alignment.center,
          child: EmptyState(
            title: title,
            message: msg,
            icon: Icons.person_search_outlined,
          ),
        ),
      );
    }

    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
      itemCount: accounts.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (ctx, idx) {
        final account = accounts[idx];
        return _buildAccountCard(context, account);
      },
    );
  }

  // ACCOUNT CARD ITEM
  Widget _buildAccountCard(BuildContext context, AccountItem account) {
    final isCustomer = account.isCustomer;
    final typeLabel = isCustomer ? 'Customer' : 'Supplier';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          if (isCustomer && account.customer != null) {
            context.push(RouteNames.customerDetails, extra: account.customer);
          } else if (!isCustomer && account.supplier != null) {
            context.push(RouteNames.supplierDetails, extra: account.supplier);
          }
        },
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Avatar Icon Container
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isCustomer
                      ? AppColors.primaryBlue.withValues(alpha: 0.08)
                      : Colors.purple.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Text(
                  account.initials,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    fontFamily: 'PlusJakartaSans',
                    color: isCustomer ? AppColors.primaryBlue : Colors.purple,
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Middle Column Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Row 1: TYPE BADGE • Account Name
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: isCustomer
                                ? AppColors.primaryBlue.withValues(alpha: 0.1)
                                : Colors.purple.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            typeLabel.toUpperCase(),
                            style: TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w900,
                              fontFamily: 'PlusJakartaSans',
                              color: isCustomer ? AppColors.primaryBlue : Colors.purple,
                              letterSpacing: 0.4,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            account.name,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              fontFamily: 'PlusJakartaSans',
                              color: AppColors.darkBlueText,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),

                    // Row 2: Phone & Email/Address
                    Row(
                      children: [
                        Icon(Icons.phone_outlined, size: 12, color: AppColors.secondaryText),
                        const SizedBox(width: 4),
                        Text(
                          account.phone.isNotEmpty ? account.phone : 'No phone number',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.secondaryText,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (account.email.isNotEmpty) ...[
                          const SizedBox(width: 6),
                          const Text('•', style: TextStyle(fontSize: 10, color: AppColors.secondaryText)),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              account.email,
                              style: const TextStyle(
                                fontSize: 11.5,
                                color: AppColors.secondaryText,
                                fontWeight: FontWeight.w400,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),

                    // Row 3: Created Date
                    Text(
                      'Created: ${DateFormat('dd MMM yyyy').format(account.createdAt)}',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.secondaryText.withValues(alpha: 0.8),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),

              // Three-Dot More Menu
              PopupMenuButton<String>(
                icon: const Icon(
                  Icons.more_vert_rounded,
                  size: 20,
                  color: AppColors.secondaryText,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                onSelected: (action) {
                  if (action == 'view') {
                    if (isCustomer && account.customer != null) {
                      context.push(RouteNames.customerDetails, extra: account.customer);
                    } else if (!isCustomer && account.supplier != null) {
                      context.push(RouteNames.supplierDetails, extra: account.supplier);
                    }
                  } else if (action == 'edit') {
                    if (isCustomer && account.customer != null) {
                      context.push(RouteNames.createMaster, extra: account.customer);
                    } else if (!isCustomer && account.supplier != null) {
                      context.push(RouteNames.createMaster, extra: account.supplier);
                    }
                  } else if (action == 'delete') {
                    _confirmDeleteAccount(context, account);
                  }
                },
                itemBuilder: (ctx) => [
                  const PopupMenuItem(
                    value: 'view',
                    child: Row(
                      children: [
                        Icon(Icons.visibility_outlined, size: 18, color: AppColors.darkBlueText),
                        SizedBox(width: 10),
                        Text('View', style: TextStyle(fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit_outlined, size: 18, color: AppColors.primaryBlue),
                        SizedBox(width: 10),
                        Text('Edit', style: TextStyle(fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.danger),
                        SizedBox(width: 10),
                        Text('Delete', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.danger)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
