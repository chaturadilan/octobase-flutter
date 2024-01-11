library octobase_flutter;

import 'dart:io';

import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:octobase_flutter/enums/action_type.dart';
import 'package:octobase_flutter/models/octobase_success.dart';
import 'package:octobase_flutter/models/server_connection_error.dart';
import 'package:octobase_flutter/models/user_info.dart';
import 'package:pluralize/pluralize.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'models/collection.dart';
import 'models/octobase_error.dart';

class OctobaseServer {
  static Octobase init(String serverURL, String mainRoute) {
    var octobase = Octobase();
    BaseOptions options = BaseOptions(
      baseUrl: '$serverURL/octobase',
    );
    Dio dio = Dio(options);
    dio.interceptors.add(LogInterceptor(responseBody: true, requestBody: true));
    octobase._dio = dio;
    octobase.logger = Logger(
        printer: PrettyPrinter(
            methodCount: 0, errorMethodCount: 0, noBoxingByDefault: true));
    octobase.mainRoute = mainRoute;
    return octobase;
  }
}

class Octobase {
  static final Octobase _singleton = Octobase._internal();

  factory Octobase() {
    return _singleton;
  }
  Octobase._internal();

  late Dio _dio;
  late Logger logger;
  String mainRoute = '/';
  String token = '';

