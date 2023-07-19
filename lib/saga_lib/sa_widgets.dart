import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:saga_test/saga_lib/sa_radio_group.dart';

export 'sa_input.dart';

// inicializado pela main()!!!
late ThemeData appTheme;
TextTheme get textTheme => appTheme.textTheme;

int mensuravelMaxDecimals = 3;

Widget iconButton(IconData icon, void Function() onPressed, {String? tooltip}) {
  return IconButton(
    icon: Icon(icon),
    onPressed: onPressed,
    tooltip: tooltip,
  );
}

Widget saCard({String? title, String? subtitle, List<Widget>? lines}) {
  final result = Card(
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (title != null) ...[
            saTitle(title),
            if (subtitle != null) ...[
              saSpace(),
              saTitle(subtitle),
            ],
            saSpace(),
          ],
          if (lines != null) ...lines,
        ],
      ),
    ),
  );
  return result;
}

Widget saCardCheck({
  required String title,
  String? subtitle,
  List<Widget>? lines,
  required bool checked,
  required void Function(bool) onChanged,
}) {
  final result = Card(
    child: StatefulBuilder(
      builder: (context, setState) {
        return CheckboxListTile(
          contentPadding: const EdgeInsets.fromLTRB(8, 4, 0, 4),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              saTitle(title),
              if (subtitle != null) ...[
                saSpace(),
                saTitle(subtitle),
              ],
              if (lines != null) ...[
                saSpace(),
                ...lines,
              ]
            ],
          ),
          value: checked,
          onChanged: (newValue) {
            checked = newValue!;
            setState(() => onChanged(checked));
          },
        );
      },
    ),
  );
  return result;
}

Widget saGroup(String title) {
  const divider = Divider(thickness: 1, height: 8);
  if (title.isEmpty) return divider;

  return Container(
    padding: const EdgeInsets.only(top: 8, bottom: 8),
    child: Row(children: [
      Text(title),
      const SizedBox(width: 8),
      const Expanded(child: divider),
    ]),
  );
}

Widget saDivider() {
  return const Divider(thickness: 1, height: 16);
}

Widget saButton(
  String label,
  void Function() onPressed, {
  bool enabled = true,
  Key? key,
  FocusNode? focusNode,
}) {
  final result = ElevatedButton(
    onPressed: enabled ? onPressed : null,
    key: key,
    focusNode: focusNode,
    child: Text(label),
  );
  return result;
}

TextStyle get titleStyle => textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.bold);
TextStyle get textStyle => textTheme.bodyMedium!;
TextStyle get valueStyle => textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.bold);

Widget saTitle(String text) {
  final result = Text(text, style: titleStyle);
  return result;
}

Widget saText(String text) {
  return Container(
    padding: const EdgeInsets.symmetric(vertical: 2),
    child: Text(text, style: textStyle),
  );
}

Widget saRadioGroup<T>(
  String label,
  Map<T, String> options,
  T value,
  void Function(T) onChanged, {
  Axis direction = Axis.vertical,
}) {
  return SARadioGroup(label, options, value, onChanged, direction: direction);
}

class SaField extends StatelessWidget {
  const SaField(
    this.label,
    this.value, {
    super.key,
    this.flexLabel = 0,
    this.flexValue = 1,
  });

  final String label;
  final dynamic value;
  final int flexLabel;
  final int flexValue;

  @override
  Widget build(BuildContext context) {
    final delimiter = label.endsWith('?') ? ' ' : ': ';
    final valueFormatted = _formatValue(value);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 4.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (label.isNotEmpty) ...[
              Flexible(flex: flexLabel, child: Text(label, style: textStyle)),
              Text(delimiter, style: textStyle),
            ],
            if (valueFormatted.isNotEmpty)
              Flexible(flex: flexValue, child: Text(valueFormatted, style: valueStyle)),
          ],
        ),
      ),
    );
  }
}

String _formatValue(dynamic value) {
  String result;
  if (value is String) {
    value.isEmpty ? result = "N/A" : result = value;
  } else if (value is int) {
    result = value.toString();
  } else if (value is double) {
    result = value.toString().replaceFirst('.', ',');
  } else if (value is DateTime) {
    final formatter = DateFormat('dd/MM/yyyy');
    result = formatter.format(value);
  } else if (value is bool) {
    result = value ? 'sim' : 'não';
  } else {
    result = value == null ? '-' : value.toString();
  }
  return result;
}

Widget saColumn(List<Widget> widgets, {int indent = 0}) {
  final result = Container(
    padding: EdgeInsets.only(left: indent * 32.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: widgets,
    ),
  );
  return result;
}

/// saRow agora torna Flexible TODOS os Containers (saFields)...
Widget saRow(List<Widget> widgets) {
  final result = Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: widgets.map((it) => it is Container ? Flexible(child: it) : it).toList(),
  );
  return result;
}

Widget saSpace([int spaces = 1]) {
  return SizedBox(width: 8.0 * spaces, height: 8.0 * spaces);
}

class Value {
  Value(this.label, this.rawValue) : value = format(rawValue);

  final String label;
  final String value;
  final dynamic rawValue;

  static String format(dynamic value) => _formatValue(value);
}
