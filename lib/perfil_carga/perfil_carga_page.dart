import 'package:flutter/material.dart';
import 'package:saga_test/perfil_carga/perfil_carga_api.dart';

import '../main/app.dart';
import '../saga_lib/sa_widgets.dart';
import '../workflow/work_page.dart';

class PerfilCargaPage extends WorkPage {
  PerfilCargaPage(this.operador, {this.lote});

  final Operador operador;
  final String? lote;

  @override
  _PerfilCargaState createState() => _PerfilCargaState();
}

enum Etapas {
  pedeLote,
  filtraCarga,
}

class _PerfilCargaState extends WorkState<PerfilCargaPage> {
  @override
  void initState() {
    super.initState();

    this.api = PerfilCargaApi(widget.operador);

    title = 'Perfil Carga';
  }

  late PerfilCargaApi api;

  final inputLote = TextEditingController();

  // pedeLote
  late List<InfoPerfilCarga> infoPerfilCarga;

  @override
  Map<int, WorkStep> createWorkflow() {
    return {
      Etapas.pedeLote.index: WorkStep(
        etapa: "Pede Lote",
        canBack: false,
        input: () async {
          inputLote.clear();
          if (widget.lote != null) inputLote.text = widget.lote!;
          return [
            SaInput('Lote', inputLote),
          ];
        },
        validate: () async {
          final lote = await checkInputValue(inputLote);
          infoPerfilCarga = await api.listarPerfilCarga(lote);

          if (infoPerfilCarga.isEmpty)
            throw Exception("Não foram encontrados itens para esse lote");
        },
      ),
      Etapas.filtraCarga.index: WorkStep(
        etapa: "Filtra Carga",
        canBack: true,
        input: () async {
          return [
            saColumn([
              SaField('BOX', infoPerfilCarga.first.strBox),
              SaField('LOTE', infoPerfilCarga.first.idcLot),
              if (infoPerfilCarga.first.codPlaVec != null)
                SaField('Placa', infoPerfilCarga.first.codPlaVec),
              if (infoPerfilCarga.first.nomPss != null)
                SaField('Motorista', infoPerfilCarga.first.nomPss),
            ]),
            saSpace(),
            saTitle('SERVIÇOS'),
            SizedBox(
              height: 200,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ListView.builder(
                    itemCount: infoPerfilCarga.length,
                    itemBuilder: (context, index) {
                      final item = infoPerfilCarga[index];
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          saRow([
                            saColumn([
                              if (item.nomCarLgt != "-" && item.nomCarLgt != null) ...[
                                SaField('GRUPO DE MERCADORIA', item.nomCarLgt),
                              ],
                              SaField('MOV/EXP', item.movExp),
                              SaField('PICKING', item.picking),
                              saSpace(),
                            ]),
                          ]),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ];
        },
        validate: () async {},
      ),
    };
  }

  @override
  Future<List<Widget>> getActions(int step) async {
    return [
      saSpace(),
      saButton('SAIR DO PERFIL DE CARGA', () => close()),
    ];
  }
}
