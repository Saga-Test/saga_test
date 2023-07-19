import '../geral/geral_api.dart';
import '../main/app.dart';
import '../saga_lib/sa_api.dart';
import '../saga_lib/sa_json.dart';

part 'associacao_rg_api.g.dart';

class AssociacaoAPI extends SAApi {
  AssociacaoAPI(this.operador)
      : idcUsuario = operador.idcUsuario,
        idcSite = operador.idcSite,
        geralAPI = GeralAPI(operador);

  final Operador operador;
  final int idcUsuario;
  final int idcSite;

  final GeralAPI geralAPI;

  Future<List<InfoImpressora>> getImpressoras() async => await geralAPI.getImpressoras();

  Future<InfoImpressora> findImpressora(String nome) async {
    final list = await getImpressoras();
    final result = list.where((it) => it.nomeID.startsWith(nome));

    if (result.isEmpty) throw Exception('Impressora inválida');

    if (result.length > 1) {
      throw Exception('Há várias impressoras com esse prefixo');
    }

    return result.first;
  }

  Future<List<InfoEndereco>> getEnderecos() async {
    final list = await getList<InfoEndereco>(
      '/api/servico/ListarEnderecosComServicos',
      {
        'idcSite': idcSite,
        'IdcUsr': idcUsuario,
      },
      (json) => InfoEndereco.fromJson(json),
    );
    return list;
  }

  Future<InfoEndereco> findEndereco(String endereco) async {
    final list = await getEnderecos();
    final result = list.where((el) => el.endereco.startsWith(endereco));

    if (result.isEmpty) throw Exception('Endereço inválido');

    if (result.length > 1) {
      throw Exception('Há mais de um endereço com esse prefixo');
    }

    return result.first;
  }

  Future<List<InfoLote>> getLotes(int idcEndereco) async {
    final list = await getList<InfoLote>(
      '/api/servico/ListarLotesComServicos',
      {
        'IdcEndereco': idcEndereco,
        'IdcUsuario': App.idcUsuario,
      },
      (json) => InfoLote.fromJson(json),
    );
    return list;
  }

  Future<void> iniciaAtividade(int idcLote) async {
    await post('/api/servico/IniciaServico', {
      'IdcSite': App.idcSite,
      'IdcLote': idcLote,
      'IdcUsuario': App.idcUsuario,
    });
  }

  Future<InfoLote> findLote(int idcEndereco, int lote) async {
    final list = await getLotes(idcEndereco);
    final result = list.where((el) => el.idcLote == lote);

    if (result.isEmpty) throw Exception('Lote inválido');

    return result.first;
  }

  Future<InfoIdt?> getIdt(String codigoRG) async {
    final idt = await get(
      '/api/servico/ListarIdtsExistente',
      {
        'CodigoRgu': codigoRG,
      },
      (json) => InfoIdt.fromJson(json),
    );
    return idt;
  }

  Future<InfoRGU?> getRGU(String codigoRGU) async {
    final rgu = await get(
      '/api/servico/ListarRguExistente',
      {
        'CodigoRgu': codigoRGU,
      },
      (json) => InfoRGU.fromJson(json),
    );
    return rgu;
  }

  Future<List<InfoProduto>> getProdutos(String idcLoteExpedicao, String? codigoRGU) async {
    final list = await getList(
      '/api/servico/ListarProdutosPedidos',
      {
        'IdcLoteExpedicao': idcLoteExpedicao,
        'CodigoRgu': codigoRGU,
      },
      (json) => InfoProduto.fromJson(json),
    );
    return list;
  }

  Future<InfoProduto> findProduto({
    required String idcLote,
    required String codigoMercadoria,
    String? codigoRGU,
    String? message,
  }) async {
    final list = await getProdutos(idcLote, codigoRGU);

    final result = list.where((el) => el.codigoMercadoria.startsWith(codigoMercadoria));

    if (result.isEmpty) throw Exception(message ?? 'Mecadoria inválida');

    return result.first;
  }

  Future<bool> executaAssociacao(
    int idcLot,
    int idcOrdem,
    String codigoRGU,
    int idcMercadoria,
    int? idcGrupoCaracteristica,
  ) async {
    final result = await post(
      '/api/servico/AssociarRGPedido',
      {
        'IdcLot': idcLot,
        'IdcOrdem': idcOrdem,
        'CodigoRGU': codigoRGU,
        'IdcMercadoria': idcMercadoria,
        'IdcGrupoCaracteristica': idcGrupoCaracteristica,
        'QuantidadeEstoquePrimario': 1,
        'IdcUsuario': App.idcUsuario,
        'IdcSite': App.idcSite,
      },
    );
    return result;
  }

  Future<void> imprimirEtiquetaRGU(
    int idcImpressora,
    String codigoRGU,
  ) async {
    await post('/api/etiqueta/ImprimeEtiquetaVolumeRGU', {
      'idcSite': operador.idcSite,
      'IdcProprietario': null,
      'idcImpressora': idcImpressora,
      'CodigoRGU': codigoRGU
    });
  }

