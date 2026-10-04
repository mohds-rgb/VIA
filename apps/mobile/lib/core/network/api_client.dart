import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiException implements Exception {
  final int statusCode;
  final String code;
  final String message;

  const ApiException({
    required this.statusCode,
    required this.code,
    required this.message,
  });

  @override
  String toString() => '$code: $message';
}

class ApiClient {
  final http.Client client;
  final String baseUrl;
  final Future<String?> Function()? tokenProvider;

  ApiClient({
    required this.client,
    required this.baseUrl,
    this.tokenProvider,
  });

  Future<Map<String, dynamic>> post(
    String path, {
    required Map<String, dynamic> body,
    String? idempotencyKey,
  }) async {
    final token = await tokenProvider?.call();
    final response = await client.post(
      Uri.parse('$baseUrl$path'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
        if (idempotencyKey != null) 'Idempotency-Key': idempotencyKey,
      },
      body: jsonEncode(body),
    );

    final decoded = response.body.isEmpty
        ? <String, dynamic>{}
        : jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode >= 400) {
      final error = decoded['error'] as Map<String, dynamic>? ?? {};
      throw ApiException(
        statusCode: response.statusCode,
        code: error['code'] as String? ?? 'UNKNOWN_ERROR',
        message: error['message'] as String? ?? 'Request failed',
      );
    }

    return decoded;
  }
}
