import '../saga_lib/sa_json.dart';

part 'convocacao.g.dart';

///
/// Tipos de Convocação
///

enum TipoConvocacao {
  naoUsado, 
  nova,
  existente,
  emExecucao
}

///
/// Classe de Convocação
///
@JsonResult()
class Convocacao {
  Convocacao(this.atividade, this.ordem, this.servicos);

  final Atividade atividade;
  final Ordem? ordem;
  final List<Servico> servicos;

  bool get isApanhaPorVoz => atividade.usaVoz;
  bool get isApanhaMultiplo => servicos.first.modoOperacao?.idc == 11;
  bool get isEmbalagem => atividade.idc == Atividade.ATIVIDADE_EMBALAGEM;
  bool get isApanhaPalete => atividade.idc == Atividade.ATIVIDADE_APANHA_PALETE;

  factory Convocacao.fromJson(Map<String, dynamic> json) =>
      _$ConvocacaoFromJson(json);
}

class Ocorrencia {
  // situacao da Ocorrencia...
  static const SITUACAO_OCO_NONE = 0;
  static const SITUACAO_OCO_REGISTRADA = 1;
  static const SITUACAO_OCO_REAVISO = 2;
  static const SITUACAO_OCO_RECONHECIDA = 3;
  static const SITUACAO_OCO_SOLUCIONADA = 4;
  static const SITUACAO_OCO_FINALIZADA_INCOMPLETA = 5;
}

@JsonResult()
class Atividade {
  Atividade(this.idc, this.nome, this.usaVoz);

  int idc; // vem no aviso...
  final String nome; // vem no aviso...
  final bool usaVoz; // vem no aviso...

  factory Atividade.fromJson(Map<String, dynamic> json) =>
      _$AtividadeFromJson(json);

  // tipo de Atividade...
  static const ATIVIDADE_RECEBIMENTO = 1;
  static const ATIVIDADE_MOVIMENTACAO = 2;
  static const ATIVIDADE_RESSUPRIMENTO = 3;
  static const ATIVIDADE_APANHA_SEPARACAO = 4;
  static const ATIVIDADE_CONFERENCIA_SEPARACAO = 5;
  static const ATIVIDADE_CONFERENCIA_CARREGAMENTO = 6;
  static const ATIVIDADE_INVENTARIO = 7;
  static const ATIVIDADE_APANHA_PALETE = 8;
  static const ATIVIDADE_MONTAR_KIT = 9;
  static const ATIVIDADE_RECEBIMENTO_PRODUCAO = 10;
  static const ATIVIDADE_DISTRIBUICAO = 11;
  static const ATIVIDADE_RECEBE_PRODUCAO = 12;
  static const ATIVIDADE_APANHA_DISPOSITIVO = 13;
  static const ATIVIDADE_FUSAO_TOTAL = 14;
  static const ATIVIDADE_FUSAO_PARCIAL = 15;
  static const ATIVIDADE_CONFERENCIA_LIBERACAO_UMA = 16;
  static const ATIVIDADE_SEPARACAO = 17;
  static const ATIVIDADE_DESOVA = 18;
  static const ATIVIDADE_ESTUFAGEM = 19;
  static const ATIVIDADE_APANHA = 20;
  static const ATIVIDADE_MOVIMENTACAO_APANHA = 21;
  static const ATIVIDADE_AUDITORIA = 22;
  static const ATIVIDADE_RECEBE_DOCUMENTO = 23;
  static const ATIVIDADE_REMONTE_VOLUME = 24;
  static const ATIVIDADE_AUDITORIA_PEDIDO = 25;
  static const ATIVIDADE_CONFERENCIA_DELIVERY_OUT = 27;
  static const ATIVIDADE_TROCA_DISPOSITVO = 28;
  static const ATIVIDADE_GOOD_ISSUES = 29;
  static const ATIVIDADE_EMBALAGEM = 30;
  static const ATIVIDADE_ASSOCIACAO_RGU = 31;

