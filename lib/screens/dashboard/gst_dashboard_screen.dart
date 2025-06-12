import 'package:flutter/material.dart';
import 'package:flutter_invoice_app/models/gst_returns/gst_return_summary.dart';
import 'package:flutter_invoice_app/services/gst_returns/gst_returns_service.dart';
import 'package:flutter_invoice_app/utils/date_formatter.dart';
import 'package:flutter_invoice_app/utils/number_formatter.dart';
import 'package:flutter_invoice_app/widgets/common/loading_indicator.dart';
import 'package:flutter_invoice_app/widgets/dashboard/compliance_score_widget.dart';
import 'package:flutter_invoice_app/widgets/dashboard/filing_status_chart_widget.dart';
import 'package:flutter_invoice_app/widgets/dashboard/gst_summary_card_widget.dart';
import 'package:flutter_invoice_app/widgets/dashboard/recent_filings_widget.dart';
import 'package:flutter_invoice_app/widgets/dashboard/tax_liability_chart_widget.dart';
import 'package:flutter_invoice_app/widgets/gstin/filing_status_legend_widget.dart';

class GstDashboardScreen extends StatefulWidget {
  const GstDashboardScreen({Key? key}) : super(key: key);

  @override
  State<GstDashboardScreen> createState() => _GstDashboardScreenState();
}

class _GstDashboardScreenState extends State<GstDashboardScreen> {
  final _gstReturnsService = GstReturnsService();
  
  bool _isLoading = true;
  String _errorMessage = '';
  
  // Dashboard data
  List<GstReturnSummary> _recentFilings = [];
  Map<String, dynamic> _dashboardData = {};
  
  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }
  
  Future<void> _loadDashboardData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    
    try {
      final dashboardData = await _gstReturnsService.getDashboardData();
      final recentFilings = await _gstReturnsService.getRecentFilings();
      
      setState(() {
        _dashboardData = dashboardData;
        _recentFilings = recentFilings;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GST Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDashboardData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: LoadingIndicator())
          : _errorMessage.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 48,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Error loading dashboard',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _errorMessage,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadDashboardData,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadDashboardData,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // GST Summary Cards
                        _buildSectionTitle('GST Summary'),
                        const SizedBox(height: 16),
                        _buildGstSummaryCards(),
                        const SizedBox(height: 24),
                        
                        // Compliance Score
                        _buildSectionTitle('Compliance Score'),
                        const SizedBox(height: 16),
                        ComplianceScoreWidget(
                          score: _dashboardData['compliance_score'] ?? 0,
                        ),
                        const SizedBox(height: 24),
                        
                        // Filing Status Chart
                        _buildSectionTitle('Filing Status'),
                        const SizedBox(height: 8),
                        const FilingStatusLegendWidget(),
                        const SizedBox(height: 16),
                        FilingStatusChartWidget(
                          filingStatusData: _dashboardData['filing_status_data'] ?? {},
                        ),
                        const SizedBox(height: 24),
                        
                        // Tax Liability Chart
                        _buildSectionTitle('Tax Liability Trend'),
                        const SizedBox(height: 16),
                        TaxLiabilityChartWidget(
                          taxLiabilityData: _dashboardData['tax_liability_data'] ?? [],
                        ),
                        const SizedBox(height: 24),
                        
                        // Recent Filings
                        _buildSectionTitle('Recent Filings'),
                        const SizedBox(height: 16),
                        RecentFilingsWidget(
                          recentFilings: _recentFilings,
                        ),
                        const SizedBox(height: 24),
                        
                        // Due Dates
                        _buildSectionTitle('Upcoming Due Dates'),
                        const SizedBox(height: 16),
                        _buildDueDatesCard(),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
    );
  }
  
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }
  
  Widget _buildGstSummaryCards() {
    final summaryData = _dashboardData['summary'] ?? {};
    
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        GstSummaryCardWidget(
          title: 'Total Tax Liability',
          amount: summaryData['total_tax_liability'] ?? 0,
          icon: Icons.account_balance,
          color: Colors.blue,
        ),
        GstSummaryCardWidget(
          title: 'Tax Paid',
          amount: summaryData['tax_paid'] ?? 0,
          icon: Icons.payment,
          color: Colors.green,
        ),
        GstSummaryCardWidget(
          title: 'Input Tax Credit',
          amount: summaryData['input_tax_credit'] ?? 0,
          icon: Icons.credit_card,
          color: Colors.purple,
        ),
        GstSummaryCardWidget(
          title: 'Balance',
          amount: summaryData['balance'] ?? 0,
          icon: Icons.account_balance_wallet,
          color: Colors.orange,
        ),
      ],
    );
  }
  
  Widget _buildDueDatesCard() {
    final dueDates = _dashboardData['due_dates'] ?? [];
    
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: dueDates.isEmpty
            ? const Center(
                child: Text(
                  'No upcoming due dates',
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),
              )
            : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: dueDates.length,
                itemBuilder: (context, index) {
                  final dueDate = dueDates[index];
                  final date = DateTime.parse(dueDate['date']);
                  final daysLeft = date.difference(DateTime.now()).inDays;
                  
                  return ListTile(
                    title: Text(dueDate['return_type']),
                    subtitle: Text('Period: ${dueDate['period']}'),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          DateFormatter.formatDate(date),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: daysLeft < 5
                                ? Colors.red.shade100
                                : daysLeft < 10
                                    ? Colors.orange.shade100
                                    : Colors.green.shade100,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            daysLeft == 0
                                ? 'Due today'
                                : daysLeft < 0
                                    ? 'Overdue'
                                    : '$daysLeft days left',
                            style: TextStyle(
                              fontSize: 12,
                              color: daysLeft < 5
                                  ? Colors.red.shade900
                                  : daysLeft < 10
                                      ? Colors.orange.shade900
                                      : Colors.green.shade900,
                            ),
                          ),
                        ),
                      ],
                    ),
                    leading: Icon(
                      Icons.event,
                      color: daysLeft < 5
                          ? Colors.red
                          : daysLeft < 10
                              ? Colors.orange
                              : Colors.green,
                    ),
                  );
                },
              ),
      ),
    );
  }
}
