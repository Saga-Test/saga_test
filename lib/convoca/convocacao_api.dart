import 'package:saga_test/saga_lib/sa_api.dart';

import '../main/app.dart';
import 'convocacao.dart';

class ConvocacaoApi extends SAApi {
  ConvocacaoApi(this.operador);

  final Operador operador;

  Future<Convocacao?> buscaConvocacao(int tipo) async {
    final result = await post(
      "/api/Mobile/PedirConvocacao",
      {
        "IdcSite": App.idcSite,
        "IdcUsuario": App.idcUsuario,
        "TipoConvocacao": tipo,
      },
      fromJson: (json) => Convocacao.fromJson(json),
      descricao: "Busca uma Convoção",
    );

    return result;
  }

  Future<Convocacao?> aceitaConvocacao(int idcLote) async {
    final result = await post(
      "/api/mobile/aceitarConvocacao",
      {
        'IdcSite': operador.idcSite,
        'IdcLote': idcLote,
        'IdcUsuario': operador.idcUsuario,
      },
      fromJson: (json) => Convocacao.fromJson(json),
      descricao: 'Aceita a Convocação recebida',
    );
    return result;
  }

  Future<void> recusaConvocacao() async {
    await post(
      '/api/mobile/recusarConvocacao',
      {
        'IdcSite': operador.idcSite,
        'IdcUsuario': operador.idcUsuario,
      },
      descricao: "Recusa a Convocação recebida",
    );
  }

  Future<void> atualizaSituacaoUsuario(int situacaoUsuario) async {
    await post(
      '/api/mobile/AtualizarSituacaoUsuario',
      {
        'IdcSite': operador.idcSite,
        'IdcUsuario': operador.idcUsuario,
        'IdcStatusUsuario': situacaoUsuario
      },
      descricao: "Muda o status do operador",
    );
  }
}
