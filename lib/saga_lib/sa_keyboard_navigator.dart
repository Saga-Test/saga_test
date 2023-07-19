import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Navegação usando ENTER entre os campos da tela,
/// exceto no campo focusExecute, que vai disparar o evento onExecute
///
/// ATENÇÃO: o ENTER funciona como TAB inclusive em botões!!!
class SAKeyboardNavigator extends StatelessWidget {
  const SAKeyboardNavigator({
    super.key,
    this.mainButton,
    required this.child,
  });

  final GlobalKey? mainButton;
  final Widget child;

  static bool enabled = true;

  @override
  Widget build(BuildContext context) {
    if (!enabled) {
      return child;
    }

    return FocusScope(
      autofocus: true,
      onKeyEvent: (FocusNode node, KeyEvent event) {
        if (event.logicalKey == LogicalKeyboardKey.enter) {
          if (event is KeyDownEvent) {
            final button = mainButton?.currentWidget as ButtonStyleButton?;

            if (button != null) {
              button.onPressed?.call();
            } else {
              node.nextFocus();
            }
          }

          return KeyEventResult.handled;
        }

        return KeyEventResult.ignored;
      },
      child: child,
    );
  }
}
