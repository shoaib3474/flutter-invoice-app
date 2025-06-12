class ApiException implements Exception {
  ApiException({
    this.statusCode,
    required this.message,
    this.errors,
  });

  final int? statusCode;
  final String message;
  final dynamic errors;
  
  @override
  String toString() {
    return 'ApiException: $message (Status: ${statusCode ?? 'Unknown'})';
  }
}
