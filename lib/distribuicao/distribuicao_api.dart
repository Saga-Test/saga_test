import '../saga_lib/sa_api.dart';
import '../saga_lib/sa_json.dart';

import '../main/app.dart';
import '../saga_lib/sa_extensions.dart';

part 'distribuicao_api.g.dart';

class DistribuicaoAPI extends SAApi {
  DistribuicaoAPI(this.operador);

  final Operador operador;

  Future<InfoUMA> confirmaUMAOrigem(String codigoUMA) async {
    final result = await post(
      '/api/distribuicao/confirmaUMAOrigem',
      {
        'idcSite': operador.idcSite,
        'idcUsuario': operador.idcUsuario,
        'codigoUMA': codigoUMA,
      },
      fromJson: (json) => InfoUMA.fromJson(json),
    );
    return result!;
  }

  Future<void> liberaUMA(int idcUMA) async {
    await post('/api/uma/liberaEmTransferencia', {
      'idcSite': operador.idcSite,
      'idcUsuario': operador.idcUsuario,
      'idcUMA': idcUMA,
    });
  }

  Future<InfoUMA?> confirmaUMADestino(String codigoUMA, List<InfoEstoque> estoques) async {
    final result = await post(
      '/api/distribuicao/confirmaUMADestino',
      {
        'idcSite': operador.idcSite,
        'idcUsuario': operador.idcUsuario,
        'codigoUMA': codigoUMA,
        'estoques': estoques.map((e) => e.toJson()).toList(),
      },
      fromJson: (json) => InfoUMA.fromJson(json),
    );
    return result;
  }

  Future<ConfirmaDestinoDTO> confirmaEnderecoDestino(
    String endereco,
    List<InfoEstoque> estoques,
    int? idcUMA,
    int? idcDispositivoUMA,
    int? idcMotivoBloqueio,
  ) async {
    final result = await post(
      '/api/distribuicao/confirmaEnderecoDestino',
      {
        'idcSite': operador.idcSite,
        'mascaraEndereco': endereco,
        'idcUMADestino': idcUMA,
        'idcDispositivoUMADestino': idcDispositivoUMA,
        'idcMotivoBloqueio': idcMotivoBloqueio,
        'estoques': estoques.map((it) => it.toJson()).toList(),
      },
      fromJson: (json) => ConfirmaDestinoDTO.fromJson(json),
    );
    return result!;
  }

  Future<void> executaDistribuicao(
    String codigoUMAOrigem,
    String codigoUMADestino,
    List<InfoEstoque> estoques,
    int? idcDispositivo,
    int? idcMotivoBloqueio,
    bool mantemBloqueioOrigem,
    int? idcEnderecoDestino,
  ) async {
    await post('/api/distribuicao/executa', {
      'idcSite': operador.idcSite,
      'idcUsuario': operador.idcUsuario,
      'codigoUMAOrigem': codigoUMAOrigem,
      'codigoUMADestino': codigoUMADestino,
      'estoques': estoques.map((it) => it.toJson()).toList(),
      'idcDispositivo': idcDispositivo,
      'idcMotivoBloqueio': idcMotivoBloqueio,
      'mantemBloqueioOrigem': mantemBloqueioOrigem,
      'idcEnderecoDestino': idcEnderecoDestino,
    });
  }

  Future<String> geraCodigoUMA(String prefix) async {
    final result = await post('/api/uma/geraCodigo', {
      'idcSite': operador.idcSite,
      'codigo': prefix,
    });
    return result;
  }

  //------------------------------------------------------------------------------------------
  // Autorização de Bloqueios
  //------------------------------------------------------------------------------------------
  Future<void> confirmaBloqueioUMADestino(int idcMotivo, int idcUMADestino) async {
    await post('/api/Distribuicao/confirmaBloqueioUMADestino', {
      'idcSite': operador.idcSite,
      'idcMotivoBloqueio': idcMotivo,
      'idcUMADestino': idcUMADestino,
    });
  }

