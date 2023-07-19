import 'package:flutter/material.dart';
import 'package:saga_test/saga_lib/sa_core.dart';

import 'sa_keyboard_navigator.dart';

class SADialogs {
  static Future showBuilder(
      BuildContext context, String title, StatefulBuilder builder) async {
    final result = await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: builder,
        );
      },
    );

    return result;
  }
}

Future<String> inputValue({
  required BuildContext context,
  String title = 'Informe o valor',
  String value = '',
  int maxLength = TextField.noMaxLength,
  bool showCounterText = false,
}) async {
  final controller = TextEditingController();

  final focusNode = FocusNode();
  focusNode.requestFocus();

  controller.text = value;
  controller.selection = TextSelection(baseOffset: 0, extentOffset: value.length);

  final field = TextField(
    controller: controller,
    focusNode: focusNode,
    maxLength: maxLength,
    decoration: InputDecoration(
      counterText: showCounterText ? null : '',
    ),
  );

  var result = await inputDialog(
    context: context,
    title: title,
    widget: field,
  );

  return result == null ? '' : field.controller!.text;
}

Future<Widget?> inputDialog({
  required BuildContext context,
  String title = 'Informe o valor',
  required Widget widget,
}) async {
  final mainButtonKey = GlobalKey();

  final result = await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (ctx) {
      final dialog = SAKeyboardNavigator(
        mainButton: mainButtonKey,
        child: AlertDialog(
          title: Text(title),
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10))),
          contentPadding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          content: SizedBox(
            width: MediaQuery.of(ctx).size.width,
            child: widget,
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('CANCELAR'),
              onPressed: () => Navigator.pop(ctx, null),
            ),
            TextButton(
              key: mainButtonKey,
              focusNode: FocusNode(),
              child: const Text('OK'),
              onPressed: () => Navigator.pop(ctx, widget),
            ),
          ],
        ),
      );

      return dialog;
    },
  );

  return result;
}

//--------------------------------------------------------------------------------------------
// EM USO
//--------------------------------------------------------------------------------------------

//--------------------------------------------------------------------------------------------
// showYesOrNo
//--------------------------------------------------------------------------------------------
enum YesOrNoResult { no, yes, yesToAll }

Future<YesOrNoResult> showYesOrNo({
  required BuildContext context,
  required String message,
  bool showYesToAll = false,
  String title = 'Confirmar',
}) async {
  final result = await showDialog<YesOrNoResult>(
    barrierDismissible: false,
    context: context,
    builder: (BuildContext context) {
      return WillPopScope(
        onWillPop: () => Future.value(false),
        child: AlertDialog(
          title: Text(title),
          contentPadding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
          content: SizedBox(
            height: MediaQuery.of(context).size.height * 1 / 5,
            width: MediaQuery.of(context).size.width * 2 / 3,
            child: Center(child: Text(message)),
          ),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
              ),
              child: const Text('NÃO'),
              onPressed: () => Navigator.pop(context, YesOrNoResult.no),
            ),
            TextButton(
              child: const Text('SIM'),
              onPressed: () => Navigator.pop(context, YesOrNoResult.yes),
            ),
            if (showYesToAll) ...[
              TextButton(
                child: const Text('SIM PARA TODOS'),
                onPressed: () => Navigator.pop(context, YesOrNoResult.yesToAll),
              ),
            ],
          ],
        ),
      );
    },
  );
  return result!;
}

//--------------------------------------------------------------------------------------------
// showList
//--------------------------------------------------------------------------------------------
Future<T?> showList<T>({
  required BuildContext context,
  required String title,
  List<T>? list,
  Future<List<T>> Function()? loadList,
  required Widget Function(T item) showItem,
  bool useFullScreen = false,
  bool canSelect = true, // lista para selecionar ou apenas consultar???
  String noItemsMessage = 'Não há nenhum item',
}) async {
  assert(list != null || loadList != null);

  list ??= await loadList!();

  final listView = list.isEmpty
      ? Center(child: Text(noItemsMessage))
      : ListView.builder(
          itemCount: list.length,
          itemBuilder: (BuildContext context, int index) {
            final item = list![index];
            return InkWell(
              child: showItem(item),
              onTap: () => canSelect ? Navigator.pop(context, item) : null,
            );
          },
        );

  T? result;

  if (context.mounted) {
    result = await showDialog<T>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color.fromARGB(255, 255, 243, 243),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title),
              IconButton(
                onPressed: () => Navigator.pop(context, null),
                icon: const Icon(Icons.close_rounded),
              ),
            ],
          ),
          content: SizedBox(
            height: MediaQuery.of(context).size.height / 2,
            width: MediaQuery.of(context).size.width / 2,
            child: listView,
          ),
        );
      },
      barrierDismissible: list.isEmpty || !canSelect,
    );
  }

  return result;
}

