import 'dart:convert';

import '../saga_lib/sa_json.dart';
import '../saga_lib/sa_api.dart';

import '../main/app.dart';
import '../geral/geral_api.dart';

part 'embalagem_api.g.dart';

//---------------------------------------------------------------------------------------------
// EmbalagemAPI
//---------------------------------------------------------------------------------------------
class EmbalagemAPI extends SAApi {
  EmbalagemAPI(this.operador)
      : idcUsuario = operador.idcUsuario,
        idcSite = operador.idcSite,
        geralAPI = GeralAPI(operador);

  final Operador operador;
  final int idcUsuario;
  final int idcSite;

  final GeralAPI geralAPI;

  /// obtém a lista de endereços para fazer embalagens...
  Future<List<InfoEndereco>> getEnderecos() async {
    final list = await getList<InfoEndereco>(
      '/api/embalagem/listaEnderecos',
      {
        'idcSite': idcSite,
        'idcUsuario': idcUsuario,
      },
      (json) => InfoEndereco.fromJson(json),
    );
    return list;
  }

  /// obtém a lista de ordens de um endereço de embalagem...
  Future<List<InfoOrdem>> getOrdens(int idcEndereco) async {
    final list = await getList<InfoOrdem>(
      '/api/embalagem/listaOrdens',
      {
        'idcSite': idcSite,
        'idcUsuario': idcUsuario,
        'idcEndereco': idcEndereco,
      },
      (json) => InfoOrdem.fromJson(json),
    );
    return list;
  }

  /// obtém a lista de mercadorias de uma ordem...
  Future<List<InfoMercadoria>> getMercadorias(int idcOrdem) async {
    final list = await getList<InfoMercadoria>(
      '/api/embalagem/listaMercadorias',
      {'idcOrdem': idcOrdem},
      (json) => InfoMercadoria.fromJson(json),
    );
    return list;
  }

  /// obtém a lista de mercadorias de uma ordem associadas a uma UMAOrigem
  Future<List<InfoMercadoria>> getMercadoriasUMAOrigem(int idcOrdem, String codUma) async {
    final list = await getList<InfoMercadoria>(
      '/api/embalagem/listaMercadorias',
      {'idcOrdem': idcOrdem, 'codUma': codUma},
      (json) => InfoMercadoria.fromJson(json),
    );
    return list;
  }

  Future<bool> verificaRGMercadoria(int idcMercadoria, String codigoBarras) async {
    final result = await get<bool>(
      '/api/embalagem/VerificaRGMercadoria',
      {
        'idcMercadoria': idcMercadoria,
        'codigoBarras': codigoBarras,
      },
      null,
    );
    return result!;
  }

  Future<List<InfoDispositivo>> getDispositivos() async {
    final list = await getList<InfoDispositivo>(
      '/api/dispositivo/listaExpedicao',
      {},
      (json) => InfoDispositivo.fromJson(json),
    );
    return list;
  }

  Future<InfoUMA?> getUMA(int idcOrdem, String codigoUMA) async {
    final result = await get<InfoUMA>(
      '/api/embalagem/ListaDadosUMADestino',
      {
        'idcSite': idcSite,
        'idcOrdem': idcOrdem,
        'idcUsuario': idcUsuario,
        'codigoUMA': codigoUMA,
      },
      (json) => InfoUMA.fromJson(json),
    );
    return result;
  }

  Future<List<UmaOrigem?>> getDadosUmaOrigem(
    int idcLoteExpedicao,
    int idcEndereco,
    int idcOrdem,
  ) async {
    final result = await getList(
      '/api/embalagem/ListaDadosUMAOrigem',
      {
        'idcLoteExpedicao': idcLoteExpedicao,
        'idcEndereco': idcEndereco,
        'idcOrdem': idcOrdem,
      },
      (json) => UmaOrigem.fromJson(json),
    );
    return result;
  }

  Future<String> geraCodigoUMA(String codigo) async {
    final result = await post(
      '/api/Estoque/GeraCodigoUMA',
      {
        'idcSite': idcSite,
        'codigo': codigo,
      },
    );
    return result;
  }

