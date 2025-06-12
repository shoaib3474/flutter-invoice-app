import 'package:flutter/material.dart';
import 'package:flutter_invoice_app/models/person/person_transaction_model.dart';
import 'package:intl/intl.dart';

class PersonPurchasesWidget extends StatelessWidget {
  final List<PersonTransaction> transactions;
  
  const PersonPurchasesWidget({
    Key? key,
    required this.transactions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM yyyy');
    final currencyFormat = NumberFormat.currency(symbol: '₹', decimalDigits: 2);
    
    if (transactions.isEmpty) {
      return const Center(
        child: Text('No purchase transactions found'),
      );
    }
    
    return ListView.builder(
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        final transaction = transactions[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            title: Text(
              transaction.invoiceNumber,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              dateFormat.format(transaction.date),
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  currencyFormat.format(transaction.amount),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Tax: ${currencyFormat.format(transaction.taxAmount)}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            leading: CircleAvatar(
              backgroundColor: Colors.blue.shade100,
              child: const Icon(
                Icons.arrow_downward,
                color: Colors.blue,
              ),
            ),
          ),
        );
      },
    );
  }
}
