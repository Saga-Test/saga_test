import 'package:flutter/material.dart';
import 'package:saga_test/informativo/info_log.dart';
import 'package:saga_test/informativo/informativo_content.dart';
import 'package:saga_test/informativo/informativo_controller.dart';

Future<void> informativoDialog(
  BuildContext context, {
  InfoLog? selectedLog,
}) async {
  selectedLog ??= InformativoController.lastLog;
  return showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    selectedLog!.nomeMetodo,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 24,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.close),
                  )
                ],
              )
            ],
          ),
        ),
        content: SizedBox(
          width: MediaQuery.of(context).size.width * .5,
          height: MediaQuery.of(context).size.height * .5,
          child: InformativoContent(selectedLog: selectedLog),
        ),
      );
    },
  );
}