  Future<bool> operadorPodeBloquear(int idcMotivo) async {
    final result = await get(
      '/api/motivo/validaPermissao',
      {'idcUsuario': operador.idcUsuario, 'idcMotivo': idcMotivo},
      null,
    );
    return result;
  }

  Future<bool> usuarioPodeBloquear(String usuario, String senha, int idcMotivo) async {
    final result = await get(
      '/api/motivo/validaPermissao',
      {'codigoUsuario': usuario, 'senha': senha, 'idcMotivo': idcMotivo},
      null,
    );
    return result;
  }

  Future<List<InfoMotivoBloqueio>> getMotivoBloqueios({int? idcUsuario}) async {
    // se idcUsuario == null, retorna TODOS os motivos deste tipo...
    final list = await getList(
      '/api/motivo/lista',
      {
        'idcTipoMotivo': TipoMotivoBloqueio.bloqueioUMA.index,
        'idcUsuario': idcUsuario,
      },
      (json) => InfoMotivoBloqueio.fromJson(json),
    );
    return list;
  }

  Future<List<InfoDispositivo>> getDispositivos() async {
    final list = await getList(
      '/api/dispositivo/lista',
      {'finalidades': '1,3'},
      (json) => InfoDispositivo.fromJson(json),
    );
    return list;
  }

  Future<InfoDispositivo> findDispositivo({String? codigo, int? idc}) async {
    final list = await getDispositivos();
    final result = list.singleWhere(
      (it) => codigo != null ? it.codigo == codigo : it.idc == idc,
      orElse: () => throw Exception('Dispositivo inválido'),
    );
    return result;
  }

  Future<List<InfoEndereco>> getEnderecosDaMercadoria(InfoEstoque estoque) async {
    final list = await getList(
      '/api/endereco/listarEnderecosDaMercadoria',
      {
        'idcSite': estoque.idcSite,
        'idcProprietario': estoque.idcProprietario,
        'idcUMA': estoque.idcUMA,
        'idcMercadoria': estoque.embalagem.mercadoria.idc,
      },
      (json) => InfoEndereco.fromJson(json),
    );
    return list;
  }

  Future<List<UMAEstoque>> getUMAsDoEndereco(String endereco, {String? codigoUma}) async {
    final list = await getList(
      '/api/Estoque/ListaUMAsManutencao',
      {
        'idcSite': operador.idcSite,
        'mascaraEndereco': endereco,
        'codigoUMA': codigoUma ?? '',
      },
      (json) => UMAEstoque.fromJson(json),
    );
    return list;
  }
}

@JsonResult()
class ConfirmaDestinoDTO {
  ConfirmaDestinoDTO(this.mensagem, this.endereco);

  final String? mensagem;
  final EnderecoDTO endereco;

  factory ConfirmaDestinoDTO.fromJson(Map<String, dynamic> json) =>
      _$ConfirmaDestinoDTOFromJson(json);
}

@JsonResult()
class EnderecoDTO {
  EnderecoDTO(this.idc, this.mascara);

  final int idc;
  final String mascara;

  factory EnderecoDTO.fromJson(Map<String, dynamic> json) => _$EnderecoDTOFromJson(json);
}

//--------------------------------------------------------------------------------------------
// Motivo de Bloqueio
//--------------------------------------------------------------------------------------------
@JsonResult()
class InfoMotivoBloqueio {
  InfoMotivoBloqueio(this.idc, this.descricao);

  final int idc;
  final String descricao;

  factory InfoMotivoBloqueio.fromJson(Map<String, dynamic> json) =>
      _$InfoMotivoBloqueioFromJson(json);

  @override
  String toString() => 'idc: $idc, descricao: $descricao';
}

enum TipoMotivoBloqueio {
  naoUsado_0,
  devolucao,
  bloqueio,
  ocorrencia,
  logoff,
  bloqueioPessoa,
  naoUsado_6,
  bloqueioUMA,
  manutencaoEstoque,
  avariaMercadoria,
  bloqueioProcesso,
  movLocPortaria,
}

//--------------------------------------------------------------------------------------------
// Dispositivo
//--------------------------------------------------------------------------------------------
@JsonResult()
class InfoDispositivo {
  InfoDispositivo(this.idc, this.codigo, this.nome);

