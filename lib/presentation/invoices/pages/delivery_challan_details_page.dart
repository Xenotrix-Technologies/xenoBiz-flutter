import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../application/bloc/delivery_challan_bloc.dart';
import '../../../application/routing/route_names.dart';
import '../../../const/colors.dart';
import '../../../const/sizes.dart';
import '../../../domain/entities/business_entity.dart';
import '../../../domain/entities/delivery_challan_entity.dart';
import '../../../infrastructure/pdf/pdf_delivery_challan_service.dart';
import '../../widgets/app_card.dart';

class DeliveryChallanDetailsPage extends StatelessWidget {
  final DeliveryChallanEntity challan;

  const DeliveryChallanDetailsPage({super.key, required this.challan});

  @override
  Widget build(BuildContext context) {
    final dateFormatter = DateFormat('dd MMM yyyy');

    final business = BusinessEntity(
      id: 'biz_01',
      name: 'Xenobiz Traders',
      address: 'Industrial Plot 45, Sector 18, Commercial Hub',
      phone: '+91 98765 43210',
      email: 'contact@xenobiz.com',
      gstin: '07AAAAA0000A1Z5',
      category: 'General',
      createdAt: DateTime.now(),
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(challan.challanNumber),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit',
            onPressed: () {
              context.push(RouteNames.createDeliveryChallan, extra: challan);
            },
          ),
          IconButton(
            icon: const Icon(Icons.print_outlined),
            tooltip: 'Print A4',
            onPressed: () {
              PdfDeliveryChallanService.printChallan(
                challan: challan,
                business: business,
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.share_outlined),
            tooltip: 'Share PDF',
            onPressed: () {
              PdfDeliveryChallanService.sharePdf(
                challan: challan,
                business: business,
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Header Card
            AppCard(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                    ),
                    child: const Icon(Icons.local_shipping_rounded,
                        color: AppColors.primaryBlue, size: 24),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'DOCUMENT TYPE',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: AppColors.secondaryText,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          challan.challanNumber,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: AppColors.darkBlueText,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildStatusChip(challan.status),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Party Details Section
            AppCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.person_pin_rounded,
                          size: 18, color: AppColors.primaryBlue),
                      SizedBox(width: 8),
                      Text(
                        'PARTY DETAILS',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: AppColors.darkBlueText,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 20),
                  _buildDetailRow('Customer Name',
                      challan.customerName.isNotEmpty ? challan.customerName : 'General Customer'),
                  if (challan.customerPhone.isNotEmpty)
                    _buildDetailRow('Phone', challan.customerPhone),
                  if (challan.customerAddress.isNotEmpty)
                    _buildDetailRow('Address', challan.customerAddress),
                  if (challan.customerGstin.isNotEmpty)
                    _buildDetailRow('GSTIN', challan.customerGstin),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Delivery Details Section
            AppCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.departure_board_rounded,
                          size: 18, color: AppColors.primaryBlue),
                      SizedBox(width: 8),
                      Text(
                        'DELIVERY DETAILS',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: AppColors.darkBlueText,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 20),
                  _buildDetailRow('Challan Date', dateFormatter.format(challan.issueDate)),
                  if (challan.deliveryDate != null)
                    _buildDetailRow('Delivery Date', dateFormatter.format(challan.deliveryDate!)),
                  if (challan.transporterName.isNotEmpty)
                    _buildDetailRow('Transporter', challan.transporterName),
                  if (challan.vehicleNumber.isNotEmpty)
                    _buildDetailRow('Vehicle No.', challan.vehicleNumber),
                  if (challan.placeOfSupply.isNotEmpty)
                    _buildDetailRow('Place of Supply', challan.placeOfSupply),
                  if (challan.referenceNumber.isNotEmpty)
                    _buildDetailRow('Ref / PO No.', challan.referenceNumber),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Items List Section
            AppCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.inventory_2_rounded,
                              size: 18, color: AppColors.primaryBlue),
                          SizedBox(width: 8),
                          Text(
                            'DISPATCHED ITEMS',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: AppColors.darkBlueText,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        'Total: ${challan.totalQuantity} Qty',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primaryBlue,
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 20),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: challan.items.length,
                    separatorBuilder: (_, __) => const Divider(height: 16),
                    itemBuilder: (ctx, idx) {
                      final item = challan.items[idx];
                      return Row(
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: AppColors.primaryBlue.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              '${idx + 1}',
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                color: AppColors.primaryBlue,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.productName,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.darkBlueText,
                                  ),
                                ),
                                if (item.hsnSac.isNotEmpty) ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    'HSN/SAC: ${item.hsnSac}',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: AppColors.secondaryText,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          Text(
                            '${item.quantity} ${item.unit}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: AppColors.darkBlueText,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Notes Section
            if (challan.notes.isNotEmpty) ...[
              AppCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'NOTES / REMARKS',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: AppColors.darkBlueText,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      challan.notes,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.secondaryText,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
            ],

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      PdfDeliveryChallanService.printChallan(
                        challan: challan,
                        business: business,
                      );
                    },
                    icon: const Icon(Icons.print_outlined, size: 18),
                    label: const Text('PRINT A4',
                        style: TextStyle(fontWeight: FontWeight.w800)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.danger,
                      side: const BorderSide(color: AppColors.danger),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () => _confirmDelete(context),
                    icon: const Icon(Icons.delete_outline, size: 18),
                    label: const Text('DELETE',
                        style: TextStyle(fontWeight: FontWeight.w800)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.secondaryText,
            ),
          ),
          const SizedBox(width: 16),
          Flexible(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.darkBlueText,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(DeliveryChallanStatus status) {
    Color bg;
    Color text;

    switch (status) {
      case DeliveryChallanStatus.delivered:
        bg = AppColors.success.withValues(alpha: 0.15);
        text = AppColors.success;
        break;
      case DeliveryChallanStatus.issued:
        bg = AppColors.primaryBlue.withValues(alpha: 0.15);
        text = AppColors.primaryBlue;
        break;
      case DeliveryChallanStatus.cancelled:
        bg = AppColors.danger.withValues(alpha: 0.15);
        text = AppColors.danger;
        break;
      case DeliveryChallanStatus.draft:
        bg = Colors.orange.withValues(alpha: 0.15);
        text = Colors.orange.shade800;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        status.label.toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: text,
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Delivery Challan?',
            style: TextStyle(fontWeight: FontWeight.w800)),
        content: Text(
            'Are you sure you want to delete Delivery Challan #${challan.challanNumber}? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              context
                  .read<DeliveryChallanBloc>()
                  .add(DeleteDeliveryChallanSubmittedEvent(challan.id));
              context.pop();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
