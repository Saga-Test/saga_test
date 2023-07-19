import 'package:flutter/material.dart';

import '../saga_lib/sa_api.dart';
import '../saga_lib/sa_widgets.dart';
import 'info_log.dart';

class InformativoContent extends StatelessWidget {
  InformativoContent({super.key, required this.selectedLog});

  final InfoLog selectedLog;

  final ValueNotifier<bool> showResponse = ValueNotifier(false);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: showResponse,
      builder: (_, showResponseValue, child) {
        return Visibility(
          visible: !showResponseValue,
          replacement: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    Text(selectedLog.response.toString()),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              saButton('Voltar', () => showResponse.value = !showResponseValue)
            ],
          ),
          child: ListView(
            children: [
              SaField("URL", selectedLog.url),
              SaField("Nome método", selectedLog.nomeMetodo),
              SaField("Nome controller", selectedLog.controller),
              SaField("Descrição", selectedLog.descricao),
              SaField(
                "Paramêtros",
                selectedLog.parametros.toString().replaceAll("{", "").replaceAll("}", ""),
              ),
              SaField("Duração(ms)", selectedLog.tempo),
              const Divider(),
              if (selectedLog.isErro) ...[
                const Text(
                  "ERRO:",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 255, 17, 0),
                  ),
                ),
                Text(
                  selectedLog.erro,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                )
              ] else ...[
                Row(
                  children: [
                    const Text("Response:"),
                    TextButton(
                      onPressed: () => showResponse.value = !showResponseValue,
                      child: const Text("Ver Response"),
                    ),
                  ],
                ),
                if (selectedLog.tipoResultado == TiposResult.primitivo.index) ...[
                  Row(
                    children: [
                      const Text(
                        "Resultado: ",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 4, 126, 4),
                        ),
                      ),
                      Text(
                        selectedLog.result,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      )
                    ],
                  ),
                ],
                if (selectedLog.tipoResultado == TiposResult.classType.index) ...[
                  Row(
                    children: [
                      const Text(
                        "Resultado: ",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 4, 126, 4),
                        ),
                      ),
                      Text(
                        selectedLog.result.runtimeType.toString(),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      )
                    ],
                  )
                ],
                if (selectedLog.tipoResultado == TiposResult.listClass.index) ...[
                  Row(
                    children: [
                      const Text(
                        "Resultado: ",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 4, 126, 4),
                        ),
                      ),
                      Text(
                        selectedLog.result.runtimeType.toString(),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      )
                    ],
                  )
                ],
              ],
            ],
          ),
        );
      },
    );
  }
}
