import 'package:url_launcher/url_launcher.dart';
import '../../domain/entities/crm_customer_entity.dart';
import '../../domain/entities/crm_entities.dart';
import '../../domain/entities/customer_entity.dart';
import '../../domain/entities/lead_entity.dart';
import '../../domain/entities/payment_entity.dart';
import '../../domain/repositories/crm_customer_repository.dart';
import '../../domain/repositories/lead_repository.dart';
import '../storage/hive_service.dart';

class CrmSearchResult {
  final List<CrmCustomerEntity> crmCustomers;
  final List<LeadEntity> leads;

  const CrmSearchResult({
    this.crmCustomers = const [],
    this.leads = const [],
  });
}

class SalesChartPoint {
  final String label;
  final double amount;
  final DateTime date;

  const SalesChartPoint({
    required this.label,
    required this.amount,
    required this.date,
  });
}

class CustomerGrowthPoint {
  final String label;
  final int count;

  const CustomerGrowthPoint({
    required this.label,
    required this.count,
  });
}

class CrmDashboardMetrics {
  final int totalCustomers;
  final int newCustomersThisMonth;
  final int totalLeads;
  final int newLeadsThisMonth;
  final double leadConversionRate;
  final int activeCustomers;
  final int dueFollowUpsCount;

  // Lead Pipeline Breakdown
  final Map<LeadStage, int> leadStageCounts;

  // Customer Growth Chart
  final double customerGrowthPercentage;
  final List<CustomerGrowthPoint> customerGrowthPoints;

  // Today Activity Summary
  final int newCustomersToday;
  final int newLeadsToday;
  final int followUpsCompletedToday;
  final int followUpsPendingToday;

  // Today's Follow-ups Summary
  final int followUpsTodayCount;
  final int followUpsOverdueCount;
  final int followUpsUpcomingCount;

  // Activity & Feed Lists
  final List<CustomerTimelineEvent> recentActivity;
  final List<LeadEntity> recentLeads;

  const CrmDashboardMetrics({
    this.totalCustomers = 0,
    this.newCustomersThisMonth = 0,
    this.totalLeads = 0,
    this.newLeadsThisMonth = 0,
    this.leadConversionRate = 0.0,
    this.activeCustomers = 0,
    this.dueFollowUpsCount = 0,
    this.leadStageCounts = const {},
    this.customerGrowthPercentage = 0.0,
    this.customerGrowthPoints = const [],
    this.newCustomersToday = 0,
    this.newLeadsToday = 0,
    this.followUpsCompletedToday = 0,
    this.followUpsPendingToday = 0,
    this.followUpsTodayCount = 0,
    this.followUpsOverdueCount = 0,
    this.followUpsUpcomingCount = 0,
    this.recentActivity = const [],
    this.recentLeads = const [],
  });

  int get newCustomers => newCustomersThisMonth;
}

class CrmService {
  final HiveService hiveService;
  final CrmCustomerRepository crmCustomerRepository;
  final LeadRepository? leadRepository;

  CrmService({
    required this.hiveService,
    required this.crmCustomerRepository,
    this.leadRepository,
  });

  // ==========================================
  // 1. NOTES MANAGEMENT
  // ==========================================

  List<CrmNoteEntity> getNotesForCustomer(String customerId) {
    try {
      final box = hiveService.getBox(HiveService.boxCrmNotes);
      final List<CrmNoteEntity> notes = [];
      for (var key in box.keys) {
        final val = box.get(key);
        if (val is Map) {
          final note = CrmNoteEntity.fromMap(Map<String, dynamic>.from(val));
          if (note.customerId == customerId) {
            notes.add(note);
          }
        }
      }
      notes.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      return notes;
    } catch (_) {
      return [];
    }
  }

  Future<void> saveNote(CrmNoteEntity note) async {
    try {
      final box = hiveService.getBox(HiveService.boxCrmNotes);
      await box.put(note.id, note.toMap());
    } catch (_) {}
  }

  Future<void> deleteNote(String noteId) async {
    try {
      final box = hiveService.getBox(HiveService.boxCrmNotes);
      await box.delete(noteId);
    } catch (_) {}
  }

  // ==========================================
  // CRM PAYMENTS MANAGEMENT
  // ==========================================

