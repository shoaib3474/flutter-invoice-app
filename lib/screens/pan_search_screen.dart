import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/gstin_tracking_provider.dart';
import '../widgets/pan/pan_search_widget.dart';
import '../models/gstin/gstin_details_model.dart';
import '../widgets/gstin/gstin_details_widget.dart';

class PanSearchScreen extends StatefulWidget {
  const PanSearchScreen({Key? key}) : super(key: key);

  @override
  _PanSearchScreenState createState() => _PanSearchScreenState();
}

class _PanSearchScreenState extends State<PanSearchScreen> {
  String? _selectedPan;
  List<GstinDetailsModel> _gstinList = [];
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
  }

  void _onPanSelected(String pan) async {
    setState(() {
      _selectedPan = pan;
      _isLoading = true;
      _errorMessage = null;
      _gstinList = [];
    });

    try {
      final provider = Provider.of<GstinTrackingProvider>(context, listen: false);
      final gstinList = await provider.getGstinsByPan(pan);
      setState(() {
        _gstinList = gstinList;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error fetching GSTINs for PAN: $e';
        _isLoading = false;
      });
    }
  }

  void _trackGstin(String gstin) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final provider = Provider.of<GstinTrackingProvider>(context, listen: false);
      await provider.trackGstin(gstin);
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
        title: const Text('PAN Search'),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () {
              // Show help dialog
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('PAN Search Help'),
                  content: const SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('This screen allows you to:'),
                        SizedBox(height: 8),
                        Text('• Search for a PAN'),
                        Text('• View all GSTINs registered with this PAN'),
                        Text('• View GSTIN details'),
                        Text('• Track filing status for any GSTIN'),
                        SizedBox(height: 16),
                        Text('To start, enter a valid PAN in the search box.'),
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
            PanSearchWidget(
              onPanSelected: _onPanSelected,
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
            else if (_selectedPan != null) ...[
              Text(
                'GSTINs for PAN: $_selectedPan',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              if (_gstinList.isEmpty)
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text('No GSTINs found for this PAN'),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _gstinList.length,
                  itemBuilder: (context, index) {
                    final gstin = _gstinList[index];
                    return GstinDetailsWidget(
                      details: gstin,
                      onTrackGstin: () => _trackGstin(gstin.gstin),
                    );
                  },
                ),
            ],
          ],
        ),
      ),
    );
  }
}
