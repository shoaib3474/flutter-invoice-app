import 'package:flutter/material.dart';
import 'package:flutter_invoice_app/widgets/qrmp/qrmp_scheme_widget.dart';

class QRMPSchemeScreen extends StatelessWidget {
  const QRMPSchemeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QRMP Scheme'),
      ),
      body: const QRMPSchemeWidget(),
    );
  }
}
