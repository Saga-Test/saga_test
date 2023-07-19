import 'package:flutter/material.dart';
import 'package:saga_test/saga_lib/sa_extensions.dart';

import '../saga_lib/sa_error.dart';
import '../saga_lib/sa_widgets.dart';
import '../saga_lib/sa_dialogs.dart';

import '../workflow/work_page.dart';
import '../main/app.dart';

import 'lista_endereco.dart';
import 'lista_para_selecao.dart';
import 'distribuicao_dialogs.dart';
import 'distribuicao.dart';

//--------------------------------------------------------------------------------------------
// DistribuicaoPage
//--------------------------------------------------------------------------------------------
class DistribuicaoPage extends WorkPage {
  const DistribuicaoPage(this.operador, {super.key});

  final Operador operador;

  @override
  createState() => _DistribuicaoState();
}

//--------------------------------------------------------------------------------------------
// DistribuicaoState
//--------------------------------------------------------------------------------------------
class _DistribuicaoState extends WorkState<DistribuicaoPage> {
  @override
  void initState() {
    title = 'Distribuição';

    exec = Distribuicao(widget.operador);
    dialogs = DistribuicaoDialogs(exec.api);
    super.initState();
  }

  void addMercadoria(String barcode) async {
    final list = estoques.findAll((it) => it.embalagem.codigosDeBarras.contains(barcode));
    if (list.isEmpty) {
      await showError(context, 'Mercadoria não encontrada: $barcode');
      return;
    }

    InfoEstoque estoque;
    if (list.length == 1) {
      estoque = list.single;
    } else {
      // qual estoque entre os que contém a mercadoria bipada???
      estoque = await dialogs.getEstoque(context, list);
    }

    estoques.add(estoque);
    inputMercadoria.clear();
    refresh();
  }

  void resetState() {
    for (var input in [
      inputUMAOrigem,
      inputMercadoria,
      inputQuantidade,
      inputUMADestino,
      inputDispositivo,
      inputEndereco,
    ]) {
      input.clear();
    }

    estoques.clear();
    mantemBloqueios = false;
    novoBloqueio = null;
  }

  late Distribuicao exec;
  late DistribuicaoDialogs dialogs;

  late ListaParaSelecao<InfoEstoque> estoques;

  final inputUMAOrigem = TextEditingController();
  final inputMercadoria = TextEditingController();
  final inputQuantidade = TextEditingController();
  final inputUMADestino = TextEditingController();
  final inputDispositivo = TextEditingController();
  final inputEndereco = TextEditingController();

  var mantemBloqueios = false;
  InfoMotivoBloqueio? novoBloqueio;

  bool exibeEnderecos = false;
  Estoque$Mercadoria? mercadoria;

