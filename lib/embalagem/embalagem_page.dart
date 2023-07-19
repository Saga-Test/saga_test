import 'package:flutter/material.dart';

import '../saga_lib/sa_dialogs.dart';
import '../saga_lib/sa_error.dart';
import '../saga_lib/sa_widgets.dart';

import '../main/app.dart';
import '../workflow/work_page.dart';
import '../geral/geral_api.dart';

import 'embalagem_dialogs.dart';
import 'embalagem_api.dart';

//--------------------------------------------------------------------------------------------
// Embalagem
//--------------------------------------------------------------------------------------------
class Embalagem {
  Embalagem(this.infoOrdem, this.infoUMA, this.infoDispositivo);

  final InfoOrdem infoOrdem;
  final InfoUMA infoUMA;
  final InfoDispositivo infoDispositivo;

  final mercadorias = <int, EmbalagemItem>{};

  bool contains(InfoMercadoria info) => mercadorias.containsKey(info.idcMercadoria);

  void inclui(InfoMercadoria info, double quantidade) {
    var item = mercadorias[info.idcMercadoria];

    if (item == null) {
      item = EmbalagemItem(info, quantidade);
      mercadorias[info.idcMercadoria] = item;
    } else {
      item.infoMercadoria = info; // atualiza caso tenha trocado alguma coisa...
      item.quantidade += quantidade;
    }
  }
}

class EmbalagemItem {
  EmbalagemItem(this.infoMercadoria, this.quantidade);

  InfoMercadoria infoMercadoria;
  double quantidade;
}

//--------------------------------------------------------------------------------------------
// EmbalagemPage
//--------------------------------------------------------------------------------------------
class EmbalagemPage extends WorkPage {
  const EmbalagemPage(this.operador, {super.key});

  final Operador operador;

  @override
  _EmbalagemState createState() => _EmbalagemState();
}

// Fluxo:
// escolhe um endereço
// escolha a impressora
// escolhe uma ordem
//   embala ordem em n UMAs
//     pega mercadoria
//     informa quantidade
// finaliza a ordem (ajustes)
enum Etapas {
  // 1:1
  pedeEndereco, // pode bipar???
  pedeImpressora, // vai selecionar
  pedeOrdem, // vai ESCOLHER
  // 1:N
  pedeUMA, // pode bipar
  pedeDispositivo, // pode não precisar
  // 1:N
  pedeMercadoria, // pode bipar
  pedeQuantidade, // vai DIGITAR
  // 1:1
  fechaOrdem, // só CONFIRMAR que mercadorias que sobraram NÃO EXISTEM
}

//--------------------------------------------------------------------------------------------
// EmbalagemState
//--------------------------------------------------------------------------------------------
class _EmbalagemState extends WorkState<EmbalagemPage> {
  @override
  void initState() {
    super.initState();

    api = EmbalagemAPI(widget.operador);
    dialogs = EmbalagemDialogs(api);

    title = 'Embalagem';
  }

  late EmbalagemAPI api;
  late EmbalagemDialogs dialogs;

  Embalagem? embalagem;
  List<InfoMercadoria>? listaDePerdas;
  List<int> umaeProcesso = [];
  bool geraBoletimOcorrenciaEmbalagem = App.site.expedicao.geraBoletimOcorrenciaEmbalagem;

  final inputEndereco = TextEditingController();
  final inputImpressora = TextEditingController();
  final inputOrdem = TextEditingController();
  final inputUMA = TextEditingController();
  final inputDispositivo = TextEditingController();
  final inputMercadoria = TextEditingController();
  final inputQuantidade = TextEditingController();

  InfoEndereco? infoEndereco;
  InfoImpressora? infoImpressora;
  InfoOrdem? infoOrdem;
  InfoUMA? infoUMA;
  InfoDispositivo? infoDispositivo;
  InfoMercadoria? infoMercadoria;

  static InfoDispositivo? lastDispositivo;
  static InfoImpressora? lastImpressora;

