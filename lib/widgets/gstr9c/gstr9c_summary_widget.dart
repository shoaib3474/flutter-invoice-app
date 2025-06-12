import 'package:flutter/material.dart';
import '../../../models/gstr9c_model.dart';

class GSTR9CSummaryWidget extends StatelessWidget {
  final GSTR9C gstr9cData;
  final VoidCallback? onEdit;
  final VoidCallback? onExport;

  const GSTR9CSummaryWidget({
    Key? key,
    required this.gstr9cData,
    this.onEdit,
    this.onExport,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const SizedBox(height: 20),
            _buildBasicInfoCard(),
            const SizedBox(height: 20),
            _buildReconciliationCard(),
            const SizedBox(height: 20),
            _buildAuditorRecommendationCard(),
            const SizedBox(height: 20),
            _buildTaxPayableCard(),
            const SizedBox(height: 20),
            _buildAuditorDetailsCard(),
            const SizedBox(height: 20),
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Card(
      elevation: 3,
      color: Theme.of(context).primaryColor,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(Icons.summarize, color: Colors.white, size: 36),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'GSTR-9C Summary',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Financial Year: ${gstr9cData.financialYear}',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInfoCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Basic Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow('GSTIN', gstr9cData.gstin),
            _buildInfoRow('Financial Year', gstr9cData.financialYear),
            _buildInfoRow('Legal Name', gstr9cData.legalName),
            _buildInfoRow('Trade Name', gstr9cData.tradeName),
          ],
        ),
      ),
    );
  }

  Widget _buildReconciliationCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Reconciliation of Turnover',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildAmountRow('Turnover as per Audited Financial Statements', 
                          gstr9cData.reconciliation.turnoverAsPerAuditedFinancialStatements),
            _buildAmountRow('Turnover as per Annual Return', 
                          gstr9cData.reconciliation.turnoverAsPerAnnualReturn),
            _buildAmountRow('Un-reconciled Turnover', 
                          gstr9cData.reconciliation.unReconciled),
            
            if (gstr9cData.reconciliation.reconciliationItems.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text(
                'Reconciliation Items',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              ...gstr9cData.reconciliation.reconciliationItems.map((item) => 
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Card(
                    margin: EdgeInsets.zero,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.description,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Amount:'),
                              Text(
                                '₹ ${item.amount.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text('Reason: ${item.reason}'),
                        ],
                      ),
                    ),
                  ),
                ),
              ).toList(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAuditorRecommendationCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Auditor\'s Recommendation',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            if (gstr9cData.auditorRecommendation.recommendations.isEmpty)
              const Text('No recommendations provided.'),
              
            ...gstr9cData.auditorRecommendation.recommendations.map((item) => 
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Card(
                  margin: EdgeInsets.zero,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.description,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Amount:'),
                            Text(
                              '₹ ${item.amount.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text('Reason: ${item.reason}'),
                      ],
                    ),
                  ),
                ),
              ),
            ).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildTaxPayableCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tax Payable',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildAmountRow('Tax Payable as per Reconciliation', 
                          gstr9cData.taxPayable.taxPayableAsPerReconciliation),
            _buildAmountRow('Tax Paid as per Annual Return', 
                          gstr9cData.taxPayable.taxPaidAsPerAnnualReturn),
            _buildAmountRow('Differential Tax Payable', 
                          gstr9cData.taxPayable.differentialTaxPayable),
            _buildAmountRow('Interest Payable', 
                          gstr9cData.taxPayable.interestPayable),
          ],
        ),
      ),
    );
  }

  Widget _buildAuditorDetailsCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Auditor Details & Certification',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Auditor Details', gstr9cData.auditorDetails),
            const SizedBox(height: 8),
            _buildInfoRow('Certification Details', gstr9cData.certificationDetails),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmountRow(String label, double amount) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            '₹ ${amount.toStringAsFixed(2)}',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        if (onEdit != null)
          ElevatedButton.icon(
            onPressed: onEdit,
            icon: const Icon(Icons.edit),
            label: const Text('Edit GSTR-9C'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
          ),
        if (onExport != null)
          ElevatedButton.icon(
            onPressed: onExport,
            icon: const Icon(Icons.upload_file),
            label: const Text('Export GSTR-9C'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColorDark,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
          ),
      ],
    );
  }
}
