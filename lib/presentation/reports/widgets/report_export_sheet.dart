import 'package:flutter/material.dart';
import '../../../const/colors.dart';

// ============================================================================
// REUSABLE REPORT PDF EXPORT / DOWNLOAD / SHARE / SAVE SHEET
// ============================================================================

void showReportPdfExportModal(
  BuildContext context, {
  required String reportTitle,
  String? period,
  String? filterSummary,
}) {
  final fileName = '${reportTitle.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_')}_Statement.pdf';

  showModalBottomSheet(
    context: context,
    backgroundColor: AppColors.surfaceCard,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (ctx) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Export $reportTitle',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.darkBlueText,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.pageBackground,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Document: $fileName',
                      style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                          color: AppColors.darkBlueText)),
                  if (period != null && period.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text('Period: $period',
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.secondaryText)),
                  ],
                  if (filterSummary != null && filterSummary.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text('Filters: $filterSummary',
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.secondaryText)),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.download_rounded, color: AppColors.primaryBlue),
              title: const Text('Download PDF Statement',
                  style: TextStyle(fontWeight: FontWeight.w700)),
              subtitle: Text('Save $fileName to Downloads'),
              onTap: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Downloaded $fileName'),
                    backgroundColor: AppColors.success,
                  ),
                );
              },
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.share_outlined, color: Colors.green),
              title: const Text('Share PDF via WhatsApp / Email',
                  style: TextStyle(fontWeight: FontWeight.w700)),
              subtitle: const Text('Share report document with partners or CA'),
              onTap: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Sharing $fileName...'),
                    backgroundColor: AppColors.success,
                  ),
                );
              },
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.print_outlined, color: Colors.deepOrange),
              title: const Text('Print PDF Document',
                  style: TextStyle(fontWeight: FontWeight.w700)),
              subtitle: const Text('Print statement via connected thermal or A4 printer'),
              onTap: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Sending $fileName to printer...'),
                    backgroundColor: AppColors.primaryBlue,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    ),
  );
}
