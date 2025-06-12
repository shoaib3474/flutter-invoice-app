enum InvoiceStatus {
  draft,
  issued,
  sent,
  paid,
  partiallyPaid,
  overdue,
  cancelled,
  voided,
}

extension InvoiceStatusExtension on InvoiceStatus {
  String get displayName {
    switch (this) {
      case InvoiceStatus.draft:
        return 'Draft';
      case InvoiceStatus.issued:
        return 'Issued';
      case InvoiceStatus.sent:
        return 'Sent';
      case InvoiceStatus.paid:
        return 'Paid';
      case InvoiceStatus.partiallyPaid:
        return 'Partially Paid';
      case InvoiceStatus.overdue:
        return 'Overdue';
      case InvoiceStatus.cancelled:
        return 'Cancelled';
      case InvoiceStatus.voided:
        return 'Void';
    }
  }

  String get value {
    switch (this) {
      case InvoiceStatus.draft:
        return 'draft';
      case InvoiceStatus.issued:
        return 'issued';
      case InvoiceStatus.sent:
        return 'sent';
      case InvoiceStatus.paid:
        return 'paid';
      case InvoiceStatus.partiallyPaid:
        return 'partially_paid';
      case InvoiceStatus.overdue:
        return 'overdue';
      case InvoiceStatus.cancelled:
        return 'cancelled';
      case InvoiceStatus.voided:
        return 'void';
    }
  }

  static InvoiceStatus fromString(String value) {
    switch (value.toLowerCase()) {
      case 'draft':
        return InvoiceStatus.draft;
      case 'issued':
        return InvoiceStatus.issued;
      case 'sent':
        return InvoiceStatus.sent;
      case 'paid':
        return InvoiceStatus.paid;
      case 'partially_paid':
        return InvoiceStatus.partiallyPaid;
      case 'overdue':
        return InvoiceStatus.overdue;
      case 'cancelled':
        return InvoiceStatus.cancelled;
      case 'void':
        return InvoiceStatus.voided;
      default:
        return InvoiceStatus.draft;
    }
  }
}
