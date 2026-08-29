import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../const/colors.dart';
import '../../widgets/app_card.dart';
import '../../widgets/ui_state_widgets.dart';

// ============================================================================
// STAFF & USER MANAGEMENT MODULE (PRODUCTION READY)
// ============================================================================

enum StaffRole {
  owner,
  administrator,
  manager,
  accountant,
  salesStaff,
  cashier,
  inventoryStaff,
}

extension StaffRoleExt on StaffRole {
  String get label {
    switch (this) {
      case StaffRole.owner:
        return 'Owner';
      case StaffRole.administrator:
        return 'Administrator';
      case StaffRole.manager:
        return 'Manager';
      case StaffRole.accountant:
        return 'Accountant';
      case StaffRole.salesStaff:
        return 'Sales Staff';
      case StaffRole.cashier:
        return 'Cashier';
      case StaffRole.inventoryStaff:
        return 'Inventory Staff';
    }
  }
}

class StaffMember {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String username;
  final StaffRole role;
  bool isActive;
  final bool isPrimaryOwner;
  final DateTime createdAt;
  final DateTime? lastActive;
  final Map<String, bool> permissions;

  StaffMember({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.username,
    required this.role,
    this.isActive = true,
    this.isPrimaryOwner = false,
    required this.createdAt,
    this.lastActive,
    required this.permissions,
  });
}

class StaffUsersPage extends StatefulWidget {
  const StaffUsersPage({super.key});

  @override
  State<StaffUsersPage> createState() => _StaffUsersPageState();
}