  // situação da Atividade...
  static const SITUACAO_ATIVIDADE_PREPARADA = 1;
  static const SITUACAO_ATIVIDADE_PROGRAMADA = 2;
  static const SITUACAO_ATIVIDADE_LIBERADA = 3;
  static const SITUACAO_ATIVIDADE_ESPERA = 4;
  static const SITUACAO_ATIVIDADE_EM_EXECUCAO = 5;
  static const SITUACAO_ATIVIDADE_FINALIZADA = 6;
  static const SITUACAO_ATIVIDADE_OCORRENCIA = 7;
  static const SITUACAO_ATIVIDADE_AUTOMATICA = 8;
  static const SITUACAO_ATIVIDADE_CANCELADO = 9;
}

@JsonResult()
class Ordem {
  Ordem(this.idc);

  final int idc;

  factory Ordem.fromJson(Map<String, dynamic> json) => _$OrdemFromJson(json);

  // tipo de Ordem..
  static const ORDEM_RECEBIMENTO = 1;
  static const ORDEM_PRODUCAO = 2;
  static const ORDEM_BALANCO = 3;
  static const ORDEM_TRANSFERENCIA = 4;
  static const ORDEM_EXPEDICAO = 5;
  static const ORDEM_MONTAGEM_KIT = 6;
  static const ORDEM_FUSAO_PALETE = 7;
  static const ORDEM_ADICIONAR_ESTOQUE = 8;
  static const ORDEM_REDUZIR_ESTOQUE = 9;
  static const ORDEM_CORRECAO_EXCESSO_PEDIDO = 10;
  static const ORDEM_CORRECAO_FILTRO_PEDIDO = 11;
  static const ORDEM_FILTRO_DOCUMENTO = 12;
  static const ORDEM_REECBIMENTO_CROSS_DOCKING = 13;
  static const ORDEM_DEVOLUCAO = 14;
  static const ORDEM_INVENTARIO_MANUAL_ESTOQUE = 15;
  static const ORDEM_EXPEDICAO_SIMPLIFICADA = 16;
  static const ORDEM_EXPEDICAO_CONSOLIDADA = 17;
  static const ORDEM_EXPEDICAO_DELIVERY = 18;
}

@JsonResult()
class Servico {
  Servico(
    this.idc,
    this.sequenciaServico,
    this.sequenciaAtividade,
    this.numeroItem,
    this.quantidade,
    this.eAjudante,
    this.lote,
    this.proprietario,
    this.modoOperacao,
    this.origem,
    this.destino,
    this.umaOrigem,
    this.umaDestino,
    this.sku,
    this.site,
    this.veiculo,
    this.grupoCaracteristica,
    this.srtQuantidade,
    this.temMaisMovimentacao,
  );

  final int idc;
  final int sequenciaServico;
  final int sequenciaAtividade;
  final int numeroItem;
  final double? quantidade;
  final String? srtQuantidade;
  final bool eAjudante;
  final bool temMaisMovimentacao;
  final Site? site;
  final Lote lote;
  final Proprietario? proprietario;
  final ModoOperacao? modoOperacao;
  final Endereco origem; // vem no aviso...
  final Endereco destino; // vem no aviso...
  final UMA? umaOrigem;
  final UMA? umaDestino;
  final SKU? sku;
  final Veiculo? veiculo;
  final GrupoCaracteristica? grupoCaracteristica;

  factory Servico.fromJson(Map<String, dynamic> json) =>
      _$ServicoFromJson(json);
}

@JsonResult()
class Lote {
  Lote(this.idc, this.processo);

  final int idc; // vem no aviso...
  final Processo? processo;

  factory Lote.fromJson(Map<String, dynamic> json) => _$LoteFromJson(json);
}

@JsonResult()
class Processo {
  Processo(this.idc);

  final int idc;

  factory Processo.fromJson(Map<String, dynamic> json) =>
      _$ProcessoFromJson(json);

  static const PROCESSO_RECEBIMENTO = 1;
  static const PROCESSO_EXPEDICAO = 2;
  static const PROCESSO_TRANSFERENCIA = 3;
  static const PROCESSO_RESSUPRIMENTO = 4;
  static const PROCESSO_INVENTARIO = 5;
  static const PROCESSO_MONTAGEM_KIT = 6;
  static const PROCESSO_PRODUCAO = 7;
  static const PROCESSO_TRANSFORMACAO_UMA = 8;
  static const PROCESSO_ARMAZENAMENTO = 9;
  static const PROCESSO_DESOVA = 10;
  static const PROCESSO_ALGUEL = 11;
  static const PROCESSO_CONF_REC = 12;
  static const PROCESSO_AUDITORIA_PEDIDO = 13;
  static const PROCESSO_CONSOLIDADO = 14;
  static const PROCESSO_DISTRIBUICAO = 15;
}

