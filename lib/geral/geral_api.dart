// ignore_for_file: public_member_api_docs, sort_constructors_first
import '../convoca/convocacao.dart';
import '../main/app.dart';
import '../saga_lib/sa_api.dart';
import '../saga_lib/sa_json.dart';

part 'geral_api.g.dart';

//-------------------------------------------------------------------------------------------
// Geral
//-------------------------------------------------------------------------------------------
class GeralAPI extends SAApi {
  GeralAPI(this.operador)
      : idcUsuario = operador.idcUsuario,
        idcSite = operador.idcSite;

  final Operador operador;
  final int idcUsuario;
  final int idcSite;

  //------------------------------------------------------------------------------------------
  // Convocação
  //------------------------------------------------------------------------------------------
  Future<Convocacao?> pegaConvocacao() async {
    final result = await post(
      '/api/Mobile/PedirConvocacao',
      {'idcSite': App.idcSite, 'idcUsuario': App.idcUsuario, 'tipoConvocacao': 'EmExecucao'},
      fromJson: (json) => Convocacao.fromJson(json),
    );
    return result;
  }

  //-----------------------------------------------------------------------------------------
  // Impressoras
  //-----------------------------------------------------------------------------------------
  Future<List<InfoImpressora>> getImpressoras() async {
    final list = await getList(
      '/api/Servico/ListarImpressoras',
      {'idcSite': this.idcSite},
      (json) => InfoImpressora.fromJson(json),
    );

    return list;
  }

  Future<void> imprimirEtiquetaVolumePrevisto(
          int idcImpressora, List<int> listIdcUMAs) async =>
      await _imprimirEtiquetaUMA(TipoEtiqueta.volumePrevisto, idcImpressora, listIdcUMAs);

  Future<void> imprimirEtiquetaVolumeReal(int idcImpressora, List<int> listIdcUMAs) async =>
      await _imprimirEtiquetaUMA(TipoEtiqueta.volumeReal, idcImpressora, listIdcUMAs);

  Future<void> imprimirEtiquetaUMA(int idcImpressora, List<int> listIdcUMAs) async =>
      await _imprimirEtiquetaUMA(TipoEtiqueta.umaBasica, idcImpressora, listIdcUMAs);

  Future<void> _imprimirEtiquetaUMA(
      TipoEtiqueta tipo, int idcImpressora, List<int> listIdcUMAs) async {
    if (tipo == TipoEtiqueta.umaBasica) {
      await post('/api/etiqueta/ImprimeEtiquetaUmaBasica', {
        'idcSite': idcSite,
        // ignore: todo
        'clientId': null, //TODO: enviar o ip do dispositivo
        'idcImpressora': idcImpressora,
        'umas': listIdcUMAs,
      });
    } else {
      await post('/api/etiqueta/ImprimeEtiquetaVolume', {
        'tipo': tipo.index,
        'idcSite': idcSite,
        // ignore: todo
        'clientId': null, //TODO: enviar o ip do dispositivo
        'idcImpressora': idcImpressora,
        'umas': listIdcUMAs,
      });
    }
  }

  Future<void> imprimeEtqProdutoLoteRecebimento(int idcImpressora, int idcLote) async {
    await post(
      '/api/etiqueta/imprimeEtiquetaProdutoLoteRecebimento',
      {
        'idcSite': operador.idcSite,
        'idcImpressora': idcImpressora,
        'idcLote': idcLote,
      },
    );
  }

  Future<void> imprimeEtiqueta(
    int idcImpressora,
    int tipoEtiqueta,
    int? idcUmaRGU,
    int? idcLote,
    int? idcPrc,
    int? idcProprietario,
    int? idcMercadoria,
    int? idcEmbalagem,
    String? codigoRGU,
    int? quantidadeEtiqueta,
    List<int?> listIdcUma,
  ) async {
    await post(
      '/api/etiqueta/imprimirEtiqueta',
      {
        "idcSite": operador.idcSite,
        "idcImpressora": idcImpressora,
        "idcUmaRGU": idcUmaRGU,
        "idcLote": idcLote,
        "idcPrc": idcPrc,
        "idcProprietario": idcProprietario,
        "idcMercadoria": idcMercadoria,
        "idcEmbalagem": idcEmbalagem,
        "idcUsuario": operador.idcUsuario,
        "codigoRGU": codigoRGU,
        "quantidadeEtiqueta": quantidadeEtiqueta,
        "tipoEtiqueta": tipoEtiqueta,
        "uma": listIdcUma,
      },
    );
  }

  //-----------------------------------------------------------------------------------------
  // InfoExecução
  //-----------------------------------------------------------------------------------------
  Future<String> getInfoExecucao(int idcAtividade, int idcModoOperacao) async {
    final result = await getString('/api/servico/ListaInfoExecucao', {
      'idcSite': idcSite,
      'idcAtividade': idcAtividade,
      'idcModoOperacao': idcModoOperacao,
      'idcUsuario': idcUsuario,
    });
    return result;
  }

