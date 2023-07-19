// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'associacao_rg_api.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

InfoEndereco _$InfoEnderecoFromJson(Map<String, dynamic> json) => InfoEndereco(
      json['IdcEndereco'] as int,
      json['Endereco'] as String,
    );

InfoLote _$InfoLoteFromJson(Map<String, dynamic> json) => InfoLote(
      json['IdcLote'] as int,
      json['IdcAtividade'] as int,
      json['IdcSituacaoAtividade'] as int,
      json['IdcOrdemServico'] as int,
      json['ValorSequenciaAtividade'] as int,
      json['NumeroItemOrdemServico'] as int,
      json['ValorSequenciaServico'] as int,
    );

InfoRGU _$InfoRGUFromJson(Map<String, dynamic> json) => InfoRGU(
      json['IdcMercadoria'] as int,
      json['CodigoMercadoria'] as String,
      json['DescricaoMercadoria'] as String,
      json['ValorEmbalagem'] as int,
    );

InfoIdt _$InfoIdtFromJson(Map<String, dynamic> json) => InfoIdt(
      json['CodigoIdt'] as String,
      json['CodigoUMA'] as String,
      json['IdcSituacaoUMA'] as int,
      json['CodigoMercadoria'] as String,
      json['DescricaoMercadoria'] as String,
      json['ValorEmbalagem'] as int,
      (json['QuantidadeEstoquePrimario'] as num).toDouble(),
      json['IdcEnderecoUMA'] as int,
      json['SituacaoUMA'] as String,
      json['MascaraEnderecoUMA'] as String,
      json['IdcMercadoria'] as int,
      json['IdcGrupoCaracteristicas'] as int?,
    );

InfoProduto _$InfoProdutoFromJson(Map<String, dynamic> json) => InfoProduto(
      json['IdcLoteExpedicao'] as int,
      json['SequenciaCarregamento'] as int,
      json['NomeCliente'] as String,
      json['IdcMercadoria'] as int,
      json['CodigoMercadoria'] as String,
      json['DescricaoMercadoria'] as String,
      json['IdcGrupoCaracteristica'] as int?,
      json['ValorCaracteristicaConcatenada'] as String,
      (json['SaldoEmUnidade'] as num).toDouble(),
      (json['Ordens'] as List<dynamic>)
          .map((e) => InfoProduto$Ordens.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

InfoProduto$Ordens _$InfoProduto$OrdensFromJson(Map<String, dynamic> json) =>
    InfoProduto$Ordens(
      json['IdcOrdem'] as int,
      json['NumeroOrdem'] as String,
    );

Map<String, dynamic> _$InfoProduto$OrdensToJson(InfoProduto$Ordens instance) =>
    <String, dynamic>{
      'IdcOrdem': instance.idcOrdem,
      'NumeroOrdem': instance.numeroOrdem,
    };