class TipoMotivoBloqueio {
  static const DEVOLUCAO = 1;
  static const BLOQUEIO = 2;
  static const OCORRENCIA = 3;
  static const LOGOFF = 4;
  static const BLOQUEIO_PESSOA = 5;
  static const BLOQUEIO_MERCADORIA = 6;
  static const BLOQUEIO_UMA = 7;
  static const MANUTENCAO_ESTOQUE = 8;
}

class ClasseMotivoBloqueio {
  static const OPERACAO_MANUAL = 1;
  static const PEDIDO = 2;
  static const INVENTARIO = 3;
  static const LOTE = 4;
}

@JsonResult()
class Proprietario {
  Proprietario(this.idc);

  final int idc;

  factory Proprietario.fromJson(Map<String, dynamic> json) =>
      _$ProprietarioFromJson(json);
}

@JsonResult()
class ModoOperacao {
  ModoOperacao(this.idc);

  final int idc;

  factory ModoOperacao.fromJson(Map<String, dynamic> json) =>
      _$ModoOperacaoFromJson(json);
}

@JsonResult()
class Endereco {
  Endereco(this.idc, this.mascara, this.nivel, this.grupo, this.enderecoVoz,
      this.codigoVerificador, this.infoCaracteristica);

  final int idc;
  final String mascara;
  final int? nivel;
  final Grupo? grupo;
  final List<String> enderecoVoz;
  final String? codigoVerificador;
  final InfoCaracteristica? infoCaracteristica;

  factory Endereco.fromJson(Map<String, dynamic> json) =>
      _$EnderecoFromJson(json);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Endereco && this.mascara == other.mascara);

  @override
  int get hashCode => super.hashCode;
}

@JsonResult()
class Grupo {
  Grupo(this.idc, this.nome);

  final int idc;
  final String nome;

  factory Grupo.fromJson(Map<String, dynamic> json) => _$GrupoFromJson(json);
}

@JsonResult()
class InfoCaracteristica {
  InfoCaracteristica(this.mensagem, this.grupos);

  final String? mensagem;
  final List<GrupoCaracteristica> grupos;

  factory InfoCaracteristica.fromJson(Map<String, dynamic> json) =>
      _$InfoCaracteristicaFromJson(json);
}

@JsonSerializable()
class GrupoCaracteristica {
  GrupoCaracteristica(this.idc, this.caracteristicas);

  int idc;
  List<Caracteristica>? caracteristicas; // lista vai ser NULL no Serviço...

  factory GrupoCaracteristica.fromJson(Map<String, dynamic> json) =>
      _$GrupoCaracteristicaFromJson(json);
  Map<String, dynamic> toJson() => _$GrupoCaracteristicaToJson(this);
}

@JsonSerializable()
class Caracteristica {
  Caracteristica(this.idc, this.nome, this.valor);

  int idc;
  String nome;
  String valor;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Caracteristica &&
          (this.nome == other.nome && this.valor == other.valor));

  @override
  int get hashCode => super.hashCode;

  factory Caracteristica.fromJson(Map<String, dynamic> json) =>
      _$CaracteristicaFromJson(json);
  Map<String, dynamic> toJson() => _$CaracteristicaToJson(this);
}

@JsonResult()
class UMA {
  UMA(this.idc, this.codigo, this.posicao, this.dispositivo, this.idcCarga, this.sequenciaCarregamento);

  final int idc;
  final String codigo;
  final int posicao;
  final String dispositivo;
  final int? idcCarga;
  final String? sequenciaCarregamento;

  factory UMA.fromJson(Map<String, dynamic> json) => _$UMAFromJson(json);

  String getOrdemCarregamento() {
    if(sequenciaCarregamento == null) return "N/A";
    if(sequenciaCarregamento!.isEmpty) return "N/A";
    if(sequenciaCarregamento!.trim() == "0") return "N/A";
    return sequenciaCarregamento!;
  }