  Future<bool> finalizaServico(
    int idcOrdemServico,
    int sequenciaAtividade,
    int numeroItemOrdemServico,
    int numeroSequencialServico,
  ) async {
    final result = await post(
      '/api/servico/FinalizaServico',
      {
        "IdcOrdemServico": idcOrdemServico,
        "SequenciaAtividade": sequenciaAtividade,
        "NumeroItemOrdemServico": numeroItemOrdemServico,
        "NumeroSequencialServico": numeroSequencialServico,
        "IdcUsuario": operador.idcUsuario
      },
    );
    return result;
  }

  Future<bool> liberaServico(
    int idcOrdemServico,
    int valorSequenciaAtividade,
    int numeroItemOrdemServico,
    int valorSequenciaServico,
  ) async {
    final result = await post(
      '/api/servico/LiberaServicoRGU',
      {
        "IdcOrdSvc": idcOrdemServico,
        "VlrNroSeqAtv": valorSequenciaAtividade,
        "NroItmOrdSvc": numeroItemOrdemServico,
        "VlrNumSeqSvc": valorSequenciaServico,
        "IdcUsuario": App.idcUsuario
      },
    );
    return result;
  }
}

@JsonResult()
class InfoEndereco {
  InfoEndereco(
    this.idcEndereco,
    this.endereco,
  );

  final int idcEndereco;
  final String endereco;

  factory InfoEndereco.fromJson(Map<String, dynamic> json) => _$InfoEnderecoFromJson(json);
}

@JsonResult()
class InfoLote {
  InfoLote(
    this.idcLote,
    this.idcAtividade,
    this.idcSituacaoAtividade,
    this.idcOrdemServico,
    this.valorSequenciaAtividade,
    this.numeroItemOrdemServico,
    this.valorSequenciaServico,
  );
  final int idcLote;
  final int idcAtividade;
  final int idcSituacaoAtividade;
  final int idcOrdemServico;
  final int valorSequenciaAtividade;
  final int numeroItemOrdemServico;
  final int valorSequenciaServico;

  factory InfoLote.fromJson(Map<String, dynamic> json) => _$InfoLoteFromJson(json);
}

@JsonResult()
class InfoRGU {
  InfoRGU(
    this.idcMercadoria,
    this.codigoMercadoria,
    this.descricaoMercadoria,
    this.valorEmbalagem,
  );
  final int idcMercadoria;
  final String codigoMercadoria;
  final String descricaoMercadoria;
  final int valorEmbalagem;

  factory InfoRGU.fromJson(Map<String, dynamic> json) => _$InfoRGUFromJson(json);
}

@JsonResult()
class InfoIdt {
  InfoIdt(
    this.codigoIdt,
    this.codigoUMA,
    this.idcSituacaoUMA,
    this.codigoMercadoria,
    this.descricaoMercadoria,
    this.valorEmbalagem,
    this.quantidadeEstoquePrimario,
    this.idcEnderecoUMA,
    this.situacaoUMA,
    this.mascaraEnderecoUMA,
    this.idcMercadoria,
    this.idcGrupoCaracteristicas,
  );
  final String codigoIdt;
  final String codigoUMA;
  final int idcSituacaoUMA;
  final int idcMercadoria;
  final String codigoMercadoria;
  final String descricaoMercadoria;
  final int valorEmbalagem;
  final int? idcGrupoCaracteristicas;
  final double quantidadeEstoquePrimario;
  final int idcEnderecoUMA;
  final String situacaoUMA;
  final String mascaraEnderecoUMA;

  factory InfoIdt.fromJson(Map<String, dynamic> json) => _$InfoIdtFromJson(json);
}

@JsonResult()
class InfoProduto {
  InfoProduto(
    this.idcLoteExpedicao,
    this.sequenciaCarregamento,
    this.nomeCliente,
    this.idcMercadoria,
    this.codigoMercadoria,
    this.descricaoMercadoria,
    this.idcGrupoCaracteristica,
    this.valorCaracteristicaConcatenada,
    this.saldoEmUnidade,
    this.ordens,
  );
  final int idcLoteExpedicao;
  final int sequenciaCarregamento;
  final String nomeCliente;
  final int idcMercadoria;
  final String codigoMercadoria;
  final String descricaoMercadoria;
  final int? idcGrupoCaracteristica;
  final String valorCaracteristicaConcatenada;
  final double saldoEmUnidade;
  final List<InfoProduto$Ordens> ordens;

  factory InfoProduto.fromJson(Map<String, dynamic> json) => _$InfoProdutoFromJson(json);
}

@JsonSerializable()
class InfoProduto$Ordens {
  InfoProduto$Ordens(
    this.idcOrdem,
    this.numeroOrdem,
  );
  final int idcOrdem;
  final String numeroOrdem;

  factory InfoProduto$Ordens.fromJson(Map<String, dynamic> json) =>
      _$InfoProduto$OrdensFromJson(json);
  Map<String, dynamic> toJson() => _$InfoProduto$OrdensToJson(this);
}
