import '../invoice/invoice_model.dart';
import '../../models/gst_returns/firestore_gstr1_model.dart';
import '../../models/gst_returns/firestore_gstr3b_model.dart';

class GSTReturnsGeneratorService {
  // Generate GSTR1 from invoices
  FirestoreGSTR1 generateGSTR1FromInvoices(
    String gstin,
    String returnPeriod,
    List<Invoice> invoices,
    String createdBy,
  ) {
    // Filter invoices for the given period and GSTIN
    final filteredInvoices = invoices.where((invoice) {
      final invoiceMonth = '${invoice.invoiceDate.month.toString().padLeft(2, '0')}${invoice.invoiceDate.year}';
      return invoice.isGstReported == false && 
             invoiceMonth == returnPeriod && 
             invoice.invoiceType == InvoiceType.sales;
    }).toList();
    
    // Generate B2B invoices
    final b2bInvoices = filteredInvoices
        .where((invoice) => invoice.isB2B && invoice.customerGstin.isNotEmpty)
        .map((invoice) => B2BInvoice(
              id: invoice.id,
              invoiceNumber: invoice.invoiceNumber,
              invoiceDate: invoice.invoiceDate,
              counterpartyGstin: invoice.customerGstin,
              counterpartyName: invoice.customerName,
              taxableValue: invoice.subtotal,
              igstAmount: invoice.igstTotal,
              cgstAmount: invoice.cgstTotal,
              sgstAmount: invoice.sgstTotal,
              cessAmount: invoice.cessTotal,
              placeOfSupply: invoice.placeOfSupply,
              reverseCharge: invoice.isReverseCharge,
              invoiceType: 'Regular',
            ))
        .toList();
    
    // Generate B2CL invoices (Large B2C - interstate above 2.5 lakhs)
    final b2clInvoices = filteredInvoices
        .where((invoice) => invoice.isB2C && invoice.isInterState && invoice.grandTotal >= 250000)
        .map((invoice) => B2CLInvoice(
              id: invoice.id,
              invoiceNumber: invoice.invoiceNumber,
              invoiceDate: invoice.invoiceDate,
              taxableValue: invoice.subtotal,
              igstAmount: invoice.igstTotal,
              cgstAmount: invoice.cgstTotal,
              sgstAmount: invoice.sgstTotal,
              cessAmount: invoice.cessTotal,
              placeOfSupply: invoice.placeOfSupply,
            ))
        .toList();
    
    // Generate B2CS invoices (Small B2C)
    final b2csMap = <String, B2CSInvoice>{};
    
    for (final invoice in filteredInvoices.where(
        (invoice) => invoice.isB2C && (invoice.isIntraState || invoice.grandTotal < 250000))) {
      final key = '${invoice.placeOfSupply}_${invoice.cgstTotal > 0 ? 'intra' : 'inter'}';
      
      if (b2csMap.containsKey(key)) {
        final existing = b2csMap[key]!;
        b2csMap[key] = B2CSInvoice(
          id: existing.id,
          type: existing.type,
          placeOfSupply: existing.placeOfSupply,
          taxableValue: existing.taxableValue + invoice.subtotal,
          igstAmount: existing.igstAmount + invoice.igstTotal,
          cgstAmount: existing.cgstAmount + invoice.cgstTotal,
          sgstAmount: existing.sgstAmount + invoice.sgstTotal,
          cessAmount: existing.cessAmount + invoice.cessTotal,
        );
      } else {
        b2csMap[key] = B2CSInvoice(
          id: DateTime.now().millisecondsSinceEpoch.toString() + key,
          type: invoice.cgstTotal > 0 ? 'Intra-State' : 'Inter-State',
          placeOfSupply: invoice.placeOfSupply,
          taxableValue: invoice.subtotal,
          igstAmount: invoice.igstTotal,
          cgstAmount: invoice.cgstTotal,
          sgstAmount: invoice.sgstTotal,
          cessAmount: invoice.cessTotal,
        );
      }
    }
    
    final b2csInvoices = b2csMap.values.toList();
    
    // Generate Export invoices
    final exportInvoices = filteredInvoices
        .where((invoice) => invoice.isExported)
        .map((invoice) => ExportInvoice(
              id: invoice.id,
              invoiceNumber: invoice.invoiceNumber,
              invoiceDate: invoice.invoiceDate,
              taxableValue: invoice.subtotal,
              igstAmount: invoice.igstTotal,
              exportType: invoice.igstTotal > 0 ? 'With Payment' : 'Without Payment',
            ))
        .toList();
    
    // Create GSTR1
    return FirestoreGSTR1.create(
      gstin: gstin,
      returnPeriod: returnPeriod,
      b2bInvoices: b2bInvoices,
      b2clInvoices: b2clInvoices,
      b2csInvoices: b2csInvoices,
      exportInvoices: exportInvoices,
      createdBy: createdBy,
    );
  }
  