  //Situação da UMA
  static const SITUACAO_UMA_NAO_EXISTE = -1;
  static const SITUACAO_UMA_CRIADA = 1;
  static const SITUACAO_UMA_ENDERECADA = 2;
  static const SITUACAO_UMA_SEL_TRANSFERENCIA = 3;
  static const SITUACAO_UMA_SEM_END_AGUAR_BALAN = 4;
  static const SITUACAO_UMA_ENDERECADA_AGUARD_BALAN = 5;
  static const SITUACAO_UMA_AGUARD_INICIO_CONFERENCIA_ = 6;
  static const SITUACAO_UMA_EM_CONFERENCIA = 7;
  static const SITUACAO_UMA_CONFERIDA_AGUARD_FIM_CONTAGEM = 8;
  static const SITUACAO_UMA_CONFERIDA_AGUARD_ARMAZENAGEM = 9;
  static const SITUACAO_UMA_ENDERECADA_AGUARD_SERVICO = 10;
  static const SITUACAO_UMA_VENDIDA = 11;
  static const SITUACAO_UMA_CANCELADA = 12;
  static const SITUACAO_UMA_OCORRENCIA = 13;
  static const SITUACAO_UMA_SELEC_TRANSF_MANUAL = 14;
  static const SITUACAO_UMA_ENFURNADA = 15;
  static const SITUACAO_UMA_FECHADA = 16;
  static const SITUACAO_UMA_EXPEDIDA = 17;
}

@JsonResult()
class SKU {
  SKU(this.idc, this.nome, this.nomeAbreviado, this.valorEmbalagem, this.peso,
      this.volume, this.estoquePadrao, this.valorVenda, this.mercadoria, this.barras);

  final int idc;
  final String nome;
  final String nomeAbreviado;
  final int valorEmbalagem;
  final double? peso;
  final double? volume;
  final double? estoquePadrao;
  final double? valorVenda;
  final Mercadoria? mercadoria;
  final List<String> barras;

  factory SKU.fromJson(Map<String, dynamic> json) => _$SKUFromJson(json);
}

@JsonResult()
class Mercadoria {
  Mercadoria(this.idc, this.codigo, this.nome, this.nomeAbreviado,
      this.mensuravel, this.skus);

  final int idc;
  final String codigo;
  final String nome;
  final String nomeAbreviado;
  final bool mensuravel;
  final List<SKU> skus;

  factory Mercadoria.fromJson(Map<String, dynamic> json) =>
      _$MercadoriaFromJson(json);

  String get nomeID => '$codigo - $nomeAbreviado';

  void checkCodigoBarras(String codigoBarras) {
    if (!skus.any((sku) => sku.barras.any((barra) => barra == codigoBarras))) {
      throw Exception('Código de Barras inválido');
    }
  }
}

@JsonResult()
class Site {
  Site(this.idc);

  final int idc;

  factory Site.fromJson(Map<String, dynamic> json) => _$SiteFromJson(json);
}

@JsonResult()
class Veiculo {
  Veiculo(this.idcVeiculo, this.placa);

  final int idcVeiculo;
  final String placa;

  factory Veiculo.fromJson(Map<String, dynamic> json) =>
      _$VeiculoFromJson(json);
}

class TipoTransacaoEstoque {
  static const TRANSACAO_ESTOQUE_RECEBIMENTO = 1;
  static const TRANSACAO_ESTOQUE_EXPEDICAO = 2;
  static const TRANSACAO_ESTOQUE_INVENTARIO = 3;
  static const TRANSACAO_ESTOQUE_MANUTENCAO = 4;
  static const TRANSACAO_ESTOQUE_BLOQUEIO = 5;
  static const TRANSACAO_ESTOQUE_FECHAMENTO_UMA = 6;
  static const TRANSACAO_ESTOQUE_FECHAMENTO_PRODUTO = 7;
  static const TRANSACAO_ESTOQUE_ESQ_ONLINE = 8;
  static const TRANSACAO_ESTOQUE_DISTRIBUICAO_UMA = 9;
  static const TRANSACAO_ESTOQUE_EM_TRANSITO = 10;
}
