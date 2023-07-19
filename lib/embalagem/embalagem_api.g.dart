// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'embalagem_api.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

InfoEndereco _$InfoEnderecoFromJson(Map<String, dynamic> json) => InfoEndereco(
      json['IdcSite'] as int,
      json['IdcEndereco'] as int,
      json['MascaraEndereco'] as String,
      json['QuantidadeOrdens'] as int,
      json['QuantidadeItens'] as int,
    );

InfoOrdem _$InfoOrdemFromJson(Map<String, dynamic> json) => InfoOrdem(
      json['IdcSite'] as int,
      json['IdcEndereco'] as int,
      json['IdcOrdem'] as int,
      json['NumeroOrdem'] as String,
      json['QuantidadeMercadorias'] as int,
      json['CodigoCliente'] as String,
      json['NomeCliente'] as String,
      (json['QuantidadeEstoqueEmbalar'] as num).toDouble(),
      (json['PesoEstoqueEmbalar'] as num).toDouble(),
      json['IdcLote'] as int,
      json['Observacao'] as String?,
      json['NumOrdensLotes'] as int,
    );

InfoMercadoria _$InfoMercadoriaFromJson(Map<String, dynamic> json) =>
    InfoMercadoria(
      json['IdcOrdem'] as int,
      json['IdcMercadoria'] as int,
      json['CodigoMercadoria'] as String,
      json['DescricaoMercadoria'] as String,
      (json['Barras'] as List<dynamic>).map((e) => e as String).toList(),
      (json['QuantidadeUnidade'] as num).toDouble(),
      (json['QuantidadeTotal'] as num).toDouble(),
      json['StrQuantidade'] as String,
      (json['UMAs'] as List<dynamic>)
          .map((e) => InfoUMA.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$InfoMercadoriaToJson(InfoMercadoria instance) =>
    <String, dynamic>{
      'IdcOrdem': instance.idcOrdem,
      'IdcMercadoria': instance.idcMercadoria,
      'CodigoMercadoria': instance.codigoMercadoria,
      'DescricaoMercadoria': instance.descricaoMercadoria,
      'QuantidadeUnidade': instance.quantidadeUnidade,
      'QuantidadeTotal': instance.quantidadeTotal,
      'StrQuantidade': instance.strQuantidade,
      'Barras': instance.listaCodigoBarras,
      'UMAs': instance.listaUMAs,
    };

InfoUMA _$InfoUMAFromJson(Map<String, dynamic> json) => InfoUMA(
      json['Idc'] as int,
      json['Codigo'] as String,
      json['IdcDispositivo'] as int?,
      json['Observacao'] as String?,
    );

Map<String, dynamic> _$InfoUMAToJson(InfoUMA instance) => <String, dynamic>{
      'Idc': instance.idc,
      'Codigo': instance.codigo,
      'IdcDispositivo': instance.idcDispositivo,
      'Observacao': instance.observacao,
    };

InfoDispositivo _$InfoDispositivoFromJson(Map<String, dynamic> json) =>
    InfoDispositivo(
      json['Idc'] as int,
      json['Codigo'] as String,
      json['Nome'] as String,
    );

Work _$WorkFromJson(Map<String, dynamic> json) => Work(
      json['Endereco'] as String,
      json['Ordem'] as String,
    );

Map<String, dynamic> _$WorkToJson(Work instance) => <String, dynamic>{
      'Endereco': instance.endereco,
      'Ordem': instance.ordem,
    };

UmaOrigem _$UmaOrigemFromJson(Map<String, dynamic> json) => UmaOrigem(
      idc: json['Idc'] as int,
      codigo: json['Codigo'] as String,
      quantidadeMercadoria: json['QuantidadeMercadoria'] as int,
      nomeAtividade: json['NomeAtividade'] as String,
      observacaoUMA: json['ObservacaoUMA'] as String?,
    );
