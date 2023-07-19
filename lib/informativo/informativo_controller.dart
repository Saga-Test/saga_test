import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:translator/translator.dart';

import 'info_log.dart';

class InformativoController extends ChangeNotifier {
  InformativoController._();

  static ValueNotifier<List<InfoLog>> logList = ValueNotifier([]);
  static InfoLog get lastLog => logList.value.last;

  static RequestOptions? request;
  static Response<dynamic>? response;
  static int? timerResponse;
  static DioError? dioError;

  static bool autoUpdate = true;

  static InfoLog _creteLog() {
    final log = InfoLog();

    if (request == null) return log;

    final pathSplit = request!.path.split("/");

    log.url = request!.baseUrl;

    log.nomeMetodo = pathSplit.last;
    log.controller = pathSplit[pathSplit.length - 2];
    log.method = request!.method;
    log.parametros = request?.method == 'GET' ? request?.queryParameters : request?.data;

    return log;
  }

  static void _addLog(InfoLog log) {
    logList.value.add(log);
    if (autoUpdate) logList.notifyListeners();
  }

  static Future<void> addError(DioError error, int timer) async {
    final log = _creteLog();

    log.tempo = "$timer (ms)";
    log.isErro = true;
    log.erro =
        dioError!.type == DioErrorType.badResponse && dioError!.response!.statusCode == 500
            ? dioError!.response?.data['Message']
            : dioError!.message;

    final erro = await GoogleTranslator().translate(log.erro, to: "pt");
    log.erro = erro.text;

    _addLog(log);
  }

  static void addResult(dynamic result, int tipo, int value) {
    final log = _creteLog();

    log.tempo = timerResponse.toString();
    log.response = response;

    log.tipoResultado = tipo;
    log.result = result;

    _addLog(log);
  }

  static void clearList() {
    logList.value.clear();
    logList.notifyListeners();
  }

  static void deleteLog(InfoLog selectedLog) {
    logList.value.remove(selectedLog);
    logList.notifyListeners();
  }
}
