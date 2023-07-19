import 'package:flutter/material.dart';

class SARadioGroup<T> extends StatefulWidget {
  const SARadioGroup(
    this.label,
    this.options,
    this.value,
    this.onChanged, {super.key, 
    this.direction = Axis.vertical,
  });

  final String label;
  final Map<T, String> options;
  final T value;
  final void Function(T) onChanged;
  final Axis direction;

  @override
  _SARadioGroupState<T> createState() => _SARadioGroupState<T>();
}

class _SARadioGroupState<T> extends State<SARadioGroup<T>> {
  @override
  void initState() {
    super.initState();

    selectedValue = widget.value;
  }

  late T selectedValue;

  void changeValue(T newValue) {
    setState(() => selectedValue = newValue);
    widget.onChanged(newValue);
  }

  @override
  Widget build(BuildContext context) {
    final radioItems = widget.options.entries.map((it) {
      return InkWell(
        onTap: () => changeValue(it.key),
        child: Row(children: [
          Radio<T>(
            value: it.key,
            groupValue: selectedValue,
            onChanged: (T? newValue) => changeValue(newValue as T),
          ),
          Text(it.value),
        ]),
      );
    });

    if (widget.direction == Axis.horizontal) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(widget.label),
          ...radioItems,
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label),
        ...radioItems,
      ],
    );
  }
}
