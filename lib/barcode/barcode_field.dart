import 'package:flutter/material.dart';

import '../saga_lib/sa_error.dart';
import '../saga_lib/sa_dialogs.dart';

import 'barcode.dart';
import 'barcode_context.dart';

//---------------------------------------------------------------------------------------------
// FieldState
//---------------------------------------------------------------------------------------------
class FieldState {
  FieldState(this.label) {
    focusNode.addListener(() {
      if (hasFocus) {
        if (autoSelectAll) selectAll();
      }
    });
  }

  final String label;
  var autoSelectAll = true;

  String get text => controller.text;
  set text(String value) => controller.text = value;

  void clear() => controller.clear();
  void selectAll() =>
      controller.selection = TextSelection(baseOffset: 0, extentOffset: text.length);

  // será que isto funciona mesmo???
  BuildContext get context => key.currentContext!;
  Widget get widget => key.currentWidget!;
  State get state => key.currentState!;

  bool get hasFocus => focusNode.hasFocus;
  void requestFocus() => focusNode.requestFocus();

  void nextFocus() => focusNode.nextFocus();

  final key = GlobalKey();
  final controller = TextEditingController();
  final focusNode = FocusNode();
}

//---------------------------------------------------------------------------------------------
// BarcodeState
//---------------------------------------------------------------------------------------------
typedef BarcodeValidateCallback = Future<void> Function(BarcodeState, String);
typedef BarcodePostCallback = void Function(BarcodeState);

class BarcodeState extends FieldState {
  BarcodeState(String label, this.field, {this.onPost}) : super(label);

  final AIField field;
  final BarcodePostCallback? onPost;
  final childs = <AIField, TextEditingController>{};

  // @override
  // void nextFocus() {
  //   super.nextFocus();
  //   focusKeyboard.nextFocus();
  // }

  // final FocusNode focusKeyboard = FocusNode();

  late BarcodeResult result;

  void addChild(AIField field, TextEditingController controller) {
    childs[field] = controller;
  }

  static void setChilds(List<BarcodeState> list) {
    for (final parent in list) {
      for (final child in list) {
        if (parent == child) continue;
        parent.addChild(child.field, child.controller);
      }
    }
  }

  void post() {
    onPost?.call(this);
  }
}

//---------------------------------------------------------------------------------------------
// BarcodeField
//---------------------------------------------------------------------------------------------
class BarcodeField extends TextField {
  BarcodeField({
    required this.context,
    required this.fieldState,
    bool autofocus = false,
    bool callNextFocus = true,
  }) : super(
          key: fieldState.key,
          controller: fieldState.controller,
          focusNode: fieldState.focusNode,
          onTap: () async {
            if (fieldState.hasFocus) {
              await _digiteBarcode(context, fieldState, callNextFocus);
            }
          },
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
          decoration: InputDecoration(
            suffixIcon: const Icon(Icons.view_column),
            labelText: fieldState.label,
            border: const OutlineInputBorder(),
            filled: true,
            fillColor: Colors.yellow[50],
          ),
          autofocus: autofocus,
          showCursor: true,
          enabled: true,
          readOnly: false,
        );

  final BuildContext context;
  final BarcodeState fieldState;
}

//---------------------------------------------------------------------------------------------
// digiteBarcode
//---------------------------------------------------------------------------------------------
Future<void> _digiteBarcode(
    BuildContext context, BarcodeState fieldState, bool callNextFocus) async {
  void close(BuildContext ctx) {
    Navigator.pop(ctx);
  }

  void execute(BuildContext ctx, String value) async {
    try {
      fieldState.text = value;

      close(ctx);

      // avança para o próximo campo...
      Future.delayed(Duration(milliseconds: 0), () {
        if (callNextFocus) fieldState.nextFocus();
      });

      // APÓS o close()!!!
      fieldState.post();
    } on Exception catch (ex) {
      await showError(ctx, ex);
    }
  }

  final input = TextEditingController();
  input.text = fieldState.text;

  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (ctx) {
      return AlertDialog(
        title: Text('DIGITE:  ${fieldState.label.toLowerCase()}'),
        content: TextField(
          autofocus: true,
          controller: input,
          onSubmitted: (_) => execute(ctx, input.text),
        ),
        actions: [
          TextButton(
            child: const Text('CANCELAR'),
            onPressed: () => close(ctx),
          ),
          TextButton(
            child: const Text('OK'),
            onPressed: () => execute(ctx, input.text),
          ),
        ],
      );
    },
  );
}

//---------------------------------------------------------------------------------------------
// inputBarcode
//---------------------------------------------------------------------------------------------
Future<String> inputBarcode({
  required BuildContext context,
  required AIField ai,
  String title = 'Informe o código de barras',
  String label = 'Código',
  String value = '',
}) async {
  final controller = TextEditingController(text: value);
  controller.selection = TextSelection(baseOffset: 0, extentOffset: value.length);

  var result = await inputDialog(
    context: context,
    title: title,
    widget: BarcodeContext(
      fields: {
        controller: ai,
      },
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
        ),
        autofocus: true,
      ),
    ),
  );

  return result == null ? '' : controller.text;
}

//---------------------------------------------------------------------------------------------
// showError
//---------------------------------------------------------------------------------------------
extension ExceptionEx on Exception {
  String get message => toString().replaceFirst('Exception: ', '');
}
