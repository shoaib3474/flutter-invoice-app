import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/gstin_tracking_provider.dart';
import '../widgets/gstin/gstin_search_widget.dart';
import '../widgets/gstin/gstin_details_widget.dart';
import '../widgets/gstin/filing_status_indicator_widget.dart';
import '../widgets/gstin/filing_status_legend_widget.dart';
import '../widgets/gstin/gstr_filing_chart_widget.dart';
import '../models/gstin/gstin_details_model.dart';

class GstinTrackingScreen extends StatefulWidget {
  const GstinTrackingScreen({Key? key}) : super(key: key);

  @override
  _GstinTrackingScreenState createState() => _GstinTrackingScreenState();
}

class _GstinTrackingScreenState extends State<GstinTrackingScreen> {
  String? _selectedGstin;
  GstinDetailsModel? _gstinDetails;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
  }

  void _onGstinSelected(String gstin) async {
    setState(() {
      _selectedGstin = gstin;
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final provider = Provider.of<GstinTrackingProvider>(context, listen: false);
      final details = await provider.getGstinDetails(gstin);
      setState(() {
        _gstinDetails = details;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error fetching GSTIN details: $e';
        _isLoading = false;
      });
    }
  }

  void _trackGstin() async {
    if (_selectedGstin == null) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final provider = Provider.of<GstinTrackingProvider>(context, listen: false);
      await provider.trackGstin(_selectedGstin!);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('GSTIN tracking enabled'),
          duration: Duration(seconds: 2),
        ),
      );
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error tracking GSTIN: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GSTIN Tracking'),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () {
              // Show help dialog
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('GSTIN Tracking Help'),
                  content: const SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('This screen allows you to:'),
                        SizedBox(height: 8),
                        Text('• Search for a GSTIN'),
                        Text('• View GSTIN details'),
                        Text('• Track filing status'),
                        Text('• View jurisdiction information'),
                        SizedBox(height: 16),
                        Text('To start, enter a valid GSTIN in the search box.'),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Close'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GstinSearchWidget(
              onGstinSelected: _onGstinSelected,
            ),
            const SizedBox(height: 16),
            if (_isLoading)
              const Center(
                child: CircularProgressIndicator(),
              )
            else if (_errorMessage != null)
              Card(
                color: Colors.red.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: Colors.red.shade700),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(color: Colors.red.shade700),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else if (_gstinDetails != null) ...[
              GstinDetailsWidget(
                details: _gstinDetails!,
                onTrackGstin: _trackGstin,
              ),
              const SizedBox(height: 16),
              if (_selectedGstin != null) ...[
                const Text(
                  'Filing Status',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Consumer<GstinTrackingProvider>(
                  builder: (context, provider, child) {
                    final isTracking = provider.isGstinTracked(_selectedGstin!);
                    if (!isTracking) {
                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              const Text(
                                'Enable tracking to view filing status',
                                style: TextStyle(fontSize: 16),
                              ),
                              const SizedBox(height: 8),
                              ElevatedButton.icon(
                                onPressed: _trackGstin,
                                icon: const Icon(Icons.track_changes),
                                label: const Text('Track GSTIN'),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    final filingHistory = provider.getFilingHistory(_selectedGstin!);
                    if (filingHistory == null || filingHistory.isEmpty) {
                      return const Card(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text('No filing history available yet'),
                        ),
                      );
                    }

                    return Column(
                      children: [
                        FilingStatusLegendWidget(),
                        const SizedBox(height: 16),
                        GstrFilingChartWidget(
                          gstin: _selectedGstin!,
                          filingHistory: filingHistory,
                        ),
                      ],
                    );
                  },
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}
