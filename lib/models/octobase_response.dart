import 'package:dio/dio.dart';

class OctobaseResponse<T> {
  final int? statusCode;
  final String? statusMessage;
  final Headers? headers;
  final Response? response;
  final T? data;
  final bool isError;

  OctobaseResponse({
    this.statusCode,
    this.statusMessage,
    required this.data,
    this.response,
    this.headers,
    this.isError = false,
  });
}
