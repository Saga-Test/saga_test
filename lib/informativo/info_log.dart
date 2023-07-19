import 'package:dio/dio.dart';

class InfoLog {
  InfoLog({
    this.url = "N/A",
    this.method = "N/A",
    this.controller = "N/A",
    this.nomeMetodo = "N/A",
    this.descricao = "N/A",
    this.parametros,
    this.tempo = "N/A",
    this.isErro = false,
    this.erro = "N/A",
    this.response,
    this.tipoResultado,
    this.result,
  });

  String url;
  String method;
  String controller;
  String nomeMetodo;
  String descricao;
  Map<String, dynamic>? parametros;
  String tempo;
  // PARTE DE ERROR
  bool isErro;
  String erro;

  // PARTE DE RESULTADO
  Response<dynamic>? response;
  int? tipoResultado;
  dynamic result;
}
