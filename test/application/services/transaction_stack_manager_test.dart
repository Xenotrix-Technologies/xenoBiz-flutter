import 'package:flutter_test/flutter_test.dart';
import 'package:xenobiz_flutter/application/services/transaction_stack_manager.dart';

void main() {
  late TransactionStackManager manager;

  setUp(() {
    manager = TransactionStackManager.instance;
    manager.clear();
  });

  group('TransactionStackManager Unit Tests', () {
    test('TC-06: Session registration and unregistration lifecycle', () {
      final session1 = TransactionSession(
        id: 's1',
        type: TransactionTypeCategory.sale,
        isEdit: false,
        hasMeaningfulData: () => false,
      );

      manager.registerSession(session1);
      expect(manager.stack.length, 1);
      expect(manager.currentSession?.id, 's1');

      manager.unregisterSession('s1');
      expect(manager.stack.length, 0);
      expect(manager.currentSession, isNull);
    });

    test('TC-01: Empty A -> B -> Complete B -> Back (Prune empty & completed)', () {
      bool emptyAHasData = false;
      bool bHasData = true;

      final sessionA = TransactionSession(
        id: 'session_A',
        type: TransactionTypeCategory.sale,
        isEdit: false,
        hasMeaningfulData: () => emptyAHasData,
      );

      final sessionB = TransactionSession(
        id: 'session_B',
        type: TransactionTypeCategory.moneyIn,
        isEdit: false,
        hasMeaningfulData: () => bHasData,
      );

      manager.registerSession(sessionA);
      manager.registerSession(sessionB);
      expect(manager.stack.length, 2);

      // Complete B
      manager.markCompleted('session_B');
      expect(manager.currentSession?.isCompleted, isTrue);

      // Prune stale sessions
      manager.pruneStaleSessions();

      // B completed and A empty -> both pruned
      expect(manager.stack.length, 0);
    });

    test('TC-02: Dirty A -> Empty B -> Dirty C -> Complete C -> Prune B & restore A', () {
      bool dirtyAData = true;
      bool emptyBData = false;
      bool dirtyCData = true;

      final sessionA = TransactionSession(
        id: 'session_A',
        type: TransactionTypeCategory.sale,
        isEdit: false,
        hasMeaningfulData: () => dirtyAData,
      );

      final sessionB = TransactionSession(
        id: 'session_B',
        type: TransactionTypeCategory.moneyIn,
        isEdit: false,
        hasMeaningfulData: () => emptyBData,
      );

      final sessionC = TransactionSession(
        id: 'session_C',
        type: TransactionTypeCategory.sale,
        isEdit: false,
        hasMeaningfulData: () => dirtyCData,
      );

      manager.registerSession(sessionA);
      manager.registerSession(sessionB);
      manager.registerSession(sessionC);
      expect(manager.stack.length, 3);

      // Complete C (e.g. from checkout)
      manager.markCurrentCompleted();
      expect(manager.stack.last.isCompleted, isTrue);

      // Simulate back from checkout removal of top completed session
      if (manager.stack.isNotEmpty && manager.stack.last.isCompleted) {
        manager.unregisterSession(manager.stack.last.id);
      }

      // Prune remaining empty session B
      manager.pruneStaleSessions();

      // Session A should remain as active current session
      expect(manager.stack.length, 1);
      expect(manager.currentSession?.id, 'session_A');
      expect(manager.currentSession?.isCompleted, isFalse);
    });

    test('TC-03: Edit A -> Create B -> Complete B -> Restore Edit A', () {
      final editSessionA = TransactionSession(
        id: 'edit_A',
        type: TransactionTypeCategory.sale,
        isEdit: true,
        entityId: 'inv_123',
        hasMeaningfulData: () => true,
      );

      final newSessionB = TransactionSession(
        id: 'new_B',
        type: TransactionTypeCategory.purchase,
        isEdit: false,
        hasMeaningfulData: () => true,
      );

      manager.registerSession(editSessionA);
      manager.registerSession(newSessionB);

      expect(manager.currentSession?.id, 'new_B');

      // Complete B
      manager.markCompleted('new_B');
      manager.unregisterSession('new_B');
      manager.pruneStaleSessions();

      // Restored edit session A
      expect(manager.stack.length, 1);
      expect(manager.currentSession?.id, 'edit_A');
      expect(manager.currentSession?.isEdit, isTrue);
      expect(manager.currentSession?.entityId, 'inv_123');
    });

    test('TC-05: Multi-level stack pruning (Dirty A -> Empty B -> Empty C -> Complete D)', () {
      manager.registerSession(TransactionSession(
        id: 'A',
        type: TransactionTypeCategory.sale,
        isEdit: false,
        hasMeaningfulData: () => true,
      ));

      manager.registerSession(TransactionSession(
        id: 'B',
        type: TransactionTypeCategory.moneyIn,
        isEdit: false,
        hasMeaningfulData: () => false,
      ));

      manager.registerSession(TransactionSession(
        id: 'C',
        type: TransactionTypeCategory.salesReturn,
        isEdit: false,
        hasMeaningfulData: () => false,
      ));

      manager.registerSession(TransactionSession(
        id: 'D',
        type: TransactionTypeCategory.purchase,
        isEdit: false,
        hasMeaningfulData: () => true,
      ));

      expect(manager.stack.length, 4);

      // Complete D and unregister it
      manager.markCompleted('D');
      manager.unregisterSession('D');

      // Prune B and C
      manager.pruneStaleSessions();

      // Only A remains
      expect(manager.stack.length, 1);
      expect(manager.currentSession?.id, 'A');
    });

    test('TC-08: Completed session does not trigger discard dialog evaluation', () {
      final session = TransactionSession(
        id: 'money_in_1',
        type: TransactionTypeCategory.moneyIn,
        isEdit: false,
        hasMeaningfulData: () => true,
      );

      manager.registerSession(session);
      expect(manager.stack.length, 1);

      // Mark completed upon successful save
      manager.markCompleted('money_in_1');
      expect(manager.currentSession?.isCompleted, isTrue);

      // Verify that isCompleted prevents dirty discard check
      expect(session.isCompleted, isTrue);
      expect(!session.isCompleted && session.hasMeaningfulData(), isFalse);
    });
  });
}
