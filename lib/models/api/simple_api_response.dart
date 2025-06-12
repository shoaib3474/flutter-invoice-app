class SimpleApiResponse<T> {
  final T? data;
  final bool success;
  final String message;
  final int statusCode;

  const SimpleApiResponse({
    this.data,
    required this.success,
    required this.message,
    required this.statusCode,
  });

  factory SimpleApiResponse.success(T data) {
    return SimpleApiResponse<T>(
      data: data,
      success: true,
      message: 'Success',
      statusCode: 200,
    );
  }

  factory SimpleApiResponse.error(String message, {int statusCode = 500}) {
    return SimpleApiResponse<T>(
      data: null,
      success: false,
      message: message,
      statusCode: statusCode,
    );
  }
}
