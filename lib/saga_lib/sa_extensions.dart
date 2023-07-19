import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'sa_api.dart';

extension ListEx<T> on List<T> {
  List<T> orderBy(Comparable value(T item)) {
    var list = List.of(this);

    list.sort((a, b) => value(a).compareTo(value(b)));

    return list;
  }
}

extension TextEditingControllerEx on TextEditingController {
  void selectAll() =>
      this.selection = TextSelection(baseOffset: 0, extentOffset: this.text.length);

  int getInt() {
    try {
      return int.parse(this.text);
    } on FormatException {
      throw Exception('Valor inválido: ${this.text}');
    }
  }
}

extension BuildContextEx on BuildContext {
  void close() => Navigator.pop(this);
}

extension ExceptionEx on Exception {
  String get message => this.toString().substringAfter('Exception: ');
}

extension StringEx on String {
  String substringAfter(String value) => this.substring(this.indexOf(value) + value.length);

  String substringFrom(String value) => this.substring(this.indexOf(value));
  String substringUntil(String value) => this.substring(0, this.indexOf(value));

  String toCamelCase() => this.length > 1
      ? this.substring(0, 1).toLowerCase() + this.substring(1)
      : this.length == 1
          ? this.substring(0, 1).toLowerCase()
          : this;

  String takeLast(int size) => this.substring(this.length - size);

  bool get isScannerValue => this.startsWith('ta') && this.endsWith('te');
}

extension DateTimeEx on DateTime {
  DateTime get date => DateTime(this.year, this.month, this.day);

  DateTime get time => DateTime(
      0, 0, 0, this.hour, this.minute, this.second, this.millisecond, this.microsecond);

  static DateTime today() => DateTime.now().date;

  static var appDateFormat = 'dd/MM/yyyy';

  static DateTime parse(String value, {String? format}) {
    var result = DateFormat(format ?? appDateFormat).parse(value);
    return result;
  }

  String format([String? format]) {
    var result = DateFormat(format ?? appDateFormat).format(this);
    return result;
  }

  static Future<DateTime> systemNow() async {
    final api = SAApi();
    final result = await api.getServerTime();
    return result;
  }

  static Future<DateTime> get systemDate async {
    final result = await systemNow();
    return result.date;
  }

  static Future<DateTime> get systemTime async {
    final result = await systemNow();
    return result.time;
  }
}

extension DoubleEx on double {
  static var mensuravelMaxDecimais = 3;

  String toQuantidade(bool mensuravel) {
    final formatter = mensuravel
        ? NumberFormat('0.${'0' * mensuravelMaxDecimais}', 'pt_BR')
        : NumberFormat('0');

    final result = formatter.format(this);
    return result;
  }
}
