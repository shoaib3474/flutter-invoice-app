import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/services/error_logger_service.dart';
import '../../../core/l10n/app_localizations.dart';
import '../widgets/crash_report_simulator_widget.dart';
import '../widgets/analytics_test_widget.dart';
import '../widgets/firebase_links_widget.dart';

class FirebaseMonitoringScreen extends StatefulWidget {
  const FirebaseMonitoringScreen({Key? key}) : super(key: key);

  @override
  State<FirebaseMonitoringScreen> createState() => _FirebaseMonitoringScreenState();
}

class _FirebaseMonitoringScreenState extends State<FirebaseMonitoringScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final ErrorLoggerService _errorLogger = ErrorLoggerService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _errorLogger.logInfo('Firebase Monitoring Screen opened');
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.firebaseMonitoring),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: [
            Tab(icon: Icon(Icons.bug_report), text: l10n.crashlytics),
            Tab(icon: Icon(Icons.analytics), text: l10n.analytics),
            Tab(icon: Icon(Icons.science), text: l10n.testTools),
            Tab(icon: Icon(Icons.link), text: l10n.quickLinks),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {});
              _errorLogger.logInfo('Firebase monitoring refreshed');
            },
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildCrashlyticsTab(context),
          _buildAnalyticsTab(context),
          _buildTestToolsTab(context),
          _buildQuickLinksTab(context),
        ],
      ),
    );
  }

  Widget _buildCrashlyticsTab(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoCard(
            title: l10n.crashReports,
            icon: Icons.bug_report,
            color: Colors.red,
            children: [
              Text(l10n.crashReportsDescription),
              const SizedBox(height: 16),
              _buildMetricRow(l10n.crashFreeUsers, '99.2%', Colors.green),
              _buildMetricRow(l10n.totalCrashes, '12', Colors.orange),
              _buildMetricRow(l10n.affectedUsers, '3', Colors.red),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => _openFirebaseConsole('crashlytics'),
                icon: const Icon(Icons.open_in_new),
                label: Text(l10n.openCrashlytics),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildRecentCrashesCard(context),
          const SizedBox(height: 16),
          _buildCrashTrendsCard(context),
        ],
      ),
    );
  }

  Widget _buildAnalyticsTab(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoCard(
            title: l10n.analyticsOverview,
            icon: Icons.analytics,
            color: Colors.blue,
            children: [
              Text(l10n.analyticsDescription),
              const SizedBox(height: 16),
              _buildMetricRow(l10n.activeUsers, '1,234', Colors.blue),
              _buildMetricRow(l10n.sessions, '5,678', Colors.green),
              _buildMetricRow(l10n.screenViews, '12,345', Colors.purple),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => _openFirebaseConsole('analytics'),
                icon: const Icon(Icons.open_in_new),
                label: Text(l10n.openAnalytics),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildTopEventsCard(context),
          const SizedBox(height: 16),
          _buildUserJourneyCard(context),
        ],
      ),
    );
  }

  Widget _buildTestToolsTab(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          CrashReportSimulatorWidget(),
          const SizedBox(height: 16),
          AnalyticsTestWidget(),
        ],
      ),
    );
  }

  Widget _buildQuickLinksTab(BuildContext context) {
    return const SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          FirebaseLinksWidget(),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required IconData icon,
    required Color color,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildMetricRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color.withOpacity(0.3)),
            ),
            child: Text(
              value,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentCrashesCard(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    return _buildInfoCard(
      title: l10n.recentCrashes,
      icon: Icons.history,
      color: Colors.orange,
      children: [
        _buildCrashItem(
          'AuthenticationException',
          'Login failed with invalid credentials',
          '2 hours ago',
          3,
        ),
        _buildCrashItem(
          'NetworkException',
          'Failed to connect to GST API',
          '5 hours ago',
          1,
        ),
        _buildCrashItem(
          'ValidationException',
          'Invalid GSTIN format',
          '1 day ago',
          2,
        ),
      ],
    );
  }

  Widget _buildCrashItem(String type, String message, String time, int count) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                type,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$count',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            message,
            style: const TextStyle(fontSize: 12),
          ),
          const SizedBox(height: 4),
          Text(
            time,
            style: const TextStyle(
              fontSize: 10,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCrashTrendsCard(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    return _buildInfoCard(
      title: l10n.crashTrends,
      icon: Icons.trending_up,
      color: Colors.purple,
      children: [
        Container(
          height: 200,
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.show_chart, size: 48, color: Colors.grey),
                SizedBox(height: 8),
                Text(
                  'Crash trends chart\n(View in Firebase Console)',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTopEventsCard(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    return _buildInfoCard(
      title: l10n.topEvents,
      icon: Icons.event,
      color: Colors.green,
      children: [
        _buildEventItem('screen_view', 'login_screen', 1234),
        _buildEventItem('user_action', 'invoice_created', 567),
        _buildEventItem('user_action', 'gst_return_filed', 234),
        _buildEventItem('app_error', 'network_timeout', 12),
      ],
    );
  }

  Widget _buildEventItem(String category, String name, int count) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                category,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$count',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserJourneyCard(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    return _buildInfoCard(
      title: l10n.userJourney,
      icon: Icons.timeline,
      color: Colors.teal,
      children: [
        _buildJourneyStep('App Launch', '100%', true),
        _buildJourneyStep('Login Screen', '85%', true),
        _buildJourneyStep('Dashboard', '78%', true),
        _buildJourneyStep('Invoice Creation', '45%', false),
        _buildJourneyStep('GST Filing', '23%', false),
      ],
    );
  }

  Widget _buildJourneyStep(String step, String percentage, bool isGood) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            isGood ? Icons.check_circle : Icons.warning,
            color: isGood ? Colors.green : Colors.orange,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(step)),
          Text(
            percentage,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isGood ? Colors.green : Colors.orange,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openFirebaseConsole(String section) async {
    final projectId = 'your-firebase-project-id'; // Replace with your project ID
    final url = 'https://console.firebase.google.com/project/$projectId/$section';
    
    try {
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
        _errorLogger.logInfo('Opened Firebase Console: $section');
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Could not open Firebase Console'),
              action: SnackBarAction(
                label: 'Copy URL',
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: url));
                },
              ),
            ),
          );
        }
      }
    } catch (e, stackTrace) {
      _errorLogger.logError(
        'Failed to open Firebase Console',
        error: e,
        stackTrace: stackTrace,
        additionalData: {'section': section, 'url': url},
      );
    }
  }
}
