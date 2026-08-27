import 'package:flutter/material.dart';
import 'transaction_stack_manager.dart';

/// Lightweight NavigatorObserver that synchronizes GoRouter/Navigator route
/// lifecycle events with [TransactionStackManager].
class TransactionRouteObserver extends NavigatorObserver {
  static final TransactionRouteObserver instance = TransactionRouteObserver._();
  TransactionRouteObserver._();

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    _reconcileRoutes();
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didRemove(route, previousRoute);
    _reconcileRoutes();
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    _reconcileRoutes();
  }

  void _reconcileRoutes() {
    TransactionStackManager.instance.pruneStaleSessions();
  }
}
