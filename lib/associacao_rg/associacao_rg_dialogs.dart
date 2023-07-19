import 'package:flutter/cupertino.dart';

import '../geral/geral_api.dart';
import '../saga_lib/sa_dialogs.dart';
import '../saga_lib/sa_widgets.dart';
import 'associacao_rg_api.dart';

class AssociacaoDialogs {
  AssociacaoDialogs(this.api);

  final AssociacaoAPI api;

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

  Future<InfoEndereco> getEndereco(BuildContext context) async {
    final result = await showList<InfoEndereco>(
        context: context,
        title: 'Endereços',
        loadList: () => api.getEnderecos(),
        showItem: (item) {
          return saCard(
            title: "\n ${item.endereco} \n",
          );
        });
    return result!;
  }

  Future<InfoLote> getLote(BuildContext context, int idcEndereco) async {
    final result = await showList<InfoLote>(
      context: context,
      title: 'Lotes',
      loadList: () => api.getLotes(idcEndereco),
      showItem: (item) {
        return saCard(
          title: '\n ${item.idcLote.toString()} \n',
        );
      },
    );
    return result!;
  }

  Future<InfoProduto?> getProduto(
      BuildContext context, String idcLoteExpedicao, String? codigoRGU) async {
    final result = await showList<InfoProduto?>(
      context: context,
      title: 'Mercadorias',
      loadList: () => api.getProdutos(idcLoteExpedicao, codigoRGU),
      showItem: (item) {
        return saCard(
          lines: [
            SaField('Cliente', item!.nomeCliente),
            SaField('Mercadoria', item.codigoMercadoria),
            SaField('Descrição', item.descricaoMercadoria),
          ],
        );
      },
    );
    return result!;
  }
}
