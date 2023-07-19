import 'package:flutter/material.dart';

import '../saga_lib/sa_core.dart';
import '../saga_lib/sa_dialogs.dart';
import '../saga_lib/sa_widgets.dart';
import '../main/app.dart';
import '../workflow/work_page.dart';
import '../geral/geral_api.dart';

import 'associacao_rg_dialogs.dart';
import 'associacao_rg_api.dart';

//--------------------------------------------------------------------------------------------
// AssociacaoPage
//--------------------------------------------------------------------------------------------
class AssociacaoPage extends WorkPage {
  const AssociacaoPage(this.operador, {super.key});

  final Operador operador;

  @override
  createState() => _AssociacaoState();
}

enum Etapas {
  pedeImpressora,
  pedeEndereco,
  pedeLote,
  pedeRGU,
  pedeMercadoria,
  finalizaAssociacao,
}

//--------------------------------------------------------------------------------------------
// AssociacaoState
//--------------------------------------------------------------------------------------------
class _AssociacaoState extends WorkState<AssociacaoPage> {
  @override
  void initState() {
    super.initState();

    title = 'Associação de RG';

    api = AssociacaoAPI(widget.operador);
    dialogs = AssociacaoDialogs(api);
  }

  late AssociacaoAPI api;
  late AssociacaoDialogs dialogs;

  final inputImpressora = TextEditingController();
  final inputEndereco = TextEditingController();
  final inputLote = TextEditingController();
  final inputRGU = TextEditingController();
  final inputMercadoria = TextEditingController();

  // pedeImpressora
  InfoImpressora? infoImpressora;
  bool impressaoAuto = true;

  // pedeEndereco
  InfoEndereco? infoEndereco;

  // pedeLote
  InfoLote? infoLote;

  // pedeRGU
  InfoRGU? infoRGU;
  String? codigoRGU;

  // pedeMercadoria
  InfoProduto? infoProduto;
  Map<InfoProduto, dynamic> listaConfirmados = {};

  Future<bool> naoTemProduto() async {
    final list = await api.getProdutos(infoLote!.idcLote.toString(), null);
    return list.isEmpty;
  }

  Future<void> realizaImpressao(String codigoRGU) async {
    await api.imprimirEtiquetaRGU(infoImpressora!.idc, codigoRGU);
    // showLongToast(msg: 'Etiqueta enviada para impressão');
  }

  Future<void> finaliza() async {
    await api.finalizaServico(
      infoLote!.idcOrdemServico,
      infoLote!.valorSequenciaAtividade,
      infoLote!.numeroItemOrdemServico,
      infoLote!.valorSequenciaServico,
    );
    listaConfirmados.clear();
    goto(Etapas.pedeLote.index);
  }

  Future<void> finalizaAssociacao() async {
    if (!await naoTemProduto()) {
      YesOrNoResult result = YesOrNoResult.no;

      if (context.mounted) {
        result = await showYesOrNo(
          context: context,
          message: "Você não associou RG em todo o estoque. Deseja finalizar?",
        );
      }

      if (result == YesOrNoResult.yes) {
        await finaliza();
      } else {
        abort();
      }
    } else {
      await finaliza();
    }
  }