  Future<InfoMercadoria?> proxMercadoria(InfoOrdem info, Embalagem embalagem) async {
    final list = await api.getMercadorias(info.idcOrdem);

    // acabaram as mercadorias da ordem???
    if (list.isEmpty) return null;

    // pega a 1a ainda NÃO EMBALADA ou se já EMBALOU TODAS, a 1a da lista...
    final result = list.firstWhere((it) => !embalagem.contains(it), orElse: () => list.first);
    return result;
  }

  Future<void> confirma(double quantidade, int? idcMercadoria) async {
    final idcUMA = await api.confirma(
      infoEndereco!.idcEndereco,
      infoOrdem!.idcOrdem,
      infoUMA!.codigo,
      infoDispositivo!.idc,
      idcMercadoria ?? infoMercadoria!.idcMercadoria,
      quantidade,
    );

    // cria outra InfoUMA com idc, se for uma nova UMA...
    if (infoUMA!.idc == 0) {
      infoUMA = InfoUMA(idcUMA, infoUMA!.codigo, infoUMA!.idcDispositivo, null);
      umaeProcesso.add(idcUMA);
    }

    embalagem!.inclui(infoMercadoria!, quantidade);
    infoMercadoria = null;

    goto(Etapas.pedeMercadoria.index);
  }

  Future<void> imprimeEtiqueta() async {
    await api.imprimirEtiquetaUMA(infoImpressora!.idc, <int>[infoUMA!.idc]);
  }

  Future<void> imprimeTodasEtiquetas() async {
    await api.imprimirEtiquetaUMA(infoImpressora!.idc, umaeProcesso);
  }

  /*
    endereço    ---> sair/finalizar
    ordem       ---> finalizar endereço
    UMA         ---> finalizar ordem
    dispositivo 
    mercadoria  ---> finalizar UMA
    quantidade
    finalizar   ---> perdas/ok ---> ordem 
  */

  @override
  Future<int> starting() async {
    try {
      // Aguardar 500ms para abrir a tela
      // Intermitente estourando que a 'api' em "loadWork" não estava
      // inicializada e dava throw exibindo mensagem
      await Future.delayed(const Duration(milliseconds: 500));

      final work = await api.loadWork();
      if (work == null) return Etapas.pedeEndereco.index;

      try {
        infoEndereco = await api.findEndereco(work.endereco);
        infoOrdem = await api.findOrdem(infoEndereco!.idcEndereco, work.ordem);
        return Etapas.pedeUMA.index;
      } catch (ex) {
        final error = 'A ordem que estava em andamento não pode ser continuada.\n'
            'Endereço: ${work.endereco}\n'
            'Ordem: ${work.ordem}\n'
            '\n'
            'Inicie uma nova ordem.';
        if (context.mounted) await showError(context, error);
      }
    } catch (ex) {
      await showError(context, ex);
    }
    return Etapas.pedeEndereco.index;
  }

