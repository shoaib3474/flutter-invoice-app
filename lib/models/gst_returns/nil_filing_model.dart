class NilFilingResult {
  final bool success;
  final String message;
  final String? acknowledgmentNumber;
  final DateTime? filingDate;
  final String? smsText;
  
  const NilFilingResult({
    required this.success,
    required this.message,
    this.acknowledgmentNumber,
    this.filingDate,
    this.smsText,
  });
  
  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'acknowledgmentNumber': acknowledgmentNumber,
      'filingDate': filingDate?.toIso8601String(),
      'smsText': smsText,
    };
  }
  
  factory NilFilingResult.fromJson(Map<String, dynamic> json) {
    return NilFilingResult(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      acknowledgmentNumber: json['acknowledgmentNumber'],
      filingDate: json['filingDate'] != null 
          ? DateTime.parse(json['filingDate']) 
          : null,
      smsText: json['smsText'],
    );
  }
}

class NilFilingRequest {
  final String gstin;
  final String period;
  final String returnType;
  final String mobileNumber;
  final DateTime requestDate;
  
  const NilFilingRequest({
    required this.gstin,
    required this.period,
    required this.returnType,
    required this.mobileNumber,
    required this.requestDate,
  });
  
  Map<String, dynamic> toJson() {
    return {
      'gstin': gstin,
      'period': period,
      'returnType': returnType,
      'mobileNumber': mobileNumber,
      'requestDate': requestDate.toIso8601String(),
    };
  }
  
  factory NilFilingRequest.fromJson(Map<String, dynamic> json) {
    return NilFilingRequest(
      gstin: json['gstin'] ?? '',
      period: json['period'] ?? '',
      returnType: json['returnType'] ?? '',
      mobileNumber: json['mobileNumber'] ?? '',
      requestDate: DateTime.parse(json['requestDate']),
    );
  }
}
