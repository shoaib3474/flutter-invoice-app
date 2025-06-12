import 'package:flutter/material.dart';
import '../widgets/hsn_sac/hsn_sac_search_widget.dart';
import '../models/hsn_sac/hsn_sac_model.dart';

class HsnSacLookupScreen extends StatefulWidget {
  const HsnSacLookupScreen({Key? key}) : super(key: key);

  @override
  _HsnSacLookupScreenState createState() => _HsnSacLookupScreenState();
}

class _HsnSacLookupScreenState extends State<HsnSacLookupScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  HsnSacModel? _selectedHsnCode;
  HsnSacModel? _selectedSacCode;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  void _onHsnCodeSelected(HsnSacModel code) {
    setState(() {
      _selectedHsnCode = code;
    });
  }

  void _onSacCodeSelected(HsnSacModel code) {
    setState(() {
      _selectedSacCode = code;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('HSN/SAC Code Lookup'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'HSN Codes'),
            Tab(text: 'SAC Codes'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () {
              // Show help dialog
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('HSN/SAC Code Lookup Help'),
                  content: const SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('This screen allows you to:'),
                        SizedBox(height: 8),
                        Text('• Search for HSN codes (for goods)'),
                        Text('• Search for SAC codes (for services)'),
                        Text('• View code details and GST rates'),
                        SizedBox(height: 16),
                        Text('To start, enter a code or description in the search box.'),
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
      body: TabBarView(
        controller: _tabController,
        children: [
          // HSN Tab
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                HsnSacSearchWidget(
                  onCodeSelected: _onHsnCodeSelected,
                  isSacMode: false,
                ),
                if (_selectedHsnCode != null) ...[
                  const SizedBox(height: 24),
                  const Text(
                    'Selected HSN Code Details',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildCodeDetailsCard(_selectedHsnCode!),
                ],
              ],
            ),
          ),
          
          // SAC Tab
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                HsnSacSearchWidget(
                  onCodeSelected: _onSacCodeSelected,
                  isSacMode: true,
                ),
                if (_selectedSacCode != null) ...[
                  const SizedBox(height: 24),
                  const Text(
                    'Selected SAC Code Details',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildCodeDetailsCard(_selectedSacCode!),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCodeDetailsCard(HsnSacModel code) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              code.isSac ? 'SAC: ${code.code}' : 'HSN: ${code.code}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(),
            _buildInfoRow('Description', code.description),
            _buildInfoRow('GST Rate', '${code.gstRate}%'),
            if (code.chapter != null)
              _buildInfoRow('Chapter', code.chapter!),
            if (code.section != null)
              _buildInfoRow('Section', code.section!),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
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

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
