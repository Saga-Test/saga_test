import 'package:flutter/material.dart';

class SaExpansiveCard extends StatelessWidget {
  SaExpansiveCard({
    Key? key,
    required this.title,
    this.isExpanded = false,
    required this.children,
    this.showStep,
    this.currIndex,
  })  : expanded = ValueNotifier(isExpanded),
        super(key: key);

  final String title;
  final bool isExpanded;
  final List<Widget> children;

  final ValueNotifier<bool> expanded;

  final Future<void> Function(int)? showStep;
  final int? currIndex;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: expanded,
      builder: (_, expandedValue, child) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Card(
            color: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 8.0,
                horizontal: 16.0,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(title),
                      IconButton(
                        onPressed: () async {
                          expanded.value = !expandedValue;

                          if (expanded.value && showStep != null) {
                            await showStep!(currIndex!);
                          }
                        },
                        icon: Icon(
                          expandedValue ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                        ),
                      ),
                    ],
                  ),
                  if (expandedValue) ...[
                    const SizedBox(height: 16),
                    ...children,
                  ]
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
