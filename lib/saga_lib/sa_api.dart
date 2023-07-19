import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:saga_test/informativo/informativo_controller.dart';

String baseURLUser = '';
Duration connectTimeoutUser = const Duration(seconds: 5);
Duration receiveTimeoutUser = const Duration(seconds: 5);
void Function({String message})? showProgress;
void Function()? hideProgress;

class SAApi {
  /// [baseURL] Request base url, it can contain sub path, like: "https://www.google.com/api/".
  ///
  /// [connectTimeout] Timeout in milliseconds for opening url.
  /// [Dio] will throw the [DioError] with [DioErrorType.CONNECT_TIMEOUT] type
  ///  when time out.
  ///
  /// [receiveTimeout] Timeout in milliseconds for receiving data.
  /// [Dio] will throw the [DioError] with [DioErrorType.RECEIVE_TIMEOUT] type
  /// when time out.
  ///
  /// [0] meanings no timeout limit.
  SAApi({
    String? baseURL,
    Duration? connectTimeout,
    Duration? receiveTimeout,
  }) {
    dio.options.baseUrl = baseURL ?? baseURLUser;
    dio.options.connectTimeout = connectTimeout ?? connectTimeoutUser;
    dio.options.receiveTimeout = receiveTimeout ?? receiveTimeoutUser;

    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (request, handler) {
        onRequest(request);
        handler.next(request);
      },
      onResponse: (response, handler) {
        onResponse(response);
        handler.next(response);
      },
      onError: (error, handler) {
        onError(error);
        handler.next(error);
      },
    ));
  }

  final dio = Dio();

  var waitProgress = 0;

  final timer = Timer();

  void logRequest(RequestOptions request) {
    final parameters = request.method == 'GET' ? request.queryParameters : request.data;
    debugPrint('\n${request.method} ${request.path} $parameters');
  }

  void logResponse(String result, Timer timer) {
    debugPrint(result);
    debugPrint('TIMER(ms) ${timer.value}');
  }

  void onRequest(RequestOptions request) async {
    timer.reset();
    timer.start();

    logRequest(request);

    showProgress?.call();
    if (waitProgress > 0) {
      await Future.delayed(Duration(milliseconds: waitProgress));
    }

    InformativoController.request = request;
  }

  void onResponse(Response<dynamic> response) {
    timer.stop();

    logResponse('RESULT: $response', timer);

    InformativoController.response = response;
    InformativoController.timerResponse = timer.value;

    hideProgress?.call();
  }

  void onError(DioError dioError) {
    timer.stop();

    logRequest(dioError.requestOptions);

    // se foi erro do server, obtém a mensagem de erro...
    // if (dioError.type == DioErrorType.response && dioError.response?.statusCode == 500) {
    //   dioError.error = dioError.response?.data['Message'];
    // }

    logResponse('ERROR: ${dioError.message}', timer);

    InformativoController.dioError = dioError;
    InformativoController.addError(dioError, timer.value);
    hideProgress?.call();
  }

  Future<DateTime> getServerTime() async {
    final response = await dio.get('/api/Configuracoes/GetDataHoraDataBase');
    final result = DateTime.parse(response.data as String);
    return result;
  }

  Future<String> getString(String path, Map<String, dynamic> values) async {
    final response = await dio.get(path, queryParameters: values);
    final result = getResult(response, null);
    return result ?? '';
  }

  Future<List<T>> getList<T>(
    String path,
    Map<String, dynamic> values,
    T Function(Map<String, dynamic>) fromJson, {
    String descricao = "N/A",
  }) async {
    final response = await dio.get(path, queryParameters: values);
    final list = getResult(response, fromJson);
    return list;
  }

  Future<T?> get<T>(
    String path,
    Map<String, dynamic> values,
    T Function(Map<String, dynamic>)? fromJson, {
    String descricao = 'N/A',
  }) async {
    final response = await dio.get(path, queryParameters: values);
    final result = getResult(response, fromJson);
    return result;
  }

  Future<T?> post<T>(
    String path,
    Map<String, dynamic> values, {
    T Function(Map<String, dynamic>)? fromJson,
    String descricao = 'N/A',
  }) async {
    final response = await dio.post(path, data: values);
    final result = getResult(response, fromJson);
    return result;
  }

  Future<List<T>> postList<T>(
    String path,
    Map<String, dynamic> values,
    T Function(Map<String, dynamic>)? fromJson, {
    String descricao = 'N/A',
  }) async {
    final response = await dio.post(path, data: values);
    final list = getResult(response, fromJson);
    return list;
  }

  dynamic getResult<T>(Response response, T Function(Map<String, dynamic>)? fromJson) {
    final timer = Timer();
    timer.start();

    TiposResult tipo = TiposResult.primitivo;
    dynamic result;
    try {
      if (fromJson == null) {
        tipo = TiposResult.primitivo;
        result = response.data;
        return result;
      }

      if (response.data is Map) {
        tipo = TiposResult.classType;
        result = fromJson(response.data as Map<String, dynamic>);
        return result;
      }

      if (response.data is List) {
        tipo = TiposResult.listClass;
        result = (response.data as List).map((json) => fromJson(json)).toList();
        return result;
      }

      result = response.data;
      return result;
    } catch (ex) {
      debugPrint('\n\n\n');
      debugPrint('******************************************************************');
      debugPrint('***** ERRO NO DECODE:\n${ex.toString()}');
      debugPrint('******************************************************************');
      debugPrint('\n\n\n');
      rethrow;
    } finally {
      InformativoController.addResult(result, tipo.index, timer.value);
      timer.stop();
      debugPrint('DECODE JSON(ms) ${timer.value}');
    }
  }
}

enum TiposResult {
  primitivo,
  classType,
  listClass,
}

class Timer {
  void start() {
    if (_millis < 0) return;
    _millis -= DateTime.now().millisecondsSinceEpoch;
  }

  void stop() {
    if (_millis >= 0) return;
    _millis += DateTime.now().millisecondsSinceEpoch;
  }

  void reset() => _millis = 0;

  int _millis = 0;

  int get value => _millis >= 0 ? _millis : _millis + DateTime.now().millisecondsSinceEpoch;
}
