import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';

import 'package:dio/dio.dart';
import 'package:meta/meta.dart';

class SAMain {
  static void execute({
    required Widget mainApp,
    bool catchErrors = true,
  }) {
    if (!catchErrors) {
      runApp(mainApp);
    } else {
      runZonedGuarded(
        () async {
          WidgetsFlutterBinding.ensureInitialized();
          FlutterError.onError = (FlutterErrorDetails details) async {
            FlutterError.presentError(details);
            await showError(true, details.exception, details.stack);
          };
          runApp(mainApp);
        },
        (error, stack) async {
          await showError(false, error, stack);
        },
      );
    }
  }

  static final navigatorKey = GlobalKey<NavigatorState>();
  static BuildContext get currentContext => navigatorKey.currentContext!;

  static String getErrorMessage(Object error) {
    String message;

    if (error is DioError) {
      message = error.message ?? '';
    } else if (error is SAException) {
      message = error.message;
    } else if (error is Exception) {
      message = error.toString().replaceFirst('Exception: ', '');
    } else {
      message = error.toString();
    }

    if (message.length > 80) {
      message = '${message.substring(0, 80)}...';
    }

    return message;
  }

  static Future<void> showError(bool flutterError, Object error, StackTrace? stack) async {
    // Exception silenciosa???
    if (error is SAAborting) return;

    final message = getErrorMessage(error);
    final stackTrace = stack?.toString() ?? 'stack == null';
    final context = navigatorKey.currentContext!;

    final terminar = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (context) => AlertDialog(
        titlePadding: EdgeInsets.zero,
        title: Container(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
          color: Colors.red,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(message),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  flutterError ? 'flutterError' : 'runZonedGuarded',
                  style: const TextStyle(fontSize: 9),
                ),
              ),
            ],
          ),
        ),
        contentPadding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        content: SizedBox(
          height: double.maxFinite,
          width: double.maxFinite,
          child: ListView(
            children: [
              Text(
                stackTrace,
                style: const TextStyle(fontSize: 13),
              ),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('TERMINAR'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('CONTINUAR'),
          ),
        ],
      ),
    );

    if (terminar == true) exit(1);
  }
}

class SAException implements Exception {
  SAException(String message, {this.title = '', this.setFocus})
      : message = message.replaceFirst('Exception: ', '');

  final String message;
  final String title;
  void Function()? setFocus;

  SAException.from(Exception ex) : this(ex.toString());

  @override
  String toString() => message;
}

class SAAborting extends SAException {
  SAAborting() : super('Abortando...');
}

@alwaysThrows
void abort() => throw SAAborting();
