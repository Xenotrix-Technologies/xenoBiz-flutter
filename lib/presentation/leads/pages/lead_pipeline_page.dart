import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../application/bloc/lead_bloc.dart';
import '../../../application/routing/route_names.dart';
import '../../../const/colors.dart';
import '../../../domain/entities/lead_entity.dart';
import '../../../application/di/injection.dart';
import '../../../domain/repositories/lead_repository.dart';
import '../../widgets/app_card.dart';
import '../../widgets/ui_state_widgets.dart';
import '../widgets/add_lead_action_sheet.dart';
import '../widgets/export_leads_modal.dart';


class LeadPipelinePage extends StatefulWidget {
  const LeadPipelinePage({super.key});

  @override
  State<LeadPipelinePage> createState() => _LeadPipelinePageState();
}

class _LeadPipelinePageState extends State<LeadPipelinePage> {
  final TextEditingController _searchController = TextEditingController();
  bool _showSearchBar = false;
  bool _isSelectionMode = false;
  final Set<String> _selectedLeadIds = {};

  LeadFilter _currentFilter = const LeadFilter();
  LeadSortOption _currentSort = LeadSortOption.dateNewest; // Default requirement #5

  final List<LeadStage> _allStages = LeadStage.values;

  void _toggleLeadSelection(String leadId) {
    setState(() {
      if (_selectedLeadIds.contains(leadId)) {
        _selectedLeadIds.remove(leadId);
        if (_selectedLeadIds.isEmpty) {
          _isSelectionMode = false;
        }
      } else {
        _selectedLeadIds.add(leadId);
      }
    });
  }

  void _selectAllLeads(List<LeadEntity> leads) {
    setState(() {
      if (_selectedLeadIds.length == leads.length) {
        _selectedLeadIds.clear();
        _isSelectionMode = false;
      } else {
        _selectedLeadIds.clear();
        _selectedLeadIds.addAll(leads.map((l) => l.id));
      }
    });
  }

