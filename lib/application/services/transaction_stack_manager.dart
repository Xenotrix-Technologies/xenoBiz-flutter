import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../routing/route_names.dart';

enum TransactionTypeCategory {
  sale,
  salesReturn,
  purchase,
  purchaseReturn,
  moneyIn,
  moneyOut,
}

extension TransactionTypeCategoryX on TransactionTypeCategory {
  String get displayName {
    switch (this) {
      case TransactionTypeCategory.sale:
        return 'Sale';
      case TransactionTypeCategory.salesReturn:
        return 'Sales Return';
      case TransactionTypeCategory.purchase:
        return 'Purchase';
      case TransactionTypeCategory.purchaseReturn:
        return 'Purchase Return';
      case TransactionTypeCategory.moneyIn:
        return 'Money In';
      case TransactionTypeCategory.moneyOut:
        return 'Money Out';
    }
  }
}

class TransactionSession {
  final String id;
  final TransactionTypeCategory type;
  final bool isEdit;
  final String? entityId;
  final bool Function() hasMeaningfulData;
  bool isCompleted;

  TransactionSession({
    required this.id,
    required this.type,
    required this.isEdit,
    this.entityId,
    required this.hasMeaningfulData,
    this.isCompleted = false,
  });
}

class TransactionStackManager {
  static final TransactionStackManager instance = TransactionStackManager._();
  TransactionStackManager._();

  final List<TransactionSession> _stack = [];

  List<TransactionSession> get stack => List.unmodifiable(_stack);

  void registerSession(TransactionSession session) {
    _stack.removeWhere((s) => s.id == session.id);
    _stack.add(session);
  }

  void unregisterSession(String id) {
    _stack.removeWhere((s) => s.id == id);
  }

  void markCompleted(String id) {
    for (var s in _stack) {
      if (s.id == id) {
        s.isCompleted = true;
      }
    }
  }

  void markCurrentCompleted() {
    if (_stack.isNotEmpty) {
      _stack.last.isCompleted = true;
    }
  }

  TransactionSession? get currentSession =>
      _stack.isNotEmpty ? _stack.last : null;

  /// Returns the nearest unfinished parent session with meaningful data on the stack.
  TransactionSession? get nearestUnfinishedSession {
    for (int i = _stack.length - 1; i >= 0; i--) {
      final s = _stack[i];
      if (!s.isCompleted && s.hasMeaningfulData()) {
        return s;
      }
    }
    return null;
  }

  /// Clears all registered sessions (useful for tests or hard resets).
  void clear() {
    _stack.clear();
  }

  /// Prunes completed sessions from top of stack.
  void pruneStaleSessions() {
    while (_stack.isNotEmpty) {
      final top = _stack.last;
      if (top.isCompleted) {
        _stack.removeLast();
      } else {
        break;
      }
    }
  }

  /// Handles Back button from Checkout / InvoiceResultPage.
  Future<void> handleBackFromCheckout(BuildContext context) async {
    if (_stack.isNotEmpty && _stack.last.isCompleted) {
      _stack.removeLast();
    }

    int popCount = 1;

    while (_stack.isNotEmpty) {
      final top = _stack.last;
      if (top.isCompleted || !top.hasMeaningfulData()) {
        _stack.removeLast();
        popCount++;
      } else {
        break;
      }
    }

    if (context.mounted) {
      if (_stack.isEmpty) {
        context.go(RouteNames.dashboard);
      } else {
        for (int i = 0; i < popCount; i++) {
          if (context.canPop()) {
            context.pop();
          } else {
            context.go(RouteNames.dashboard);
            break;
          }
        }
      }
    }
  }

  /// Handles Back button from an active transaction form screen.
  Future<void> handleBackFromTransaction(
      BuildContext context, String currentSessionId) async {
    final idx = _stack.indexWhere((s) => s.id == currentSessionId);
    if (idx != -1) {
      final session = _stack[idx];
      if (!session.isCompleted && session.hasMeaningfulData()) {
        final shouldDiscard = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text('Discard ${session.type.displayName}?'),
            content: Text(
                'You have unsaved changes in this ${session.type.displayName.toLowerCase()}. Do you want to discard them?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Discard',
                    style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        );
        if (shouldDiscard != true) return;
        if (!context.mounted) return;
      }
      _stack.removeAt(idx);
    }

    int popCount = 1;

    // Skip any empty or completed sessions underneath
    while (_stack.isNotEmpty) {
      final top = _stack.last;
      if (top.isCompleted || !top.hasMeaningfulData()) {
        _stack.removeLast();
        popCount++;
      } else {
        break;
      }
    }

    if (context.mounted) {
      if (_stack.isEmpty) {
        context.go(RouteNames.dashboard);
      } else {
        for (int i = 0; i < popCount; i++) {
          if (context.canPop()) {
            context.pop();
          } else {
            context.go(RouteNames.dashboard);
            break;
          }
        }
      }
    }
  }
}
