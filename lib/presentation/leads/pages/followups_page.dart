import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../application/di/injection.dart';
import '../../../const/colors.dart';
import '../../../domain/entities/crm_entities.dart';
import '../../../domain/entities/customer_entity.dart';
import '../../../domain/repositories/customer_repository.dart';
import '../../../infrastructure/services/crm_service.dart';
import '../../widgets/app_card.dart';
import '../../widgets/ui_state_widgets.dart';

class FollowUpsPage extends StatefulWidget {
  const FollowUpsPage({super.key});

  @override
  State<FollowUpsPage> createState() => _FollowUpsPageState();
}

class _FollowUpsPageState extends State<FollowUpsPage> with SingleTickerProviderStateMixin {
  late final CrmService _crmService;
  late TabController _tabController;
  List<CrmFollowUpEntity> _allFollowUps = [];
  Map<String, CustomerEntity> _customerMap = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _crmService = getIt<CrmService>();
    _tabController = TabController(length: 4, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final custRepo = getIt<CustomerRepository>();
      final customers = await custRepo.getCustomers();
      final Map<String, CustomerEntity> map = {};
      for (var c in customers) {
        map[c.id] = c;
      }

      final followUps = _crmService.getFollowUps();

      if (mounted) {
        setState(() {
          _allFollowUps = followUps;
          _customerMap = map;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showAddFollowUpDialog() {
    final titleCtrl = TextEditingController();
    final notesCtrl = TextEditingController();
    DateTime selectedDate = DateTime.now().add(const Duration(days: 1));
    TimeOfDay selectedTime = const TimeOfDay(hour: 10, minute: 30);
    CustomerEntity? selectedCustomer;

    showDialog(
      context: context,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            final customersList = _customerMap.values.toList();
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: const Text('Schedule Follow-Up', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<CustomerEntity>(
                      initialValue: selectedCustomer,
                      decoration: InputDecoration(
                        labelText: 'Select Customer *',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      items: customersList
                          .map((c) => DropdownMenuItem(
                                value: c,
                                child: Text('${c.name} (${c.phone})', style: const TextStyle(fontSize: 13)),
                              ))
                          .toList(),
                      onChanged: (val) {
                        setDialogState(() => selectedCustomer = val);
                      },
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: titleCtrl,
                      decoration: InputDecoration(
                        labelText: 'Follow-Up Title *',
                        hintText: 'e.g., Call regarding payment balance',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: notesCtrl,
                      decoration: InputDecoration(
                        labelText: 'Notes / Remarks',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: selectedDate,
                                firstDate: DateTime.now(),
                                lastDate: DateTime.now().add(const Duration(days: 365)),
                              );
                              if (picked != null) {
                                setDialogState(() => selectedDate = picked);
                              }
                            },
                            icon: const Icon(Icons.calendar_today_rounded, size: 16),
                            label: Text(DateFormat('dd MMM yyyy').format(selectedDate), style: const TextStyle(fontSize: 11)),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () async {
                              final picked = await showTimePicker(context: context, initialTime: selectedTime);
                              if (picked != null) {
                                setDialogState(() => selectedTime = picked);
                              }
                            },
                            icon: const Icon(Icons.access_time_rounded, size: 16),
                            label: Text(selectedTime.format(context), style: const TextStyle(fontSize: 11)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(dialogCtx), child: const Text('Cancel')),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryBlue, foregroundColor: Colors.white),
                  onPressed: () async {
                    if (selectedCustomer != null && titleCtrl.text.trim().isNotEmpty) {
                      Navigator.pop(dialogCtx);
                      final fu = CrmFollowUpEntity(
                        id: 'fu_${DateTime.now().millisecondsSinceEpoch}',
                        customerId: selectedCustomer!.id,
                        customerName: selectedCustomer!.name,
                        title: titleCtrl.text.trim(),
                        notes: notesCtrl.text.trim(),
                        dueDate: selectedDate,
                        dueTime: selectedTime.format(context),
                        status: 'pending',
                      );
                      await _crmService.saveFollowUp(fu);
                      _loadData();
                    }
                  },
                  child: const Text('Save Task'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final todayList = _allFollowUps.where((f) => f.isToday).toList();
    final upcomingList = _allFollowUps.where((f) => !f.isCompleted && !f.isOverdue && !f.isToday).toList();
    final overdueList = _allFollowUps.where((f) => f.isOverdue).toList();
    final completedList = _allFollowUps.where((f) => f.isCompleted).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Follow-ups & Reminders', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        actions: [
          IconButton(icon: const Icon(Icons.refresh_rounded), onPressed: _loadData),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.amberAccent,
          indicatorWeight: 3,
          tabs: [
            Tab(text: 'Today (${todayList.length})'),
            Tab(text: 'Upcoming (${upcomingList.length})'),
            Tab(text: 'Overdue (${overdueList.length})'),
            Tab(text: 'Completed (${completedList.length})'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: null,
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
        onPressed: _showAddFollowUpDialog,
        icon: const Icon(Icons.add_task_rounded),
        label: const Text('New Follow-up', style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: _isLoading
          ? const FollowupsPageSkeleton()
          : TabBarView(
              controller: _tabController,
              children: [
                _buildTaskList(todayList, 'No follow-ups due today.'),
                _buildTaskList(upcomingList, 'No upcoming follow-ups.'),
                _buildTaskList(overdueList, 'No overdue follow-ups.'),
                _buildTaskList(completedList, 'No completed follow-ups.'),
              ],
            ),
    );
  }

  Widget _buildTaskList(List<CrmFollowUpEntity> tasks, String emptyMessage) {
    if (tasks.isEmpty) {
      return EmptyState(
        title: 'All Clear!',
        message: emptyMessage,
        icon: Icons.event_available_rounded,
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: tasks.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (ctx, idx) {
        final task = tasks[idx];
        final customer = _customerMap[task.customerId];

        return AppCard(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Checkbox(
                    value: task.isCompleted,
                    activeColor: AppColors.success,
                    onChanged: (_) async {
                      await _crmService.toggleFollowUpStatus(task.id);
                      _loadData();
                    },
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          task.title,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                            color: task.isCompleted ? AppColors.secondaryText : AppColors.darkBlueText,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Customer: ${task.customerName}',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primaryBlue),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.danger),
                    onPressed: () async {
                      await _crmService.deleteFollowUp(task.id);
                      _loadData();
                    },
                  ),
                ],
              ),

              if (task.notes.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.only(left: 48, top: 4, bottom: 6),
                  child: Text(task.notes, style: const TextStyle(fontSize: 12, color: AppColors.secondaryText)),
                ),
              ],

              const Divider(height: 14),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.access_time_rounded,
                        size: 14,
                        color: task.isOverdue ? AppColors.danger : AppColors.secondaryText,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Due: ${DateFormat('dd MMM yyyy').format(task.dueDate)} • ${task.dueTime}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: task.isOverdue ? AppColors.danger : AppColors.secondaryText,
                        ),
                      ),
                    ],
                  ),
                  if (customer != null && customer.phone.isNotEmpty) ...[
                    Row(
                      children: [
                        InkWell(
                          onTap: () => CrmService.makePhoneCall(customer.phone),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            child: Icon(Icons.phone_outlined, size: 16, color: AppColors.primaryBlue),
                          ),
                        ),
                        const SizedBox(width: 8),
                        InkWell(
                          onTap: () => CrmService.openWhatsApp(customer.phone),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            child: Icon(Icons.chat_bubble_outline_rounded, size: 16, color: Color(0xFF128C7E)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
