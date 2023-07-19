import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:saga_test/saga_lib/sa_widgets.dart';

class SaInput extends StatefulWidget {
  const SaInput(
    this.label,
    this.controller, {
    this.autofocus = false,
    this.prefixIcon,
    this.suffixIcon,
    this.isSecret = false,
    this.mensuravel,
    this.readOnly = false,
    this.focusNode,
    this.helperText = "",
    super.key,
  });

  final String label;
  final String helperText;
  final TextEditingController controller;
  final bool autofocus;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool isSecret;
  final bool? mensuravel;
  final bool readOnly;
  final FocusNode? focusNode;

  @override
  State<SaInput> createState() => _DefaultTextFieldState();
}

class _DefaultTextFieldState extends State<SaInput> {
  bool isObscure = false;

  @override
  void initState() {
    super.initState();

    isObscure = widget.isSecret;
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      obscureText: isObscure,
      controller: widget.controller,
      autofocus: widget.autofocus,
      focusNode: widget.focusNode,
      readOnly: widget.readOnly,
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        labelText: widget.label,
        helperText: widget.helperText,
        prefixIcon: widget.prefixIcon,
        suffixIcon: widget.isSecret
            ? IconButton(
                onPressed: () {
                  setState(() {
                    isObscure = !isObscure;
                  });
                },
                icon: Icon(
                  isObscure ? Icons.visibility : Icons.visibility_off,
                ),
              )
            : widget.suffixIcon,
      ),
      inputFormatters: widget.mensuravel == null
          ? null
          : [
              if (widget.mensuravel == true)
                FilteringTextInputFormatter.allow(
                  RegExp(
                    unicode: true,
                    '^[0-9]([0-9]{1,6})?([,.][0-9]{0,$mensuravelMaxDecimals})?',
                  ),
                )
              else
                FilteringTextInputFormatter.digitsOnly
            ],
    );
  }
}


// SaTextField(
//     label: label,
//     controller: value,
//     readOnly: readOnly,
//     obscureText: obscureText,
//     textInputAction: textInputAction,
//     autofocus: autofocus,
//     focusNode: focusNode,
//     validator: validator,
//     onSaved: onSaved,
//     onFieldSubmitted: (value) {
//       if (focusNode != null) {
//         focusNode.nextFocus();
//       }
//     },
//     decoration: InputDecoration(
//       labelText: '$label${label.isNotEmpty ? ':' : ''}',
//       prefixIcon: prefixIcon,
//       suffixIcon: suffixIcon,
//       helperText: helperText,
//     ),
//     // quantidade mensurável
//     mensuravel: mensuravel,
//   );