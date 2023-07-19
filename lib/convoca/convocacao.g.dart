// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'convocacao.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Convocacao _$ConvocacaoFromJson(Map<String, dynamic> json) => Convocacao(
      Atividade.fromJson(json['Atividade'] as Map<String, dynamic>),
      json['Ordem'] == null
          ? null
          : Ordem.fromJson(json['Ordem'] as Map<String, dynamic>),
      (json['Servicos'] as List<dynamic>)
          .map((e) => Servico.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Atividade _$AtividadeFromJson(Map<String, dynamic> json) => Atividade(
      json['Idc'] as int,
      json['Nome'] as String,
      json['UsaVoz'] as bool,
    );

Ordem _$OrdemFromJson(Map<String, dynamic> json) => Ordem(
      json['Idc'] as int,
    );

Servico _$ServicoFromJson(Map<String, dynamic> json) => Servico(
      json['Idc'] as int,
      json['SequenciaServico'] as int,
      json['SequenciaAtividade'] as int,
      json['NumeroItem'] as int,
      (json['Quantidade'] as num?)?.toDouble(),
      json['EAjudante'] as bool,
      Lote.fromJson(json['Lote'] as Map<String, dynamic>),
      json['Proprietario'] == null
          ? null
          : Proprietario.fromJson(json['Proprietario'] as Map<String, dynamic>),
      json['ModoOperacao'] == null
          ? null
          : ModoOperacao.fromJson(json['ModoOperacao'] as Map<String, dynamic>),
      Endereco.fromJson(json['Origem'] as Map<String, dynamic>),
      Endereco.fromJson(json['Destino'] as Map<String, dynamic>),
      json['UmaOrigem'] == null
          ? null
          : UMA.fromJson(json['UmaOrigem'] as Map<String, dynamic>),
      json['UmaDestino'] == null
          ? null
          : UMA.fromJson(json['UmaDestino'] as Map<String, dynamic>),
      json['Sku'] == null
          ? null
          : SKU.fromJson(json['Sku'] as Map<String, dynamic>),
      json['Site'] == null
          ? null
          : Site.fromJson(json['Site'] as Map<String, dynamic>),
      json['Veiculo'] == null
          ? null
          : Veiculo.fromJson(json['Veiculo'] as Map<String, dynamic>),
      json['GrupoCaracteristica'] == null
          ? null
          : GrupoCaracteristica.fromJson(
              json['GrupoCaracteristica'] as Map<String, dynamic>),
      json['SrtQuantidade'] as String?,
      json['TemMaisMovimentacao'] as bool,
    );

Lote _$LoteFromJson(Map<String, dynamic> json) => Lote(
      json['Idc'] as int,
      json['Processo'] == null
          ? null
          : Processo.fromJson(json['Processo'] as Map<String, dynamic>),
    );

Processo _$ProcessoFromJson(Map<String, dynamic> json) => Processo(
      json['Idc'] as int,
    );

Proprietario _$ProprietarioFromJson(Map<String, dynamic> json) => Proprietario(
      json['Idc'] as int,
    );

ModoOperacao _$ModoOperacaoFromJson(Map<String, dynamic> json) => ModoOperacao(
      json['Idc'] as int,
    );

Endereco _$EnderecoFromJson(Map<String, dynamic> json) => Endereco(
      json['Idc'] as int,
      json['Mascara'] as String,
      json['Nivel'] as int?,
      json['Grupo'] == null
          ? null
          : Grupo.fromJson(json['Grupo'] as Map<String, dynamic>),
      (json['EnderecoVoz'] as List<dynamic>).map((e) => e as String).toList(),
      json['CodigoVerificador'] as String?,
      json['InfoCaracteristica'] == null
          ? null
          : InfoCaracteristica.fromJson(
              json['InfoCaracteristica'] as Map<String, dynamic>),
    );

Grupo _$GrupoFromJson(Map<String, dynamic> json) => Grupo(
      json['Idc'] as int,
      json['Nome'] as String,
    );

InfoCaracteristica _$InfoCaracteristicaFromJson(Map<String, dynamic> json) =>
    InfoCaracteristica(
      json['Mensagem'] as String?,
      (json['Grupos'] as List<dynamic>)
          .map((e) => GrupoCaracteristica.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

GrupoCaracteristica _$GrupoCaracteristicaFromJson(Map<String, dynamic> json) =>
    GrupoCaracteristica(
      json['Idc'] as int,
      (json['Caracteristicas'] as List<dynamic>?)
          ?.map((e) => Caracteristica.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$GrupoCaracteristicaToJson(
        GrupoCaracteristica instance) =>
    <String, dynamic>{
      'Idc': instance.idc,
      'Caracteristicas': instance.caracteristicas,
    };

Caracteristica _$CaracteristicaFromJson(Map<String, dynamic> json) =>
    Caracteristica(
      json['Idc'] as int,
      json['Nome'] as String,
      json['Valor'] as String,
    );

Map<String, dynamic> _$CaracteristicaToJson(Caracteristica instance) =>
    <String, dynamic>{
      'Idc': instance.idc,
      'Nome': instance.nome,
      'Valor': instance.valor,
    };

UMA _$UMAFromJson(Map<String, dynamic> json) => UMA(
      json['Idc'] as int,
      json['Codigo'] as String,
      json['Posicao'] as int,
      json['Dispositivo'] as String,
      json['IdcCarga'] as int?,
      json['SequenciaCarregamento'] as String?,
    );

SKU _$SKUFromJson(Map<String, dynamic> json) => SKU(
      json['Idc'] as int,
      json['Nome'] as String,
      json['NomeAbreviado'] as String,
      json['ValorEmbalagem'] as int,
      (json['Peso'] as num?)?.toDouble(),
      (json['Volume'] as num?)?.toDouble(),
      (json['EstoquePadrao'] as num?)?.toDouble(),
      (json['ValorVenda'] as num?)?.toDouble(),
      json['Mercadoria'] == null
          ? null
          : Mercadoria.fromJson(json['Mercadoria'] as Map<String, dynamic>),
      (json['Barras'] as List<dynamic>).map((e) => e as String).toList(),
    );

Mercadoria _$MercadoriaFromJson(Map<String, dynamic> json) => Mercadoria(
      json['Idc'] as int,
      json['Codigo'] as String,
      json['Nome'] as String,
      json['NomeAbreviado'] as String,
      json['Mensuravel'] as bool,
      (json['Skus'] as List<dynamic>)
          .map((e) => SKU.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Site _$SiteFromJson(Map<String, dynamic> json) => Site(
      json['Idc'] as int,
    );

Veiculo _$VeiculoFromJson(Map<String, dynamic> json) => Veiculo(
      json['IdcVeiculo'] as int,
      json['Placa'] as String,
    );