  @override
  Map<int, WorkStep> createWorkflow() {
    // se deve bipar na mercadoria (usado no workflow)...
    var validaMercadoria = App.site.expedicao.validaBarrasMercadoriaNaEmbalagem;

    return {
      Etapas.pedeEndereco.index: WorkStep(
        etapa: 'Pede Endereço',
        canBack: false,
        init: () async {
          inputEndereco.clear();
          inputOrdem.clear();
        },
        input: () async {
          return [
            SaInput(
              'Endereço',
              inputEndereco,
              suffixIcon: iconButton(Icons.arrow_drop_down_circle, () async {
                infoEndereco = await dialogs.getEndereco(context);
                inputEndereco.text = infoEndereco!.mascaraEndereco;

                nextStep();
              }),
            ),
          ];
        },
        validate: () async {
          infoEndereco = await api.findEndereco(inputEndereco.text);

          // armazena com a máscara dos "."...
          inputEndereco.text = infoEndereco!.mascaraEndereco;
        },
      ),
      Etapas.pedeImpressora.index: WorkStep(
        etapa: 'Pede Impressora',
        canBack: true,
        init: () async {
          inputImpressora.text = lastImpressora?.nomeID ?? '';
        },
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
          ];
        },
        validate: () async {
          infoImpressora = await api.findImpressora(inputImpressora.text);
          lastImpressora = infoImpressora;
        },
      ),
      Etapas.pedeOrdem.index: WorkStep(
        etapa: 'Pede Ordem',
        canBack: true,
        init: () async {
          inputOrdem.clear();
        },
        input: () async {
          return [
            SaInput(
              'Ordem',
              inputOrdem,
              suffixIcon: iconButton(Icons.arrow_drop_down_circle, () async {
                infoOrdem = await dialogs.getOrdem(context, infoEndereco!);
                inputOrdem.text = infoOrdem!.numeroOrdem;
              }),
            ),
          ];
        },
        validate: () async {
          infoOrdem = await api.findOrdem(infoEndereco!.idcEndereco, inputOrdem.text);
          await api.iniciaOrdem(infoOrdem!.idcOrdem);

          await api.saveWork(infoEndereco!, infoOrdem!);
        },
      ),
      Etapas.pedeUMA.index: WorkStep(
        etapa: 'Pede UMA',
        canBack: false,
        init: () async {
          inputUMA.clear();
        },
        input: () async {
          return [
            saCardCheck(
              title: 'Validar mercadoria automaticamente',
              checked: validaMercadoria,
              onChanged: (value) {
                validaMercadoria = value;
              },
            ),
            saSpace(),
            SaInput(
              'UMA',
              inputUMA,
              suffixIcon: iconButton(Icons.add, () async {
                final codigo = await api.geraCodigoUMA(inputUMA.text);
                inputUMA.text = codigo;
              }, tooltip: 'gerar'),
            ),
          ];
        },
        validate: () async {
          // critica a UMA...
          final codigoUMA = checkInputValue(inputUMA);
          infoUMA = await api.getUMA(infoOrdem!.idcOrdem, codigoUMA);

          // se for uma UMA nova, tem que PEDIR o dispositivo...
          if (infoUMA == null) return;

          // UMA já existente: obtém o dispositivo e pede mercadoria...
          infoDispositivo = await api.findDispositivo(idc: infoUMA!.idcDispositivo);
          lastDispositivo = infoDispositivo;

          embalagem = Embalagem(infoOrdem!, infoUMA!, infoDispositivo!);

          goto(Etapas.pedeMercadoria.index);
        },
      ),
      Etapas.pedeDispositivo.index: WorkStep(
        etapa: 'Pede Dispositivo',
        canBack: true,
        init: () async {
          inputDispositivo.text = lastDispositivo?.codigo ?? '';
        },
        input: () async {
          return [
            SaInput(
              'Dispositivo',
              inputDispositivo,
              suffixIcon: iconButton(Icons.arrow_drop_down_circle, () async {
                infoDispositivo = await dialogs.getDispositivo(context);
                inputDispositivo.text = infoDispositivo!.codigo;

                nextStep();
              }),
            ),
          ];
        },
        validate: () async {
          final codigoDispositivo = checkInputValue(inputDispositivo);
          infoDispositivo = await api.findDispositivo(codigo: codigoDispositivo);
          lastDispositivo = infoDispositivo;

          infoUMA = InfoUMA(0, inputUMA.text, infoDispositivo!.idc, null);

          embalagem = Embalagem(infoOrdem!, infoUMA!, infoDispositivo!);
        },
      ),
      Etapas.pedeMercadoria.index: WorkStep(
        etapa: 'Pede Mercadoria',
        canBack: false,
        init: () async {
          inputMercadoria.clear();

          if (infoMercadoria == null) {
            infoMercadoria = await proxMercadoria(infoOrdem!, embalagem!);

            // se já processou TODAS as mercadorias, fecha a ordem...
            if (infoMercadoria == null) {
              goto(Etapas.fechaOrdem.index);
            }
          }

          // define a mercadoria, se necessário...
          if (validaMercadoria && infoMercadoria != null) {
            goto(Etapas.pedeQuantidade.index);
          }
        },
        input: () async {
          return [
            SaInput(
              'Mercadoria',
              inputMercadoria,
            ),
          ];
        },
        validate: () async {
          final codigoBarras = inputMercadoria.text;
          await api.checkMercadoria(infoMercadoria!, codigoBarras);
        },
      ),
      Etapas.pedeQuantidade.index: WorkStep(
        etapa: 'Pede Quantidade',
        canBack: validaMercadoria,
        init: () async {
          inputQuantidade.text = infoMercadoria!.qtdeFaltaEmbalar.toString();
        },
        input: () async {
          return [
            SaInput(
              'Quantidade',
              inputQuantidade,
            ),
          ];
        },
        validate: () async {
          double qtde = checkInputValue(inputQuantidade, type: InputType.double);
          checkDoubleValue(qtde, 1.0, infoMercadoria!.qtdeFaltaEmbalar.toDouble());

          await confirma(qtde, null);
        },
      ),
      Etapas.fechaOrdem.index: WorkStep(
        etapa: 'Fecha Ordem',
        canBack: false,
        init: () async {
          listaDePerdas = await api.getMercadorias(infoOrdem!.idcOrdem);
        },
        input: () async {
          return [];
        },
        validate: () async {
          await api.finalizaOrdem(infoOrdem!.idcOrdem);
          await api.clearWork();

          umaeProcesso.clear();

          // se não achar o endereço, é porque acabaram as suas ordens...
          final aindaTemOrdem = await api.existsEndereco(infoEndereco!.mascaraEndereco);
          if (aindaTemOrdem) {
            // refresh no endereço - para mostrar a qtde de ordens correta...
            infoEndereco = await api.findEndereco(infoEndereco!.mascaraEndereco);

            goto(Etapas.pedeOrdem.index);
          } else {
            goto(Etapas.pedeEndereco.index);
          }
        },
      ),
    };
  }

  @override
  Future<List<Widget>> getBody(int step) async {
    final etapa = Etapas.values[step];

    return [
      // impressora selecionada na 1a linha...
      if (infoImpressora != null) ...[
        SaField('Impressora', infoImpressora!.nomeID),
      ],
      if (etapa.index > Etapas.pedeEndereco.index) ...[
        saRow([
          SaField('Endereço', infoEndereco!.mascaraEndereco),
          SaField('Ordens', infoEndereco!.quantidadeOrdens),
        ]),
      ],
      if (etapa.index > Etapas.pedeOrdem.index) ...[
        saRow([
          SaField('Ordem', infoOrdem!.numeroOrdem),
          SaField('Mercadorias', infoOrdem!.quantidadeMercadorias),
        ]),
        if (infoOrdem!.observacao != null) ...[
          SaField('Observação', infoOrdem!.observacao),
        ],
        saDivider(),
      ],
      if (etapa == Etapas.fechaOrdem) ...[
        if (listaDePerdas!.isEmpty) ...[
          saSpace(),
          saText('A ordem foi embalada SEM NENHUMA PERDA.'),
        ],
        if (listaDePerdas!.isNotEmpty) ...[
          saSpace(),
          saText('As seguintes mercadorias não serão embaladas'),
          saSpace(),
          if (geraBoletimOcorrenciaEmbalagem) ...[
            saText('Elas SERÃO REGISTRADOS COMO PERDAS:'),
          ],
          ...listaDePerdas!
              .map((it) => SaField(it.nomeID, it.qtdeFaltaEmbalar, flexLabel: 1, flexValue: 0))
        ],
      ],
      if (etapa != Etapas.fechaOrdem) ...[
        if (etapa.index > Etapas.pedeUMA.index) ...[
          if (infoUMA == null) SaField('UMA', inputUMA.text),
          if (infoUMA != null) SaField('UMA', '${infoUMA!.codigo} (${infoDispositivo!.nome})'),
          saDivider(),
        ],
        if (etapa.index >= Etapas.pedeMercadoria.index) ...[
          SaField('Mercadoria', infoMercadoria!.nomeID),
          saRow([
            SaField('Falta pegar', infoMercadoria!.qtdeFaltaEmbalar),
            SaField('Quantidade', infoMercadoria!.progresso),
          ]),
        ],
      ]
    ];
  }

  @override
  Future<List<Widget>> getActions(int step) async {
    final etapa = Etapas.values[step];

    if (etapa == Etapas.pedeEndereco) {
      return [
        saSpace(),
        saButton('SAIR da EMBALAGEM', () => close()),
      ];
    }

    if (etapa == Etapas.pedeOrdem) {
      return [
        saSpace(),
        saButton('selecionar NOVO ENDEREÇO', () => goto(Etapas.pedeEndereco.index)),
        saSpace(),
        saButton(
          'mostrar MERCADORIAS',
          () => tryExecute(() async {
            infoOrdem = await api.findOrdem(infoEndereco!.idcEndereco, inputOrdem.text);
            await dialogs.getMercadoria(context, infoOrdem!);
          }),
        ),
      ];
    }

    if (etapa == Etapas.pedeUMA) {
      return [
        saSpace(),
        saButton('finalizar a ORDEM', () => goto(Etapas.fechaOrdem.index)),
      ];
    }

    if (etapa == Etapas.pedeMercadoria || etapa == Etapas.pedeQuantidade) {
      return [
        saSpace(),
        saButton('trocar de MERCADORIA', () async {
          infoMercadoria = await dialogs.getMercadoria(context, infoOrdem!);
          refresh();
        }),
        saSpace(),
        saButton('finalizar/trocar a UMA', () => goto(Etapas.pedeUMA.index)),
        saSpace(),
        saButton('imprimir ETIQUETA da UMA', () => imprimeEtiqueta()),
        saSpace(),
        saButton('pesquisar estoque único', () async {
          await tryExecute(() async {
            final umaOrigem = await dialogs.getUmaOrigem(
              context,
              infoOrdem!.idcLote,
              infoEndereco!.idcEndereco,
              infoOrdem!.idcOrdem,
            );

            if (umaOrigem != null && context.mounted) {
              final result = await showYesOrNo(
                context: context,
                message: "Será realizado a fusão da UMA\nDeseja continuar?",
              );

              if (result == YesOrNoResult.no) return;

              final mercadorias = await api.getMercadoriasUMAOrigem(
                infoOrdem!.idcOrdem,
                umaOrigem.codigo,
              );

              if (mercadorias.isEmpty) {
                throw Exception("O estoque dessa UMA já foi embalado");
              }

              final idcUMA = await api.confirmaEstoqueUnico(
                infoEndereco!.idcEndereco,
                infoOrdem!.idcOrdem,
                infoUMA!.codigo,
                infoDispositivo!.idc,
                umaOrigem.idc,
                mercadorias,
              );

              if (infoUMA!.idc == 0) {
                infoUMA = InfoUMA(idcUMA, infoUMA!.codigo, infoUMA!.idcDispositivo, null);
                umaeProcesso.add(idcUMA);
              }

              for (var mercadoria in mercadorias) {
                embalagem!.inclui(mercadoria, mercadoria.quantidadeUnidade);
              }

              infoMercadoria = null;
              goto(Etapas.pedeMercadoria.index);
            }
          });
        }),
      ];
    }

    if (etapa == Etapas.fechaOrdem) {
      return [
        if (listaDePerdas!.isNotEmpty) ...[
          saSpace(),
          saButton('continuar EMBALANDO a ORDEM', () => goto(Etapas.pedeUMA.index)),
        ],
        saSpace(),
        SaInput('Impressora', inputImpressora,
            suffixIcon: iconButton(Icons.arrow_drop_down_circle, () async {
              infoImpressora = await dialogs.getImpressora(context);
              inputImpressora.text = infoImpressora!.nomeID;
            })),
        saSpace(),
        saButton('imprimir ETIQUETA da UMA', () async {
          await imprimeEtiqueta();
          // showLongToast(msg: "Impressão enviada com sucesso");
        }),
        saSpace(),
        saButton(('imprimir TODAS ETIQUETAS de UMA'), () async {
          await imprimeTodasEtiquetas();
          // showLongToast(msg: "Impressão enviada com sucesso");
        })
      ];
    }

    return [];
  }
}
