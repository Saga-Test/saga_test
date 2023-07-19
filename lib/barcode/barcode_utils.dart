import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

//---------------------------------------------------------------------------------------------
// Utils
//---------------------------------------------------------------------------------------------
bool debugON = true;

debug(String value) {
  if (!debugON) return;
  debugPrint(value);
}

debugIf(bool condition, String value) {
  if (!debugON) return;
  if (condition) debugPrint(value);
}

extension StringEx on String {
  double toDecimal(String format) {
    // string= '1234,56' -> double= 1234.56
    var value = replaceAll(',', '.');

    // para o caso de não ter vírgula no número: aí o format entra em ação...
    if (format.isNotEmpty) {
      // se format= '999,9999' e string= '123456' -> double = 12.3456
      final p = format.replaceAll(',', '.').indexOf('.');
      if (p >= 0) {
        final decimalPlaces = format.length - 1 - p;
        value = value.insert(value.length - decimalPlaces, '.');
      }
    }

    final result = double.parse(value);
    return result;
  }

  DateTime toDate(String format, int day) {
    // temos que usar parseStrict(), para evitar que mês 13 some 1 ao ano!!!
    // para isto, ano tem que ter 4 dígitos!!!
    var value = this;
    format = format.isEmpty
        ? value.length == 8
            ? 'YYYYMMDD'
            : 'YYMMDD'
        : format.toUpperCase();

    // garante ano com 4 dígitos!!!
    if (!format.contains('YYYY')) {
      format = format.replaceFirst('YY', 'YYYY');

      final p = format.indexOf('YY');
      value = '${substring(0, p)}20${substring(p)}';
    }

    final sbFormat = StringBuffer();
    final sbValue = StringBuffer();

    // 08/06/2020 - parser só funciona com separador!!!
    for (var i = 0; i < format.length; i++) {
      if (i > 0 && format[i] != format[i - 1]) {
        if ('DMY'.contains(format[i]) && 'DMY'.contains(format[i - 1])) {
          sbFormat.write('/');
          sbValue.write('/');
        }
      }
      sbFormat.write(format[i]);
      sbValue.write(value[i]);
    }

    // fixFormat/fixValue contém obrigatoriamente separadores!!!
    format = sbFormat.toString().replaceAll('D', 'd').replaceAll('Y', 'y');
    value = sbValue.toString();

    final formatter = DateFormat(format);

    // converte tanto ano/mes quanto data completa...
    DateTime result;
    if (!format.contains('dd')) {
      final yymm = formatter.parseStrict(value);
      result = day == 1 ? yymm.toFirstDayOfMonth() : yymm.toLastDayOfMonth();
    } else {
      result = formatter.parseStrict(value);
    }

    return result;
  }

  String insert(int index, String value) {
    return substring(0, index) + value + substring(index);
  }
}

extension DateEx on DateTime {
  String toFormat(String format) {
    final formatter = DateFormat(format);
    return formatter.format(this);
  }

  String toDDMMYY() => toFormat('dd/MM/yy');

  DateTime toFirstDayOfMonth() => DateTime(year, month, 1);

  DateTime toLastDayOfMonth() => DateTime(year, month + 1, 0);
}

// 1.5 -> 1,5
// 060.0 -> 60
String formatNumeric(double value) {
  // se terminar com '.0', tira as decimais senão troca '.' por ','
  var result = value.toString();
  if (result.endsWith('.0')) {
    result = result.replaceFirst('.0', '');
  } else {
    result = result.replaceAll('.', ',');
  }
  return result;
}