  @override
  Map<int, WorkStep> createWorkflow() {
    return {
      Etapas.pedeImpressora.index: WorkStep(
        etapa: 'Pede Impressora',
        canBack: false,
        input: () async {
          return [
            SaInput(
              'Impressora',
              inputImpressora,
              suffixIcon: iconButton(Icons.arrow_drop_down_circle, () async {
                infoImpressora = await dialogs.getImpressora(context);
                inputImpressora.text = infoImpressora!.nomeID;
                nextStep();
              }),
            ),
            saSpace(),
            saCardCheck(
              title: 'Imprimir Automaticamente',
              checked: impressaoAuto,
              onChanged: (value) {
                impressaoAuto = value;
              },
            ),
          ];
        },
        validate: () async {
          infoImpressora = await api.findImpressora(inputImpressora.text);
        },
      ),
      Etapas.pedeEndereco.index: WorkStep(
        etapa: 'Pede Endereço',
        canBack: true,
        init: () async {
          inputEndereco.clear();
        },
        input: () async {
          return [
            SaInput(
              'Endereço',
              inputEndereco,
              suffixIcon: iconButton(
                Icons.arrow_drop_down_circle,
                () async {
                  infoEndereco = await dialogs.getEndereco(context);
                  inputEndereco.text = infoEndereco!.endereco;
                  nextStep();
                },
              ),
            ),
          ];
        },
        validate: () async {
          infoEndereco = await api.findEndereco(inputEndereco.text);
        },
      ),
      Etapas.pedeLote.index: WorkStep(
        etapa: 'Pede Lote',
        canBack: true,
        init: () async {
          inputLote.clear();
        },
        input: () async {
          return [
            SaInput(
              'Lote',
              inputLote,
              suffixIcon: iconButton(
                Icons.arrow_drop_down_circle,
                () async {
                  infoLote = await dialogs.getLote(context, infoEndereco!.idcEndereco);
                  inputLote.text = infoLote!.idcLote.toString();
                  nextStep();
                },
              ),
            ),
          ];
        },
        validate: () async {
          final int lote = checkInputValue(inputLote, type: InputType.int);

          infoLote = await api.findLote(infoEndereco!.idcEndereco, lote);

          // Caso não tenha mercadoria no lote, finalizar o serviço
          if (await naoTemProduto()) {
            // Associando o serviço a um usuário para poder finalizar
            await api.iniciaAtividade(infoLote!.idcLote);

            await finaliza();

            inputLote.clear();

            throw Exception("Não há mercadorias para esse lote");
          }

          await api.iniciaAtividade(infoLote!.idcLote);
        },
      ),
      Etapas.pedeRGU.index: WorkStep(
        etapa: 'Pede RGU',
        canBack: false,
        init: () async {
          inputRGU.clear();
          inputMercadoria.clear();
        },
        input: () async {
          return [
            SaInput(
              'RG',
              inputRGU,
            ),
            saSpace(),
            saButton("Finalizar Lote", () async {
              await finalizaAssociacao();
            })
          ];
        },
        validate: () async {
          codigoRGU = checkInputValue(inputRGU);

          final infoidt = await api.getIdt(codigoRGU!);
          if (infoidt != null) throw Exception('RG já associado');

          infoRGU = await api.getRGU(codigoRGU!);
          if (infoRGU != null) {
            infoProduto = await api.findProduto(
              idcLote: infoLote!.idcLote.toString(),
              codigoMercadoria: infoRGU!.codigoMercadoria,
              codigoRGU: codigoRGU,
              message: 'RG não pertence a esse lote',
            );
            inputMercadoria.text = infoProduto!.codigoMercadoria;
          }
        },
      ),
      Etapas.pedeMercadoria.index: WorkStep(
        etapa: 'Pede Mercadoria',
        canBack: true,
        init: () async {
          infoProduto = null;
        },
        input: () async {
          return [
            SaInput(
              'Mercadoria',
              inputMercadoria,
              suffixIcon: iconButton(Icons.arrow_drop_down_circle, () async {
                infoProduto = await dialogs.getProduto(
                  context,
                  infoLote!.idcLote.toString(),
                  infoRGU == null ? null : codigoRGU,
                );
                inputMercadoria.text = infoProduto!.codigoMercadoria;
                nextStep();
              }),
            ),
            saSpace(),
          ];
        },
        validate: () async {
          checkInputValue(inputMercadoria);

          if (infoProduto == null) {
            final result = await api.findProduto(
              idcLote: infoLote!.idcLote.toString(),
              codigoMercadoria: inputMercadoria.text,
              codigoRGU: infoRGU == null ? null : codigoRGU,
            );

            infoProduto = result;
          }

          final result = await api.executaAssociacao(
            infoLote!.idcLote,
            infoProduto!.ordens.first.idcOrdem,
            codigoRGU!,
            infoProduto!.idcMercadoria,
            infoProduto!.idcGrupoCaracteristica,
          );

          if (!result) throw Exception('Não foi possível associar o RG');

          listaConfirmados[infoProduto!] = codigoRGU!;

          if (impressaoAuto) {
            // se retonar erro, não fazer nada!
            try {
              await realizaImpressao(codigoRGU!);
            } catch (_) {}
          }
        },
      ),
      Etapas.finalizaAssociacao.index: WorkStep(
        etapa: 'Finaliza Associação',
        canBack: false,
        input: () async {
          return [
            saButton('Trocar impressora', () async {
              infoImpressora = await dialogs.getImpressora(context);
              inputImpressora.text = infoImpressora!.nomeID;
            }),
            saSpace(),
            saButton('Associar Novo', () async {
              if (await naoTemProduto()) {
                await finaliza();
                // showLongToast(msg: 'Lote finalizado');

                infoLote = null;
              } else {
                goto(Etapas.pedeRGU.index);
              }
            }),
          ];
        },
        validate: () async {
          await finalizaAssociacao();
        },
      ),
    };
  }

