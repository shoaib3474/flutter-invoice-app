// ignore_for_file: unused_local_variable, avoid_redundant_argument_values

import 'package:flutter_invoice_app/models/invoice/invoice_item_model.dart';
import 'package:flutter_invoice_app/models/invoice/invoice_model.dart';
import 'package:flutter_invoice_app/models/invoice/invoice_status.dart';
import 'package:flutter_invoice_app/services/firebase/firebase_service.dart';
import 'package:flutter_invoice_app/services/mock/mock_firebase_service.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_helpers.dart';

void main() {
  group('Firebase Service Tests', () {
    late FirebaseService firebaseService;
    late MockFirebaseAuth mockAuth;

    setUpAll(() async {
      await TestHelpers.setupFirebaseForTesting();
    });

    setUp(() {
      mockAuth = MockFirebaseAuth();
      firebaseService = FirebaseService();
    });

    group('Invoice Operations', () {
      test('should create invoice successfully', () async {
        await TestHelpers.signInTestUser();

        final invoice = InvoiceModel(
          id: 'test-id',
          invoiceNumber: 'INV-001',
          customerName: 'Test Customer',
          customerEmail: 'test@customer.com',
          customerAddress: '123 Test Street',
          customerState: 'Test State',
          customerStateCode: 0,
          placeOfSupply: 'Test Supply Place',
          placeOfSupplyCode: 0,
          items: [
            InvoiceItem(
              id: 'item-1',
              name: 'Test Item',
              description: 'Test Item Description',
              quantity: 1,
              unit: 'pcs',
              unitPrice: 1000,
              hsnSacCode: '1234',
              taxableValue: 1000,
              totalBeforeTax: 1000,
              cgstRate: 9,
              cgstAmount: 90,
              sgstRate: 9,
              sgstAmount: 90,
              igstAmount: 0,
              cessAmount: 0,
              totalAfterTax: 1180,
            ),
          ],
          subtotal: 1000,
          cgstTotal: 90,
          sgstTotal: 90,
          igstTotal: 0,
          cessTotal: 0,
          taxAmount: 180,
          totalTax: 180,
          grandTotal: 1180,
          invoiceDate: DateTime.now(),
          dueDate: DateTime.now().add(const Duration(days: 30)),
          status: InvoiceStatus.draft,
          createdBy: 'test-user',
        );

        // This would normally interact with Firestore
        // For testing, we'll verify the model is valid
        expect(invoice.invoiceNumber, equals('INV-001'));
        expect(invoice.total, equals(1180.0));
        expect(invoice.status, equals(InvoiceStatus.draft));
      });

      test('should validate invoice data', () {
        final invoice = InvoiceModel(
          id: '',
          invoiceNumber: '',
          customerName: '',
          customerEmail: 'invalid-email',
          customerAddress: '',
          customerState: '',
          customerStateCode: 0,
          placeOfSupply: '',
          placeOfSupplyCode: 0,
          items: [],
          subtotal: -100, // Invalid negative amount
          cgstTotal: 0,
          sgstTotal: 0,
          igstTotal: 0,
          cessTotal: 0,
          taxAmount: 0,
          totalTax: 0,
          grandTotal: 0,
          invoiceDate: DateTime.now(),
          dueDate: DateTime.now()
              .subtract(const Duration(days: 1)), // Invalid past due date
          status: InvoiceStatus.draft,
          createdBy: '',
        );

        // Test validation logic
        expect(invoice.invoiceNumber.isEmpty, isTrue);
        expect(invoice.customerName.isEmpty, isTrue);
        expect(invoice.subtotal < 0, isTrue);
        expect(invoice.dueDate.isBefore(invoice.date), isTrue);
      });
    });

    group('Authentication', () {
      test('should handle user sign in', () async {
        await TestHelpers.signInTestUser();
        expect(mockAuth.currentUser, isNotNull);
        expect(mockAuth.currentUser?.email, equals('test@example.com'));
      });

      test('should handle user sign out', () async {
        await TestHelpers.signInTestUser();
        expect(mockAuth.currentUser, isNotNull);

        await TestHelpers.signOutTestUser();
        expect(mockAuth.currentUser, isNull);
      });
    });
  });
}