  List<PaymentEntity> getPaymentsForCustomer(String customerId) {
    try {
      final box = hiveService.getBox(HiveService.boxPayments);
      final List<PaymentEntity> list = [];
      for (var key in box.keys) {
        final val = box.get(key);
        if (val is Map) {
          final p = PaymentEntity(
            id: val['id']?.toString() ?? key.toString(),
            invoiceId: val['invoiceId']?.toString() ?? '',
            customerId: val['customerId']?.toString() ?? '',
            customerName: val['customerName']?.toString() ?? '',
            amount: (val['amount'] as num?)?.toDouble() ?? 0.0,
            paymentMode: val['paymentMode']?.toString() ?? 'CASH',
            referenceNumber: val['referenceNumber']?.toString() ?? '',
            paymentDate: DateTime.tryParse(val['paymentDate']?.toString() ?? '') ?? DateTime.now(),
            notes: val['notes']?.toString() ?? '',
          );
          if (p.customerId == customerId) {
            list.add(p);
          }
        }
      }
      list.sort((a, b) => b.paymentDate.compareTo(a.paymentDate));
      return list;
    } catch (_) {
      return [];
    }
  }

  Future<void> saveCustomerPayment(PaymentEntity payment) async {
    try {
      final box = hiveService.getBox(HiveService.boxPayments);
      await box.put(payment.id, {
        'id': payment.id,
        'invoiceId': payment.invoiceId,
        'customerId': payment.customerId,
        'customerName': payment.customerName,
        'amount': payment.amount,
        'paymentMode': payment.paymentMode,
        'referenceNumber': payment.referenceNumber,
        'paymentDate': payment.paymentDate.toIso8601String(),
        'notes': payment.notes,
      });
    } catch (_) {}
  }

  // ==========================================
  // 2. FOLLOW-UPS MANAGEMENT
  // ==========================================

  List<CrmFollowUpEntity> getFollowUps({String? customerId}) {
    try {
      final box = hiveService.getBox(HiveService.boxCrmFollowUps);
      final List<CrmFollowUpEntity> followUps = [];
      for (var key in box.keys) {
        final val = box.get(key);
        if (val is Map) {
          final fu = CrmFollowUpEntity.fromMap(Map<String, dynamic>.from(val));
          if (customerId == null || customerId.isEmpty || fu.customerId == customerId) {
            followUps.add(fu);
          }
        }
      }
      followUps.sort((a, b) => a.dueDate.compareTo(b.dueDate));
      return followUps;
    } catch (_) {
      return [];
    }
  }

  Future<void> saveFollowUp(CrmFollowUpEntity followUp) async {
    try {
      final box = hiveService.getBox(HiveService.boxCrmFollowUps);
      await box.put(followUp.id, followUp.toMap());
    } catch (_) {}
  }

  Future<void> deleteFollowUp(String followUpId) async {
    try {
      final box = hiveService.getBox(HiveService.boxCrmFollowUps);
      await box.delete(followUpId);
    } catch (_) {}
  }

  Future<void> toggleFollowUpStatus(String followUpId) async {
    try {
      final box = hiveService.getBox(HiveService.boxCrmFollowUps);
      final val = box.get(followUpId);
      if (val is Map) {
        final fu = CrmFollowUpEntity.fromMap(Map<String, dynamic>.from(val));
        final newStatus = fu.isCompleted ? 'pending' : 'completed';
        await box.put(followUpId, fu.copyWith(status: newStatus).toMap());
      }
    } catch (_) {}
  }

  // ==========================================
  // 3. CRM CUSTOMER ACTIVITY TIMELINE
  // ==========================================

  Future<List<CustomerTimelineEvent>> getCrmCustomerTimeline(String crmCustomerId, {CrmCustomerEntity? customer}) async {
    final List<CustomerTimelineEvent> timeline = [];
    try {
      CrmCustomerEntity? cust = customer;
      cust ??= await crmCustomerRepository.getCrmCustomer(crmCustomerId);

      // 1. CRM Profile Registered
      timeline.add(
        CustomerTimelineEvent(
          id: 'create_${cust.id}',
          customerId: cust.id,
          title: 'CRM Profile Registered',
          description: 'Profile created for ${cust.name}. Source: ${cust.source}',
          eventType: 'ACCOUNT',
          timestamp: cust.createdAt,
        ),
      );

      // 2. CRM Notes
      final notes = getNotesForCustomer(cust.id);
      for (var n in notes) {
        timeline.add(
          CustomerTimelineEvent(
            id: 'note_${n.id}',
            customerId: cust.id,
            title: 'CRM Note Added',
            description: n.text,
            eventType: 'NOTE',
            timestamp: n.updatedAt,
          ),
        );
      }

      // 3. CRM Follow-ups
      final followUps = getFollowUps(customerId: cust.id);
      for (var f in followUps) {
        timeline.add(
          CustomerTimelineEvent(
            id: 'fu_${f.id}',
            customerId: cust.id,
            title: 'Follow-up: ${f.title}',
            description: '${f.notes.isNotEmpty ? "${f.notes} • " : ""}Status: ${f.status.toUpperCase()}',
            eventType: 'FOLLOW_UP',
            timestamp: f.dueDate,
          ),
        );
      }

      timeline.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    } catch (_) {}
    return timeline;
  }

