class ApiResponse<T> {
  final bool success;
  final T? data;
  final ApiError? error;
  final ApiMeta? meta;

  ApiResponse({
    required this.success,
    this.data,
    this.error,
    this.meta,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic)? fromJsonT,
  ) {
    return ApiResponse<T>(
      success: json['success'] ?? false,
      data: json['data'] != null && fromJsonT != null
          ? fromJsonT(json['data'])
          : json['data'] as T?,
      error: json['error'] != null ? ApiError.fromJson(json['error']) : null,
      meta: json['meta'] != null ? ApiMeta.fromJson(json['meta']) : null,
    );
  }
}

class ApiError {
  final String code;
  final String message;
  final Map<String, dynamic>? details;
  final int? statusCode;

  ApiError({
    required this.code,
    required this.message,
    this.details,
    this.statusCode,
  });

  factory ApiError.fromJson(Map<String, dynamic> json) {
    return ApiError(
      code: json['code'] ?? 'UNKNOWN_ERROR',
      message: json['message'] ?? 'An error occurred',
      details: json['details'],
      statusCode: json['statusCode'],
    );
  }
}

class ApiMeta {
  final String? timestamp;
  final String? requestId;
  final String? path;
  final String? method;
  final String? version;
  final int? page;
  final int? limit;
  final int? total;
  final int? totalPages;
  final bool? hasNext;
  final bool? hasPrev;

  ApiMeta({
    this.timestamp,
    this.requestId,
    this.path,
    this.method,
    this.version,
    this.page,
    this.limit,
    this.total,
    this.totalPages,
    this.hasNext,
    this.hasPrev,
  });

  factory ApiMeta.fromJson(Map<String, dynamic> json) {
    return ApiMeta(
      timestamp: json['timestamp'],
      requestId: json['requestId'],
      path: json['path'],
      method: json['method'],
      version: json['version'],
      page: json['page'],
      limit: json['limit'],
      total: json['total'],
      totalPages: json['totalPages'],
      hasNext: json['hasNext'],
      hasPrev: json['hasPrev'],
    );
  }
}

class PaginatedResponse<T> {
  final List<T> data;
  final ApiMeta meta;

  PaginatedResponse({
    required this.data,
    required this.meta,
  });

  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic) fromJsonT,
  ) {
    final response = ApiResponse.fromJson(json, null);
    return PaginatedResponse<T>(
      data: (response.data as List<dynamic>?)
              ?.map((e) => fromJsonT(e))
              .toList() ??
          [],
      meta: response.meta ?? ApiMeta(),
    );
  }
}

