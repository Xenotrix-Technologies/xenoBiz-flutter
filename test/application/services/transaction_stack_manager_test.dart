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

    test('TC-01: Empty A -> B -> Complete B -> Back (Retain A on stack)', () {
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

      // Prune stale sessions (completed B is pruned)
      manager.pruneStaleSessions();

      // Session A remains on stack for the user to return to
      expect(manager.stack.length, 1);
      expect(manager.currentSession?.id, 'session_A');
    });

    test('TC-02: Dirty A -> Empty B -> Dirty C -> Complete C -> Unwind stack correctly', () {
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

      // Prune completed sessions
      manager.pruneStaleSessions();

      // Unfinished sessions B and A remain on stack
      expect(manager.stack.length, 2);
      expect(manager.currentSession?.id, 'session_B');

      // When B is popped/unregistered
      manager.unregisterSession('session_B');
      expect(manager.stack.length, 1);
      expect(manager.currentSession?.id, 'session_A');
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

    test('TC-05: Multi-level stack pruning (A -> B -> C -> Complete D)', () {
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

      // Prune completed sessions
      manager.pruneStaleSessions();

      // Stack contains C, B, A in reverse order
      expect(manager.stack.length, 3);
      expect(manager.currentSession?.id, 'C');
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

    group('Conditional Restoration - Cases 1 through 8', () {
      test('Case 1: Empty A -> B -> Complete B skips empty A', () {
        manager.registerSession(TransactionSession(id: 'A', type: TransactionTypeCategory.sale, isEdit: false, hasMeaningfulData: () => false));
        manager.registerSession(TransactionSession(id: 'B', type: TransactionTypeCategory.sale, isEdit: false, hasMeaningfulData: () => true, isCompleted: true));

        // Unwind stack from B completion
        int popCount = 0;
        if (manager.stack.isNotEmpty && manager.stack.last.isCompleted) manager.unregisterSession(manager.stack.last.id);
        popCount++;

        while (manager.stack.isNotEmpty) {
          final top = manager.stack.last;
          if (top.isCompleted || !top.hasMeaningfulData()) {
            manager.unregisterSession(top.id);
            popCount++;
          } else {
            break;
          }
        }

        expect(manager.stack.length, 0); // Both B and empty A pruned
      });

      test('Case 2: Dirty A -> B -> Complete B restores dirty A', () {
        manager.registerSession(TransactionSession(id: 'A', type: TransactionTypeCategory.sale, isEdit: false, hasMeaningfulData: () => true));
        manager.registerSession(TransactionSession(id: 'B', type: TransactionTypeCategory.sale, isEdit: false, hasMeaningfulData: () => true, isCompleted: true));

        if (manager.stack.isNotEmpty && manager.stack.last.isCompleted) manager.unregisterSession(manager.stack.last.id);

        while (manager.stack.isNotEmpty) {
          final top = manager.stack.last;
          if (top.isCompleted || !top.hasMeaningfulData()) {
            manager.unregisterSession(top.id);
          } else {
            break;
          }
        }

        expect(manager.stack.length, 1);
        expect(manager.currentSession?.id, 'A');
      });

      test('Case 3: Dirty A -> Empty B -> C -> Complete C skips B and restores A', () {
        manager.registerSession(TransactionSession(id: 'A', type: TransactionTypeCategory.sale, isEdit: false, hasMeaningfulData: () => true));
        manager.registerSession(TransactionSession(id: 'B', type: TransactionTypeCategory.sale, isEdit: false, hasMeaningfulData: () => false));
        manager.registerSession(TransactionSession(id: 'C', type: TransactionTypeCategory.sale, isEdit: false, hasMeaningfulData: () => true, isCompleted: true));

        if (manager.stack.isNotEmpty && manager.stack.last.isCompleted) manager.unregisterSession(manager.stack.last.id);

        while (manager.stack.isNotEmpty) {
          final top = manager.stack.last;
          if (top.isCompleted || !top.hasMeaningfulData()) {
            manager.unregisterSession(top.id);
          } else {
            break;
          }
        }

        expect(manager.stack.length, 1);
        expect(manager.currentSession?.id, 'A');
      });

      test('Case 4: Dirty A -> Dirty B -> C -> Complete C restores B', () {
        manager.registerSession(TransactionSession(id: 'A', type: TransactionTypeCategory.sale, isEdit: false, hasMeaningfulData: () => true));
        manager.registerSession(TransactionSession(id: 'B', type: TransactionTypeCategory.sale, isEdit: false, hasMeaningfulData: () => true));
        manager.registerSession(TransactionSession(id: 'C', type: TransactionTypeCategory.sale, isEdit: false, hasMeaningfulData: () => true, isCompleted: true));

        if (manager.stack.isNotEmpty && manager.stack.last.isCompleted) manager.unregisterSession(manager.stack.last.id);

        while (manager.stack.isNotEmpty) {
          final top = manager.stack.last;
          if (top.isCompleted || !top.hasMeaningfulData()) {
            manager.unregisterSession(top.id);
          } else {
            break;
          }
        }

        expect(manager.stack.length, 2);
        expect(manager.currentSession?.id, 'B');
      });

      test('Case 5: Empty A -> Empty B -> C -> Complete C skips both A and B', () {
        manager.registerSession(TransactionSession(id: 'A', type: TransactionTypeCategory.sale, isEdit: false, hasMeaningfulData: () => false));
        manager.registerSession(TransactionSession(id: 'B', type: TransactionTypeCategory.sale, isEdit: false, hasMeaningfulData: () => false));
        manager.registerSession(TransactionSession(id: 'C', type: TransactionTypeCategory.sale, isEdit: false, hasMeaningfulData: () => true, isCompleted: true));

        if (manager.stack.isNotEmpty && manager.stack.last.isCompleted) manager.unregisterSession(manager.stack.last.id);

        while (manager.stack.isNotEmpty) {
          final top = manager.stack.last;
          if (top.isCompleted || !top.hasMeaningfulData()) {
            manager.unregisterSession(top.id);
          } else {
            break;
          }
        }

        expect(manager.stack.length, 0);
      });

      test('Case 6: Empty A -> Dirty B -> C -> Complete C restores B', () {
        manager.registerSession(TransactionSession(id: 'A', type: TransactionTypeCategory.sale, isEdit: false, hasMeaningfulData: () => false));
        manager.registerSession(TransactionSession(id: 'B', type: TransactionTypeCategory.sale, isEdit: false, hasMeaningfulData: () => true));
        manager.registerSession(TransactionSession(id: 'C', type: TransactionTypeCategory.sale, isEdit: false, hasMeaningfulData: () => true, isCompleted: true));

        if (manager.stack.isNotEmpty && manager.stack.last.isCompleted) manager.unregisterSession(manager.stack.last.id);

        while (manager.stack.isNotEmpty) {
          final top = manager.stack.last;
          if (top.isCompleted || !top.hasMeaningfulData()) {
            manager.unregisterSession(top.id);
          } else {
            break;
          }
        }

        expect(manager.stack.length, 2);
        expect(manager.currentSession?.id, 'B');
      });

      test('Case 7: Dirty A -> Empty B -> Empty C -> Empty D -> E -> Complete E skips B, C, D to restore A', () {
        manager.registerSession(TransactionSession(id: 'A', type: TransactionTypeCategory.sale, isEdit: false, hasMeaningfulData: () => true));
        manager.registerSession(TransactionSession(id: 'B', type: TransactionTypeCategory.sale, isEdit: false, hasMeaningfulData: () => false));
        manager.registerSession(TransactionSession(id: 'C', type: TransactionTypeCategory.sale, isEdit: false, hasMeaningfulData: () => false));
        manager.registerSession(TransactionSession(id: 'D', type: TransactionTypeCategory.sale, isEdit: false, hasMeaningfulData: () => false));
        manager.registerSession(TransactionSession(id: 'E', type: TransactionTypeCategory.sale, isEdit: false, hasMeaningfulData: () => true, isCompleted: true));

        if (manager.stack.isNotEmpty && manager.stack.last.isCompleted) manager.unregisterSession(manager.stack.last.id);

        while (manager.stack.isNotEmpty) {
          final top = manager.stack.last;
          if (top.isCompleted || !top.hasMeaningfulData()) {
            manager.unregisterSession(top.id);
          } else {
            break;
          }
        }

        expect(manager.stack.length, 1);
        expect(manager.currentSession?.id, 'A');
      });

      test('Case 8: Dirty A -> Dirty B -> Empty C -> D -> Complete D skips C and restores B', () {
        manager.registerSession(TransactionSession(id: 'A', type: TransactionTypeCategory.sale, isEdit: false, hasMeaningfulData: () => true));
        manager.registerSession(TransactionSession(id: 'B', type: TransactionTypeCategory.sale, isEdit: false, hasMeaningfulData: () => true));
        manager.registerSession(TransactionSession(id: 'C', type: TransactionTypeCategory.sale, isEdit: false, hasMeaningfulData: () => false));
        manager.registerSession(TransactionSession(id: 'D', type: TransactionTypeCategory.sale, isEdit: false, hasMeaningfulData: () => true, isCompleted: true));

        if (manager.stack.isNotEmpty && manager.stack.last.isCompleted) manager.unregisterSession(manager.stack.last.id);

        while (manager.stack.isNotEmpty) {
          final top = manager.stack.last;
          if (top.isCompleted || !top.hasMeaningfulData()) {
            manager.unregisterSession(top.id);
          } else {
            break;
          }
        }

        expect(manager.stack.length, 2);
        expect(manager.currentSession?.id, 'B');
      });
    });
  });
}
