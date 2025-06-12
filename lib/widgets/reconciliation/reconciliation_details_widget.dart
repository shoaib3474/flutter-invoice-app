import 'package:flutter/material.dart';
import 'package:flutter_invoice_app/models/reconciliation/reconciliation_result_model.dart';
import 'package:intl/intl.dart';

class ReconciliationDetailsWidget extends StatelessWidget {
  final ReconciliationResult reconciliationResult;
  
  const ReconciliationDetailsWidget({
    super.key,
    required this.reconciliationResult,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(symbol: '₹', decimalDigits: 2);
    
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Reconciliation Details',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            
            // Filter controls
            Row(
              children: [
                const Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: 'Search',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                DropdownButton<MatchStatus>(
                  hint: const Text('Filter by Status'),
                  items: MatchStatus.values.map((status) {
                    return DropdownMenuItem<MatchStatus>(
                      value: status,
                      child: Text(_getMatchStatusText(status)),
                    );
                  }).toList(),
                  onChanged: (value) {
                    // Implement filtering
                  },
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Data table
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: _buildDataColumns(),
                    rows: _buildDataRows(currencyFormat),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  List<DataColumn> _buildDataColumns() {
    final columns = <DataColumn>[
      const DataColumn(label: Text('Invoice No.')),
      const DataColumn(label: Text('Date')),
      const DataColumn(label: Text('Counterparty')),
    ];
    
    // Add source-specific columns
    columns.add(DataColumn(label: Text('${_getSource1Name()} Taxable')));
    columns.add(DataColumn(label: Text('${_getSource1Name()} Tax')));
    
    columns.add(DataColumn(label: Text('${_getSource2Name()} Taxable')));
    columns.add(DataColumn(label: Text('${_getSource2Name()} Tax')));
    
    if (reconciliationResult.type == ReconciliationType.comprehensive) {
      columns.add(DataColumn(label: Text('${_getSource3Name()} Taxable')));
      columns.add(DataColumn(label: Text('${_getSource3Name()} Tax')));
    }
    
    columns.add(const DataColumn(label: Text('Difference')));
    columns.add(const DataColumn(label: Text('Status')));
    
    return columns;
  }
  
  List<DataRow> _buildDataRows(NumberFormat currencyFormat) {
    return reconciliationResult.items.map((item) {
      final cells = <DataCell>[
        DataCell(Text(item.invoiceNumber ?? 'N/A')),
        DataCell(Text(item.invoiceDate ?? 'N/A')),
        DataCell(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item.counterpartyName ?? 'N/A'),
              if (item.counterpartyGstin != null)
                Text(
                  item.counterpartyGstin ?? '',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
            ],
          ),
        ),
      ];
      
      // Source 1 values
      cells.add(DataCell(Text(
        item.taxableValueSource1 != null
            ? currencyFormat.format(item.taxableValueSource1!)
            : 'N/A',
      )));
      
      final source1Tax = (item.igstSource1 ?? 0) +
          (item.cgstSource1 ?? 0) +
          (item.sgstSource1 ?? 0);
      
      cells.add(DataCell(Text(
        source1Tax > 0 ? currencyFormat.format(source1Tax) : 'N/A',
      )));
      
      // Source 2 values
      cells.add(DataCell(Text(
        item.taxableValueSource2 != null
            ? currencyFormat.format(item.taxableValueSource2!)
            : 'N/A',
      )));
      
      final source2Tax = (item.igstSource2 ?? 0) +
          (item.cgstSource2 ?? 0) +
          (item.sgstSource2 ?? 0);
      
      cells.add(DataCell(Text(
        source2Tax > 0 ? currencyFormat.format(source2Tax) : 'N/A',
      )));
      
      // Source 3 values (for comprehensive reconciliation)
      if (reconciliationResult.type == ReconciliationType.comprehensive) {
        cells.add(DataCell(Text(
          item.taxableValueSource3 != null
              ? currencyFormat.format(item.taxableValueSource3!)
              : 'N/A',
        )));
        
        final source3Tax = (item.igstSource3 ?? 0) +
            (item.cgstSource3 ?? 0) +
            (item.sgstSource3 ?? 0);
        
        cells.add(DataCell(Text(
          source3Tax > 0 ? currencyFormat.format(source3Tax) : 'N/A',
        )));
      }
      
      // Difference
      double? taxDifference;
      if (source1Tax > 0 && source2Tax > 0) {
        taxDifference = (source1Tax - source2Tax).abs();
      }
      
      cells.add(DataCell(
        Text(
          taxDifference != null ? currencyFormat.format(taxDifference) : 'N/A',
          style: TextStyle(
            color: taxDifference != null && taxDifference > 0.01 ? Colors.red : null,
            fontWeight: taxDifference != null && taxDifference > 0.01 ? FontWeight.bold : null,
          ),
        ),
      ));
      
      // Status
      cells.add(DataCell(
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: _getStatusColor(item.matchStatus).withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            _getMatchStatusText(item.matchStatus),
            style: TextStyle(
              color: _getStatusColor(item.matchStatus),
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
        onTap: item.discrepancies?.isNotEmpty ?? false
            ? () {
                // Show discrepancies in a dialog
              }
            : null,
      ));
      
      return DataRow(cells: cells);
    }).toList();
  }
  
  String _getMatchStatusText(MatchStatus status) {
    switch (status) {
      case MatchStatus.matched:
        return 'Matched';
      case MatchStatus.partiallyMatched:
        return 'Partially Matched';
      case MatchStatus.mismatched:
        return 'Mismatched';
      case MatchStatus.onlyInSource1:
        return 'Only in ${_getSource1Name()}';
      case MatchStatus.onlyInSource2:
        return 'Only in ${_getSource2Name()}';
      case MatchStatus.onlyInSource3:
        return 'Only in ${_getSource3Name()}';
    }
  }
  
  Color _getStatusColor(MatchStatus status) {
    switch (status) {
      case MatchStatus.matched:
        return Colors.green;
      case MatchStatus.partiallyMatched:
        return Colors.orange;
      case MatchStatus.mismatched:
        return Colors.red;
      case MatchStatus.onlyInSource1:
        return Colors.purple;
      case MatchStatus.onlyInSource2:
        return Colors.teal;
      case MatchStatus.onlyInSource3:
        return Colors.indigo;
    }
  }
  
  String _getSource1Name() {
    switch (reconciliationResult.type) {
      case ReconciliationType.gstr1VsGstr2a:
        return 'GSTR-1';
      case ReconciliationType.gstr1VsGstr3b:
        return 'GSTR-1';
      case ReconciliationType.gstr2aVsGstr2b:
        return 'GSTR-2A';
      case ReconciliationType.gstr2bVsGstr3b:
        return 'GSTR-2B';
      case ReconciliationType.comprehensive:
        return 'GSTR-1';
    }
  }
  
  String _getSource2Name() {
    switch (reconciliationResult.type) {
      case ReconciliationType.gstr1VsGstr2a:
        return 'GSTR-2A';
      case ReconciliationType.gstr1VsGstr3b:
        return 'GSTR-3B';
      case ReconciliationType.gstr2aVsGstr2b:
        return 'GSTR-2B';
      case ReconciliationType.gstr2bVsGstr3b:
        return 'GSTR-3B';
      case ReconciliationType.comprehensive:
        return 'GSTR-3B';
    }
  }
  
  String _getSource3Name() {
    return 'GSTR-2B';
  }
}
