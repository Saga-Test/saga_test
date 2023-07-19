import 'package:flutter/material.dart';

import '../saga_lib/sa_error.dart';
import 'barcode.dart';
import 'barcode_field.dart';

const prefix = 'ta';
const suffix = 'te';

typedef BeepCallback = void Function(TextEditingController, BarcodeResult);

class BarcodeReader {
  BarcodeReader(this.context, {this.onBeep});

  final BuildContext context;
  final BeepCallback? onBeep;

  final mapControllers = <TextEditingController, String>{};
  final mapCallbacks = <TextEditingController, VoidCallback>{};
  var running = false;

  // último barcode lido...
  BarcodeResult? lastResult;

  // atividade em execução - usada para restringir digitação...
  int? atividade;

  void addBarcodeStates(List<BarcodeState?> states) {
    for (final state in states) {
      if (state == null) continue;
      addField(state.controller, state.field);
    }
  }

  void addField(TextEditingController controller, AIField ai) {
    addFieldByName(controller, ai.name);
  }

  void addFieldByName(TextEditingController controller, String fieldName) {
    final listener = () => listening(controller);
    controller.addListener(listener);

    mapCallbacks[controller] = listener;
    mapControllers[controller] = fieldName;
  }

  void removeField(TextEditingController controller) {
    final listener = mapCallbacks[controller]!;
    controller.removeListener(listener);

    mapCallbacks.remove(controller);
    mapControllers.remove(controller);
  }

  void clearFields() {
    // percorre o mapa usando uma cópia, para poder remover seus itens!!!
    final list = mapControllers.keys.toList();
    list.forEach((controller) => removeField(controller));
  }

  bool isBarcode(String text) {
    return text.startsWith(prefix) && text.endsWith(suffix);
  }

  bool podeDigitar(TextEditingController controller) {
    // se não definiu a atividade, pode tudo...
    if (atividade == null) return true;

    // procura permissões da atividade: se não achou, pode tudo...
    final permissoes = BarcodeManager.instance.permissoesAtividades[atividade];
    if (permissoes == null) return true;

    // procura o campo AI: se não achou, pode tudo...
    final fieldName = mapControllers[controller];
    if (fieldName == null) return true;

    final ai = AIField.values.byName(fieldName);
    switch (ai) {
      case AIField.codend:
        return permissoes.permiteDigitarEndereco;
      case AIField.coduma:
        return permissoes.permiteDigitarUMA;
      case AIField.codbrr:
        return permissoes.permiteDigitarMercadoria;
      default:
        return true;
    }
  }

  Future<void> listening(TextEditingController controller) async {
    // se está no parse/setResults, não interfere...
    if (running) return;

    // se não tem nada, nada a fazer...
    if (controller.text.isEmpty) return;

    // se ainda não for código de barra...
    if (!isBarcode(controller.text)) {
      // se não pode digitar, limpa...
      if (!podeDigitar(controller)) {
        controller.clear();
      }
      return;
    }

    debugPrint('${DateTime.now()} =====> SCANNER: ${controller.text}');
    running = true;
    try {
      debugPrint('raw= ${controller.text}');

      final result = await parse(controller);
      lastResult = result;

      setResults(controller, result);
      onBeep?.call(controller, result);
    } catch (ex) {
      debugPrint('=====> PARSE ERROR: ${ex.toString()}');
      await showError(context, ex);
    } finally {
      running = false;
    }
  }

  Future<BarcodeResult> parse(TextEditingController controller) async {
    // ATENÇÃO para o trim() - evita etiquetas com espaços - faz parse do que foi lido...
    var raw = controller.text;
    raw = raw.substring(prefix.length, raw.length - suffix.length).trim();

    final result = await BarcodeManager.instance.parse(raw);
    return result;
  }

  void setResults(TextEditingController controller, BarcodeResult result) {
    if (result.isBarraComum) {
      controller.text = result.barcode;
    } else {
      for (final controller in mapControllers.keys) {
        final fieldName = mapControllers[controller];
        final value = result.mapValues[fieldName] ?? '';

        controller.text = value;
      }
    }
  }

  void setValues(BarcodeResult result, [TextEditingController? ignore]) {
    for (final kv in mapControllers.entries) {
      if (kv.key == ignore) continue;

      final ai = kv.value;
      final value = result.mapValues[ai];

      if (value != null) {
        kv.key.text = value;
      }
    }
  }
}
