import 'package:flutter/material.dart';
import 'package:flutter_invoice_app/models/person/person_transaction_model.dart';
import 'package:flutter_invoice_app/utils/responsive_helper.dart';
import 'package:flutter_invoice_app/widgets/person/person_sales_widget.dart';
import 'package:flutter_invoice_app/widgets/person/person_purchases_widget.dart';
import 'package:flutter_invoice_app/widgets/person/person_search_widget.dart';
import 'package:flutter_invoice_app/widgets/person/person_summary_widget.dart';
import 'package:intl/intl.dart';

class PersonDetailScreen extends StatefulWidget {
  const PersonDetailScreen({Key? key}) : super(key: key);

  @override
  State<PersonDetailScreen> createState() => _PersonDetailScreenState();
}

class _PersonDetailScreenState extends State<PersonDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? _selectedPersonId;
  String? _selectedPersonName;
  bool _isLoading = false;
  String? _error;
  List<PersonTransaction> _transactions = [];
  final currencyFormat = NumberFormat.currency(symbol: '₹', decimalDigits: 2);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onPersonSelected(String id, String name) {
    setState(() {
      _selectedPersonId = id;
      _selectedPersonName = name;
      _isLoading = true;
      _error = null;
    });

    // Simulate loading data
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _isLoading = false;
        _transactions = _generateDemoTransactions(id);
      });
    });
  }

  List<PersonTransaction> _generateDemoTransactions(String personId) {
    final random = DateTime.now().millisecondsSinceEpoch % 10;
    final count = 5 + random;
    final transactions = <PersonTransaction>[];

    for (int i = 0; i < count; i++) {
      final isSale = i % 2 == 0;
      final date = DateTime.now().subtract(Duration(days: i * 5));
      final amount = (10000 + (random * 1000) + (i * 1000)) / 100;

      transactions.add(
        PersonTransaction(
          id: 'TRX${date.millisecondsSinceEpoch}',
          personId: personId,
          type: isSale ? TransactionType.sale : TransactionType.purchase,
          date: date,
          invoiceNumber: 'INV${date.year}${date.month}${date.day}${i + 1}',
          amount: amount,
          taxAmount: amount * 0.18,
          status: i % 5 == 0 ? TransactionStatus.pending : TransactionStatus.completed,
        ),
      );
    }

    return transactions;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_selectedPersonName ?? 'Person Details'),
        bottom: _selectedPersonId != null
            ? TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: 'Sales'),
                  Tab(text: 'Purchases'),
                ],
              )
            : null,
      ),
      body: ResponsiveBuilder(
        builder: (context, deviceType) {
          return Padding(
            padding: ResponsiveHelper.getScreenPadding(context),
            child: Column(
              children: [
                // Person Search
                PersonSearchWidget(
                  onPersonSelected: _onPersonSelected,
                ),
                const SizedBox(height: 16),

                // Content
                if (_selectedPersonId == null)
                  const Expanded(
                    child: Center(
                      child: Text('Search for a person to view their details'),
                    ),
                  )
                else if (_isLoading)
                  const Expanded(
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  )
                else if (_error != null)
                  Expanded(
                    child: Center(
                      child: Text(_error!),
                    ),
                  )
                else
                  Expanded(
                    child: Column(
                      children: [
                        // Summary
                        PersonSummaryWidget(
                          transactions: _transactions,
                        ),
                        const SizedBox(height: 16),

                        // Tabs
                        Expanded(
                          child: TabBarView(
                            controller: _tabController,
                            children: [
                              // Sales Tab
                              PersonSalesWidget(
                                transactions: _transactions
                                    .where((t) => t.type == TransactionType.sale)
                                    .toList(),
                              ),

                              // Purchases Tab
                              PersonPurchasesWidget(
                                transactions: _transactions
                                    .where((t) => t.type == TransactionType.purchase)
                                    .toList(),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