  final int idc;
  final String codigo;
  final String nome;

  String get nomeID => '$codigo - $nome';

  factory InfoDispositivo.fromJson(Map<String, dynamic> json) =>
      _$InfoDispositivoFromJson(json);

  @override
  String toString() => '{idc: $idc, codigo: $codigo, nome: $nome}';
}

enum FinalidadeDispositivo {
  naoUsado_0,
  armazenamento,
  expedicao,
  armazenamento_e_expedicao,
  ressuprimento,
}

//--------------------------------------------------------------------------------------------
// UMA
//--------------------------------------------------------------------------------------------
@JsonResult()
class InfoUMA {
  InfoUMA(
    this.idc,
    this.codigo,
    this.idcSite,
    this.idcDispositivo,
    this.idcSituacao,
    this.idcLoteCriacao,
    this.endereco,
    this.situacao,
    this.dispositivo,
    this.estoques,
    this.bloqueios,
  );

  final int idc;
  final String codigo;
  final int idcSite;
  final int idcDispositivo;
  final int idcSituacao;
  final int? idcLoteCriacao;
  final String endereco;
  final UMA$Situacao situacao;
  final InfoDispositivo dispositivo;
  final List<InfoEstoque> estoques;
  final List<InfoMotivoBloqueio> bloqueios;

  List<InfoEstoque> get estoquesOrdenadosPorApanha =>
      estoques.orderBy((item) => item.embalagem.mercadoria.apanhasOrdenados);

  factory InfoUMA.fromJson(Map<String, dynamic> json) => _$InfoUMAFromJson(json);

  @override
  String toString() =>
      'idc: $idc, codigo: $codigo, idcSite: $idcSite, idcDispositivo: $idcDispositivo, idcSituacao: $idcSituacao, idcLoteCriacao: $idcLoteCriacao, situacao: $situacao, dispositivo: $dispositivo, estoques: $estoques, bloqueios: $bloqueios';
}

@JsonResult()
class UMA$Situacao {
  UMA$Situacao(this.idc, this.nome);

  final int idc;
  final String nome;

  factory UMA$Situacao.fromJson(Map<String, dynamic> json) => _$UMA$SituacaoFromJson(json);

  @override
  String toString() => 'idc: $idc, nome: $nome';
}

//--------------------------------------------------------------------------------------------
// Estoque
//--------------------------------------------------------------------------------------------
@JsonSerializable()
class InfoEstoque {
  InfoEstoque(
    this.idc,
    this.idcSite,
    this.idcProprietario,
    this.idcUMA,
    this.idcGrupoCaracteristica,
    this.dataFabricacao,
    this.dataValidade,
    this.dataRecebimento,
    this.idcEmbalagem,
    this.quantidade,
    this.proprietario,
    this.embalagem,
    this.ordemEntrada,
    this.caracteristicas,
  );

  final int idc;
  final int idcSite;
  final int idcProprietario;
  final int idcUMA;
  final int? idcGrupoCaracteristica;
  final DateTime dataFabricacao;
  final DateTime dataValidade;
  final DateTime dataRecebimento;
  final int idcEmbalagem;
  final double quantidade;
  final Estoque$Pessoa proprietario;
  final Estoque$SKU$Mercadoria embalagem;
  final Estoque$OrdemEntrada? ordemEntrada;
  final List<Estoque$Caracteristica> caracteristicas;

  factory InfoEstoque.fromJson(Map<String, dynamic> json) => _$InfoEstoqueFromJson(json);
  Map<String, dynamic> toJson() => _$InfoEstoqueToJson(this);

  InfoEstoque copyWith({double? quantidade}) {
    return InfoEstoque(
      this.idc,
      this.idcSite,
      this.idcProprietario,
      this.idcUMA,
      this.idcGrupoCaracteristica,
      this.dataFabricacao,
      this.dataValidade,
      this.dataRecebimento,
      this.idcEmbalagem,
      quantidade ?? this.quantidade,
      this.proprietario,
      this.embalagem,
      this.ordemEntrada,
      this.caracteristicas,
    );
  }

