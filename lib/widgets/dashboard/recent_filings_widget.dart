import 'package:flutter/material.dart';
import 'package:flutter_invoice_app/models/gst_returns/gst_return_summary.dart';
import 'package:flutter_invoice_app/utils/date_formatter.dart';
import 'package:flutter_invoice_app/widgets/gstin/filing_status_indicator_widget.dart';

class RecentFilingsWidget extends StatelessWidget {
  final List<GstReturnSummary> recentFilings;
  
  const RecentFilingsWidget({
    Key? key,
    required this.recentFilings,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: recentFilings.isEmpty
            ? const Center(
                child: Text(
                  'No recent filings',
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),
              )
            : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: recentFilings.length,
                itemBuilder: (context, index) {
                  final filing = recentFilings[index];
                  
                  return ListTile(
                    title: Text(filing.getTypeDisplayName()),
                    subtitle: Text('Period: ${filing.period}'),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          DateFormatter.formatDate(filing.filingDate),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        FilingStatusIndicatorWidget(
                          status: filing.status,
                          showLabel: true,
                        ),
                      ],
                    ),
                    leading: const Icon(Icons.description),
                    onTap: () {
                      // Navigate to filing details
                    },
                  );
                },
              ),
      ),
    );
  }
}
