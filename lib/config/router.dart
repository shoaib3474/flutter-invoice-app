import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';

import '../screens/home_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/invoice/invoice_list_screen.dart';
import '../screens/invoice/invoice_form_screen.dart';
import '../screens/invoice/invoice_detail_screen.dart';
import '../screens/gstr1_screen.dart';
import '../screens/gstr3b_screen.dart';
import '../screens/gstr4_screen.dart';
import '../screens/gstr9_screen.dart';
import '../screens/gstr9c_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../screens/dashboard/gst_dashboard_screen.dart';
import '../models/invoice/invoice_model.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/dashboard',
        name: 'dashboard',
        builder: (context, state) => const GstDashboardScreen(),
      ),
      GoRoute(
        path: '/invoices',
        name: 'invoices',
        builder: (context, state) => const InvoiceListScreen(),
        routes: [
          GoRoute(
            path: '/create',
            name: 'create-invoice',
            builder: (context, state) => const InvoiceFormScreen(),
          ),
          GoRoute(
            path: '/edit/:id',
            name: 'edit-invoice',
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return InvoiceFormScreen(invoiceId: id);
            },
          ),
          GoRoute(
            path: '/:id',
            name: 'invoice-detail',
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return InvoiceDetailScreen(invoiceId: id);
            },
          ),
        ],
      ),
      GoRoute(
        path: '/gstr1',
        name: 'gstr1',
        builder: (context, state) => const GSTR1Screen(),
      ),
      GoRoute(
        path: '/gstr3b',
        name: 'gstr3b',
        builder: (context, state) => const GSTR3BScreen(),
      ),
      GoRoute(
        path: '/gstr4',
        name: 'gstr4',
        builder: (context, state) => const GSTR4Screen(),
      ),
      GoRoute(
        path: '/gstr9',
        name: 'gstr9',
        builder: (context, state) => const GSTR9Screen(),
      ),
      GoRoute(
        path: '/gstr9c',
        name: 'gstr9c',
        builder: (context, state) => const GSTR9CScreen(),
      ),
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Page not found',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'The page you are looking for does not exist.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go('/'),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
  );
}