  @override
  String toString() =>
      'idc: $idc, idcSite: $idcSite, idcProprietario: $idcProprietario, idcUMA: $idcUMA, idcGrupoCaracteristica: $idcGrupoCaracteristica, $dataFabricacao, dataValidade: $dataValidade, dataRecebimento: $dataRecebimento, idcEmbalagem: $idcEmbalagem, quantidade: $quantidade, proprietario: $proprietario, embalagem: $embalagem, ordemEntrada: $ordemEntrada, caracteristicas: $caracteristicas';
}

@JsonSerializable()
class Estoque$Pessoa {
  Estoque$Pessoa(this.idc, this.codigo, this.nome);

  final int idc;
  final String codigo;
  final String nome;

  factory Estoque$Pessoa.fromJson(Map<String, dynamic> json) => _$Estoque$PessoaFromJson(json);
  Map<String, dynamic> toJson() => _$Estoque$PessoaToJson(this);

  @override
  String toString() => 'idc: $idc, codigo: $codigo, nome: $nome';
}

@JsonSerializable()
class Estoque$SKU {
  Estoque$SKU(this.idc, this.nome, this.valor, this.codigosDeBarras);

  final int idc;
  final String nome;
  final int valor;
  final List<String> codigosDeBarras;

  factory Estoque$SKU.fromJson(Map<String, dynamic> json) => _$Estoque$SKUFromJson(json);
  Map<String, dynamic> toJson() => _$Estoque$SKUToJson(this);
}

@JsonSerializable()
class Estoque$SKU$Mercadoria extends Estoque$SKU {
  Estoque$SKU$Mercadoria(
      super.idc, super.nome, super.valor, super.codigosDeBarras, this.mercadoria);

  final Estoque$Mercadoria mercadoria;

  factory Estoque$SKU$Mercadoria.fromJson(Map<String, dynamic> json) =>
      _$Estoque$SKU$MercadoriaFromJson(json);
  Map<String, dynamic> toJson() => _$Estoque$SKU$MercadoriaToJson(this);
}

@JsonSerializable()
class Estoque$Mercadoria {
  Estoque$Mercadoria(this.idc, this.codigo, this.nome, this.mensuravel, this.prazoValidade,
      this.embalagens, this.caracteristicas, this.enderecosApanha);

  final int idc;
  final String codigo;
  final String nome;
  final bool mensuravel;
  final int prazoValidade;
  final List<Estoque$SKU> embalagens;
  final List<Mercadoria$Caracteristica> caracteristicas;
  final List<String> enderecosApanha;

  String get apanhasOrdenados => enderecosApanha.orderBy((item) => item).join(', ');
  String get toShow => '$codigo - $nome';

  factory Estoque$Mercadoria.fromJson(Map<String, dynamic> json) =>
      _$Estoque$MercadoriaFromJson(json);
  Map<String, dynamic> toJson() => _$Estoque$MercadoriaToJson(this);

  @override
  String toString() =>
      'idc: $idc, codigo: $codigo, nome: $nome, mensuravel: $mensuravel, prazoValidade: $prazoValidade';
}

@JsonSerializable()
class Mercadoria$Caracteristica {
  Mercadoria$Caracteristica(this.idc, this.nome, this.obrigatoria);

  final int idc;
  final String nome;
  final bool obrigatoria;

  factory Mercadoria$Caracteristica.fromJson(Map<String, dynamic> json) =>
      _$Mercadoria$CaracteristicaFromJson(json);
  Map<String, dynamic> toJson() => _$Mercadoria$CaracteristicaToJson(this);
}

@JsonSerializable()
class Estoque$OrdemEntrada {
  Estoque$OrdemEntrada(this.idc, this.numeroOrdem, this.fornecedor);

  final int idc;
  final String numeroOrdem;
  final Estoque$Pessoa fornecedor;

  factory Estoque$OrdemEntrada.fromJson(Map<String, dynamic> json) =>
      _$Estoque$OrdemEntradaFromJson(json);
  Map<String, dynamic> toJson() => _$Estoque$OrdemEntradaToJson(this);

