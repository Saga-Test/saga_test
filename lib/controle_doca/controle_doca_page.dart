import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../main/app.dart';
import '../saga_lib/sa_widgets.dart';
import '../workflow/work_page.dart';
import 'controle_doca_api.dart';
import 'controle_doca_dialogs.dart';

class ControleDocaPage extends WorkPage {
  const ControleDocaPage(this.operador, {super.key});

  final Operador operador;

  @override
  _ControleDocaState createState() => _ControleDocaState();
}

var idcProcesso = Processo.expedicao;

enum Etapas {
  pedeDoca,
  atualizaStatus,
}

enum Processo { naoUsado, expedicao, recebimento }

final mapValorProcesso = {
  Processo.expedicao: 'Expedição',
  Processo.recebimento: 'Recebimento',
};

class _ControleDocaState extends WorkState<ControleDocaPage> {
  @override
  void initState() {
    title = 'Controle de Doca';

    api = ControleDocaApi(widget.operador);
    dialogs = ControleDocaDialogs(api);

    super.initState();
  }

  late ControleDocaApi api;
  late ControleDocaDialogs dialogs;

  final inputDoca = TextEditingController();

  // pedeDoca
  InfoDoca? infoDoca;
  List<InfoVeiculo>? infoVeiculos;

  Future buscaVeiculos() async =>
      infoVeiculos = await api.getVeiculos(idcProcesso.index, 1, infoDoca?.idcLoc ?? 0);

  @override
  Map<int, WorkStep> createWorkflow() {
    return {
      Etapas.pedeDoca.index: WorkStep(
        etapa: "Pede Doca",
        canBack: false,
        input: () async {
          return [
            saRadioGroup<Processo>(
              'Processo:',
              mapValorProcesso,
              Processo.expedicao,
              (value) => idcProcesso = value,
            ),
            saSpace(),
            SaInput(
              'Doca',
              inputDoca,
              suffixIcon: iconButton(
                Icons.search,
                () async {
                  infoDoca = await dialogs.getDoca(context);
                  inputDoca.text = infoDoca?.nomLoc ?? "";
                  nextStep();
                },
                tooltip: 'pesquisar',
              ),
            ),
            saSpace(),
          ];
        },
        validate: () async {
          final local = checkInputValue(inputDoca);
          infoDoca = await api.findDoca(local);

          infoVeiculos = await buscaVeiculos();
          if (infoVeiculos != null) {
            if (infoVeiculos!.isEmpty) throw Exception("Não existem veículos");
          }
        },
      ),
      Etapas.atualizaStatus.index: WorkStep(
        etapa: "Atualiza Status",
        input: () async {
          return [
            SizedBox(
              height: 200,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: ListView.builder(
                    itemCount: infoVeiculos?.length ?? 0,
                    itemBuilder: (context, index) {
                      final veiculo = infoVeiculos?[index];
                      final data = veiculo?.datHorIni;
                      final dataFormatada =
                          DateFormat('dd/MM/yyyy').format(data ?? DateTime.now());
                      final horaFormatada = DateFormat('kk:mm').format(data ?? DateTime.now());
                      return Visibility(
                        visible: veiculo != null,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            saRow(
                              [
                                saColumn([
                                  SaField('Data/Hora', '$dataFormatada - $horaFormatada'),
                                  SaField('Veiculo', veiculo?.codPlaVec),
                                  SaField('Motorista', veiculo?.nomMot),
                                  saSpace(),
                                ]),
                                IconButton(
                                  icon: const Icon(Icons.add_location_alt_outlined),
                                  iconSize: 32,
                                  onPressed: () async {
                                    final result = await api
                                        .confirmaChegadaVeiculoDoca(veiculo?.idcMov ?? 0);

                                    if (result) {
                                      await buscaVeiculos();
                                      if (infoVeiculos != null) {
                                        if (infoVeiculos!.isEmpty) {
                                          goto(Etapas.pedeDoca.index);
                                        }
                                      }
                                      refresh();
                                      // showLongToast(msg: 'O veículo foi liberado');
                                    }
                                  },
                                )
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ];
        },
      ),
    };
  }
}
