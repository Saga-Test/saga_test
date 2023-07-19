import 'package:flutter/material.dart';

import '../saga_lib/sa_keyboard_navigator.dart';
import '../barcode/barcode_context.dart';
import '../saga_lib/sa_error.dart';

import '../barcode/barcode.dart';

//--------------------------------------------------------------------------------------------
// Confirmação de Endereço de Origem
//--------------------------------------------------------------------------------------------
Future<bool> confirmaEnderecoDeOrigem(
  BuildContext context,
  String endereco,
) async {
  final result = await confirmaBarcode(
    context,
    label: 'Endereço de Origem',
    value: endereco,
    aiField: AIField.codend,
    errorMessage: 'Bipe ou digite o endereço de origem',
  );
  return result;
}

//--------------------------------------------------------------------------------------------
// Diálogo de Confirmação de Valor, podendo bipar...
//--------------------------------------------------------------------------------------------
Future<bool> confirmaBarcode(
  BuildContext context, {
  String title = 'Confirmação',
  required String label,
  required String value,
  required AIField aiField,
  String errorMessage = 'Bipe ou digite o valor',
}) async {
  final controller = TextEditingController();

  Future<void> validate() async {
    final valueOK = controller.text == value ||
        (aiField == AIField.codend &&
            controller.text.replaceAll('.', '') == value.replaceAll('.', ''));

    if (!valueOK) {
      await showError(context, errorMessage);
      return;
    }

    Navigator.pop(context, true);
  }

  final mainButtonKey = GlobalKey();

  final result = await showDialog<bool>(
    barrierDismissible: false,
    context: context,
    builder: (BuildContext context) {
      return SAKeyboardNavigator(
        mainButton: mainButtonKey,
        child: BarcodeContext(
          fields: {
            controller: aiField,
          },
          onBeep: (_, __) => validate(),
          child: SingleChildScrollView(
            child: WillPopScope(
              onWillPop: () => Future.value(false),
              child: AlertDialog(
                title: Text(title),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      autofocus: true,
                      controller: controller,
                      decoration: InputDecoration(
                        label: Text(label),
                        helperText: value,
                      ),
                    ),
                  ],
                ),
                actions: <Widget>[
                  TextButton(
                    child: Text('CANCELAR'),
                    onPressed: () => Navigator.pop(context, false),
                  ),
                  TextButton(
                    key: mainButtonKey,
                    focusNode: FocusNode(),
                    child: Text('OK'),
                    onPressed: () => validate(),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );

  return result!;
}
