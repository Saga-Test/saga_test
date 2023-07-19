import 'package:flutter/material.dart';

import './barcode.dart';
import './barcode_reader.dart';

//--------------------------------------------------------------------------------------------
// Widget que cria um CONTEXTO de barcode...
//--------------------------------------------------------------------------------------------
class BarcodeContext extends StatefulWidget {
  const BarcodeContext({
    super.key,
    required this.child,
    required this.fields,
    this.caracteristicas,
    this.atividade,
    this.onBeep,
    this.initialValues,
  });

  final Widget child;
  final Map<TextEditingController, AIField> fields;
  final Map<TextEditingController, String>? caracteristicas;
  final int? atividade;
  final BeepCallback? onBeep;
  final BarcodeResult? initialValues;

  @override
  State<BarcodeContext> createState() => BarcodeContextState();
}

class BarcodeContextState extends State<BarcodeContext> {
  @override
  void initState() {
    super.initState();
    register(widget);
  }

  @override
  void didUpdateWidget(covariant BarcodeContext oldWidget) {
    super.didUpdateWidget(oldWidget);
    unRegister(oldWidget);
    register(widget);
  }

  @override
  void dispose() {
    super.dispose();
    unRegister(widget);
  }

  late BarcodeReader barcodeReader;

  void register(BarcodeContext widget) {
    barcodeReader = BarcodeReader(context, onBeep: widget.onBeep);
    barcodeReader.atividade = widget.atividade;

    for (final field in widget.fields.entries) {
      barcodeReader.addField(field.key, field.value);
    }
    if (widget.caracteristicas != null) {
      for (final field in widget.caracteristicas!.entries) {
        barcodeReader.addFieldByName(field.key, field.value);
      }
    }

    // se tem valores iniciais, atribui...
    if (widget.initialValues != null) {
      barcodeReader.setValues(widget.initialValues!);
    }

  }

  void unRegister(BarcodeContext widget) {
    for (final field in widget.fields.entries) {
      barcodeReader.removeField(field.key);
    }
    if (widget.caracteristicas != null) {
      for (final field in widget.caracteristicas!.entries) {
        barcodeReader.removeField(field.key);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
