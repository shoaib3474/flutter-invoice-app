import 'package:flutter/material.dart';
import 'package:flutter_invoice_app/providers/alert_provider.dart';
import 'package:provider/provider.dart';

class AlertBadgeWidget extends StatelessWidget {
  final Widget child;
  final VoidCallback onTap;

  const AlertBadgeWidget({
    Key? key,
    required this.child,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<AlertProvider>(
      builder: (context, provider, _) {
        final unacknowledgedCount = provider.unacknowledgedCount;

        return Stack(
          alignment: Alignment.center,
          children: [
            child,
            if (unacknowledgedCount > 0)
              Positioned(
                top: 0,
                right: 0,
                child: GestureDetector(
                  onTap: onTap,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      unacknowledgedCount > 99 ? '99+' : '$unacknowledgedCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
