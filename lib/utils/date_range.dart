import 'package:flutter/material.dart';

import '../saga_lib/sa_extensions.dart';
import 'utils.dart';

//--------------------------------------------------------------------------------------------
// DateRange
//--------------------------------------------------------------------------------------------
class DateRange {
  DateRange(this.input1, this.input2, this.prazoEmDias) {
    input1.addListener(() => _listeningDates(input1));
    input2.addListener(() => _listeningDates(input2));
  }

  final TextEditingController input1;
  final TextEditingController input2;
  int prazoEmDias;

  final _lastValues = Map<TextEditingController, String>();

  void setDates(DateTime data1, DateTime data2) {
    prazoEmDias = data2.difference(data1).inDays;
    input1.text = formatDate(data1);
    input2.text = formatDate(data2);
  }

  void _calculateRange(TextEditingController input) {
    final value = input.text;
    final lastValue = _lastValues[input] ?? '';

    // este evento é chamado às vezes sem mudar o valor...
    if (value == lastValue) return;

    // se está apagando, apenas limpa o outro campo...
    final apagando = value.length < lastValue.length;
    if (apagando) {
      input == input1 ? input2.clear() : input1.clear();
    } else {
      // se data ainda é inválida, nada mais a fazer...
      final data = tryParseDate(value);
      if (data == null) return;

      final prazo = Duration(days: prazoEmDias);
      final data1 = input == input1 ? data : data.subtract(prazo);
      final data2 = input == input2 ? data : data.add(prazo);

      input1.text = formatDate(data1);
      input2.text = formatDate(data2);
      input.selection = TextSelection.fromPosition(TextPosition(offset: input.text.length));
    }

    _lastValues[input1] = input1.text;
    _lastValues[input2] = input2.text;
  }

  bool _executing = false;

  void _listeningDates(TextEditingController input) {
    // ignora chamadas feitas pelas leitura do scanner...
    if (input.text.isScannerValue) return;

    // evita recursividade...
    if (_executing) return;

    _executing = true;
    try {
      _calculateRange(input);
    } finally {
      _executing = false;
    }
  }
}
