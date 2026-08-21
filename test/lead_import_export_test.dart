import 'package:flutter_test/flutter_test.dart';
import 'package:xenobiz_flutter/domain/entities/lead_entity.dart';
import 'package:xenobiz_flutter/domain/repositories/lead_repository.dart';
import 'package:xenobiz_flutter/infrastructure/services/lead_export_service.dart';
import 'package:xenobiz_flutter/infrastructure/services/lead_import_service.dart';

class MockLeadRepository implements LeadRepository {
  final List<LeadEntity> leads = [];

  @override
  Future<LeadEntity> createLead(LeadEntity lead, {LeadFollowUpEntity? initialFollowUp}) async {
    leads.add(lead);
    return lead;
  }

  @override
  Future<List<LeadEntity>> getLeads({LeadFilter? filter, LeadSortOption? sort, String? query}) async {
    return leads;
  }

  @override
  Future<LeadEntity?> getLeadById(String id) async {
    return leads.firstWhere((l) => l.id == id);
  }

  @override
  Future<LeadEntity> updateLead(LeadEntity lead) async => lead;

  @override
  Future<LeadEntity> updateLeadStage(String leadId, LeadStage stage, {String? lostReason, String? updatedBy}) async {
    final idx = leads.indexWhere((l) => l.id == leadId);
    final updated = leads[idx].copyWith(stage: stage, lostReason: lostReason);
    leads[idx] = updated;
    return updated;
  }

  @override
  Future<void> addLeadActivity(LeadActivityEntity activity) async {}

  @override
  Future<LeadFollowUpEntity> addLeadFollowUp(LeadFollowUpEntity followUp) async => followUp;

  @override
  Future<LeadNoteEntity> addLeadNote(LeadNoteEntity note) async => note;

  @override
  Future<FollowUpTaskEntity> createFollowUpTask(FollowUpTaskEntity task) async => task;

  @override
  Future<void> deleteLeadNote(String noteId) async {}

  @override
  Future<List<FollowUpTaskEntity>> getFollowUpTasks({bool? completedOnly}) async => [];

  @override
  Future<List<LeadActivityEntity>> getLeadActivities(String leadId) async => [];

  @override
  Future<List<LeadFollowUpEntity>> getLeadFollowUps(String leadId) async => [];

  @override
  Future<List<LeadNoteEntity>> getLeadNotes(String leadId) async => [];

  @override
  Future<void> toggleFollowUpCompletion(String followUpId) async {}

  @override
  Future<void> toggleTaskCompletion(String taskId) async {}
}

void main() {
  late MockLeadRepository mockRepo;
  late LeadImportService importService;

  setUp(() {
    mockRepo = MockLeadRepository();
    importService = LeadImportService(leadRepository: mockRepo);
  });

  group('LeadExportService Tests', () {
    test('Available fields list contains mandatory CRM fields', () {
      final fields = LeadExportService.availableFields;
      expect(fields.any((f) => f.key == 'contactName'), isTrue);
      expect(fields.any((f) => f.key == 'phone'), isTrue);
      expect(fields.any((f) => f.key == 'email'), isTrue);
      expect(fields.any((f) => f.key == 'companyName'), isTrue);
      expect(fields.any((f) => f.key == 'stage'), isTrue);
      expect(fields.any((f) => f.key == 'estimatedValue'), isTrue);
    });
  });

  group('LeadImportService Tests', () {
    test('Auto-column mapping correctly matches header names', () {
      final headers = [
        'Customer Name',
        'Mobile',
        'Email Address',
        'Business',
        'Deal Value',
        'Next Follow Up',
        'Unrecognized Column',
      ];

      final mapping = importService.autoMapColumns(headers);

      expect(mapping['Customer Name'], equals('contactName'));
      expect(mapping['Mobile'], equals('phone'));
      expect(mapping['Email Address'], equals('email'));
      expect(mapping['Business'], equals('companyName'));
      expect(mapping['Deal Value'], equals('estimatedValue'));
      expect(mapping['Next Follow Up'], equals('nextFollowUpDate'));
      expect(mapping['Unrecognized Column'], equals('SKIP'));
    });

    test('Validation detects missing lead name and invalid phone/email', () async {
      final headers = ['Lead Name', 'Phone Number', 'Email', 'Expected Value'];
      final rows = [
        ['', '9876543210', 'test@example.com', '10000'], // Missing name
        ['John Doe', '123', 'invalid-email', 'abc'], // Invalid phone, email, and value
        ['Valid Lead', '9876543210', 'valid@example.com', '50000'], // Fully valid
      ];

      final mapping = importService.autoMapColumns(headers);
      final parsed = await importService.validateAndParseRows(
        fileHeaders: headers,
        dataRows: rows,
        columnMapping: mapping,
      );

      expect(parsed.totalRows, equals(3));
      expect(parsed.validCount, equals(1));
      expect(parsed.invalidCount, equals(2));

      expect(parsed.rows[0].isValid, isFalse);
      expect(parsed.rows[0].errors, contains('Missing Lead Name'));

      expect(parsed.rows[1].isValid, isFalse);
      expect(parsed.rows[1].errors.length, greaterThanOrEqualTo(2));

      expect(parsed.rows[2].isValid, isTrue);
      expect(parsed.rows[2].parsedLead?.contactName, equals('Valid Lead'));
      expect(parsed.rows[2].parsedLead?.estimatedValue, equals(50000.0));
    });

    test('Duplicate detection identifies matching phone numbers', () async {
      await mockRepo.createLead(LeadEntity(
        id: 'existing_1',
        title: 'Existing Lead',
        contactName: 'Existing Lead',
        phone: '9999999999',
        email: 'existing@example.com',
        stage: LeadStage.newLead,
        estimatedValue: 10000,
        createdAt: DateTime.now(),
      ));

      final headers = ['Lead Name', 'Phone Number', 'Email'];
      final rows = [
        ['New Unique Lead', '8888888888', 'unique@example.com'],
        ['Duplicate Lead', '9999999999', 'dup@example.com'],
      ];

      final mapping = importService.autoMapColumns(headers);
      final parsed = await importService.validateAndParseRows(
        fileHeaders: headers,
        dataRows: rows,
        columnMapping: mapping,
      );

      expect(parsed.duplicateCount, equals(1));
      expect(parsed.rows[0].isDuplicate, isFalse);
      expect(parsed.rows[1].isDuplicate, isTrue);
    });
  });
}
