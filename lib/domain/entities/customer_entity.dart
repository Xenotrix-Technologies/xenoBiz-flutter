import 'package:equatable/equatable.dart';
import 'billing_customer_entity.dart';

typedef CustomerEntity = BillingCustomerEntity;

class CustomerTimelineEvent extends Equatable {
  final String id;
  final String customerId;
  final String title;
  final String description;
  final String eventType; // INVOICE, PAYMENT, FOLLOW_UP, NOTE
  final double? amount;
  final DateTime timestamp;

  const CustomerTimelineEvent({
    required this.id,
    required this.customerId,
    required this.title,
    required this.description,
    required this.eventType,
    this.amount,
    required this.timestamp,
  });

  @override
  List<Object?> get props => [id, customerId, title, description, eventType, amount, timestamp];
}
