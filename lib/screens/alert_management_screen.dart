import 'package:flutter/material.dart';
import 'package:flutter_invoice_app/providers/alert_provider.dart';
import 'package:flutter_invoice_app/widgets/alerts/alert_configuration_list_widget.dart';
import 'package:flutter_invoice_app/widgets/alerts/alert_list_widget.dart';
import 'package:provider/provider.dart';

class AlertManagementScreen extends StatefulWidget {
  const AlertManagementScreen({Key? key}) : super(key: key);

  @override
  State<AlertManagementScreen> createState() => _AlertManagementScreenState();
}

class _AlertManagementScreenState extends State<AlertManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Load data when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<AlertProvider>(context, listen: false);
      provider.loadAlertConfigurations();
      provider.loadAlertInstances();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Alert Management'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Active Alerts'),
            Tab(text: 'Alert Configurations'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: () {
              final provider = Provider.of<AlertProvider>(context, listen: false);
              provider.loadAlertConfigurations();
              provider.loadAlertInstances();
            },
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          AlertListWidget(),
          AlertConfigurationListWidget(),
        ],
      ),
    );
  }
}
