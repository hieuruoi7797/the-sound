class BaseResponse<T> {
  final T? data;
  final String? message;
  final bool success;

  BaseResponse({
    this.data,
    this.message,
    this.success = false,
  });

  factory BaseResponse.fromJson(Map<String, dynamic> json, T Function(Map<String, dynamic>) fromJson) {
    return BaseResponse(
      data: json['data'] != null ? fromJson(json['data']) : null,
      message: json['message'],
      success: json['success'] ?? false,
    );
  }
} 