  // Generate GSTR3B from invoices
  FirestoreGSTR3B generateGSTR3BFromInvoices(
    String gstin,
    String returnPeriod,
    List<Invoice> salesInvoices,
    List<Invoice> purchaseInvoices,
    String createdBy,
  ) {
    // Filter invoices for the given period and GSTIN
    final filteredSalesInvoices = salesInvoices.where((invoice) {
      final invoiceMonth = '${invoice.invoiceDate.month.toString().padLeft(2, '0')}${invoice.invoiceDate.year}';
      return invoiceMonth == returnPeriod && invoice.invoiceType == InvoiceType.sales;
    }).toList();
    
    final filteredPurchaseInvoices = purchaseInvoices.where((invoice) {
      final invoiceMonth = '${invoice.invoiceDate.month.toString().padLeft(2, '0')}${invoice.invoiceDate.year}';
      return invoiceMonth == returnPeriod && invoice.invoiceType == InvoiceType.purchase;
    }).toList();
    
    // Calculate outward supplies
    double taxableOutwardSupplies = 0;
    double taxableOutwardSuppliesZeroRated = 0;
    double taxableOutwardSuppliesNilRated = 0;
    double nonGstOutwardSupplies = 0;
    double intraStateSupplies = 0;
    double interStateSupplies = 0;
    double outwardIgstAmount = 0;
    double outwardCgstAmount = 0;
    double outwardSgstAmount = 0;
    double outwardCessAmount = 0;
    
    for (final invoice in filteredSalesInvoices) {
      if (invoice.igstTotal > 0 || invoice.cgstTotal > 0 || invoice.sgstTotal > 0) {
        taxableOutwardSupplies += invoice.subtotal;
        
        if (invoice.isIntraState) {
          intraStateSupplies += invoice.subtotal;
        } else {
          interStateSupplies += invoice.subtotal;
        }
        
        outwardIgstAmount += invoice.igstTotal;
        outwardCgstAmount += invoice.cgstTotal;
        outwardSgstAmount += invoice.sgstTotal;
        outwardCessAmount += invoice.cessTotal;
      } else if (invoice.isExported) {
        taxableOutwardSuppliesZeroRated += invoice.subtotal;
      } else {
        taxableOutwardSuppliesNilRated += invoice.subtotal;
      }
    }
    
    // Calculate inward supplies
    double reverseChargeSupplies = 0;
    double importOfGoods = 0;
    double importOfServices = 0;
    double ineligibleITC = 0;
    double eligibleITC = 0;
    double inwardIgstAmount = 0;
    double inwardCgstAmount = 0;
    double inwardSgstAmount = 0;
    double inwardCessAmount = 0;
    
    for (final invoice in filteredPurchaseInvoices) {
      if (invoice.isReverseCharge) {
        reverseChargeSupplies += invoice.subtotal;
      } else if (invoice.isImported) {
        if (invoice.items.any((item) => item.name.toLowerCase().contains('service'))) {
          importOfServices += invoice.subtotal;
        } else {
          importOfGoods += invoice.subtotal;
        }
      }
      
      // Assuming all ITC is eligible for now
      eligibleITC += invoice.subtotal;
      inwardIgstAmount += invoice.igstTotal;
      inwardCgstAmount += invoice.cgstTotal;
      inwardSgstAmount += invoice.sgstTotal;
      inwardCessAmount += invoice.cessTotal;
    }
    
    // Create OutwardSupplies
    final outwardSupplies = OutwardSupplies(
      taxableOutwardSupplies: taxableOutwardSupplies,
      taxableOutwardSuppliesZeroRated: taxableOutwardSuppliesZeroRated,
      taxableOutwardSuppliesNilRated: taxableOutwardSuppliesNilRated,
      nonGstOutwardSupplies: nonGstOutwardSupplies,
      intraStateSupplies: intraStateSupplies,
      interStateSupplies: interStateSupplies,
      igstAmount: outwardIgstAmount,
      cgstAmount: outwardCgstAmount,
      sgstAmount: outwardSgstAmount,
      cessAmount: outwardCessAmount,
    );
    
    // Create InwardSupplies
    final inwardSupplies = InwardSupplies(
      reverseChargeSupplies: reverseChargeSupplies,
      importOfGoods: importOfGoods,
      importOfServices: importOfServices,
      ineligibleITC: ineligibleITC,
      eligibleITC: eligibleITC,
      igstAmount: inwardIgstAmount,
      cgstAmount: inwardCgstAmount,
      sgstAmount: inwardSgstAmount,
      cessAmount: inwardCessAmount,
    );
    
    // Create ITCDetails
    final itcDetails = ITCDetails(
      itcAvailed: inwardIgstAmount + inwardCgstAmount + inwardSgstAmount + inwardCessAmount,
      itcReversed: 0,
      itcNet: inwardIgstAmount + inwardCgstAmount + inwardSgstAmount + inwardCessAmount,
      ineligibleITC: 0,
    );
    
    // Calculate tax payable
    final igstPayable = outwardIgstAmount - inwardIgstAmount;
    final cgstPayable = outwardCgstAmount - inwardCgstAmount;
    final sgstPayable = outwardSgstAmount - inwardSgstAmount;
    final cessPayable = outwardCessAmount - inwardCessAmount;
    
    // Create TaxPayment
    final taxPayment = TaxPayment(
      igstAmount: igstPayable > 0 ? igstPayable : 0,
      cgstAmount: cgstPayable > 0 ? cgstPayable : 0,
      sgstAmount: sgstPayable > 0 ? sgstPayable : 0,
      cessAmount: cessPayable > 0 ? cessPayable : 0,
      interestAmount: 0,
      lateFeesAmount: 0,
      penaltyAmount: 0,
      totalAmount: (igstPayable > 0 ? igstPayable : 0) +
                  (cgstPayable > 0 ? cgstPayable : 0) +
                  (sgstPayable > 0 ? sgstPayable : 0) +
                  (cessPayable > 0 ? cessPayable : 0),
    );
    
    // Create GSTR3B
    return FirestoreGSTR3B.create(
      gstin: gstin,
      returnPeriod: returnPeriod,
      outwardSupplies: outwardSupplies,
      inwardSupplies: inwardSupplies,
      itcDetails: itcDetails,
      taxPayment: taxPayment,
      createdBy: createdBy,
    );
  }
}
