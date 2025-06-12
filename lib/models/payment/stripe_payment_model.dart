class StripePaymentIntent {
  final String id;
  final String clientSecret;
  final int amount;
  final String currency;
  final String status;
  final String invoiceId;
  final DateTime createdAt;

  const StripePaymentIntent({
    required this.id,
    required this.clientSecret,
    required this.amount,
    required this.currency,
    required this.status,
    required this.invoiceId,
    required this.createdAt,
  });

  factory StripePaymentIntent.fromJson(Map<String, dynamic> json) {
    return StripePaymentIntent(
      id: json['id'] as String,
      clientSecret: json['client_secret'] as String,
      amount: json['amount'] as int,
      currency: json['currency'] as String,
      status: json['status'] as String,
      invoiceId: json['invoice_id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'client_secret': clientSecret,
      'amount': amount,
      'currency': currency,
      'status': status,
      'invoice_id': invoiceId,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

class StripePaymentResult {
  final String paymentIntentId;
  final String status;
  final int amount;
  final String currency;
  final String invoiceId;
  final String? paymentMethodId;
  final String? receiptUrl;
  final DateTime processedAt;

  const StripePaymentResult({
    required this.paymentIntentId,
    required this.status,
    required this.amount,
    required this.currency,
    required this.invoiceId,
    this.paymentMethodId,
    this.receiptUrl,
    required this.processedAt,
  });

  factory StripePaymentResult.fromJson(Map<String, dynamic> json) {
    return StripePaymentResult(
      paymentIntentId: json['payment_intent_id'] as String,
      status: json['status'] as String,
      amount: json['amount'] as int,
      currency: json['currency'] as String,
      invoiceId: json['invoice_id'] as String,
      paymentMethodId: json['payment_method_id'] as String?,
      receiptUrl: json['receipt_url'] as String?,
      processedAt: DateTime.parse(json['processed_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'payment_intent_id': paymentIntentId,
      'status': status,
      'amount': amount,
      'currency': currency,
      'invoice_id': invoiceId,
      'payment_method_id': paymentMethodId,
      'receipt_url': receiptUrl,
      'processed_at': processedAt.toIso8601String(),
    };
  }
}

class StripeCustomer {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final DateTime createdAt;

  const StripeCustomer({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    required this.createdAt,
  });

  factory StripeCustomer.fromJson(Map<String, dynamic> json) {
    return StripeCustomer(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String?,
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['created'] as int * 1000),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'created': createdAt.millisecondsSinceEpoch ~/ 1000,
    };
  }
}

class StripeInvoice {
  final String id;
  final String number;
  final String status;
  final int amountDue;
  final int amountPaid;
  final String currency;
  final String customerId;
  final String? hostedInvoiceUrl;
  final String? invoicePdf;
  final DateTime dueDate;
  final DateTime createdAt;

  const StripeInvoice({
    required this.id,
    required this.number,
    required this.status,
    required this.amountDue,
    required this.amountPaid,
    required this.currency,
    required this.customerId,
    this.hostedInvoiceUrl,
    this.invoicePdf,
    required this.dueDate,
    required this.createdAt,
  });

  factory StripeInvoice.fromJson(Map<String, dynamic> json) {
    return StripeInvoice(
      id: json['id'] as String,
      number: json['number'] as String,
      status: json['status'] as String,
      amountDue: json['amount_due'] as int,
      amountPaid: json['amount_paid'] as int,
      currency: json['currency'] as String,
      customerId: json['customer'] as String,
      hostedInvoiceUrl: json['hosted_invoice_url'] as String?,
      invoicePdf: json['invoice_pdf'] as String?,
      dueDate: DateTime.fromMillisecondsSinceEpoch(json['due_date'] as int * 1000),
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['created'] as int * 1000),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'number': number,
      'status': status,
      'amount_due': amountDue,
      'amount_paid': amountPaid,
      'currency': currency,
      'customer': customerId,
      'hosted_invoice_url': hostedInvoiceUrl,
      'invoice_pdf': invoicePdf,
      'due_date': dueDate.millisecondsSinceEpoch ~/ 1000,
      'created': createdAt.millisecondsSinceEpoch ~/ 1000,
    };
  }
}

class StripeRefund {
  final String id;
  final int amount;
  final String currency;
  final String paymentIntentId;
  final String status;
  final String? reason;
  final DateTime createdAt;

  const StripeRefund({
    required this.id,
    required this.amount,
    required this.currency,
    required this.paymentIntentId,
    required this.status,
    this.reason,
    required this.createdAt,
  });

  factory StripeRefund.fromJson(Map<String, dynamic> json) {
    return StripeRefund(
      id: json['id'] as String,
      amount: json['amount'] as int,
      currency: json['currency'] as String,
      paymentIntentId: json['payment_intent_id'] as String,
      status: json['status'] as String,
      reason: json['reason'] as String?,
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['created'] as int * 1000),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'currency': currency,
      'payment_intent_id': paymentIntentId,
      'status': status,
      'reason': reason,
      'created': createdAt.millisecondsSinceEpoch ~/ 1000,
    };
  }
}
