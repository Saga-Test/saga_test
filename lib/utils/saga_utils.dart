import 'package:flutter/material.dart';

class SAGAUtils {
  static void checkEndereco(TextEditingController input, String value) {
    if (input.text.isEmpty) {
      throw Exception('Campo obrigatório');
    }

    final inputValue = input.text;

    if (_isNotEnderecoIgual(inputValue, value)) {
      throw Exception('Endereço inválido');
    }
  }

  static void checkValor(TextEditingController input, String value) {
    if (input.text.isEmpty) {
      throw Exception('Campo obrigatório');
    }

    final inputValue = input.text;

    if (inputValue == value) {
      throw Exception('Valor inválido');
    }
  }

  // compara 2 endereços...
  static bool _isEnderecoIgual(String e1, String e2) =>
      e1.replaceAll('.', '') == e2.replaceAll('.', '');

  static bool _isNotEnderecoIgual(String e1, String e2) => !_isEnderecoIgual(e1, e2);
}