//--------------------------------------------------------------------------------------------
// showCheckList
//--------------------------------------------------------------------------------------------
Future<List<T>?> showCheckList<T>({
  required BuildContext context,
  required String title,
  required List<T> list,
  required List<T> listChecked,
  String noItemsMessage = '',
  required Widget Function(T) showItem,
}) async {
  final result = List<T>.from(listChecked);

  return await showDialog<List<T>>(
    context: context,
    barrierDismissible: list.isEmpty,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(title),
            insetPadding: const EdgeInsets.all(16),
            content: SizedBox(
              width: double.maxFinite,
              height: double.maxFinite,
              child: list.isEmpty
                  ? Center(child: Text(noItemsMessage))
                  : ListView.separated(
                      separatorBuilder: (_, __) => const Divider(),
                      itemCount: list.length,
                      itemBuilder: (_, index) {
                        final item = list[index];
                        final widget = showItem(item);
                        final checked = result.contains(item);

                        return CheckboxListTile(
                          contentPadding: EdgeInsets.zero,
                          title: widget,
                          value: checked,
                          onChanged: (checked) {
                            setState(() {
                              if (checked!) {
                                result.add(item);
                              } else {
                                result.remove(item);
                              }
                            });
                          },
                        );
                      },
                    ),
            ),
            actions: [
              ElevatedButton(
                child: const Text('cancelar'),
                onPressed: () => Navigator.pop(context, null),
              ),
              ElevatedButton(
                child: const Text('OK'),
                onPressed: () => Navigator.pop(context, result),
              ),
            ],
          );
        },
      );
    },
  );
}

//--------------------------------------------------------------------------------------------
// showMessage
//--------------------------------------------------------------------------------------------
Future<void> showMessage({
  required BuildContext context,
  String title = 'Atenção',
  required String message,
}) async {
  final mainButtonKey = GlobalKey();

  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return SAKeyboardNavigator(
        mainButton: mainButtonKey,
        child: AlertDialog(
          title: Text(title),
          content: Text(
            message,
            textAlign: TextAlign.center,
          ),
          actions: <Widget>[
            TextButton(
              key: mainButtonKey,
              focusNode: FocusNode(),
              autofocus: true,
              child: const Text('OK'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );
    },
  );
}

//--------------------------------------------------------------------------------------------
// inputUserDialog
//--------------------------------------------------------------------------------------------
Future<bool> inputUserDialog({
  required BuildContext context,
  required String title,
  required Future<void> Function(String, String) onValidate,
  int? maxLength,
}) async {
  final fieldUser = TextEditingController();
  final fieldPassword = TextEditingController();

  final mainButtonKey = GlobalKey();

  return await showDialog(
    context: context,
    builder: (context) {
      return SAKeyboardNavigator(
        mainButton: mainButtonKey,
        child: AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: fieldUser,
                  autofocus: true,
                  decoration: const InputDecoration(labelText: 'usuário'),
                  maxLength: maxLength,
                ),
                TextField(
                  controller: fieldPassword,
                  decoration: const InputDecoration(labelText: 'senha'),
                  maxLength: maxLength,
                  obscureText: true,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () => Navigator.pop(context, false),
            ),
            TextButton(
              key: mainButtonKey,
              focusNode: FocusNode(),
              child: const Text('OK'),
              onPressed: () async {
                try {
                  final user = fieldUser.text;
                  final password = fieldPassword.text;
                  await onValidate.call(user, password);

                  if (context.mounted) {
                    Navigator.pop(context, true);
                  }
                } catch (ex) {
                  // await showError(context, ex);
                }
              },
            ),
          ],
        ),
      );
    },
  );
}

class Progress {
  static void show({String message = 'aguarde...'}) {
    final context = SAMain.currentContext;
    _stack.add(context);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Row(
            children: [
              const CircularProgressIndicator(),
              Expanded(
                child: Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  static final List<BuildContext> _stack = [];

  static void hide() {
    final context = _stack.removeLast();
    Navigator.pop(context);
  }
}