  Future<int> confirma(
    int idcEndereco,
    int idcOrdem,
    String codigoUMADestino,
    int idcDispositivo,
    int idcMercadoria,
    double quantidadeUnidade,
  ) async {
    final result = await post(
      '/api/embalagem/confirma',
      {
        'idcSite': idcSite,
        'idcUsuario': idcUsuario,
        'idcEndereco': idcEndereco,
        'idcOrdem': idcOrdem,
        'codigoUMADestino': codigoUMADestino,
        'idcDispositivo': idcDispositivo,
        'idcUMAOrigem': null,
        'idcMercadoria': idcMercadoria,
        'quantidadeUnidade': quantidadeUnidade,
      },
    );
    return result;
  }

  Future<int> confirmaEstoqueUnico(
    int idcEndereco,
    int idcOrdem,
    String codigoUMADestino,
    int idcDispositivo,
    int idcUmaOrigem,
    List<InfoMercadoria> mercadorias,
  ) async {
    final result = await post(
      '/api/embalagem/confirmaEstoqueUnico',
      {
        'idcSite': idcSite,
        'idcUsuario': idcUsuario,
        'idcEndereco': idcEndereco,
        'idcOrdem': idcOrdem,
        'codigoUMADestino': codigoUMADestino,
        'idcDispositivo': idcDispositivo,
        'idcUMAOrigem': idcUmaOrigem,
        'mercadorias': mercadorias.map((e) => e.toJson()).toList(),
      },
    );
    return result;
  }

  Future<void> iniciaOrdem(int idcOrdem) async {
    await post(
      '/api/embalagem/iniciaOrdem',
      {
        'idcSite': idcSite,
        'idcOrdem': idcOrdem,
        'idcUsuario': idcUsuario,
      },
    );
  }

  Future<void> finalizaOrdem(int idcOrdem) async {
    await post(
      '/api/embalagem/finaliza',
      {
        'idcSite': idcSite,
        'idcOrdem': idcOrdem,
        'idcUsuario': idcUsuario,
      },
    );
  }

  bool isEnderecoIgual(String e1, String e2) {
    return e1.replaceAll('.', '') == e2.replaceAll('.', '');
  }

  Future<bool> existsEndereco(String endereco) async {
    final list = await getEnderecos();
    final result = list.any((it) => isEnderecoIgual(it.mascaraEndereco, endereco));
    return result;
  }

  Future<InfoEndereco> findEndereco(String endereco) async {
    final list = await getEnderecos();
    final result = list.singleWhere(
      (it) => isEnderecoIgual(it.mascaraEndereco, endereco),
      orElse: () => throw Exception('Endereço inválido'),
    );
    return result;
  }

  Future<InfoOrdem> findOrdem(int idcEndereco, String numero) async {
    final list = await getOrdens(idcEndereco);
    final result = list.singleWhere(
      (it) => it.numeroOrdem == numero,
      orElse: () => throw Exception('Ordem inválida'),
    );
    return result;
  }

  Future<InfoDispositivo> findDispositivo({String? codigo, int? idc}) async {
    final list = await getDispositivos();
    final result = list.singleWhere(
      (it) => codigo != null ? it.codigo == codigo : it.idc == idc,
      orElse: () => throw Exception('Dispositivo inválido'),
    );
    return result;
  }

  Future<void> checkMercadoria(InfoMercadoria infoMercadoria, String codigoBarras) async {
    // se código de barras faz parte da lista de códigos de barras, ok...
    if (infoMercadoria.listaCodigoBarras.contains(codigoBarras)) return;

    // chama API para validar o código de barras...
    final ok = await verificaRGMercadoria(infoMercadoria.idcMercadoria, codigoBarras);
    if (!ok) {
      throw Exception('Mercadoria inválida');
    }
  }

  //-----------------------------------------------------------------------------------------
  // Impressão de Etiquetas
  //-----------------------------------------------------------------------------------------
  Future<void> imprimirEtiquetaUMA(int idcImpressora, List<int> listIdcUMAs) async =>
      await geralAPI.imprimirEtiquetaVolumeReal(idcImpressora, listIdcUMAs);

  Future<List<InfoImpressora>> getImpressoras() async => await geralAPI.getImpressoras();

  Future<InfoImpressora> findImpressora(String nome) async {
    final list = await getImpressoras();
    final result = list.where((it) => it.nomeID.startsWith(nome));

    if (result.isEmpty) {
      throw Exception('Impressora inválida');
    }

    if (result.length > 1) {
      throw Exception('Há várias impressoras com esse prefixo');
    }

    return result.first;
  }

  //------------------------------------------------------------------------------------------
  // save/load
  //------------------------------------------------------------------------------------------
  Future<Work?> loadWork() async {
    final str = await loadInfoExecucao();
    if (str.isEmpty) return null;

    final json = jsonDecode(str);
    final work = Work.fromJson(json);
    return work;
  }