  Future<String> _cacheToken(String newToken) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if (newToken != '') {
      await prefs.setString('octobase_token', newToken);
    } else {
      logger.e("Cannot save token. Token is Empty");
    }
    return newToken;
  }

  Future<void> _clearToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('octobase_token');
  }

  Future<String> loadToken(
      {String newToken = '', bool cacheToken = false}) async {
    if (cacheToken == false) {
      _clearToken();
    }
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if (newToken != '') {
      token = newToken;
      if (cacheToken) await _cacheToken(newToken);
      return token;
    } else if (token != '') {
      return token;
    } else {
      token = prefs.getString('octobase_token') ?? '';
      return token;
    }
  }

  Future<UserInfo> register(String firstName, String lastName, String email,
      String username, String password, String confirmPassword,
      {bool cacheToken = true}) async {
    try {
      Response response = await _dio.post(
        '/register',
        data: {
          'first_name': firstName,
          'last_name': lastName,
          'email': email,
          'username': username,
          'password': password,
          'password_confirmation': confirmPassword
        },
      );
      var userInfo = UserInfo.fromJson(response.data);
      await loadToken(newToken: userInfo.token ?? '', cacheToken: cacheToken);
      return userInfo;
    } on DioException catch (ex) {
      if (ex.error is SocketException) {
        logger.e("Error => Not able to connect to the server");
        throw ServerConnectionError(ex.message!);
      } else {
        OctobaseError error = OctobaseError.fromJson(ex.response?.data);
        error.code = ex.response?.statusCode;
        logger.e("Error => Code: ${error.code}, Message: ${error.error}");
        throw error;
      }
    }
  }

  Future<UserInfo> login(String email, String password,
      {bool cacheToken = true}) async {
    try {
      Response response = await _dio.post(
        '/login',
        data: {
          'email': email,
          'password': password,
        },
      );
      var userInfo = UserInfo.fromJson(response.data);
      await loadToken(newToken: userInfo.token ?? '', cacheToken: cacheToken);
      return userInfo;
    } on DioException catch (ex) {
      if (ex.error is SocketException) {
        logger.e("Error => Not able to connect to the server");
        throw ServerConnectionError(ex.message!);
      } else {
        OctobaseError error = OctobaseError.fromJson(ex.response?.data);
        error.code = ex.response?.statusCode;
        logger.e("Error => Code: ${error.code}, Message: ${error.error}");
        throw error;
      }
    }
  }

  Future<UserInfo> loginFirebase(String idToken,
      {bool cacheToken = true}) async {
    try {
      Response response = await _dio.post(
        '/login/firebase',
        data: {
          'token': idToken,
        },
      );
      var userInfo = UserInfo.fromJson(response.data);
      await loadToken(newToken: userInfo.token ?? '', cacheToken: cacheToken);
      return userInfo;
    } on DioException catch (ex) {
      if (ex.error is SocketException) {
        logger.e("Error => Not able to connect to the server");
        throw ServerConnectionError(ex.message!);
      } else {
        OctobaseError error = OctobaseError.fromJson(ex.response?.data);
        error.code = ex.response?.statusCode;
        logger.e("Error => Code: ${error.code}, Message: ${error.error}");
        throw error;
      }
    }
  }

  Future<UserInfo> refresh({bool cacheToken = true}) async {
    try {
      Response response = await _dio.post(
        '/refresh',
        options: Options(
          headers: {'Authorization': 'Bearer ${await loadToken()}'},
        ),
      );
      var userInfo = UserInfo.fromJson(response.data);
      await loadToken(newToken: userInfo.token ?? '', cacheToken: cacheToken);
      return userInfo;
    } on DioException catch (ex) {
      if (ex.error is SocketException) {
        logger.e("Error => Not able to connect to the server");
        throw ServerConnectionError(ex.message!);
      } else {
        OctobaseError error = OctobaseError.fromJson(ex.response?.data);
        error.code = ex.response?.statusCode;
        logger.e("Error => Code: ${error.code}, Message: ${error.error}");
        throw error;
      }
    }
  }

  Future<OctobaseSuccess> logout() async {
    try {
      Response response = await _dio.post(
        '/logout',
        options: Options(
          headers: {'Authorization': 'Bearer ${await loadToken()}'},
        ),
      );
      var success = OctobaseSuccess.fromJson(response.data);
      token = '';
      await _clearToken();
      return success;
    } on DioException catch (ex) {
      if (ex.error is SocketException) {
        logger.e("Error => Not able to connect to the server");
        throw ServerConnectionError(ex.message!);
      } else {
        OctobaseError error = OctobaseError.fromJson(ex.response?.data);
        error.code = ex.response?.statusCode;
        logger.e("Error => Code: ${error.code}, Message: ${error.error}");
        throw error;
      }
    }
  }

  Future<UserInfo> user() async {
    try {
      Response response = await _dio.get(
        '/user',
        options: Options(
          headers: {'Authorization': 'Bearer ${await loadToken()}'},
        ),
      );
      var userInfo = UserInfo.fromJson(response.data);
      token = userInfo.token ?? '';
      return userInfo;
    } on DioException catch (ex) {
      if (ex.error is SocketException) {
        logger.e("Error => Not able to connect to the server");
        throw ServerConnectionError(ex.message!);
      } else {
        OctobaseError error = OctobaseError.fromJson(ex.response?.data);
        error.code = ex.response?.statusCode;
        logger.e("Error => Code: ${error.code}, Message: ${error.error}");
        throw error;
      }
    }
  }

  Future<Collection<T>> selectAll<T>(
    T Function(Map<String, dynamic>) fromJson, {
    String? controller,
    String? mainRoute,
    int? page,
    int? perPage,
    String? userId,
    String? own,
    String? withOthers,
    String? select,
    String? where,
    String? order,
  }) async {
    mainRoute ??= this.mainRoute;
    controller ??= Pluralize().plural(T.toString().toLowerCase());
    try {
      fromJsonModel(data) => fromJson(data as Map<String, dynamic>);

      var data = {};
      data['page'] = page ?? data['page'];
      data['perPage'] = perPage ?? data['perPage'];
      data['userId'] = userId ?? data['userId'];
      data['own'] = own ?? data['own'];
      data['with'] = withOthers ?? data['with'];
      data['select'] = select ?? data['select'];
      data['where'] = where ?? data['where'];
      data['order'] = order ?? data['order'];

      Response response = await _dio.get(
        '/$mainRoute/$controller',
        data: data,
        options: Options(
          headers: {'Authorization': 'Bearer ${await loadToken()}'},
        ),
      );

      var obj = Collection<T>.fromJson(response.data, fromJsonModel);
      return obj;
    } on DioException catch (ex) {
      if (ex.error is SocketException) {
        logger.e("Error => Not able to connect to the server");
        throw ServerConnectionError(ex.message!);
      } else {
        OctobaseError error = OctobaseError.fromJson(ex.response?.data);
        error.code = ex.response?.statusCode;
        logger.e("Error => Code: ${error.code}, Message: ${error.error}");
        throw error;
      }
    }
  }

  Future<T> selectOne<T>(
    T Function(Map<String, dynamic>) fromJson,
    int id, {
    String? controller,
    String? mainRoute,
    String? userId,
    String? own,
    String? withOthers,
    String? select,
    String? where,
    String? order,
  }) async {
    mainRoute ??= this.mainRoute;
    controller ??= Pluralize().plural(T.toString().toLowerCase());
    try {
      var data = {};
      data['with'] = withOthers ?? data['with'];
      data['select'] = select ?? data['select'];

      Response response = await _dio.get(
        '/$mainRoute/$controller/$id',
        data: data,
        options: Options(
          headers: {'Authorization': 'Bearer ${await loadToken()}'},
        ),
      );
      var obj = fromJson(response.data);
      return obj;
    } on DioException catch (ex) {
      if (ex.error is SocketException) {
        logger.e("Error => Not able to connect to the server");
        throw ServerConnectionError(ex.message!);
      } else {
        OctobaseError error = OctobaseError.fromJson(ex.response?.data);
        error.code = ex.response?.statusCode;
        logger.e("Error => Code: ${error.code}, Message: ${error.error}");
        throw error;
      }
    }
  }

  Future<T> add<T>(T Function(Map<String, dynamic>) fromJson,
      {Map<String, dynamic>? data,
      String? controller,
      String? mainRoute}) async {
    mainRoute ??= this.mainRoute;
    controller ??= Pluralize().plural(T.toString().toLowerCase());
    try {
      Response response = await _dio.post(
        '/$mainRoute/$controller',
        data: data,
        options: Options(
          headers: {'Authorization': 'Bearer ${await loadToken()}'},
        ),
      );
      var obj = fromJson(response.data);
      return obj;
    } on DioException catch (ex) {
      if (ex.error is SocketException) {
        logger.e("Error => Not able to connect to the server");
        throw ServerConnectionError(ex.message!);
      } else {
        OctobaseError error = OctobaseError.fromJson(ex.response?.data);
        error.code = ex.response?.statusCode;
        logger.e("Error => Code: ${error.code}, Message: ${error.error}");
        throw error;
      }
    }
  }

  Future<T> update<T>(T Function(Map<String, dynamic>) fromJson, int id,
      {Map<String, dynamic>? data,
      String? controller,
      String? mainRoute}) async {
    mainRoute ??= this.mainRoute;
    controller ??= Pluralize().plural(T.toString().toLowerCase());
    try {
      Response response = await _dio.post(
        '/$mainRoute/$controller/$id',
        data: data,
        options: Options(
          headers: {'Authorization': 'Bearer ${await loadToken()}'},
        ),
      );
      var obj = fromJson(response.data);
      return obj;
    } on DioException catch (ex) {
      if (ex.error is SocketException) {
        logger.e("Error => Not able to connect to the server");
        throw ServerConnectionError(ex.message!);
      } else {
        OctobaseError error = OctobaseError.fromJson(ex.response?.data);
        error.code = ex.response?.statusCode;
        logger.e("Error => Code: ${error.code}, Message: ${error.error}");
        throw error;
      }
    }
  }

  Future<OctobaseSuccess> delete<T>(int id,
      {String? controller, String? mainRoute}) async {
    mainRoute ??= this.mainRoute;
    controller ??= Pluralize().plural(T.toString().toLowerCase());
    try {
      Response response = await _dio.delete(
        '/$mainRoute/$controller/$id',
        options: Options(
          headers: {'Authorization': 'Bearer ${await loadToken()}'},
        ),
      );
      var success = OctobaseSuccess.fromJson(response.data);
      return success;
    } on DioException catch (ex) {
      if (ex.error is SocketException) {
        logger.e("Error => Not able to connect to the server");
        throw ServerConnectionError(ex.message!);
      } else {
        OctobaseError error = OctobaseError.fromJson(ex.response?.data);
        error.code = ex.response?.statusCode;
        logger.e("Error => Code: ${error.code}, Message: ${error.error}");
        throw error;
      }
    }
  }

  Future<T> custom<T>(T Function(Map<String, dynamic>) fromJson, String? url,
      ActionType actionType,
      {String? mainRoute, Map<String, dynamic>? data}) async {
    mainRoute ??= this.mainRoute;
    var headers = <String, dynamic>{};
    headers['Authorization'] = 'Bearer ${await loadToken()}';
    Response? response;
    try {
      switch (actionType) {
        case ActionType.put:
          response = await _dio.put(
            '/$mainRoute/$url',
            options: Options(
              headers: headers,
            ),
          );
          break;
        case ActionType.get:
          response = await _dio.get(
            '/$mainRoute/$url',
            options: Options(
              headers: headers,
            ),
          );
          break;
        case ActionType.delete:
          response = await _dio.delete(
            '/$mainRoute/$url',
            options: Options(
              headers: headers,
            ),
          );
          break;
        default:
          response = await _dio.post(
            '/$mainRoute/$url',
            data: data,
            options: Options(
              headers: headers,
            ),
          );
      }

      var obj = fromJson(response.data);
      return obj;
    } on DioException catch (ex) {
      if (ex.error is SocketException) {
        logger.e("Error => Not able to connect to the server");
        throw ServerConnectionError(ex.message!);
      } else {
        OctobaseError error = OctobaseError.fromJson(ex.response?.data);
        error.code = ex.response?.statusCode;
        logger.e("Error => Code: ${error.code}, Message: ${error.error}");
        throw error;
      }
    }
  }
}
