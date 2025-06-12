import 'package:flutter/material.dart';
import '../../../models/gstr9_model.dart';

class GSTR9SummaryWidget extends StatelessWidget {
  final GSTR9 gstr9Data;
  final VoidCallback? onEdit;
  final VoidCallback? onExport;

  const GSTR9SummaryWidget({
    Key? key,
    required this.gstr9Data,
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
            _buildPart1Card(),
            const SizedBox(height: 20),
            _buildPart2Card(),
            const SizedBox(height: 20),
            _buildPart3Card(),
            const SizedBox(height: 20),
            _buildPart4Card(),
            const SizedBox(height: 20),
            _buildPart5Card(),
            const SizedBox(height: 20),
            _buildPart6Card(),
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
                  'GSTR-9 Summary',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Financial Year: ${gstr9Data.financialYear}',
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
            _buildInfoRow('GSTIN', gstr9Data.gstin),
            _buildInfoRow('Financial Year', gstr9Data.financialYear),
            _buildInfoRow('Legal Name', gstr9Data.legalName),
            _buildInfoRow('Trade Name', gstr9Data.tradeName),
          ],
        ),
      ),
    );
  }

  Widget _buildPart1Card() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Part 1: Details of outward supplies',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildAmountRow('Total outward supplies', gstr9Data.part1.totalOutwardSupplies),
            _buildAmountRow('Zero-rated supplies', gstr9Data.part1.zeroRatedSupplies),
            _buildAmountRow('Nil-rated supplies', gstr9Data.part1.nilRatedSupplies),
            _buildAmountRow('Exempted supplies', gstr9Data.part1.exemptedSupplies),
            _buildAmountRow('Non-GST supplies', gstr9Data.part1.nonGSTSupplies),
          ],
        ),
      ),
    );
  }

  Widget _buildPart2Card() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Part 2: Details of inward supplies',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildAmountRow('Inward supplies attracting reverse charge', 
                          gstr9Data.part2.inwardSuppliesAttractingReverseCharge),
            _buildAmountRow('Imports of goods and services', 
                          gstr9Data.part2.importsOfGoodsAndServices),
            _buildAmountRow('Inward supplies liable to reverse charge', 
                          gstr9Data.part2.inwardSuppliesLiableToReverseCharge),
          ],
        ),
      ),
    );
  }

  Widget _buildPart3Card() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Part 3: Details of tax paid',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildAmountRow('Tax payable on outward supplies', 
                          gstr9Data.part3.taxPayableOnOutwardSupplies),
            _buildAmountRow('Tax payable on reverse charge', 
                          gstr9Data.part3.taxPayableOnReverseCharge),
            _buildAmountRow('Interest payable', gstr9Data.part3.interestPayable),
            _buildAmountRow('Late fee payable', gstr9Data.part3.lateFeePayable),
            _buildAmountRow('Penalty payable', gstr9Data.part3.penaltyPayable),
          ],
        ),
      ),
    );
  }

  Widget _buildPart4Card() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Part 4: Details of ITC availed',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildAmountRow('ITC Availed on Invoices', gstr9Data.part4.itcAvailedOnInvoices),
            _buildAmountRow('ITC Reversed and Reclaimed', gstr9Data.part4.itcReversedAndReclaimed),
            _buildAmountRow('ITC Availed but Ineligible', gstr9Data.part4.itcAvailedButIneligible),
          ],
        ),
      ),
    );
  }

  Widget _buildPart5Card() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Part 5: Details of Refunds',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildAmountRow('Refund Claimed', gstr9Data.part5.refundClaimed),
            _buildAmountRow('Refund Sanctioned', gstr9Data.part5.refundSanctioned),
            _buildAmountRow('Refund Rejected', gstr9Data.part5.refundRejected),
            _buildAmountRow('Refund Pending', gstr9Data.part5.refundPending),
          ],
        ),
      ),
    );
  }

  Widget _buildPart6Card() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Part 6: Tax, Interest, Late Fee, Penalties',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildAmountRow('Tax Payable as per Section 73 or 74', 
                          gstr9Data.part6.taxPayableAsPerSection73Or74),
            _buildAmountRow('Tax Paid as per Section 73 or 74', 
                          gstr9Data.part6.taxPaidAsPerSection73Or74),
            _buildAmountRow('Interest Payable as per Section 73 or 74', 
                          gstr9Data.part6.interestPayableAsPerSection73Or74),
            _buildAmountRow('Interest Paid as per Section 73 or 74', 
                          gstr9Data.part6.interestPaidAsPerSection73Or74),
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
            label: const Text('Edit GSTR-9'),
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
            label: const Text('Export GSTR-9'),
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