  Future<void> saveWork(InfoEndereco infoEndereco, InfoOrdem infoOrdem) async {
    final work = Work(infoEndereco.mascaraEndereco, infoOrdem.numeroOrdem);
    final json = work.toJson();

    final str = jsonEncode(json);
    await saveInfoExecucao(str);
  }

  Future<void> clearWork() async {
    await clearInfoExecucao();
  }

  static const idcAtividade = 30;
  static const idcModoOperacao = 1;

  Future<String> loadInfoExecucao() async {
    final result = await getString('/api/servico/ListaInfoExecucao', {
      'idcSite': idcSite,
      'idcAtividade': idcAtividade,
      'idcModoOperacao': idcModoOperacao,
      'idcUsuario': idcUsuario,
    });
    return result;
  }

  Future<void> saveInfoExecucao(String infoJson) async {
    await post('/api/servico/SalvaInfoExecucao', {
      'idcSite': idcSite,
      'idcAtividade': idcAtividade,
      'idcModoOperacao': idcModoOperacao,
      'idcUsuario': idcUsuario,
      'json': infoJson,
    });
  }

  Future<void> clearInfoExecucao() async {
    await post('/api/servico/RemoveInfoExecucao', {
      'idcSite': idcSite,
      'idcAtividade': idcAtividade,
      'idcModoOperacao': idcModoOperacao,
      'idcUsuario': idcUsuario,
    });
  }
}

//---------------------------------------------------------------------------------------------
// InfoEndereco
//---------------------------------------------------------------------------------------------
@JsonResult()
class InfoEndereco {
  InfoEndereco(this.idcSite, this.idcEndereco, this.mascaraEndereco, this.quantidadeOrdens,
      this.quantidadeItens);

  final int idcSite;
  final int idcEndereco;
  final String mascaraEndereco;
  final int quantidadeOrdens;
  final int quantidadeItens;

  String get nomeID => mascaraEndereco;

  @override
  String toString() =>
      '{idcSite: $idcSite, idcEndereco: $idcEndereco, mascaraEndereco: $mascaraEndereco, quantidadeOrdens: $quantidadeOrdens, quantidadeItens: $quantidadeItens}';

  factory InfoEndereco.fromJson(Map<String, dynamic> json) => _$InfoEnderecoFromJson(json);
}

//---------------------------------------------------------------------------------------------
// InfoOrdem
//---------------------------------------------------------------------------------------------
@JsonResult()
class InfoOrdem {
  InfoOrdem(
    this.idcSite,
    this.idcEndereco,
    this.idcOrdem,
    this.numeroOrdem,
    this.quantidadeMercadorias,
    this.codigoCliente,
    this.nomeCliente,
    this.quantidadeEstoqueEmbalar,
    this.pesoEstoqueEmbalar,
    this.idcLote,
    this.observacao,
    this.numOrdensLotes,
  );

  final int idcSite;
  final int idcEndereco;
  final int idcOrdem;
  final String numeroOrdem;
  final int quantidadeMercadorias;
  final String codigoCliente;
  final String nomeCliente;
  final double quantidadeEstoqueEmbalar;
  final double pesoEstoqueEmbalar;
  final int idcLote;
  final String? observacao;
  final int numOrdensLotes;

  String get nomeID => numeroOrdem;
  String get clienteID => '$codigoCliente - $nomeCliente';

  @override
  String toString() =>
      '{idcSite: $idcSite, idcEndereco: $idcEndereco, idcOrdem: $idcOrdem, numeroOrdem: $numeroOrdem, quantidadeMercadorias: $quantidadeMercadorias, codigoCliente: $codigoCliente, nomeCliente: $nomeCliente, quantidadeEstoqueEmbalar: $quantidadeEstoqueEmbalar, pesoEstoqueEmbalar: $pesoEstoqueEmbalar, idcLote: $idcLote, obsPedido: $observacao, numOrdensLotes: $numOrdensLotes}';

  factory InfoOrdem.fromJson(Map<String, dynamic> json) => _$InfoOrdemFromJson(json);
}

//---------------------------------------------------------------------------------------------
// InfoMercadoria
//---------------------------------------------------------------------------------------------
@JsonSerializable()
class InfoMercadoria {
  InfoMercadoria(
    this.idcOrdem,
    this.idcMercadoria,
    this.codigoMercadoria,
    this.descricaoMercadoria,
    this.listaCodigoBarras,
    this.quantidadeUnidade,
    this.quantidadeTotal,
    this.strQuantidade,
    this.listaUMAs,
  );

