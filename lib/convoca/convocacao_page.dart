import 'package:flutter/material.dart';
import 'package:saga_test/saga_lib/sa_page_card.dart';
import 'package:saga_test/saga_lib/sa_page.dart';

import '../convoca/convocacao_api.dart';
import '../convoca/convocacao_executor.dart';
import '../login/parametros.dart';
import '../main/app.dart';
import './convocacao.dart';

class ConvocacaoPage extends StatefulWidget {
  const ConvocacaoPage(this.operador, {super.key});

  final Operador operador;

  @override
  State<ConvocacaoPage> createState() => _ConvocacaoPageState();
}

class _ConvocacaoPageState extends State<ConvocacaoPage> {
  @override
  void initState() {
    super.initState();

    api = ConvocacaoApi(widget.operador);
    exec = ConvocacaoExecutor(context, api);

    _usaVoz = Parametros.usuarioUsaVoz;

    exec.procuraExecucaoEmAndamento();
  }

  @override
  Future<void> dispose() async {
    super.dispose();

    if (exec.timerWasActive) await exec.stopConvocador();

    await exec.setStatusOcupado();

    Parametros.usuarioUsaVoz = _usaVoz;
    Parametros.save();

    exec.contadorController.dispose();
    exec.convController.dispose();
  }

  late ConvocacaoApi api;
  late ConvocacaoExecutor exec;

  bool _usaVoz = false;

  TextStyle get smallFontStyle => const TextStyle(fontSize: 18, color: Colors.black54);
  TextStyle get mediumFontStyle => const TextStyle(fontSize: 20, color: Colors.black54);
  TextStyle get bigFontStyle => const TextStyle(fontSize: 24);

  @override
  Widget build(BuildContext context) {
    return SaPage(
      title: "Convocação",
      canBack: true,
      children: [
        SaPageCard(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 500,
                height: 360,
                child: ValueListenableBuilder<Convocacao?>(
                  valueListenable: exec.convController,
                  builder: (BuildContext context, Convocacao? conv, Widget? child) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Center(
                        child: ListView(
                          shrinkWrap: true,
                          children: [
                            SizedBox(
                              width: 500,
                              height: 360,
                              child: Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 4, right: 8),
                                    child: Align(
                                      alignment: Alignment.topRight,
                                      child: ValueListenableBuilder<int>(
                                        valueListenable: exec.contadorController,
                                        builder: (BuildContext context, int contador,
                                            Widget? child) {
                                          return Container(
                                            width: 36,
                                            height: 24,
                                            color: exec.conv != null || !exec.timerisActive
                                                ? const Color(0xFFCC0000)
                                                : Colors.greenAccent.shade400,
                                            child: Center(child: Text(contador.toString())),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Card(
                                      child: Padding(
                                        padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
                                        child: Column(
                                          children: [
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.end,
                                              children: [
                                                const Padding(
                                                  padding: EdgeInsets.only(right: 10),
                                                  child: Text('Usar voz'),
                                                ),
                                                SizedBox(
                                                  height: 40,
                                                  child: StatefulBuilder(
                                                    builder: (context, setState) {
                                                      return Switch(
                                                        value: _usaVoz,
                                                        onChanged: (value) async {
                                                          _usaVoz = value;
                                                          await exec.setUsaVoz(_usaVoz);
                                                          setState(() {});
                                                        },
                                                      );
                                                    },
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Expanded(
                                              child: Container(
                                                width: 500,
                                                color: const Color(0xFFFFCC80),
                                                child: conv != null
                                                    ? Column(
                                                        children: [
                                                          const SizedBox(height: 24),
                                                          Text(conv.atividade.nome,
                                                              style: bigFontStyle),
                                                          const SizedBox(height: 20),
                                                          Text(
                                                            'Lote: ${conv.servicos.first.lote.idc}',
                                                            style: mediumFontStyle,
                                                          ),
                                                          const SizedBox(height: 16),
                                                          if (conv.servicos.first.destino
                                                              .mascara.isNotEmpty) ...[
                                                            Text(
                                                              'Origem: ${conv.servicos.first.origem.mascara}',
                                                              style: smallFontStyle,
                                                            ),
                                                            Text(
                                                              'Destino: ${conv.servicos.first.destino.mascara}',
                                                              style: smallFontStyle,
                                                            ),
                                                            if (conv.isApanhaPorVoz)
                                                              Text(
                                                                '(permite VOZ)',
                                                                style: smallFontStyle,
                                                              ),
                                                          ] else ...[
                                                            Text(
                                                              'Local: ${conv.servicos.first.origem.mascara}',
                                                              style: smallFontStyle,
                                                            ),
                                                          ],
                                                        ],
                                                      )
                                                    : Center(
                                                        child: Text(
                                                          'aguarde uma convocação...',
                                                          style: smallFontStyle,
                                                        ),
                                                      ),
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Row(
                                              children: [
                                                ElevatedButton(
                                                  onPressed: conv != null
                                                      ? () async =>
                                                          await exec.recusaConvocacao()
                                                      : null,
                                                  child: const Text('RECUSAR'),
                                                ),
                                                const SizedBox(width: 8),
                                                Expanded(
                                                  child: ElevatedButton(
                                                    onPressed: conv != null
                                                        ? () async =>
                                                            await exec.aceitaConvocacao()
                                                        : null,
                                                    child: const Text('ACEITAR'),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
