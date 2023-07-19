import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

import 'sa_core.dart';
export 'sa_core.dart';

class SAWarning extends SAException {
  SAWarning(String message, {String title = '', Function()? setFocus})
      : super(message, title: title, setFocus: setFocus);
}

Future<void> showError(BuildContext context, dynamic error) async {
  // Exception silenciosa???
  if (error is SAAborting) return;

  if (error is DioError) {
    await showDioError(context, error);
  } else if (error is SAWarning) {
    await showWarning(context, error);
  } else if (error is SAException) {
    await showException(context, error);
  } else if (error is Exception) {
    await showException(context, SAException.from(error));
  } else {
    // demais erros...
    await _showError(true, context, error.toString(), '', null);
  }
}

Future<void> showDioError(BuildContext context, DioError error,
    {String title = '', Function()? onExecute}) async {
  await _showError(true, context, error, title, onExecute);
}

Future<void> showException(BuildContext context, SAException error,
    {String title = '', Function()? onExecute}) async {
  await _showError(true, context, error, title, onExecute);
}

Future<void> showWarning(BuildContext context, SAWarning error,
    {String title = '', Function()? onExecute}) async {
  await _showError(false, context, error, title, onExecute);
}

Future<void> _showError(bool isError, BuildContext context, dynamic error, String title,
    Function()? onExecute) async {
  if (error is SAException) {
    title = error.title;
    onExecute = error.setFocus;
  }

  if (title.isEmpty) {
    title = isError ? 'Erro' : 'Warning';
  }

  final message = getErrorMessage(error);

  final icon = isError
      ? const Icon(Icons.error, color: Colors.red, size: 48)
      : Icon(Icons.warning, color: Colors.yellow[700], size: 48);

  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Column(
          children: [
            icon,
            const SizedBox(height: 4),
            Text(title),
          ],
        ),
        contentPadding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
        content: Text(
          message,
          textAlign: TextAlign.center,
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('OK'),
            onPressed: () {
              onExecute?.call();
              Navigator.pop(context);
            },
          ),
        ],
      );
    },
  );
}

String getErrorMessage(dynamic error) {
  String message;

  if (error is DioError) {
    message = error.type == DioErrorType.badResponse && error.response?.statusCode == 500
        ? error.response?.data['Message']
        : error.message;
  } else if (error is SAException) {
    message = error.message;
  } else {
    if (error is Exception) {
      message = error.toString().replaceFirst('Exception: ', '');
    } else {
      message = error.toString();
    }
  }

  return message;
}
