import 'package:flutter/material.dart';

class SaButton extends StatelessWidget {
  const SaButton({
    required this.onPressed,
    required this.label,
    super.key,
  });

  final Future<void> Function() onPressed;
  final String label;

  @override
  Widget build(BuildContext context) {
    bool isLoading = false;

    return StatefulBuilder(
      builder: (BuildContext context, setState) {
        return ElevatedButton(
          onPressed: isLoading
              ? null
              : () async {
                  try {
                    setState(() => isLoading = true);
                    await onPressed();
                  } finally {
                    setState(() => isLoading = false);
                  }
                },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Visibility(
              visible: !isLoading,
              replacement: const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(),
              ),
              child: Text(label),
            ),
          ),
        );
      },
    );
  }
}
