library octobase_flutter;

import 'dart:io';

import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:octobase_flutter/enums/action_type.dart';
import 'package:octobase_flutter/models/octobase_response.dart';
import 'package:octobase_flutter/models/octobase_success.dart';
import 'package:octobase_flutter/models/server_connection_error.dart';
import 'package:octobase_flutter/models/user_info.dart';
import 'package:pluralize/pluralize.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'models/octobase_error.dart';

class OctobaseServer {
  static Octobase init(String serverURL, String mainRoute,
      {bool debugLogs = false,
      Dio? dio,
      Dio? mockDio,
      List<Interceptor> interceptors = const [],
      List<Interceptor> mockInterceptors = const []}) {
    var octobase = Octobase();
    BaseOptions options = BaseOptions(
      baseUrl: '$serverURL/octobase',
    );

    if (dio == null) {
      dio = Dio(options);
    } else {
      dio.options = options;
    }

    if (debugLogs) {
      dio.interceptors
          .add(LogInterceptor(responseBody: true, requestBody: true));
    }
    for (var interceptor in interceptors) {
      dio.interceptors.add(interceptor);
    }
    octobase._dio = dio;
    octobase.logger = Logger(
        printer: PrettyPrinter(
            methodCount: 0, errorMethodCount: 0, noBoxingByDefault: true));

    // Do same for Mock

    if (mockDio != null) {
      if (debugLogs) {
        mockDio.interceptors
            .add(LogInterceptor(responseBody: true, requestBody: true));
      }
      for (var interceptor in mockInterceptors) {
        mockDio.interceptors.add(interceptor);
      }
      octobase._mockDio = mockDio;
    }

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
  Dio? _mockDio;
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

  Dio _getDio(bool isMock) {
    if (isMock == true && _mockDio == null) {
      throw Exception("Mock Dio is not initialized");
    } else {
      return isMock ? _mockDio! : _dio;
    }
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

  Future<OctobaseResponse<UserInfo>> register(String firstName, String lastName,
      String email, String username, String password, String confirmPassword,
      {bool cacheToken = true,
      String? appCheckToken,
      bool isMock = false}) async {
    try {
      Options options = Options(
        headers: {
          if (appCheckToken != null) 'X-Firebase-AppCheck': appCheckToken,
        },
      );

      Response response = await _getDio(isMock).post(
        '/register',
        data: {
          'first_name': firstName,
          'last_name': lastName,
          'email': email,
          'username': username,
          'password': password,
          'password_confirmation': confirmPassword
        },
        options: options,
      );
      var userInfo = UserInfo.fromJson(response.data);
      await loadToken(newToken: userInfo.token ?? '', cacheToken: cacheToken);
      return OctobaseResponse<UserInfo>(
        statusCode: response.statusCode,
        statusMessage: response.statusMessage,
        response: response,
        headers: response.headers,
        data: userInfo,
      );
    } on DioException catch (ex) {
      if (ex.error is SocketException) {
        logger.e("Error => Not able to connect to the server");
        throw ServerConnectionError(ex.message!);
      } else {
        OctobaseError error = OctobaseError.fromJson(ex.response?.data);
        logger.e(
            "Error => Status Code: ${ex.response?.statusCode}, Code: ${error.code}, Message: ${error.message}");
        throw OctobaseResponse<OctobaseError>(
            statusCode: ex.response?.statusCode,
            statusMessage: ex.response?.statusMessage,
            response: ex.response,
            headers: ex.response?.headers,
            data: error,
            isError: true);
      }
    }
  }

  Future<OctobaseResponse<UserInfo>> login(String email, String password,
      {bool cacheToken = true,
      String? appCheckToken,
      bool isMock = false}) async {
    try {
      Options options = Options(
        headers: {
          if (appCheckToken != null) 'X-Firebase-AppCheck': appCheckToken,
        },
      );

      Response response = await _getDio(isMock).post(
        '/login',
        data: {
          'email': email,
          'password': password,
        },
        options: options,
      );
      var userInfo = UserInfo.fromJson(response.data);
      await loadToken(newToken: userInfo.token ?? '', cacheToken: cacheToken);
      return OctobaseResponse<UserInfo>(
        statusCode: response.statusCode,
        statusMessage: response.statusMessage,
        response: response,
        headers: response.headers,
        data: userInfo,
      );
    } on DioException catch (ex) {
      if (ex.error is SocketException) {
        logger.e("Error => Not able to connect to the server");
        throw ServerConnectionError(ex.message!);
      } else {
        OctobaseError error = OctobaseError.fromJson(ex.response?.data);
        logger.e(
            "Error => Status Code: ${ex.response?.statusCode}, Code: ${error.code}, Message: ${error.message}");
        throw OctobaseResponse<OctobaseError>(
            statusCode: ex.response?.statusCode,
            statusMessage: ex.response?.statusMessage,
            response: ex.response,
            headers: ex.response?.headers,
            data: error,
            isError: true);
      }
    }
  }

  Future<OctobaseResponse<UserInfo>> loginFirebase(String idToken,
      {bool cacheToken = true,
      String? appCheckToken,
      bool isMock = false}) async {
    try {
      Options options = Options(
        headers: {
          if (appCheckToken != null) 'X-Firebase-AppCheck': appCheckToken,
        },
      );
      Response response = await _getDio(isMock).post(
        '/login/firebase',
        data: {
          'token': idToken,
        },
        options: options,
      );
      var userInfo = UserInfo.fromJson(response.data);
      await loadToken(newToken: userInfo.token ?? '', cacheToken: cacheToken);
      return OctobaseResponse<UserInfo>(
        statusCode: response.statusCode,
        statusMessage: response.statusMessage,
        response: response,
        headers: response.headers,
        data: userInfo,
      );
    } on DioException catch (ex) {
      if (ex.error is SocketException) {
        logger.e("Error => Not able to connect to the server");
        throw ServerConnectionError(ex.message!);
      } else {
        OctobaseError error = OctobaseError.fromJson(ex.response?.data);
        logger.e(
            "Error => Status Code: ${ex.response?.statusCode}, Code: ${error.code}, Message: ${error.message}");
        throw OctobaseResponse<OctobaseError>(
            statusCode: ex.response?.statusCode,
            statusMessage: ex.response?.statusMessage,
            response: ex.response,
            headers: ex.response?.headers,
            data: error,
            isError: true);
      }
    }
  }

  Future<OctobaseResponse<UserInfo>> refresh(
      {bool cacheToken = true,
      String? appCheckToken,
      bool isMock = false}) async {
    try {
      Response response = await _getDio(isMock).post(
        '/refresh',
        options: Options(
          headers: {
            'Authorization': 'Bearer ${await loadToken()}',
            if (appCheckToken != null) 'X-Firebase-AppCheck': appCheckToken,
          },
        ),
      );
      var userInfo = UserInfo.fromJson(response.data);
      await loadToken(newToken: userInfo.token ?? '', cacheToken: cacheToken);
      return OctobaseResponse<UserInfo>(
        statusCode: response.statusCode,
        statusMessage: response.statusMessage,
        response: response,
        headers: response.headers,
        data: userInfo,
      );
    } on DioException catch (ex) {
      if (ex.error is SocketException) {
        logger.e("Error => Not able to connect to the server");
        throw ServerConnectionError(ex.message!);
      } else {
        OctobaseError error = OctobaseError.fromJson(ex.response?.data);
        logger.e(
            "Error => Status Code: ${ex.response?.statusCode}, Code: ${error.code}, Message: ${error.message}");
        throw OctobaseResponse<OctobaseError>(
            statusCode: ex.response?.statusCode,
            statusMessage: ex.response?.statusMessage,
            response: ex.response,
            headers: ex.response?.headers,
            data: error,
            isError: true);
      }
    }
  }

  Future<OctobaseResponse<OctobaseSuccess>> logout(
      {bool isMock = false}) async {
    try {
      Response response = await _getDio(isMock).post(
        '/logout',
        options: Options(
          headers: {'Authorization': 'Bearer ${await loadToken()}'},
        ),
      );
      var success = OctobaseSuccess.fromJson(response.data);
      token = '';
      await _clearToken();
      return OctobaseResponse<OctobaseSuccess>(
        statusCode: response.statusCode,
        statusMessage: response.statusMessage,
        response: response,
        headers: response.headers,
        data: success,
      );
    } on DioException catch (ex) {
      if (ex.error is SocketException) {
        logger.e("Error => Not able to connect to the server");
        throw ServerConnectionError(ex.message!);
      } else {
        OctobaseError error = OctobaseError.fromJson(ex.response?.data);
        logger.e(
            "Error => Status Code: ${ex.response?.statusCode}, Code: ${error.code}, Message: ${error.message}");
        throw OctobaseResponse<OctobaseError>(
            statusCode: ex.response?.statusCode,
            statusMessage: ex.response?.statusMessage,
            response: ex.response,
            headers: ex.response?.headers,
            data: error,
            isError: true);
      }
    }
  }

  Future<OctobaseResponse<UserInfo>> user({bool isMock = false}) async {
    try {
      Response response = await _getDio(isMock).get(
        '/user',
        options: Options(
          headers: {'Authorization': 'Bearer ${await loadToken()}'},
        ),
      );
      var userInfo = UserInfo.fromJson(response.data);
      token = userInfo.token ?? '';
      return OctobaseResponse<UserInfo>(
        statusCode: response.statusCode,
        statusMessage: response.statusMessage,
        response: response,
        headers: response.headers,
        data: userInfo,
      );
    } on DioException catch (ex) {
      if (ex.error is SocketException) {
        logger.e("Error => Not able to connect to the server");
        throw ServerConnectionError(ex.message!);
      } else {
        OctobaseError error = OctobaseError.fromJson(ex.response?.data);
        logger.e(
            "Error => Status Code: ${ex.response?.statusCode}, Code: ${error.code}, Message: ${error.message}");
        throw OctobaseResponse<OctobaseError>(
            statusCode: ex.response?.statusCode,
            statusMessage: ex.response?.statusMessage,
            response: ex.response,
            headers: ex.response?.headers,
            data: error,
            isError: true);
      }
    }
  }

  Future<OctobaseResponse<OctobaseSuccess>> checkToken(
      {bool isMock = false}) async {
    try {
      Response response = await _getDio(isMock).get(
        '/user',
        options: Options(
          headers: {'Authorization': 'Bearer ${await loadToken()}'},
        ),
      );
      var success = OctobaseSuccess.fromJson(response.data);
      return OctobaseResponse<OctobaseSuccess>(
        statusCode: response.statusCode,
        statusMessage: response.statusMessage,
        response: response,
        headers: response.headers,
        data: success,
      );
    } on DioException catch (ex) {
      if (ex.error is SocketException) {
        logger.e("Error => Not able to connect to the server");
        throw ServerConnectionError(ex.message!);
      } else {
        OctobaseError error = OctobaseError.fromJson(ex.response?.data);
        logger.e(
            "Error => Status Code: ${ex.response?.statusCode}, Code: ${error.code}, Message: ${error.message}");
        throw OctobaseResponse<OctobaseError>(
            statusCode: ex.response?.statusCode,
            statusMessage: ex.response?.statusMessage,
            response: ex.response,
            headers: ex.response?.headers,
            data: error,
            isError: true);
      }
    }
  }

  Future<OctobaseResponse> selectAll<T>(
    T Function(Map<String, dynamic>) fromJson, {
    String? controller,
    String? mainRoute,
    String action = '',
    int? page,
    int? perPage,
    String? userId,
    String? own,
    String? withOthers,
    String? select,
    String? where,
    String? order,
    bool isMock = false,
  }) async {
    mainRoute ??= this.mainRoute;
    controller ??= Pluralize().plural(T.toString().toLowerCase());
    if (action != '') {
      controller = '$controller/$action';
    }
    try {
      var data = {};
      data['page'] = page ?? data['page'];
      data['perPage'] = perPage ?? data['perPage'];
      data['userId'] = userId ?? data['userId'];
      data['own'] = own ?? data['own'];
      data['with'] = withOthers ?? data['with'];
      data['select'] = select ?? data['select'];
      data['where'] = where ?? data['where'];
      data['order'] = order ?? data['order'];

      Response response = await _getDio(isMock).get(
        '/$mainRoute/$controller',
        data: data,
        options: Options(
          headers: {'Authorization': 'Bearer ${await loadToken()}'},
        ),
      );

      var obj = response.data.map<T>((item) => fromJson(item)).toList();
      return OctobaseResponse<List<T>>(
        statusCode: response.statusCode,
        statusMessage: response.statusMessage,
        response: response,
        headers: response.headers,
        data: obj,
      );
    } on DioException catch (ex) {
      if (ex.error is SocketException) {
        logger.e("Error => Not able to connect to the server");
        throw ServerConnectionError(ex.message!);
      } else {
        OctobaseError error = OctobaseError.fromJson(ex.response?.data);
        logger.e(
            "Error => Status Code: ${ex.response?.statusCode}, Code: ${error.code}, Message: ${error.message}");
        throw OctobaseResponse<OctobaseError>(
            statusCode: ex.response?.statusCode,
            statusMessage: ex.response?.statusMessage,
            response: ex.response,
            headers: ex.response?.headers,
            data: error,
            isError: true);
      }
    }
  }

  Future<OctobaseResponse> selectOne<T>(
    T Function(Map<String, dynamic>) fromJson,
    int id, {
    String? controller,
    String? mainRoute,
    String action = '',
    String? userId,
    String? own,
    String? withOthers,
    String? select,
    String? where,
    String? order,
    bool isMock = false,
  }) async {
    mainRoute ??= this.mainRoute;
    controller ??= Pluralize().plural(T.toString().toLowerCase());
    if (action != '') {
      controller = '$controller/$action';
    }
    try {
      var data = {};
      data['with'] = withOthers ?? data['with'];
      data['select'] = select ?? data['select'];

      Response response = await _getDio(isMock).get(
        '/$mainRoute/$controller/$id',
        data: data,
        options: Options(
          headers: {'Authorization': 'Bearer ${await loadToken()}'},
        ),
      );
      var obj = fromJson(response.data);
      return OctobaseResponse<T>(
        statusCode: response.statusCode,
        statusMessage: response.statusMessage,
        response: response,
        headers: response.headers,
        data: obj,
      );
    } on DioException catch (ex) {
      if (ex.error is SocketException) {
        logger.e("Error => Not able to connect to the server");
        throw ServerConnectionError(ex.message!);
      } else {
        OctobaseError error = OctobaseError.fromJson(ex.response?.data);
        logger.e(
            "Error => Status Code: ${ex.response?.statusCode}, Code: ${error.code}, Message: ${error.message}");
        throw OctobaseResponse<OctobaseError>(
            statusCode: ex.response?.statusCode,
            statusMessage: ex.response?.statusMessage,
            response: ex.response,
            headers: ex.response?.headers,
            data: error,
            isError: true);
      }
    }
  }

  Future<OctobaseResponse> add<T>(
    T Function(Map<String, dynamic>) fromJson, {
    Map<String, dynamic>? data,
    String? controller,
    String? mainRoute,
    String action = '',
    bool isMock = false,
  }) async {
    mainRoute ??= this.mainRoute;
    controller ??= Pluralize().plural(T.toString().toLowerCase());
    if (action != '') {
      controller = '$controller/$action';
    }
    try {
      Response response = await _getDio(isMock).post(
        '/$mainRoute/$controller',
        data: data,
        options: Options(
          headers: {'Authorization': 'Bearer ${await loadToken()}'},
        ),
      );
      var obj = fromJson(response.data);
      return OctobaseResponse<T>(
        statusCode: response.statusCode,
        statusMessage: response.statusMessage,
        response: response,
        headers: response.headers,
        data: obj,
      );
    } on DioException catch (ex) {
      if (ex.error is SocketException) {
        logger.e("Error => Not able to connect to the server");
        throw ServerConnectionError(ex.message!);
      } else {
        OctobaseError error = OctobaseError.fromJson(ex.response?.data);
        logger.e(
            "Error => Status Code: ${ex.response?.statusCode}, Code: ${error.code}, Message: ${error.message}");
        throw OctobaseResponse<OctobaseError>(
            statusCode: ex.response?.statusCode,
            statusMessage: ex.response?.statusMessage,
            response: ex.response,
            headers: ex.response?.headers,
            data: error,
            isError: true);
      }
    }
  }

  Future<OctobaseResponse> addOrUpdate<T>(
    T Function(Map<String, dynamic>) fromJson, {
    Map<String, dynamic>? data,
    String? userId,
    String? own,
    String? withOthers,
    String? select,
    String? where,
    bool update = true,
    String? controller,
    String? mainRoute,
    String action = '',
    bool isMock = false,
  }) async {
    var meta = {};
    meta['userId'] = userId ?? meta['userId'];
    meta['own'] = own ?? meta['own'];
    meta['with'] = withOthers ?? meta['with'];
    meta['select'] = select ?? meta['select'];
    meta['where'] = where ?? meta['where'];

    mainRoute ??= this.mainRoute;
    controller ??= Pluralize().plural(T.toString().toLowerCase());
    if (action != '') {
      controller = '$controller/$action';
    }
    try {
      Response? responseSearch;
      if (where != null) {
        responseSearch = await _getDio(isMock).get(
          '/$mainRoute/$controller',
          data: meta,
          options: Options(
            headers: {'Authorization': 'Bearer ${await loadToken()}'},
          ),
        );
      }

      int? id;
      try {
        id = responseSearch?.data?.first['id'];
      } catch (e) {
        id = null;
      }

      if (id == null) {
        Response response = await _getDio(isMock).post(
          '/$mainRoute/$controller',
          data: data,
          options: Options(
            headers: {'Authorization': 'Bearer ${await loadToken()}'},
          ),
        );
        var obj = fromJson(response.data);
        return OctobaseResponse<T>(
          statusCode: response.statusCode,
          statusMessage: response.statusMessage,
          response: response,
          headers: response.headers,
          data: obj,
        );
      } else {
        if (update) {
          Response response = await _getDio(isMock).post(
            '/$mainRoute/$controller/$id}',
            data: data,
            options: Options(
              headers: {'Authorization': 'Bearer ${await loadToken()}'},
            ),
          );
          var obj = fromJson(response.data);
          return OctobaseResponse<T>(
            statusCode: response.statusCode,
            statusMessage: response.statusMessage,
            response: response,
            headers: response.headers,
            data: obj,
          );
        } else {
          var obj = fromJson(responseSearch?.data?.first);
          return OctobaseResponse<T>(
            data: obj,
          );
        }
      }
    } on DioException catch (ex) {
      if (ex.error is SocketException) {
        logger.e("Error => Not able to connect to the server");
        throw ServerConnectionError(ex.message!);
      } else {
        OctobaseError error = OctobaseError.fromJson(ex.response?.data);
        logger.e(
            "Error => Status Code: ${ex.response?.statusCode}, Code: ${error.code}, Message: ${error.message}");
        throw OctobaseResponse<OctobaseError>(
            statusCode: ex.response?.statusCode,
            statusMessage: ex.response?.statusMessage,
            response: ex.response,
            headers: ex.response?.headers,
            data: error,
            isError: true);
      }
    }
  }

  Future<OctobaseResponse> update<T>(
    T Function(Map<String, dynamic>) fromJson,
    int id, {
    Map<String, dynamic>? data,
    String? controller,
    String? mainRoute,
    String action = '',
    bool isMock = false,
  }) async {
    mainRoute ??= this.mainRoute;
    controller ??= Pluralize().plural(T.toString().toLowerCase());
    if (action != '') {
      controller = '$controller/$action';
    }
    try {
      Response response = await _getDio(isMock).post(
        '/$mainRoute/$controller/$id',
        data: data,
        options: Options(
          headers: {'Authorization': 'Bearer ${await loadToken()}'},
        ),
      );
      var obj = fromJson(response.data);
      return OctobaseResponse<T>(
        statusCode: response.statusCode,
        statusMessage: response.statusMessage,
        response: response,
        headers: response.headers,
        data: obj,
      );
    } on DioException catch (ex) {
      if (ex.error is SocketException) {
        logger.e("Error => Not able to connect to the server");
        throw ServerConnectionError(ex.message!);
      } else {
        OctobaseError error = OctobaseError.fromJson(ex.response?.data);
        logger.e(
            "Error => Status Code: ${ex.response?.statusCode}, Code: ${error.code}, Message: ${error.message}");
        throw OctobaseResponse<OctobaseError>(
            statusCode: ex.response?.statusCode,
            statusMessage: ex.response?.statusMessage,
            response: ex.response,
            headers: ex.response?.headers,
            data: error,
            isError: true);
      }
    }
  }

  Future<OctobaseResponse> delete<T>(
    int id, {
    String? controller,
    String? mainRoute,
    String action = '',
    bool isMock = false,
  }) async {
    mainRoute ??= this.mainRoute;
    controller ??= Pluralize().plural(T.toString().toLowerCase());
    if (action != '') {
      controller = '$controller/$action';
    }
    try {
      Response response = await _getDio(isMock).delete(
        '/$mainRoute/$controller/$id',
        options: Options(
          headers: {'Authorization': 'Bearer ${await loadToken()}'},
        ),
      );
      var success = OctobaseSuccess.fromJson(response.data);
      return OctobaseResponse<OctobaseSuccess>(
        statusCode: response.statusCode,
        statusMessage: response.statusMessage,
        response: response,
        headers: response.headers,
        data: success,
      );
    } on DioException catch (ex) {
      if (ex.error is SocketException) {
        logger.e("Error => Not able to connect to the server");
        throw ServerConnectionError(ex.message!);
      } else {
        OctobaseError error = OctobaseError.fromJson(ex.response?.data);
        logger.e(
            "Error => Status Code: ${ex.response?.statusCode}, Code: ${error.code}, Message: ${error.message}");
        throw OctobaseResponse<OctobaseError>(
            statusCode: ex.response?.statusCode,
            statusMessage: ex.response?.statusMessage,
            response: ex.response,
            headers: ex.response?.headers,
            data: error,
            isError: true);
      }
    }
  }

  Future<OctobaseResponse> custom<T>(
    T Function(Map<String, dynamic>) fromJson,
    String? url,
    ActionType actionType, {
    String? mainRoute,
    Object? data,
    Map<String, dynamic>? queryParams,
    bool isList = false,
    isNullResponse = false,
    bool isMock = false,
  }) async {
    mainRoute ??= this.mainRoute;
    var headers = <String, dynamic>{};
    headers['Authorization'] = 'Bearer ${await loadToken()}';
    Response? response;
    try {
      switch (actionType) {
        case ActionType.put:
          response = await _getDio(isMock).put(
            '/$mainRoute/$url',
            data: data,
            queryParameters: queryParams,
            options: Options(
              headers: headers,
            ),
          );
          break;
        case ActionType.get:
          response = await _getDio(isMock).get(
            '/$mainRoute/$url',
            data: data,
            queryParameters: queryParams,
            options: Options(
              headers: headers,
            ),
          );
          break;
        case ActionType.delete:
          response = await _getDio(isMock).delete(
            '/$mainRoute/$url',
            data: data,
            queryParameters: queryParams,
            options: Options(
              headers: headers,
            ),
          );
          break;
        default:
          response = await _getDio(isMock).post(
            '/$mainRoute/$url',
            data: data,
            queryParameters: queryParams,
            options: Options(
              headers: headers,
            ),
          );
      }

      if (isNullResponse) {
        return OctobaseResponse<T>(
          statusCode: response.statusCode,
          statusMessage: response.statusMessage,
          response: response,
          headers: response.headers,
          data: null,
        );
      }

      if (isList) {
        var obj = response.data.map<T>((item) => fromJson(item)).toList();
        return OctobaseResponse<List<T>>(
          statusCode: response.statusCode,
          statusMessage: response.statusMessage,
          response: response,
          headers: response.headers,
          data: obj,
        );
      } else {
        var obj = fromJson(response.data);
        return OctobaseResponse<T>(
          statusCode: response.statusCode,
          statusMessage: response.statusMessage,
          response: response,
          headers: response.headers,
          data: obj,
        );
      }
    } on DioException catch (ex) {
      if (ex.error is SocketException) {
        logger.e("Error => Not able to connect to the server");
        throw ServerConnectionError(ex.message!);
      } else {
        OctobaseError error = OctobaseError.fromJson(ex.response?.data);
        logger.e(
            "Error => Status Code: ${ex.response?.statusCode}, Code: ${error.code}, Message: ${error.message}");
        throw OctobaseResponse<OctobaseError>(
            statusCode: ex.response?.statusCode,
            statusMessage: ex.response?.statusMessage,
            response: ex.response,
            headers: ex.response?.headers,
            data: error,
            isError: true);
      }
    }
  }
}