class _StaffUsersPageState extends State<StaffUsersPage> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _activeStatusFilter = 'All'; // All, Active, Inactive
  String? _selectedRoleFilter;

  // Mock initial staff data for production demonstration
  final List<StaffMember> _staffList = [
    StaffMember(
      id: 'staff-1',
      name: 'Rajesh Sharma',
      email: 'rajesh@xenobiz.com',
      phone: '+91 9876543210',
      username: 'rajesh_owner',
      role: StaffRole.owner,
      isActive: true,
      isPrimaryOwner: true,
      createdAt: DateTime(2025, 1, 1),
      lastActive: DateTime.now(),
      permissions: {
        'view_sales': true, 'create_sales': true, 'edit_sales': true, 'delete_sales': true,
        'view_purchases': true, 'create_purchases': true, 'edit_purchases': true,
        'view_inventory': true, 'manage_stock': true, 'view_accounts': true,
        'view_reports': true, 'gst_returns': true, 'manage_staff': true,
      },
    ),
    StaffMember(
      id: 'staff-2',
      name: 'John Mathew',
      email: 'john@xenobiz.com',
      phone: '+91 9812345678',
      username: 'john_admin',
      role: StaffRole.administrator,
      isActive: true,
      createdAt: DateTime(2025, 3, 15),
      lastActive: DateTime.now().subtract(const Duration(hours: 2)),
      permissions: {
        'view_sales': true, 'create_sales': true, 'edit_sales': true, 'delete_sales': true,
        'view_purchases': true, 'create_purchases': true, 'edit_purchases': true,
        'view_inventory': true, 'manage_stock': true, 'view_accounts': true,
        'view_reports': true, 'gst_returns': true, 'manage_staff': false,
      },
    ),
    StaffMember(
      id: 'staff-3',
      name: 'Arun Kumar',
      email: 'arun@xenobiz.com',
      phone: '+91 9765432109',
      username: 'arun_cashier',
      role: StaffRole.cashier,
      isActive: true,
      createdAt: DateTime(2025, 5, 10),
      lastActive: DateTime.now().subtract(const Duration(minutes: 45)),
      permissions: {
        'view_sales': true, 'create_sales': true, 'edit_sales': false, 'delete_sales': false,
        'view_purchases': false, 'create_purchases': false, 'edit_purchases': false,
        'view_inventory': true, 'manage_stock': false, 'view_accounts': false,
        'view_reports': false, 'gst_returns': false, 'manage_staff': false,
      },
    ),
    StaffMember(
      id: 'staff-4',
      name: 'Priya Verma',
      email: 'priya@xenobiz.com',
      phone: '+91 9654321098',
      username: 'priya_acc',
      role: StaffRole.accountant,
      isActive: true,
      createdAt: DateTime(2025, 6, 1),
      lastActive: DateTime.now().subtract(const Duration(days: 1)),
      permissions: {
        'view_sales': true, 'create_sales': true, 'edit_sales': true, 'delete_sales': false,
        'view_purchases': true, 'create_purchases': true, 'edit_purchases': true,
        'view_inventory': true, 'manage_stock': false, 'view_accounts': true,
        'view_reports': true, 'gst_returns': true, 'manage_staff': false,
      },
    ),
    StaffMember(
      id: 'staff-5',
      name: 'Rahul Singh',
      email: 'rahul@xenobiz.com',
      phone: '+91 9543210987',
      username: 'rahul_sales',
      role: StaffRole.salesStaff,
      isActive: false,
      createdAt: DateTime(2025, 7, 20),
      lastActive: DateTime.now().subtract(const Duration(days: 12)),
      permissions: {
        'view_sales': true, 'create_sales': true, 'edit_sales': false, 'delete_sales': false,
        'view_purchases': false, 'create_purchases': false, 'edit_purchases': false,
        'view_inventory': true, 'manage_stock': false, 'view_accounts': false,
        'view_reports': false, 'gst_returns': false, 'manage_staff': false,
      },
    ),
  ];

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<StaffMember> get _filteredStaff {
    final query = _searchCtrl.text.trim().toLowerCase();
    return _staffList.where((staff) {
      final matchesQuery = query.isEmpty ||
          staff.name.toLowerCase().contains(query) ||
          staff.email.toLowerCase().contains(query) ||
          staff.phone.contains(query) ||
          staff.username.toLowerCase().contains(query);

      final matchesStatus = _activeStatusFilter == 'All' ||
          (_activeStatusFilter == 'Active' && staff.isActive) ||
          (_activeStatusFilter == 'Inactive' && !staff.isActive);

      final matchesRole = _selectedRoleFilter == null ||
          staff.role.label == _selectedRoleFilter;

      return matchesQuery && matchesStatus && matchesRole;
    }).toList();
  }

  void _showCreateStaffDialog() {
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final usernameCtrl = TextEditingController();
    StaffRole selectedRole = StaffRole.salesStaff;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            backgroundColor: Colors.white,
            title: const Text('Add New Staff Member',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.darkBlueText)),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Full Name *',
                      hintText: 'e.g. Amit Kumar',
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: phoneCtrl,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Phone Number *',
                      hintText: '+91 9876543210',
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email Address',
                      hintText: 'amit@example.com',
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: usernameCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Username *',
                      hintText: 'amit_sales',
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text('Role Assignment',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.darkBlueText)),
                  const SizedBox(height: 4),
                  DropdownButtonHideUnderline(
                    child: DropdownButton<StaffRole>(
                      value: selectedRole,
                      isExpanded: true,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.darkBlueText),
                      items: StaffRole.values
                          .where((r) => r != StaffRole.owner)
                          .map((r) => DropdownMenuItem(value: r, child: Text(r.label)))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) setModalState(() => selectedRole = val);
                      },
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel', style: TextStyle(color: AppColors.secondaryText)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  if (nameCtrl.text.trim().isEmpty) return;

                  final newStaff = StaffMember(
                    id: 'staff-${DateTime.now().millisecondsSinceEpoch}',
                    name: nameCtrl.text.trim(),
                    email: emailCtrl.text.trim(),
                    phone: phoneCtrl.text.trim(),
                    username: usernameCtrl.text.trim(),
                    role: selectedRole,
                    isActive: true,
                    createdAt: DateTime.now(),
                    lastActive: DateTime.now(),
                    permissions: {
                      'view_sales': true, 'create_sales': true, 'edit_sales': false, 'delete_sales': false,
                      'view_purchases': false, 'create_purchases': false, 'edit_purchases': false,
                      'view_inventory': true, 'manage_stock': false, 'view_accounts': false,
                      'view_reports': false, 'gst_returns': false, 'manage_staff': false,
                    },
                  );

                  setState(() {
                    _staffList.add(newStaff);
                  });

                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Added staff member ${newStaff.name}!'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                },
                child: const Text('Add Staff Member', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showPermissionsDialog(StaffMember staff) {
    final perms = Map<String, bool>.from(staff.permissions);

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            backgroundColor: Colors.white,
            title: Row(
              children: [
                const Icon(Icons.security_rounded, color: AppColors.primaryBlue),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Permissions: ${staff.name}',
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.darkBlueText),
                  ),
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Role: ${staff.role.label}',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primaryBlue)),
                  const SizedBox(height: 10),
                  const Divider(height: 1),
                  const SizedBox(height: 10),

                  _buildPermissionCategory('SALES MODULE', [
                    _permSwitch('View Sales', 'view_sales', perms, setModalState),
                    _permSwitch('Create Invoices', 'create_sales', perms, setModalState),
                    _permSwitch('Edit Invoices', 'edit_sales', perms, setModalState),
                    _permSwitch('Delete Invoices', 'delete_sales', perms, setModalState),
                  ]),

                  _buildPermissionCategory('PURCHASES & SUPPLIERS', [
                    _permSwitch('View Purchases', 'view_purchases', perms, setModalState),
                    _permSwitch('Create Purchases', 'create_purchases', perms, setModalState),
                    _permSwitch('Edit Purchases', 'edit_purchases', perms, setModalState),
                  ]),

                  _buildPermissionCategory('INVENTORY & PRODUCTS', [
                    _permSwitch('View Catalog', 'view_inventory', perms, setModalState),
                    _permSwitch('Adjust Stock', 'manage_stock', perms, setModalState),
                  ]),

                  _buildPermissionCategory('ACCOUNTS & REPORTS', [
                    _permSwitch('View Financial Ledger', 'view_accounts', perms, setModalState),
                    _permSwitch('View Reports', 'view_reports', perms, setModalState),
                    _permSwitch('GST Compliance', 'gst_returns', perms, setModalState),
                  ]),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel', style: TextStyle(color: AppColors.secondaryText)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  setState(() {
                    staff.permissions.clear();
                    staff.permissions.addAll(perms);
                  });
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Updated permissions for ${staff.name}!'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                },
                child: const Text('Save Permissions', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPermissionCategory(String title, List<Widget> switches) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.secondaryText, letterSpacing: 0.5)),
        const SizedBox(height: 4),
        ...switches,
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _permSwitch(String label, String key, Map<String, bool> perms, StateSetter setModalState) {
    final val = perms[key] ?? false;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 12.5, color: AppColors.darkBlueText)),
        Switch(
          value: val,
          activeTrackColor: AppColors.primaryBlue,
          onChanged: (newVal) {
            setModalState(() {
              perms[key] = newVal;
            });
          },
        ),
      ],
    );
  }

  void _showStaffDetailsSheet(StaffMember staff) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: AppColors.primaryBlue,
                  child: Text(
                    _getInitials(staff.name),
                    style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.white, fontSize: 16),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(staff.name,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.darkBlueText)),
                      Text(staff.email, style: const TextStyle(fontSize: 12, color: AppColors.secondaryText)),
                    ],
                  ),
                ),
                _buildStatusChip(staff.isActive),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 14),

            _detailRow('Phone Number', staff.phone),
            _detailRow('Username', staff.username),
            _detailRow('Assigned Role', staff.role.label),
            _detailRow('Account Created', DateFormat('dd MMM yyyy').format(staff.createdAt)),
            if (staff.lastActive != null)
              _detailRow('Last Active', DateFormat('dd MMM yyyy, hh:mm a').format(staff.lastActive!)),

            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.primaryBlue)),
                    icon: const Icon(Icons.security, size: 16, color: AppColors.primaryBlue),
                    label: const Text('Permissions', style: TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.w700)),
                    onPressed: () {
                      Navigator.pop(ctx);
                      _showPermissionsDialog(staff);
                    },
                  ),
                ),
                const SizedBox(width: 10),
                if (!staff.isPrimaryOwner)
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: staff.isActive ? Colors.orange : AppColors.success,
                        foregroundColor: Colors.white,
                      ),
                      icon: Icon(staff.isActive ? Icons.block : Icons.check_circle, color: Colors.white, size: 16),
                      label: Text(
                        staff.isActive ? 'Deactivate' : 'Activate',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
                      ),
                      onPressed: () {
                        setState(() {
                          staff.isActive = !staff.isActive;
                        });
                        Navigator.pop(ctx);
                      },
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: AppColors.secondaryText)),
          Text(value, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.darkBlueText)),
        ],
      ),
    );
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : 'U';
  }

  @override
  Widget build(BuildContext context) {
    final totalCount = _staffList.length;
    final activeCount = _staffList.where((s) => s.isActive).length;
    final inactiveCount = _staffList.where((s) => !s.isActive).length;
    final filtered = _filteredStaff;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Staff & Users',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: Colors.white),
        ),
        backgroundColor: AppColors.deepNavy,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            tooltip: 'Add New Staff',
            icon: const Icon(Icons.person_add_outlined),
            onPressed: _showCreateStaffDialog,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
        onPressed: _showCreateStaffDialog,
        child: const Icon(Icons.add, size: 28),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderSummaryBar(totalCount, activeCount, inactiveCount),
            const SizedBox(height: 16),
            _buildSearchAndFilters(),
            const SizedBox(height: 16),
            const Text(
              'Team Members & Access Levels',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.darkBlueText),
            ),
            const SizedBox(height: 10),
            if (filtered.isEmpty)
              const EmptyState(
                title: 'No Staff Members Found',
                message: 'No users match your search or selected filter.',
                icon: Icons.people_outline,
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filtered.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (ctx, idx) => _buildStaffCard(filtered[idx]),
              ),
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderSummaryBar(int total, int active, int inactive) {
    return Row(
      children: [
        Expanded(child: _buildSummaryCard('Total Users', '$total', AppColors.primaryBlue)),
        const SizedBox(width: 8),
        Expanded(child: _buildSummaryCard('Active', '$active', AppColors.success)),
        const SizedBox(width: 8),
        Expanded(child: _buildSummaryCard('Inactive', '$inactive', AppColors.secondaryText)),
      ],
    );
  }

  Widget _buildSummaryCard(String title, String value, Color color) {
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      child: Column(
        children: [
          Text(title, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.secondaryText)),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: color)),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    final statusFilters = ['All', 'Active', 'Inactive'];

    return AppCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Container(
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.pageBackground,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border),
            ),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                hintText: 'Search staff by name, phone, email...',
                hintStyle: TextStyle(fontSize: 12, color: AppColors.secondaryText),
                prefixIcon: Icon(Icons.search, size: 18, color: AppColors.secondaryText),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: statusFilters.map((s) {
                final isSelected = _activeStatusFilter == s;
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: ChoiceChip(
                    label: Text(s, style: const TextStyle(fontSize: 11)),
                    selected: isSelected,
                    selectedColor: AppColors.primaryBlue,
                    backgroundColor: AppColors.pageBackground,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : AppColors.darkBlueText,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    ),
                    onSelected: (val) {
                      if (val) setState(() => _activeStatusFilter = s);
                    },
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStaffCard(StaffMember staff) {
    return AppCard(
      padding: const EdgeInsets.all(12),
      onTap: () => _showStaffDetailsSheet(staff),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: staff.isPrimaryOwner
                    ? AppColors.deepNavy
                    : AppColors.primaryBlue.withValues(alpha: 0.15),
                child: Text(
                  _getInitials(staff.name),
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                    color: staff.isPrimaryOwner ? Colors.white : AppColors.primaryBlue,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          staff.name,
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.darkBlueText),
                        ),
                        if (staff.isPrimaryOwner) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.deepNavy,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text('OWNER',
                                style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: Colors.white)),
                          ),
                        ],
                      ],
                    ),
                    Text(
                      '${staff.email} • ${staff.phone}',
                      style: const TextStyle(fontSize: 11, color: AppColors.secondaryText),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, size: 20, color: AppColors.secondaryText),
                onSelected: (val) {
                  switch (val) {
                    case 'view':
                      _showStaffDetailsSheet(staff);
                      break;
                    case 'permissions':
                      _showPermissionsDialog(staff);
                      break;
                    case 'toggle_active':
                      if (!staff.isPrimaryOwner) {
                        setState(() {
                          staff.isActive = !staff.isActive;
                        });
                      }
                      break;
                    case 'delete':
                      if (!staff.isPrimaryOwner) {
                        setState(() {
                          _staffList.removeWhere((s) => s.id == staff.id);
                        });
                      }
                      break;
                  }
                },
                itemBuilder: (ctx) => [
                  const PopupMenuItem(value: 'view', child: Text('View Details')),
                  const PopupMenuItem(value: 'permissions', child: Text('Manage Permissions')),
                  if (!staff.isPrimaryOwner)
                    PopupMenuItem(
                      value: 'toggle_active',
                      child: Text(staff.isActive ? 'Deactivate User' : 'Activate User'),
                    ),
                  if (!staff.isPrimaryOwner)
                    const PopupMenuItem(
                      value: 'delete',
                      child: Text('Delete User', style: TextStyle(color: AppColors.danger)),
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  staff.role.label,
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.primaryBlue),
                ),
              ),
              _buildStatusChip(staff.isActive),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(bool isActive) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.circle, size: 8, color: isActive ? AppColors.success : AppColors.secondaryText),
        const SizedBox(width: 4),
        Text(
          isActive ? 'Active' : 'Inactive',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: isActive ? AppColors.success : AppColors.secondaryText,
          ),
        ),
      ],
    );
  }
}
