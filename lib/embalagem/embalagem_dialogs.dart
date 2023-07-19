import 'package:flutter/material.dart';

import '../saga_lib/sa_widgets.dart';
import '../saga_lib/sa_dialogs.dart';

import '../geral/geral_api.dart';

import 'embalagem_api.dart';

class EmbalagemDialogs {
  EmbalagemDialogs(this.api);

  final EmbalagemAPI api;

  Future<InfoEndereco> getEndereco(BuildContext context) async {
    final result = await showList<InfoEndereco>(
      context: context,
      title: 'Endereços',
      loadList: () => api.getEnderecos(),
      showItem: (item) {
        return saCard(
          title: item.nomeID,
          lines: [
            saRow([
              SaField('Ordens', item.quantidadeOrdens),
              SaField('Itens', item.quantidadeItens),
            ]),
          ],
        );
      },
    );
    return result!;
  }

  Future<InfoOrdem> getOrdem(BuildContext context, InfoEndereco endereco) async {
    final result = await showList<InfoOrdem>(
      context: context,
      title: 'Ordens',
      loadList: () => api.getOrdens(endereco.idcEndereco),
      showItem: (item) {
        return saCard(
          title: item.nomeID,
          lines: [
            SaField('Lote', item.idcLote),
            SaField('Qtd. pedidos', item.numOrdensLotes),
            SaField('Mercadorias', item.quantidadeMercadorias),
            SaField('Estoques', item.quantidadeEstoqueEmbalar.toInt()),
            SaField('Peso', item.pesoEstoqueEmbalar),
            saSpace(),
            saText('Cliente:'),
            SaField('', item.clienteID),
            saText('Observação:'),
            SaField('', item.observacao),
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

  Future<InfoMercadoria> getMercadoria(BuildContext context, InfoOrdem ordem) async {
    final result = await showList<InfoMercadoria>(
      context: context,
      title: 'Mercadorias',
      loadList: () => api.getMercadorias(ordem.idcOrdem),
      showItem: (item) {
        return saCard(
          title: item.nomeID,
          lines: [
            saRow([
              SaField('Faltam', item.qtdeFaltaEmbalar),
              SaField('Total', item.descTotal),
            ]),
            saSpace(),
            saText('UMAs:'),
            SaField('', item.umas),
          ],
        );
      },
    );
    return result!;
  }

  Future<InfoImpressora> getImpressora(BuildContext context) async {
    final result = await showList<InfoImpressora>(
      context: context,
      title: 'Impressoras',
      loadList: () => api.getImpressoras(),
      showItem: (item) {
        return saCard(
          title: item.nomeID,
          lines: [
            SaField('Nome', item.nome),
            SaField('Servidor', item.nomeServidor),
            SaField('Padrão', item.impressoraPadrao),
          ],
        );
      },
    );
    return result!;
  }

  Future<UmaOrigem?> getUmaOrigem(
    BuildContext context,
    int idcLoteExpedicao,
    int idcEndereco,
    int idcOrdem,
  ) async {
    final result = await showList<UmaOrigem?>(
      context: context,
      title: 'UMAs Origem',
      loadList: () => api.getDadosUmaOrigem(idcLoteExpedicao, idcEndereco, idcOrdem),
      showItem: (item) {
        return saCard(
          lines: [
            SaField('Codigo', item!.codigo),
            SaField('Num. mercadoria', item.quantidadeMercadoria),
            SaField('Observação', item.observacaoUMA),
          ],
        );
      },
    );
    return result;
  }
}