  @override
  Future<List<Widget>> getBody(int step) async {
    final etapa = Etapas.values[step];

    return [
      if (etapa.index != Etapas.finalizaAssociacao.index) ...[
        if (etapa.index > Etapas.pedeImpressora.index) ...[
          SaField('Impressora', infoImpressora!.nomeID),
          SaField(
              'Imprimir automaticamente', impressaoAuto ? 'Selecionado' : 'Não selecionado'),
        ],
        if (etapa.index > Etapas.pedeEndereco.index) ...[
          SaField('Endereco', infoEndereco!.endereco),
        ],
        if (etapa.index > Etapas.pedeLote.index) ...[
          SaField('Lote', infoLote!.idcLote),
        ],
        if (etapa.index > Etapas.pedeRGU.index) ...[
          SaField('RG', codigoRGU),
        ],
        if (etapa.index == Etapas.pedeMercadoria.index) ...[
          if (inputMercadoria.text.isNotEmpty) ...[
            saDivider(),
            saTitle('MERCADORIA ASSOCIADA AO RG:'),
            SaField('Cliente', infoProduto!.nomeCliente),
            SaField('Mercadoria', infoProduto!.codigoMercadoria),
            SaField('Descrição', infoProduto!.descricaoMercadoria),
            saDivider(),
          ]
        ]
      ] else ...[
        saTitle('ASSOCIAÇÕES REGISTRADAS:'),
        saSpace(),
        SizedBox(
          height: 200,
          child: Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: ListView.builder(
                itemCount: listaConfirmados.entries.length,
                itemBuilder: (context, index) {
                  final reverseIndex = listaConfirmados.length - 1 - index;
                  final key = listaConfirmados.keys.elementAt(reverseIndex);
                  final value = listaConfirmados.values.elementAt(reverseIndex);
                  return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    saRow([
                      saColumn([
                        SaField('Ordem', key.ordens.first.numeroOrdem),
                        SaField(
                            'Produto', "${key.codigoMercadoria} - ${key.descricaoMercadoria}"),
                        SaField('RG', value),
                        saSpace(),
                      ]),
                      IconButton(
                        icon: Icon(Icons.adf_scanner_outlined),
                        iconSize: 32,
                        onPressed: () async => {
                          tryExecute(
                            () async => await realizaImpressao(value),
                          )
                        },
                      ),
                    ]),
                  ]);
                },
              ),
            ),
          ),
        ),
        Align(
            alignment: Alignment.bottomRight,
            child: SaField("QUANTIDADE", listaConfirmados.length)),
        saDivider(),
        saSpace(),
      ]
    ];
  }

  @override
  Future<List<Widget>> getActions(int step) async {
    return [
      if (listaConfirmados.isEmpty) ...[
        saSpace(),
        saButton('SAIR DA ASSOCIAÇÃO DE RG', () async {
          if (infoLote != null) {
            await api.liberaServico(
              infoLote!.idcOrdemServico,
              infoLote!.valorSequenciaAtividade,
              infoLote!.numeroItemOrdemServico,
              infoLote!.valorSequenciaServico,
            );
          }

          await close();
        })
      ]
    ];
  }
}
