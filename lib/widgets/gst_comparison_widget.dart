import 'package:flutter/material.dart';
import 'package:flutter_invoice_app/models/gst_comparison_model.dart';
import 'package:flutter_invoice_app/services/gst_comparison_service.dart';

class GSTComparisonWidget extends StatefulWidget {
  const GSTComparisonWidget({
    super.key,
    required this.gstin,
    required this.returnPeriod,
    required this.returnType,
  });

  final String gstin;
  final String returnPeriod;
  final String returnType;

  @override
  State<GSTComparisonWidget> createState() => _GSTComparisonWidgetState();
}

class _GSTComparisonWidgetState extends State<GSTComparisonWidget> {
  final GSTComparisonService _service = GSTComparisonService();
  List<GSTComparisonModel> _comparisons = [];
  bool _isLoading = false;
  final String _selectedPeriod = '';

  @override
  void initState() {
    super.initState();
    _loadComparisons();
  }

  Future<void> _loadComparisons() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final comparisons = await _service.compareGSTReturns(
        widget.gstin,
        widget.returnPeriod,
        widget.returnType,
      );
      
      setState(() {
        _comparisons = comparisons;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading comparisons: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_comparisons.isEmpty) {
      return const Center(
        child: Text('No comparison data available'),
      );
    }

    return ListView.builder(
      itemCount: _comparisons.length,
      itemBuilder: (context, index) {
        final comparison = _comparisons[index];
        return Card(
          child: ListTile(
            title: Text(comparison.description),
            subtitle: Text('Period: ${comparison.period}'),
            trailing: Text(
              '₹${comparison.amount.toStringAsFixed(2)}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        );
      },
    );
  }
}