  @override
  String toString() => 'idc: $idc, numeroOrdem: $numeroOrdem, fornecedor: $fornecedor';
}

@JsonSerializable()
class Estoque$Caracteristica {
  Estoque$Caracteristica(this.idc, this.nome, this.valor);

  final int idc;
  final String nome;
  final String valor;

  String get toShow => '$nome: $valor';

  factory Estoque$Caracteristica.fromJson(Map<String, dynamic> json) =>
      _$Estoque$CaracteristicaFromJson(json);
  Map<String, dynamic> toJson() => _$Estoque$CaracteristicaToJson(this);

  @override
  String toString() => 'idc: $idc, nome: $nome, valor: $valor';
}

//--------------------------------------------------------------------------------------------
// Endereco
//--------------------------------------------------------------------------------------------
@JsonResult()
class InfoEndereco {
  InfoEndereco(this.idc, this.mascara, this.finalidade, this.maiorValidade);

  final int idc;
  final String mascara;
  final String finalidade;
  final DateTime? maiorValidade;

  String get nomeID => '$mascara';

  factory InfoEndereco.fromJson(Map<String, dynamic> json) => _$InfoEnderecoFromJson(json);

  @override
  String toString() => '{idc: $idc, mascara: $mascara}';
}

//-------------------------------------------------------------------------------------------
// UMAEstoque
//-------------------------------------------------------------------------------------------
@JsonSerializable()
class UMAEstoque {
  UMAEstoque(
    this.idc,
    this.idcSite,
    this.codigo,
    this.posicao,
    this.quantidadeItens,
    this.infoMercadorias,
    this.motivoBloqueio,
    this.situacao,
    this.endereco,
    this.dispositivo,
    this.proprietario,
  );

  final int idc;
  final int idcSite;
  final String codigo;
  final int? posicao;
  final int quantidadeItens;
  final String infoMercadorias;
  int? motivoBloqueio;

  final UMAEstoque$Situacao? situacao;
  final UMAEstoque$Endereco endereco;
  final UMAEstoque$Dispositivo dispositivo;
  final UMAEstoque$Proprietario proprietario;

  factory UMAEstoque.fromJson(Map<String, dynamic> json) => _$UMAEstoqueFromJson(json);

  Map<String, dynamic> toJson() => _$UMAEstoqueToJson(this);
}

@JsonSerializable()
class UMAEstoque$Situacao {
  UMAEstoque$Situacao(this.idc, this.nome);

  final int idc;
  final String nome;

  factory UMAEstoque$Situacao.fromJson(Map<String, dynamic> json) =>
      _$UMAEstoque$SituacaoFromJson(json);

  Map<String, dynamic> toJson() => _$UMAEstoque$SituacaoToJson(this);
}

@JsonSerializable()
class UMAEstoque$Endereco {
  UMAEstoque$Endereco(this.idc, this.mascara);

  final int idc;
  final String mascara;

  factory UMAEstoque$Endereco.fromJson(Map<String, dynamic> json) =>
      _$UMAEstoque$EnderecoFromJson(json);

  Map<String, dynamic> toJson() => _$UMAEstoque$EnderecoToJson(this);
}

@JsonSerializable()
class UMAEstoque$Dispositivo {
  UMAEstoque$Dispositivo(this.idc, this.codigo, this.nome);

  final int idc;
  final String codigo;
  final String nome;

  factory UMAEstoque$Dispositivo.fromJson(Map<String, dynamic> json) =>
      _$UMAEstoque$DispositivoFromJson(json);

  Map<String, dynamic> toJson() => _$UMAEstoque$DispositivoToJson(this);
}

@JsonSerializable()
class UMAEstoque$Proprietario {
  UMAEstoque$Proprietario(this.idc, this.codigo, this.nome);

  final int idc;
  final String codigo;
  final String nome;

  factory UMAEstoque$Proprietario.fromJson(Map<String, dynamic> json) =>
      _$UMAEstoque$ProprietarioFromJson(json);

  Map<String, dynamic> toJson() => _$UMAEstoque$ProprietarioToJson(this);
}
