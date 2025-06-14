import 'package:go_router/go_router.dart';
import '../../screens/invoice/invoice_list_screen.dart';
import '../../screens/invoice/invoice_form_screen.dart';
import '../../screens/invoice/invoice_detail_screen.dart';

class InvoiceRoutes {
  static List<GoRoute> get routes => [
        GoRoute(
          path: 'invoices',
          name: 'invoices',
          builder: (context, state) => const InvoiceListScreen(),
          routes: [
            GoRoute(
              path: 'create',
              name: 'invoice-create',
              builder: (context, state) => const InvoiceFormScreen(),
            ),
            // GoRoute(
            //   path: 'edit/:id',
            //   name: 'invoice-edit',
            //   builder: (context, state) {
            //     return InvoiceFormScreen(invoice: );
            //   },
            // ),
            GoRoute(
              path: 'detail/:id',
              name: 'invoice-detail',
              builder: (context, state) {
                final id = state.pathParameters['id']!;
                return InvoiceDetailScreen(invoiceId: id);
              },
            ),
          ],
        ),
      ];
}
