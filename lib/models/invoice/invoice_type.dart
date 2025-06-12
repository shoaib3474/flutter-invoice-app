enum InvoiceType {
  sales,
  purchase,
  regular,
  proforma,
  creditNote,
  debitNote,
  export,
  standard,
}

extension InvoiceTypeExtension on InvoiceType {
  String get displayName {
    switch (this) {
      case InvoiceType.sales:
        return 'Sales Invoice';
      case InvoiceType.purchase:
        return 'Purchase Invoice';
      case InvoiceType.regular:
        return 'Regular Invoice';
      case InvoiceType.proforma:
        return 'Proforma Invoice';
      case InvoiceType.creditNote:
        return 'Credit Note';
      case InvoiceType.debitNote:
        return 'Debit Note';
      case InvoiceType.export:
        return 'Export Invoice';
      case InvoiceType.standard:
        return 'Standard Invoice';
    }
  }

  String get value {
    switch (this) {
      case InvoiceType.sales:
        return 'sales';
      case InvoiceType.purchase:
        return 'purchase';
      case InvoiceType.regular:
        return 'regular';
      case InvoiceType.proforma:
        return 'proforma';
      case InvoiceType.creditNote:
        return 'credit_note';
      case InvoiceType.debitNote:
        return 'debit_note';
      case InvoiceType.export:
        return 'export';
      case InvoiceType.standard:
        return 'standard';
    }
  }

  static InvoiceType fromString(String value) {
    switch (value.toLowerCase()) {
      case 'sales':
        return InvoiceType.sales;
      case 'purchase':
        return InvoiceType.purchase;
      case 'regular':
        return InvoiceType.regular;
      case 'proforma':
        return InvoiceType.proforma;
      case 'credit_note':
        return InvoiceType.creditNote;
      case 'debit_note':
        return InvoiceType.debitNote;
      case 'export':
        return InvoiceType.export;
      case 'standard':
        return InvoiceType.standard;
      default:
        return InvoiceType.standard;
    }
  }
}
