import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// extension IterableEX<T> on Iterable<T> {
//   T? get firstOrNull => this.isEmpty ? null : this.first;
// }

///
/// tryParseDate:
/// aceita datas 21/07/2021, 21.07.2021 e 21072021
///
DateTime? tryParseDate(String value, {bool forceParse = false, FocusNode? focus}) {
  DateTime parse(String format, String value) {
    final result = DateFormat(format).parse(value);
    return result.year >= 1900 && result.year <= 2099 ? result : throw FormatException();
  }

  try {
    final containsSeparator = value.contains('/') || value.contains('.');

    // já tem digitação para converter???
    // 1/1/2021, 1.1.2021 ou 01012021: length == 8
    if (
        // 20/12/21 ou 20/12/2021 ???
        (containsSeparator && (value.length == 8 || value.length == 10)) ||
            // 201221 ou 20122021 ???
            (!containsSeparator && (value.length == 6 || value.length == 8))) {
      if (value.contains('/')) return parse('d/M/yy', value);
      if (value.contains('.')) return parse('d.M.yy', value);
      if (value.length == 6 || value.length == 8)
        return parse('d-M-yy',
            '${value.substring(0, 2)}-${value.substring(2, 4)}-${value.substring(4)}');
    }

    // valor ainda é inválido e é obrigado a converter...
    if (forceParse) throw FormatException();
  } catch (ex) {
    if (forceParse) {
      focus?.requestFocus();
      final message = value.isEmpty ? 'Campo obrigatório' : 'Data "$value" inválida';
      throw Exception(message);
    }
  }

  return null;
}

String formatDate(DateTime? value) {
  if (value == null) return '';

  final formatter = DateFormat('dd/MM/yyyy');
  final result = formatter.format(value);
  return result;
}

int? parseInt(String value) {
  if (value.isEmpty) return null;

  final result = int.parse(value);
  return result;
}
