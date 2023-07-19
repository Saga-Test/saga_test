import 'package:flutter/material.dart';
import 'package:saga_test/saga_lib/sa_extensions.dart';

import '../barcode/ai.dart';
import '../barcode/barcode_field.dart';
import '../saga_lib/sa_widgets.dart';
import '../saga_lib/sa_dialogs.dart';

import 'distribuicao_api.dart';

class DistribuicaoDialogs {
  DistribuicaoDialogs(this.api);

  final DistribuicaoAPI api;

  Future<List<InfoEstoque>?> getEstoques(
      BuildContext context, InfoUMA uma, List<InfoEstoque> selecionados) async {
    final result = await showCheckList<InfoEstoque>(
      context: context,
      title: 'Apenas as Mercadorias',
      list: uma.estoquesOrdenadosPorApanha,
      listChecked: selecionados,
      showItem: (item) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            saTitle(item.embalagem.mercadoria.toShow),
            saSpace(),
            SaField('Emb', '${item.embalagem.valor} - ${item.embalagem.nome}'),
            saSpace(),
            saColumn([
              for (final c in item.caracteristicas) ...[
                SaField(c.nome, c.valor),
              ],
              saRow(
                [
                  SaField('Fab', item.dataFabricacao),
                  SaField('Val', item.dataValidade),
                ],
              ),
              SaField(
                'Quantidade',
                item.quantidade.toQuantidade(item.embalagem.mercadoria.mensuravel),
              ),
              SaField('End. Apanha', item.embalagem.mercadoria.apanhasOrdenados),
            ]),
          ],
        );
      },
    );
    return result;
  }

  Future<InfoEstoque> getEstoque(BuildContext context, List<InfoEstoque> estoques) async {
    final result = await showList<InfoEstoque>(
      context: context,
      title: 'Estoques',
      list: estoques,
      showItem: (item) {
        return saCard(
          //title: item.nomeID,
          lines: [
            saTitle(item.embalagem.mercadoria.toShow),
            saSpace(),
            saTitle(item.embalagem.nome),
            saSpace(),
            saColumn([
              for (final c in item.caracteristicas) ...[
                SaField(c.nome, c.valor),
              ],
              SaField('Fabricação', item.dataFabricacao),
              SaField('Validade', item.dataValidade),
              SaField('Quantidade', item.quantidade.toInt()),
            ]),
          ],
        );
      },
    );
    return result!;
  }

  Future<InfoDispositivo> getDispositivo(BuildContext context) async {
    final result = await showList<InfoDispositivo>(
      context: context,
      title: 'Dispositivos',
      loadList: () => api.getDispositivos(),
      showItem: (item) {
        return saCard(
          title: item.nomeID,
          lines: [
            SaField('Nome', item.nome),
          ],
        );
      },
    );
    return result!;
  }

  Future<Estoque$SKU> getSKU(BuildContext context, Estoque$Mercadoria mercadoria) async {
    final result = await showList<Estoque$SKU>(
      context: context,
      title: 'Embalagens',
      list: mercadoria.embalagens,
      showItem: (item) {
        return saCard(
          lines: [
            SaField('Nome', item.nome),
            SaField('Quantidade', item.valor),
          ],
        );
      },
    );
    return result!;
  }

  Future<InfoMotivoBloqueio?> getMotivoBloqueio(
    BuildContext context, {
    bool canCancel = true,
  }) async {
    final result = await showList<InfoMotivoBloqueio>(
      context: context,
      title: 'Motivos de Bloqueios',
      loadList: () => api.getMotivoBloqueios(),
      showItem: (item) {
        return saCard(
          lines: [
            saText('${item.descricao}\n'),
          ],
        );
      },
    );
    return result;
  }

  Future<InfoEndereco?> getEnderecoDestino(BuildContext context, InfoEstoque estoque) async {
    final result = await showList<InfoEndereco>(
      context: context,
      title: 'Endereços com a Mercadoria',
      loadList: () => api.getEnderecosDaMercadoria(estoque),
      showItem: (item) {
        return saCard(
          lines: [
            saText(item.mascara),
            saText(item.finalidade),
            SaField('Maior validade', item.maiorValidade ?? '<sem validade>'),
          ],
        );
      },
    );
    return result;
  }

  Future<UMAEstoque?> getUMAsDoEndereco(BuildContext context, String endereco) async {
    final result = await showList<UMAEstoque>(
      context: context,
      title: 'UMAs do Endereço',
      loadList: () => api.getUMAsDoEndereco(endereco),
      showItem: (item) {
        return saCard(
          lines: [
            saText(item.codigo),
            SaField('Endereço', item.endereco.mascara),
            SaField('Qtde Itens', item.quantidadeItens),
            SaField('Produtos', item.infoMercadorias),
          ],
        );
      },
    );
    return result;
  }

  Future<UMAEstoque?> escolherUMAdeEndereco(
    BuildContext context, {
    String enderecoSelecionado = '',
  }) async {
    // pede o endereço...
    final endereco = await inputBarcode(
      context: context,
      ai: AIField.codend,
      title: 'Pesquisar UMA',
      label: 'Endereço',
      value: enderecoSelecionado,
    );
    if (endereco.isEmpty) return null;

    // mostra lookup de UMAs do endereço...
    final uma = await getUMAsDoEndereco(context, endereco);
    return uma;
  }
}