  // ==========================================
  // 4. GLOBAL CRM SEARCH
  // ==========================================

  Future<CrmSearchResult> searchCrm(String query) async {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return const CrmSearchResult();

    try {
      final crmCustomers = await crmCustomerRepository.getCrmCustomers(query: q);
      final allLeads = leadRepository != null ? await leadRepository!.getLeads() : <LeadEntity>[];
      final matchedLeads = allLeads.where((l) {
        return l.contactName.toLowerCase().contains(q) ||
            l.title.toLowerCase().contains(q) ||
            l.companyName.toLowerCase().contains(q) ||
            l.phone.toLowerCase().contains(q);
      }).toList();

      return CrmSearchResult(
        crmCustomers: crmCustomers,
        leads: matchedLeads,
      );
    } catch (_) {
      return const CrmSearchResult();
    }
  }

  // ==========================================
  // 5. CRM DASHBOARD OVERVIEW METRICS
  // ==========================================

  Future<CrmDashboardMetrics> getCrmDashboardMetrics() async {
    try {
      final crmCustomers = await crmCustomerRepository.getCrmCustomers();
      final leads = leadRepository != null ? await leadRepository!.getLeads() : <LeadEntity>[];
      final followUps = getFollowUps();
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      // 1. Customer metrics & growth
      int newCustMonth = 0;
      int newCustToday = 0;
      int activeCustCount = 0;

      for (var c in crmCustomers) {
        if (c.createdAt.year == now.year && c.createdAt.month == now.month) {
          newCustMonth++;
        }
        final cDate = DateTime(c.createdAt.year, c.createdAt.month, c.createdAt.day);
        if (cDate.isAtSameMomentAs(today)) {
          newCustToday++;
        }
        if (c.status.toLowerCase() == 'active') {
          activeCustCount++;
        }
      }

      // Customer growth points over 6 months
      final List<CustomerGrowthPoint> custGrowthPoints = [];
      const monthAbbrs = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      for (int i = 5; i >= 0; i--) {
        final monthDt = DateTime(now.year, now.month - i, 1);
        final monthEnd = DateTime(now.year, now.month - i + 1, 0, 23, 59, 59);
        final countAtMonth = crmCustomers.where((c) => c.createdAt.isBefore(monthEnd)).length;
        final mLabel = monthAbbrs[(monthDt.month - 1) % 12];
        custGrowthPoints.add(CustomerGrowthPoint(label: mLabel, count: countAtMonth));
      }

      final double custGrowthPct = custGrowthPoints.length >= 2 && custGrowthPoints[custGrowthPoints.length - 2].count > 0
          ? ((custGrowthPoints.last.count - custGrowthPoints[custGrowthPoints.length - 2].count) /
                  custGrowthPoints[custGrowthPoints.length - 2].count) *
              100.0
          : 0.0;

      // 2. Leads & Lead Pipeline
      int newLeadsMonth = 0;
      int newLeadsTodayCount = 0;
      int wonLeadsCount = 0;
      final Map<LeadStage, int> stageMap = {
        LeadStage.newLead: 0,
        LeadStage.contacted: 0,
        LeadStage.proposalSent: 0,
        LeadStage.negotiating: 0,
        LeadStage.won: 0,
        LeadStage.lost: 0,
      };

      for (var l in leads) {
        stageMap[l.stage] = (stageMap[l.stage] ?? 0) + 1;
        if (l.createdAt.year == now.year && l.createdAt.month == now.month) {
          newLeadsMonth++;
        }
        final lDate = DateTime(l.createdAt.year, l.createdAt.month, l.createdAt.day);
        if (lDate.isAtSameMomentAs(today)) {
          newLeadsTodayCount++;
        }
        if (l.stage == LeadStage.won) {
          wonLeadsCount++;
        }
      }

      final double conversionRate = leads.isNotEmpty ? (wonLeadsCount / leads.length) * 100.0 : 0.0;

      final recentLeadsList = List<LeadEntity>.from(leads);
      recentLeadsList.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      // 3. Follow-ups summary
      int fuCompletedToday = 0;
      int fuOverdue = 0;
      int fuToday = 0;
      int fuUpcoming = 0;

      for (var f in followUps) {
        if (f.isCompleted) {
          final fDate = DateTime(f.dueDate.year, f.dueDate.month, f.dueDate.day);
          if (fDate.isAtSameMomentAs(today)) fuCompletedToday++;
        } else if (f.isOverdue) {
          fuOverdue++;
        } else if (f.isToday) {
          fuToday++;
        } else {
          fuUpcoming++;
        }
      }

      // 4. Recent Activity Feed
      final List<CustomerTimelineEvent> recentFeed = [];

      for (var l in leads) {
        recentFeed.add(
          CustomerTimelineEvent(
            id: 'feed_lead_${l.id}',
            customerId: l.id,
            title: 'New Lead Added',
            description: '${l.contactName} (${l.title}) • ${l.stage.name.toUpperCase()}',
            eventType: 'LEAD',
            amount: l.estimatedValue,
            timestamp: l.createdAt,
          ),
        );
      }

      for (var fu in followUps) {
        if (fu.isCompleted) {
          recentFeed.add(
            CustomerTimelineEvent(
              id: 'feed_fu_${fu.id}',
              customerId: fu.customerId,
              title: 'Follow-up Completed',
              description: 'Followed up with ${fu.customerName}',
              eventType: 'FOLLOW_UP',
              timestamp: fu.dueDate,
            ),
          );
        }
      }

      for (var c in crmCustomers) {
        recentFeed.add(
          CustomerTimelineEvent(
            id: 'feed_cust_${c.id}',
            customerId: c.id,
            title: 'New CRM Customer Registered',
            description: '${c.name} added to CRM',
            eventType: 'ACCOUNT',
            timestamp: c.createdAt,
          ),
        );
      }

      recentFeed.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      return CrmDashboardMetrics(
        totalCustomers: crmCustomers.length,
        newCustomersThisMonth: newCustMonth,
        totalLeads: leads.length,
        newLeadsThisMonth: newLeadsMonth,
        leadConversionRate: conversionRate,
        activeCustomers: activeCustCount,
        dueFollowUpsCount: fuToday + fuOverdue,
        leadStageCounts: stageMap,
        customerGrowthPercentage: custGrowthPct,
        customerGrowthPoints: custGrowthPoints,
        newCustomersToday: newCustToday,
        newLeadsToday: newLeadsTodayCount,
        followUpsCompletedToday: fuCompletedToday,
        followUpsPendingToday: fuToday,
        followUpsTodayCount: fuToday,
        followUpsOverdueCount: fuOverdue,
        followUpsUpcomingCount: fuUpcoming,
        recentActivity: recentFeed.take(10).toList(),
        recentLeads: recentLeadsList.take(5).toList(),
      );
    } catch (_) {
      return const CrmDashboardMetrics();
    }
  }

  // ==========================================
  // 6. QUICK CALL & WHATSAPP LAUNCHERS
  // ==========================================

  static Future<bool> makePhoneCall(String phone) async {
    final cleanPhone = phone.replaceAll(RegExp(r'[^\d+]'), '');
    if (cleanPhone.isEmpty) return false;
    final uri = Uri.parse('tel:$cleanPhone');
    if (await canLaunchUrl(uri)) {
      return await launchUrl(uri);
    }
    return false;
  }

  static Future<bool> openWhatsApp(String phone, {String text = ''}) async {
    String cleanDigits = phone.replaceAll(RegExp(r'[^\d]'), '');
    if (cleanDigits.isEmpty) return false;

    if (cleanDigits.length == 10) {
      cleanDigits = '91$cleanDigits';
    }

    final encodedText = Uri.encodeComponent(text);
    final webUri = Uri.parse('https://wa.me/$cleanDigits?text=$encodedText');

    try {
      if (await canLaunchUrl(webUri)) {
        return await launchUrl(webUri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {}
    return false;
  }
}