  final int idcOrdem;
  final int idcMercadoria;
  final String codigoMercadoria;
  final String descricaoMercadoria;
  final double quantidadeUnidade;
  final double quantidadeTotal;
  final String strQuantidade;

  @JsonKey(name: 'Barras')
  final List<String> listaCodigoBarras;

  @JsonKey(name: 'UMAs')
  final List<InfoUMA> listaUMAs;

  String get nomeID => '$codigoMercadoria - $descricaoMercadoria';

  String get descTotal => '$qtdeTotalEmbalar ($descQuantidade)';
  String get descQuantidade =>
      strQuantidade.replaceAll('(', '').replaceAll(')', '').replaceAll(' e ', ' ');
  String get progresso => '$qtdeJaEmbalada/$qtdeTotalEmbalar';

  bool get isMensuravel => false;
  num get qtdeJaEmbalada => qtdeTotalEmbalar - qtdeFaltaEmbalar;
  num get qtdeFaltaEmbalar => isMensuravel ? quantidadeUnidade : quantidadeUnidade.toInt();
  num get qtdeTotalEmbalar => isMensuravel ? quantidadeTotal : quantidadeTotal.toInt();

  String get umas {
    final sb = StringBuffer();
    for (final uma in listaUMAs) {
      sb.writeln(uma.codigo);
      if (uma.observacao != null) sb.writeln(uma.observacao);
    }
    return sb.toString();
  }

  @override
  String toString() =>
      '{idcOrdem: $idcOrdem, idcMercadoria: $idcMercadoria, codigoMercadoria: $codigoMercadoria, descricaoMercadoria: $descricaoMercadoria, quantidadeUnidade: $quantidadeUnidade strQuantidade: $strQuantidade listaUMAs: $listaUMAs}';

  factory InfoMercadoria.fromJson(Map<String, dynamic> json) => _$InfoMercadoriaFromJson(json);

  Map<String, dynamic> toJson() => _$InfoMercadoriaToJson(this);
}

//---------------------------------------------------------------------------------------------
// InfoUMA
//---------------------------------------------------------------------------------------------
@JsonSerializable()
class InfoUMA {
  InfoUMA(this.idc, this.codigo, this.idcDispositivo, this.observacao);

  final int idc;
  final String codigo;
  final int? idcDispositivo; // na lista de UMAs da mercadoria não vem o dispositivo...
  final String? observacao;

  String get nomeID => codigo;

  @override
  String toString() => '{idc: $idc, codigo: $codigo, idcDispositivo: $idcDispositivo}';

  factory InfoUMA.fromJson(Map<String, dynamic> json) => _$InfoUMAFromJson(json);

  Map<String, dynamic> toJson() => _$InfoUMAToJson(this);
}

//---------------------------------------------------------------------------------------------
// InfoDispositivo
//---------------------------------------------------------------------------------------------
@JsonResult()
class InfoDispositivo {
  InfoDispositivo(this.idc, this.codigo, this.nome);

  final int idc;
  final String codigo;
  final String nome;

  String get nomeID => codigo;

  @override
  String toString() => '{idc: $idc, codigo: $codigo, nome: $nome}';

  factory InfoDispositivo.fromJson(Map<String, dynamic> json) =>
      _$InfoDispositivoFromJson(json);
}

//---------------------------------------------------------------------------------------------
// Work
//---------------------------------------------------------------------------------------------
@JsonSerializable()
class Work {
  Work(this.endereco, this.ordem);

  final String endereco;
  final String ordem;

  @override
  String toString() => '{endereco: $endereco, ordem: $ordem}';

  factory Work.fromJson(Map<String, dynamic> json) => _$WorkFromJson(json);
  Map<String, dynamic> toJson() => _$WorkToJson(this);
}

@JsonResult()
class UmaOrigem {
  UmaOrigem({
    required this.idc,
    required this.codigo,
    required this.quantidadeMercadoria,
    required this.nomeAtividade,
    required this.observacaoUMA,
  });

  final int idc;
  final String codigo;
  final int quantidadeMercadoria;
  final String nomeAtividade;
  final String? observacaoUMA;

  factory UmaOrigem.fromJson(Map<String, dynamic> json) => _$UmaOrigemFromJson(json);
}