  Future<void> salvaInfoExecucao(
      int idcAtividade, int idcModoOperacao, String infoJson) async {
    await post('/api/servico/SalvaInfoExecucao', {
      'idcSite': idcSite,
      'idcAtividade': idcAtividade,
      'idcModoOperacao': idcModoOperacao,
      'idcUsuario': idcUsuario,
      'json': infoJson,
    });
  }

  Future<void> excluiInfoExecucao(int idcAtividade, int idcModoOperacao) async {
    await post('/api/servico/RemoveInfoExecucao', {
      'idcSite': idcSite,
      'idcAtividade': idcAtividade,
      'idcModoOperacao': idcModoOperacao,
      'idcUsuario': idcUsuario,
    });
  }

  //-----------------------------------------------------------------------------------------
  // GeralInfoLote
  //-----------------------------------------------------------------------------------------
  Future<List<GeralInfoLote>> listarDadosPedidoRecByLote(int idcLote, int? idcUMA) async {
    final list = await getList<GeralInfoLote>(
      '/api/servico/listarDadosPedidoRecByLote',
      {
        'idcLote': idcLote,
        'idcUMA': idcUMA,
      },
      (json) => GeralInfoLote.fromJson(json),
    );
    return list;
  }

  //-----------------------------------------------------------------------------------------
  // DialogInfoUMA
  //-----------------------------------------------------------------------------------------
  Future<ObservacaoUMA> listaInfoUMA(int idcUMA) async {
    final result = await get(
      '/api/estoque/pesquisaDadosUma',
      {
        'idcUMA': idcUMA,
      },
      (json) => ObservacaoUMA.fromJson(json),
    );
    return result!;
  }

  Future<bool> atualizaInfoUMA(
    int idcUMA,
    double peso,
    double volume,
    String obs,
  ) async {
    final result = await post(
      '/api/estoque/atualizaDadosUma',
      {
        'idcUMA': idcUMA,
        'peso': peso,
        'volume': volume,
        'observacao': obs,
      },
    );
    return result!;
  }
}

//--------------------------------------------------------------------------------------------
// Impressoras
//--------------------------------------------------------------------------------------------
// ATENÇÃO: as posições abaixo SÃO IMPORTANTES, pois o 'index' é usado!!!
enum TipoEtiqueta { umaBasica, volumePrevisto, volumeReal }

const ETIQUETA_UMA_BASICA = 143;
const ETIQUETA_UMAE_BASICA = 154;
const ETIQUETA_VOLUME = 164;
const ETIQUETA_PRODUTO = 145;

@JsonResult()
class InfoImpressora {
  InfoImpressora(
    this.impressoraPadrao,
    this.impressoraCMP,
    this.impressoraLocal,
    this.status,
    this.idc,
    this.site,
    this.tipo,
    this.caminho,
    this.nomeComercial,
    this.nomeServidor,
    this.nome,
    this.porta,
  );

  final bool impressoraPadrao;
  final bool impressoraCMP;
  final bool impressoraLocal;
  final int status;
  final int idc;
  final int site;
  final int tipo;
  final String caminho;
  final String nomeComercial;
  final String nomeServidor;
  final String nome;
  final String porta;

  // nome que identifica unicamente cada impressora...
  String get nomeID => '$idc - $nome';

  factory InfoImpressora.fromJson(Map<String, dynamic> json) => _$InfoImpressoraFromJson(json);
}

@JsonResult()
class GeralInfoLote {
  GeralInfoLote(
    this.idcLote,
    this.numOrdem,
    this.numOrdemExterna,
    this.codigoPessoa,
    this.nomePessoa,
    this.codigoTransportadora,
    this.nomeTransportadora,
    this.observacao,
    this.cidade,
    this.estado,
    this.numAgrupamento,
    this.endereco,
    this.qtdUMA,
    this.placaVeiculo,
    this.motorista,
    this.qtdUMATot,
  );

  int idcLote;
  String numOrdem;
  String numOrdemExterna;
  String codigoPessoa;
  String nomePessoa;
  String codigoTransportadora;
  String nomeTransportadora;
  String observacao;
  String cidade;
  String estado;
  String numAgrupamento;
  String endereco;
  int qtdUMA;
  String placaVeiculo;
  String motorista;
  int qtdUMATot;

  String get qtd => '$qtdUMA - $qtdUMATot';

  factory GeralInfoLote.fromJson(Map<String, dynamic> json) => _$GeralInfoLoteFromJson(json);
}

@JsonResult()
class ObservacaoUMA {
  ObservacaoUMA({
    required this.idcUma,
    required this.peso,
    required this.volume,
    required this.observacao,
  });

  int idcUma;
  double peso;
  double volume;
  String observacao;

  factory ObservacaoUMA.fromJson(Map<String, dynamic> json) => _$ObservacaoUMAFromJson(json);
}