  @override
  Map<int, WorkStep> createWorkflow() {
    return {
      Etapa.pedeUMAOrigem.index: WorkStep(
        etapa: 'Pede Uma Origem',
        canBack: false,
        init: () async {
          exec.enderecosMercadorias.clear();
        },
        input: () async {
          return [
            SaInput(
              'UMA Origem',
              inputUMAOrigem,
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  iconButton(Icons.search, () async {
                    final uma = await dialogs.escolherUMAdeEndereco(context);
                    if (uma == null) return;

                    inputUMAOrigem.text = uma.codigo;
                  }, tooltip: 'pesquisar'),
                ],
              ),
            ),
            saCardCheck(
              title: 'Exibir tela de endereços',
              checked: exibeEnderecos,
              onChanged: (value) => exibeEnderecos = value,
            ),
          ];
        },
        validate: () async {
          await exec.informaUMAOrigem(inputUMAOrigem);
          estoques = ListaParaSelecao(exec.umaOrigem.estoques);

          if (exibeEnderecos) {
            await exec.buscaEnderecos();
          } else {
            goto(Etapa.escolheEstoques.index);
          }
        },
      ),
      Etapa.exibeEnderecos.index: WorkStep(
        etapa: 'Exibe Enderecos',
        canBack: false,
        input: () async {
          return [
            ListaEndereco(exec, estoques, nextStep),
          ];
        },
        validate: () async {},
      ),
      Etapa.escolheEstoques.index: WorkStep(
        etapa: 'Excolhe Estoques',
        canBack: false,
        input: () async {
          return [
            SaInput(
              'Mercadoria',
              inputMercadoria,
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  iconButton(Icons.add, () async {
                    final barcode = inputMercadoria.text;
                    if (barcode.isEmpty) return;

                    addMercadoria(barcode);
                  }, tooltip: 'adicionar'),
                  iconButton(Icons.search, () async {
                    final list = await dialogs.getEstoques(
                      context,
                      exec.umaOrigem,
                      estoques.escolhidos,
                    );

                    // pressionou o CANCELAR???
                    if (list == null) return;

                    estoques.clear();
                    estoques.addAll(list);
                    refresh();
                  }, tooltip: 'restringir'),
                ],
              ),
            ),
          ];
        },
        validate: () async {
          if (estoques.unico) {
            goto(Etapa.pedeQuantidade.index);
          } else {
            goto(Etapa.pedeUMADestino.index);
          }
        },
      ),
      Etapa.pedeQuantidade.index: WorkStep(
        etapa: 'Pede Quantidade',
        canBack: true,
        init: () async {
          inputQuantidade.clear();
          mercadoria = estoques.single.embalagem.mercadoria;
        },
        input: () async {
          return [
            SaInput(
              'Quantidade',
              inputQuantidade,
              mensuravel: mercadoria?.mensuravel,
              suffixIcon: iconButton(Icons.arrow_drop_down_circle, () async {
                // consulta as embalagens desta mercadoria...
                await dialogs.getSKU(context, mercadoria!);
              }),
            ),
          ];
        },
        validate: () async {
          await exec.informaQuantidade(inputQuantidade, estoques.single);
        },
      ),
      Etapa.pedeUMADestino.index: WorkStep(
        etapa: 'Pede UMA Destino',
        canBack: true,
        init: () async {
          inputUMADestino.clear();
        },
        input: () async {
          return [
            SaInput(
              'UMA Destino',
              inputUMADestino,
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  iconButton(Icons.add, () async {
                    inputUMADestino.text = await exec.geraCodigoUMA(inputUMADestino.text);
                  }, tooltip: 'gerar'),
                  iconButton(Icons.search, () async {
                    final uma = await dialogs.escolherUMAdeEndereco(
                      context,
                      enderecoSelecionado: exec.enderecoSelecionado,
                    );
                    if (uma == null) return;

                    inputUMADestino.text = uma.codigo;
                  }, tooltip: 'pesquisar'),
                ],
              ),
            ),
          ];
        },
        validate: () async {
          await exec.informaUMADestino(inputUMADestino, estoques.selecionados);

          if (exec.novaUMA) {
            goto(Etapa.pedeDispositivo.index);
          } else {
            goto(Etapa.bloqueiaUMADestino.index);
          }
        },
      ),
      Etapa.pedeDispositivo.index: WorkStep(
        etapa: 'Pede Dispositivo',
        canBack: false,
        init: () async {
          inputDispositivo.text = Distribuicao.lastDispositivo;
        },
        input: () async {
          return [
            SaInput(
              'Dispositivo',
              inputDispositivo,
              suffixIcon: iconButton(Icons.arrow_drop_down_circle, () async {
                final infoDispositivo = await dialogs.getDispositivo(context);
                inputDispositivo.text = infoDispositivo.codigo;

                nextStep();
              }),
            ),
          ];
        },
        validate: () async {
          await exec.informaDispositivo(inputDispositivo);
        },
      ),
      Etapa.bloqueiaUMADestino.index: WorkStep(
        etapa: 'Bloqueia UMA Destino',
        canBack: false,
        input: () async {
          return [
            saDivider(),
            if (exec.umaOrigem.bloqueios.isNotEmpty)
              CheckboxListTile(
                title: const Text(
                    'Selecione para manter os bloqueios da UMA de origem ou CONTINUAR para seguir.'),
                value: mantemBloqueios,
                onChanged: (bool? value) async {
                  setState(() => mantemBloqueios = value!);
                  nextStep();
                },
                secondary: const Icon(Icons.grid_off_sharp),
              )
            else
              saButton('bloquear UMA de destino', () async {
                final bloqueio = await dialogs.getMotivoBloqueio(context);
                if (bloqueio == null) return;

                final podeBloquear = await podeBloquearUMA(bloqueio);
                if (!podeBloquear) return;

                novoBloqueio = bloqueio;
                nextStep();
              }),
          ];
        },
        validate: () async {
          await exec.informaBloqueio(mantemOrigem: mantemBloqueios, novo: novoBloqueio);

          // só pede endereço para novas UMAs...
          if (exec.novaUMA) {
            goto(Etapa.pedeEnderecoUMA.index);
          } else {
            goto(Etapa.finaliza.index);
          }
        },
      ),
      Etapa.pedeEnderecoUMA.index: WorkStep(
        etapa: 'Pede Endereco UMA',
        canBack: false,
        init: () async {
          inputEndereco.clear();
          if (exibeEnderecos) {
            inputEndereco.text = exec.enderecoSelecionado;
          }
        },
        input: () async {
          return [
            SaInput(
              'Endereço de Destino',
              inputEndereco,
              suffixIcon: !estoques.unico
                  ? null
                  : iconButton(
                      Icons.arrow_drop_down_circle,
                      () async {
                        final estoque = estoques.single;
                        final infoEndereco =
                            await dialogs.getEnderecoDestino(context, estoque);

                        if (infoEndereco != null) {
                          inputEndereco.text = infoEndereco.mascara;
                          nextStep();
                        }
                      },
                    ),
            ),
          ];
        },
        validate: () async {
          await exec.informaDestino(inputEndereco, estoques.selecionados);

          final mensagem = exec.confirmaDestino!.mensagem;
          if (mensagem != null && mensagem.isNotEmpty && context.mounted) {
            final result =
                await showYesOrNo(context: context, title: 'Atenção', message: mensagem);

            if (result == YesOrNoResult.no) {
              abort();
            }
          }
        },
      ),
      Etapa.finaliza.index: WorkStep(
        etapa: 'Finaliza',
        canBack: true,
        input: () async {
          return [];
        },
        validate: () async {
          await exec.executa(estoques.selecionados);

          exec = Distribuicao(widget.operador);
          resetState();
          goto(Etapa.pedeUMAOrigem.index);
        },
      ),
    };
  }

  Future<bool> podeBloquearUMA(InfoMotivoBloqueio bloqueio) async {
    final operadorTemPermissao = await exec.operadorPodeBloquear(bloqueio.idc);
    if (operadorTemPermissao) return true;

    bool usuarioTemPermissao = false;

    if (context.mounted) {
      usuarioTemPermissao = await inputUserDialog(
        context: context,
        title: 'Autorizar Bloqueio',
        onValidate: (usuario, senha) async {
          final temPermissao = await exec.usuarioPodeBloquear(usuario, senha, bloqueio.idc);

          if (!temPermissao) {
            throw Exception('Este usuário não tem permissão para este bloqueio');
          }
        },
      );
    }

    return usuarioTemPermissao;
  }

  @override
  Future<List<Widget>> getBody(int step) async {
    final etapa = Etapa.values[step];

    return [
      if (etapa.index > Etapa.pedeUMAOrigem.index) ...[
        saRow([
          SaField('UMA Origem', exec.umaOrigem.codigo),
        ]),
      ],
      if (etapa.index >= Etapa.escolheEstoques.index) ...[
        // se selecionou TODOS e é mais de 1 estoque...
        if (estoques.todos && !estoques.unico) ...[
          const SaField('Estoques', 'TODAS AS MERCADORIAS'),
        ] else
          // se restringiu ou é apenas 1 estoque, mostra os estoques...
          for (final item in estoques.selecionados) ...[
            saColumn([
              saSpace(),
              SaField('', item.embalagem.mercadoria.toShow),
              saRow([
                SaField('Validade', item.dataValidade),
                SaField('Quantidade',
                    item.quantidade.toQuantidade(item.embalagem.mercadoria.mensuravel)),
              ]),
            ])
          ],
        saDivider(),
      ],
      if (etapa.index > Etapa.pedeQuantidade.index) ...[
        if (estoques.unico) ...[
          SaField('Quantidade', exec.quantidade),
        ],
      ],
      if (etapa.index > Etapa.pedeUMADestino.index) ...[
        saRow([
          SaField('UMA Destino', exec.destinoToShow),
        ]),
      ],
      if (etapa.index > Etapa.bloqueiaUMADestino.index) ...[
        saRow([
          SaField('Novo bloqueio', exec.bloqueioToShow),
          saDivider(),
        ]),
      ],
    ];
  }

  @override
  Future<List<Widget>> getActions(int step) async {
    final etapa = Etapa.values[step];

    if (etapa == Etapa.pedeUMAOrigem) {
      return [
        saSpace(),
        saButton('SAIR da DISTRIBUIÇÃO', () => close()),
      ];
    }

    if (etapa == Etapa.escolheEstoques) {
      return [
        saSpace(),
        saButton(
          'Trocar a UMA de Origem',
          () => tryExecute(() async {
            await exec.cancela(context, pedeConfirmacao: false);

            goto(Etapa.pedeUMAOrigem.index);
          }),
        )
      ];
    }

    if (etapa == Etapa.pedeEnderecoUMA || etapa == Etapa.finaliza) {
      return [
        saSpace(),
        saButton(
          'CANCELAR a DISTRIBUIÇÃO',
          () => tryExecute(() async {
            await exec.cancela(context, pedeConfirmacao: true);

            this.exec = Distribuicao(widget.operador);
            resetState();
            goto(Etapa.pedeUMAOrigem.index);
          }),
        ),
      ];
    }

    return [];
  }
}
