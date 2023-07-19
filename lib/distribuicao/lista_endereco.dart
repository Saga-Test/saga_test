import 'package:flutter/material.dart';

import '../saga_lib/sa_widgets.dart';
import 'distribuicao.dart';
import 'lista_para_selecao.dart';

class ListaEndereco extends StatefulWidget {
  const ListaEndereco(
    this.exec,
    this.estoques,
    this.nextStep, {
    Key? key,
  }) : super(key: key);

  final Distribuicao exec;
  final ListaParaSelecao<InfoEstoque> estoques;
  final Future<void> Function() nextStep;

  @override
  State<ListaEndereco> createState() => _ListaEnderecoState();
}

class _ListaEnderecoState extends State<ListaEndereco> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Inverter ordem"),
            Switch(
              value: widget.exec.inverterOrdenacao,
              onChanged: (value) async {
                widget.exec.inverterOrdenacao = value;
                widget.exec.enderecosMercadorias.clear();
                await widget.exec.buscaEnderecos();
                setState(() {});
              },
            )
          ],
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: widget.exec.enderecosMercadorias.length,
          itemBuilder: (context, index) {
            final estoque = widget.exec.umaOrigem.estoquesOrdenadosPorApanha[index];

            final enderecos =
                widget.exec.enderecosMercadorias[estoque.embalagem.mercadoria.nome];

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: saTitle(estoque.embalagem.mercadoria.nome),
                  ),
                  saSpace(),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: enderecos!.length,
                    itemBuilder: (_, index) {
                      InfoEndereco endereco;

                      if (widget.exec.inverterOrdenacao) {
                        final reverseIndex = (enderecos.length - 1) - index;

                        endereco = enderecos[reverseIndex];
                      } else {
                        endereco = enderecos[index];
                      }

                      return InkWell(
                        onTap: () {
                          widget.estoques.clear();
                          widget.estoques.addAll([estoque]);
                          widget.exec.enderecoSelecionado = endereco.mascara;
                          widget.nextStep();
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: saCard(
                            lines: [
                              saTitle(endereco.mascara),
                              saText(endereco.finalidade),
                              SaField(
                                'Maior validade',
                                endereco.maiorValidade ?? '<sem validade>',
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
