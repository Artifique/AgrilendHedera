import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService();
});

class ApiService {
  final Dio dio;
  String? _authToken;

  static final ApiService _instance = ApiService._internal();

  factory ApiService() {
    return _instance;
  }

  ApiService._internal() : dio = Dio(BaseOptions(
    baseUrl: 'http://192.168.1.164:8080',
    connectTimeout: const Duration(seconds: 30),
    // receiveTimeout: const Duration(seconds: 30),
  )) {
    // Attach interceptor to add Authorization header when token is present
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        if (_authToken != null && _authToken!.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $_authToken';
        }
        print('API Request: ${options.method} ${options.path}');
        print('Headers: ${options.headers}');
        print('Data: ${options.data}');
        return handler.next(options);
      },
      onResponse: (response, handler) {
        print(
            'API Response: ${response.statusCode} ${response.requestOptions.path}');
        print('Response Data: ${response.data}');
        return handler.next(response);
      },
      onError: (DioException e, handler) {
        // Changed error type to DioException
        print('API Error: ${e.response?.statusCode} ${e.requestOptions.path}');
        print('Error Message: ${e.message}');
        if (e.response != null) {
          print('Error Response Data: ${e.response?.data}');
        }
        return handler.next(e);
      },
    ));
  }

  void setAuthToken(String? token) {
    _authToken = token;
  }

  Future<Response> get(String path,
      {Map<String, dynamic>? queryParameters}) async {
    return dio.get(path, queryParameters: queryParameters);
  }

  Future<Response> post(String path, {dynamic data, Options? options}) async {
    return dio.post(path, data: data, options: options);
  }

  Future<Response> put(String path, {dynamic data}) async {
    return dio.put(path, data: data);
  }

  Future<Response> delete(String path) async {
    return dio.delete(path);
  }
}