  void _confirmDeleteSelectedLeads() {
    final count = _selectedLeadIds.length;
    if (count == 0) return;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Leads', style: TextStyle(fontWeight: FontWeight.w800)),
        content: Text(
          'Are you sure you want to delete $count lead(s)? This action cannot be undone.',
          style: const TextStyle(fontSize: 13, color: AppColors.secondaryText),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF4444)),
            onPressed: () {
              final idsToDelete = _selectedLeadIds.toList();
              context.read<LeadBloc>().add(DeleteLeadsEvent(idsToDelete));
              setState(() {
                _selectedLeadIds.clear();
                _isSelectionMode = false;
              });
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('$count lead(s) deleted successfully'),
                  backgroundColor: AppColors.danger,
                ),
              );
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _loadLeads();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadLeads() {
    context.read<LeadBloc>().add(FetchLeadsEvent(
          filter: _currentFilter,
          sort: _currentSort,
          query: _searchController.text.trim(),
        ));
  }

  Color _getStageColor(LeadStage stage) {
    switch (stage) {
      case LeadStage.newLead:
        return const Color(0xFF2563EB);
      case LeadStage.contacted:
        return const Color(0xFF0284C7);
      case LeadStage.qualified:
        return const Color(0xFF0D9488);
      case LeadStage.proposalSent:
        return const Color(0xFF8B5CF6);
      case LeadStage.negotiating:
        return const Color(0xFFD97706);
      case LeadStage.won:
        return const Color(0xFF10B981);
      case LeadStage.lost:
        return const Color(0xFFEF4444);
    }
  }

  String _getStageName(LeadStage stage) {
    switch (stage) {
      case LeadStage.newLead:
        return 'New';
      case LeadStage.contacted:
        return 'Contacted';
      case LeadStage.qualified:
        return 'Qualified';
      case LeadStage.proposalSent:
        return 'Proposal';
      case LeadStage.negotiating:
        return 'Negotiation';
      case LeadStage.won:
        return 'Won';
      case LeadStage.lost:
        return 'Lost';
    }
  }

  Color _getPriorityColor(LeadPriority priority) {
    switch (priority) {
      case LeadPriority.high:
        return const Color(0xFFEF4444);
      case LeadPriority.medium:
        return const Color(0xFFF59E0B);
      case LeadPriority.low:
        return const Color(0xFF10B981);
    }
  }

  // ==================== ADVANCED FILTER BOTTOM SHEET (#4) ====================
  void _showAdvancedFilterSheet() {
    Set<LeadStage> tempStages = Set.from(_currentFilter.stages);
    Set<LeadPriority> tempPriorities = Set.from(_currentFilter.priorities);
    Set<String> tempSources = Set.from(_currentFilter.sources);
    String? tempStaff = _currentFilter.assignedStaff;
    String? tempValueRange = _currentFilter.valueRange;
    String? tempDateRange = _currentFilter.dateRange;
    String? tempFollowUpStatus = _currentFilter.followUpStatus;

    final allSources = ['Walk-in', 'Referral', 'Website', 'WhatsApp', 'Phone', 'Social Media', 'Other'];
    final allStaff = ['All', 'Self', 'Sales Manager', 'Rahul S', 'Anita N', 'Admin'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return DraggableScrollableSheet(
              initialChildSize: 0.85,
              maxChildSize: 0.95,
              minChildSize: 0.5,
              expand: false,
              builder: (_, scrollController) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  child: Column(
                    children: [
                      Center(
                        child: Container(width: 36, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Filter Leads & Pipeline', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.darkBlueText)),
                          IconButton(icon: const Icon(Icons.close_rounded), onPressed: () => Navigator.pop(ctx)),
                        ],
                      ),
                      const Divider(height: 12),
                      Expanded(
                        child: ListView(
                          controller: scrollController,
                          children: [
                            // 1. Stage Multi-select
                            _buildFilterGroupTitle('LEAD STAGE (MULTI-SELECT)'),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: LeadStage.values.map((st) {
                                final isSelected = tempStages.contains(st);
                                final color = _getStageColor(st);
                                return FilterChip(
                                  label: Text(_getStageName(st)),
                                  selected: isSelected,
                                  selectedColor: color.withValues(alpha: 0.2),
                                  checkmarkColor: color,
                                  labelStyle: TextStyle(color: isSelected ? color : AppColors.darkBlueText, fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500, fontSize: 12),
                                  onSelected: (val) {
                                    setModalState(() {
                                      if (val) {
                                        tempStages.add(st);
                                      } else {
                                        tempStages.remove(st);
                                      }
                                    });
                                  },
                                );
                              }).toList(),
                            ),

                            const SizedBox(height: 16),

                            // 2. Priority Multi-select
                            _buildFilterGroupTitle('PRIORITY'),
                            Wrap(
                              spacing: 8,
                              children: LeadPriority.values.map((pr) {
                                final isSelected = tempPriorities.contains(pr);
                                final pName = pr.name[0].toUpperCase() + pr.name.substring(1);
                                final pColor = _getPriorityColor(pr);
                                return FilterChip(
                                  label: Text(pName),
                                  selected: isSelected,
                                  selectedColor: pColor.withValues(alpha: 0.2),
                                  checkmarkColor: pColor,
                                  labelStyle: TextStyle(color: isSelected ? pColor : AppColors.darkBlueText, fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500, fontSize: 12),
                                  onSelected: (val) {
                                    setModalState(() {
                                      if (val) {
                                        tempPriorities.add(pr);
                                      } else {
                                        tempPriorities.remove(pr);
                                      }
                                    });
                                  },
                                );
                              }).toList(),
                            ),

                            const SizedBox(height: 16),

                            // 3. Lead Source Multi-select
                            _buildFilterGroupTitle('LEAD SOURCE'),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: allSources.map((src) {
                                final isSelected = tempSources.contains(src);
                                return FilterChip(
                                  label: Text(src),
                                  selected: isSelected,
                                  onSelected: (val) {
                                    setModalState(() {
                                      if (val) {
                                        tempSources.add(src);
                                      } else {
                                        tempSources.remove(src);
                                      }
                                    });
                                  },
                                );
                              }).toList(),
                            ),

                            const SizedBox(height: 16),

                            // 4. Assigned Staff
                            _buildFilterGroupTitle('ASSIGNED STAFF'),
                            Wrap(
                              spacing: 8,
                              children: allStaff.map((st) {
                                final isSelected = tempStaff == st || (tempStaff == null && st == 'All');
                                return ChoiceChip(
                                  label: Text(st),
                                  selected: isSelected,
                                  onSelected: (val) {
                                    if (val) setModalState(() => tempStaff = st == 'All' ? null : st);
                                  },
                                );
                              }).toList(),
                            ),

                            const SizedBox(height: 16),

                            // 6. Created Date Range
                            _buildFilterGroupTitle('CREATED DATE'),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                ChoiceChip(label: const Text('All'), selected: tempDateRange == 'all', onSelected: (_) => setModalState(() => tempDateRange = 'all')),
                                ChoiceChip(label: const Text('Today'), selected: tempDateRange == 'today', onSelected: (_) => setModalState(() => tempDateRange = 'today')),
                                ChoiceChip(label: const Text('Yesterday'), selected: tempDateRange == 'yesterday', onSelected: (_) => setModalState(() => tempDateRange = 'yesterday')),
                                ChoiceChip(label: const Text('Last 7 Days'), selected: tempDateRange == 'last7Days', onSelected: (_) => setModalState(() => tempDateRange = 'last7Days')),
                                ChoiceChip(label: const Text('Last 30 Days'), selected: tempDateRange == 'last30Days', onSelected: (_) => setModalState(() => tempDateRange = 'last30Days')),
                                ChoiceChip(label: const Text('This Month'), selected: tempDateRange == 'thisMonth', onSelected: (_) => setModalState(() => tempDateRange = 'thisMonth')),
                              ],
                            ),

                            const SizedBox(height: 16),

                            // 7. Follow-up Filter
                            _buildFilterGroupTitle('FOLLOW-UP STATUS'),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                ChoiceChip(label: const Text('All'), selected: tempFollowUpStatus == 'all', onSelected: (_) => setModalState(() => tempFollowUpStatus = 'all')),
                                ChoiceChip(label: const Text('No Follow-up'), selected: tempFollowUpStatus == 'none', onSelected: (_) => setModalState(() => tempFollowUpStatus = 'none')),
                                ChoiceChip(label: const Text('Upcoming'), selected: tempFollowUpStatus == 'upcoming', onSelected: (_) => setModalState(() => tempFollowUpStatus = 'upcoming')),
                                ChoiceChip(label: const Text('Due Today'), selected: tempFollowUpStatus == 'dueToday', onSelected: (_) => setModalState(() => tempFollowUpStatus = 'dueToday')),
                                ChoiceChip(label: const Text('Overdue'), selected: tempFollowUpStatus == 'overdue', onSelected: (_) => setModalState(() => tempFollowUpStatus = 'overdue')),
                              ],
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),

                      // FILTER ACTIONS: RESET & APPLY FILTERS
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                              onPressed: () {
                                setModalState(() {
                                  tempStages.clear();
                                  tempPriorities.clear();
                                  tempSources.clear();
                                  tempStaff = null;
                                  tempValueRange = 'all';
                                  tempDateRange = 'all';
                                  tempFollowUpStatus = 'all';
                                });
                              },
                              child: const Text('Reset All', style: TextStyle(fontWeight: FontWeight.w700)),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryBlue, padding: const EdgeInsets.symmetric(vertical: 14)),
                              onPressed: () {
                                setState(() {
                                  _currentFilter = LeadFilter(
                                    stages: tempStages,
                                    priorities: tempPriorities,
                                    sources: tempSources,
                                    assignedStaff: tempStaff,
                                    valueRange: tempValueRange,
                                    dateRange: tempDateRange,
                                    followUpStatus: tempFollowUpStatus,
                                  );
                                });
                                Navigator.pop(ctx);
                                _loadLeads();
                              },
                              child: const Text('Apply Filters', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  // ==================== SORTING BOTTOM SHEET (#5) ====================
  void _showSortOptionsSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Sort Leads & Pipeline', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.darkBlueText)),
                const SizedBox(height: 14),
                _buildSortOptionTile('Date Created — Newest First (Default)', LeadSortOption.dateNewest, ctx),
                _buildSortOptionTile('Date Created — Oldest First', LeadSortOption.dateOldest, ctx),
                _buildSortOptionTile('Recently Updated', LeadSortOption.recentlyUpdated, ctx),
                _buildSortOptionTile('Name — A to Z', LeadSortOption.nameAZ, ctx),
                _buildSortOptionTile('Name — Z to A', LeadSortOption.nameZA, ctx),
                _buildSortOptionTile('Follow-up Date — Soonest', LeadSortOption.followUpSoonest, ctx),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSortOptionTile(String title, LeadSortOption option, BuildContext modalCtx) {
    final isSelected = _currentSort == option;
    return ListTile(
      dense: true,
      title: Text(
        title,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
          color: isSelected ? AppColors.primaryBlue : AppColors.darkBlueText,
        ),
      ),
      trailing: isSelected ? const Icon(Icons.check_circle_rounded, color: AppColors.primaryBlue) : null,
      onTap: () {
        setState(() => _currentSort = option);
        Navigator.pop(modalCtx);
        _loadLeads();
      },
    );
  }

  Widget _buildFilterGroupTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.secondaryText, letterSpacing: 0.6),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filterCount = _currentFilter.activeFilterCount;
    final leadState = context.watch<LeadBloc>().state;
    final leadsList = leadState is LeadsLoadedState ? leadState.leads : <LeadEntity>[];
    final isAllSelected = leadsList.isNotEmpty && _selectedLeadIds.length == leadsList.length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _isSelectionMode
          ? AppBar(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.darkBlueText,
              elevation: 0,
              scrolledUnderElevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.close_rounded, color: AppColors.darkBlueText),
                onPressed: () {
                  setState(() {
                    _isSelectionMode = false;
                    _selectedLeadIds.clear();
                  });
                },
              ),
              title: Text(
                '${_selectedLeadIds.length} Selected',
                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
              ),
              actions: [
                TextButton.icon(
                  icon: Icon(
                    isAllSelected ? Icons.deselect_rounded : Icons.select_all_rounded,
                    size: 18,
                    color: AppColors.primaryBlue,
                  ),
                  label: Text(
                    isAllSelected ? 'Deselect All' : 'Select All',
                    style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.primaryBlue, fontSize: 13),
                  ),
                  onPressed: () => _selectAllLeads(leadsList),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded, color: Colors.red),
                  tooltip: 'Delete Selected',
                  onPressed: _selectedLeadIds.isEmpty ? null : _confirmDeleteSelectedLeads,
                ),
              ],
            )
          : AppBar(
              title: const Text('Leads & Pipeline', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20)),
              backgroundColor: Colors.white,
              foregroundColor: AppColors.darkBlueText,
              elevation: 0,
              scrolledUnderElevation: 0,
              actions: [
                IconButton(
                  icon: Icon(_showSearchBar ? Icons.close_rounded : Icons.search_rounded, color: AppColors.darkBlueText),
                  onPressed: () {
                    setState(() {
                      _showSearchBar = !_showSearchBar;
                      if (!_showSearchBar) {
                        _searchController.clear();
                        _loadLeads();
                      }
                    });
                  },
                ),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.filter_list_rounded, color: AppColors.darkBlueText),
                      onPressed: _showAdvancedFilterSheet,
                    ),
                    if (filterCount > 0)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(color: AppColors.primaryBlue, shape: BoxShape.circle),
                          child: Text('$filterCount', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800)),
                        ),
                      ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.sort_rounded, color: AppColors.darkBlueText),
                  onPressed: _showSortOptionsSheet,
                ),
                IconButton(
                  icon: const Icon(Icons.file_upload_outlined, color: AppColors.darkBlueText),
                  tooltip: 'Export Leads',
                  onPressed: () async {
                    final filteredLeads = leadsList;
                    final allLeads = await getIt<LeadRepository>().getLeads();

                    List<String> summaryParts = [];
                    if (_currentFilter.stages.isNotEmpty) {
                      summaryParts.add('Stages: ${_currentFilter.stages.map((s) => _getStageName(s)).join(", ")}');
                    }
                    if (_currentFilter.priorities.isNotEmpty) {
                      summaryParts.add('Priorities: ${_currentFilter.priorities.map((p) => p.name).join(", ")}');
                    }
                    if (_searchController.text.trim().isNotEmpty) {
                      summaryParts.add('Query: "${_searchController.text.trim()}"');
                    }
                    final filterSummary = summaryParts.isEmpty ? 'All Leads' : summaryParts.join(' | ');

                    if (context.mounted) {
                      ExportLeadsModal.show(
                        context: context,
                        allLeads: allLeads,
                        filteredLeads: filteredLeads,
                        filterSummary: filterSummary,
                      );
                    }
                  },
                ),
              ],
            ),
      floatingActionButton: _isSelectionMode
          ? null
          : FloatingActionButton.extended(
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Add Lead', style: TextStyle(fontWeight: FontWeight.w800)),
              onPressed: () {
                AddLeadActionSheet.show(context);
              },
            ),

      body: BlocBuilder<LeadBloc, LeadState>(
        builder: (context, state) {
          if (state is LeadLoadingState) {
            return const LoadingState(message: 'Loading leads & pipeline...');
          }

          if (state is LeadErrorState) {
            return ErrorState(message: state.message, onRetry: _loadLeads);
          }

          final leads = state is LeadsLoadedState ? state.leads : <LeadEntity>[];

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search Bar Toggle Overlay
              if (_showSearchBar) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: AppCard(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                    child: TextField(
                      controller: _searchController,
                      autofocus: true,
                      onChanged: (_) => _loadLeads(),
                      decoration: const InputDecoration(
                        hintText: 'Search lead name, company, phone, email...',
                        hintStyle: TextStyle(fontSize: 13, color: AppColors.secondaryText),
                        prefixIcon: Icon(Icons.search_rounded, color: AppColors.primaryBlue),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
              ],

              // Stage Quick Filter Row
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    ChoiceChip(
                      label: Text('All (${leads.length})'),
                      selected: _currentFilter.stages.isEmpty,
                      selectedColor: AppColors.primaryBlue,
                      labelStyle: TextStyle(
                        color: _currentFilter.stages.isEmpty ? Colors.white : AppColors.darkBlueText,
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                      ),
                      onSelected: (_) {
                        setState(() => _currentFilter = _currentFilter.copyWith(stages: {}));
                        _loadLeads();
                      },
                    ),
                    const SizedBox(width: 8),
                    ..._allStages.map((st) {
                      final count = leads.where((l) => l.stage == st).length;
                      final isSelected = _currentFilter.stages.contains(st);
                      final color = _getStageColor(st);
                      return Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: ChoiceChip(
                          label: Text('${_getStageName(st)} ($count)'),
                          selected: isSelected,
                          selectedColor: color,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : color,
                            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                            fontSize: 12,
                          ),
                          backgroundColor: color.withValues(alpha: 0.1),
                          onSelected: (val) {
                            setState(() {
                              final newStages = Set<LeadStage>.from(_currentFilter.stages);
                              if (val) {
                                newStages.add(st);
                              } else {
                                newStages.remove(st);
                              }
                              _currentFilter = _currentFilter.copyWith(stages: newStages);
                            });
                            _loadLeads();
                          },
                        ),
                      );
                    }),
                  ],
                ),
              ),

              // Active filter tags bar if any active
              if (filterCount > 0)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Row(
                    children: [
                      Text('$filterCount active filters applied', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primaryBlue)),
                      const Spacer(),
                      GestureDetector(
                        onTap: () {
                          setState(() => _currentFilter = const LeadFilter());
                          _loadLeads();
                        },
                        child: const Text('Clear All', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFFEF4444))),
                      ),
                    ],
                  ),
                ),

              // LEAD LIST (#6, #15 EMPTY STATE)
              Expanded(
                child: leads.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  color: AppColors.primaryBlue.withValues(alpha: 0.08),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.person_search_rounded, size: 40, color: AppColors.primaryBlue),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'No leads found',
                                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.darkBlueText),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Create your first lead to start building your pipeline.',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 13, color: AppColors.secondaryText),
                              ),
                              const SizedBox(height: 24),
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primaryBlue,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                icon: const Icon(Icons.add_rounded),
                                label: const Text('Add Lead', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                                onPressed: () {
                                  context.push(RouteNames.addLead);
                                },
                              ),
                            ],
                          ),
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: () async => _loadLeads(),
                        child: ListView.separated(
                          padding: const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 80),
                          itemCount: leads.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 10),
                          itemBuilder: (ctx, idx) {
                            final lead = leads[idx];
                            return _buildLeadCard(lead);
                          },
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  // COMPACT LEAD CARD (#6 Hierarchy: Name -> Stage -> Value -> Priority -> Date)
  Widget _buildLeadCard(LeadEntity lead) {
    final stageColor = _getStageColor(lead.stage);
    final priorityColor = _getPriorityColor(lead.priority);
    final isSelected = _selectedLeadIds.contains(lead.id);

    return AppCard(
      padding: const EdgeInsets.all(14),
      backgroundColor: isSelected ? AppColors.primaryBlue.withValues(alpha: 0.06) : null,
      border: isSelected ? Border.all(color: AppColors.primaryBlue, width: 1.5) : null,
      onTap: () {
        if (_isSelectionMode) {
          _toggleLeadSelection(lead.id);
        } else {
          context.push(RouteNames.leadDetails, extra: lead);
        }
      },
      onLongPress: () {
        if (!_isSelectionMode) {
          setState(() {
            _isSelectionMode = true;
            _selectedLeadIds.add(lead.id);
          });
        } else {
          _toggleLeadSelection(lead.id);
        }
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_isSelectionMode) ...[
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: Checkbox(
                      value: isSelected,
                      activeColor: AppColors.primaryBlue,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                      onChanged: (_) => _toggleLeadSelection(lead.id),
                    ),
                  ),
                ),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lead.contactName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.darkBlueText,
                      ),
                    ),
                    if (lead.companyName.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        lead.companyName,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.secondaryText,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: stageColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: stageColor.withValues(alpha: 0.3)),
                ),
                child: Text(
                  _getStageName(lead.stage),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: stageColor,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(color: priorityColor, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    lead.priority.name.toUpperCase(),
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: priorityColor),
                  ),
                ],
              ),
              Text(
                'Created: ${lead.createdAt.day}/${lead.createdAt.month}/${lead.createdAt.year}',
                style: const TextStyle(fontSize: 11, color: AppColors.secondaryText),
              ),
            ],
          ),

          if (lead.nextFollowUpDate != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                children: [
                  const Icon(Icons.event_outlined, size: 14, color: AppColors.primaryBlue),
                  const SizedBox(width: 4),
                  Text(
                    'Next Follow-up: ${lead.nextFollowUpDate!.day}/${lead.nextFollowUpDate!.month}/${lead.nextFollowUpDate!.year} ${lead.nextFollowUpTime ?? ""}',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.secondaryText),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
