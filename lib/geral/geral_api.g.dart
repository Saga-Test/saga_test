// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'geral_api.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

InfoImpressora _$InfoImpressoraFromJson(Map<String, dynamic> json) =>
    InfoImpressora(
      json['ImpressoraPadrao'] as bool,
      json['ImpressoraCMP'] as bool,
      json['ImpressoraLocal'] as bool,
      json['Status'] as int,
      json['Idc'] as int,
      json['Site'] as int,
      json['Tipo'] as int,
      json['Caminho'] as String,
      json['NomeComercial'] as String,
      json['NomeServidor'] as String,
      json['Nome'] as String,
      json['Porta'] as String,
    );

GeralInfoLote _$GeralInfoLoteFromJson(Map<String, dynamic> json) =>
    GeralInfoLote(
      json['IdcLote'] as int,
      json['NumOrdem'] as String,
      json['NumOrdemExterna'] as String,
      json['CodigoPessoa'] as String,
      json['NomePessoa'] as String,
      json['CodigoTransportadora'] as String,
      json['NomeTransportadora'] as String,
      json['Observacao'] as String,
      json['Cidade'] as String,
      json['Estado'] as String,
      json['NumAgrupamento'] as String,
      json['Endereco'] as String,
      json['QtdUMA'] as int,
      json['PlacaVeiculo'] as String,
      json['Motorista'] as String,
      json['QtdUMATot'] as int,
    );

ObservacaoUMA _$ObservacaoUMAFromJson(Map<String, dynamic> json) =>
    ObservacaoUMA(
      idcUma: json['IdcUma'] as int,
      peso: (json['Peso'] as num).toDouble(),
      volume: (json['Volume'] as num).toDouble(),
      observacao: json['Observacao'] as String,
    );
