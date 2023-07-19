// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'distribuicao_api.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ConfirmaDestinoDTO _$ConfirmaDestinoDTOFromJson(Map<String, dynamic> json) =>
    ConfirmaDestinoDTO(
      json['Mensagem'] as String?,
      EnderecoDTO.fromJson(json['Endereco'] as Map<String, dynamic>),
    );

EnderecoDTO _$EnderecoDTOFromJson(Map<String, dynamic> json) => EnderecoDTO(
      json['Idc'] as int,
      json['Mascara'] as String,
    );

InfoMotivoBloqueio _$InfoMotivoBloqueioFromJson(Map<String, dynamic> json) =>
    InfoMotivoBloqueio(
      json['Idc'] as int,
      json['Descricao'] as String,
    );

InfoDispositivo _$InfoDispositivoFromJson(Map<String, dynamic> json) =>
    InfoDispositivo(
      json['Idc'] as int,
      json['Codigo'] as String,
      json['Nome'] as String,
    );

InfoUMA _$InfoUMAFromJson(Map<String, dynamic> json) => InfoUMA(
      json['Idc'] as int,
      json['Codigo'] as String,
      json['IdcSite'] as int,
      json['IdcDispositivo'] as int,
      json['IdcSituacao'] as int,
      json['IdcLoteCriacao'] as int?,
      json['Endereco'] as String,
      UMA$Situacao.fromJson(json['Situacao'] as Map<String, dynamic>),
      InfoDispositivo.fromJson(json['Dispositivo'] as Map<String, dynamic>),
      (json['Estoques'] as List<dynamic>)
          .map((e) => InfoEstoque.fromJson(e as Map<String, dynamic>))
          .toList(),
      (json['Bloqueios'] as List<dynamic>)
          .map((e) => InfoMotivoBloqueio.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

UMA$Situacao _$UMA$SituacaoFromJson(Map<String, dynamic> json) => UMA$Situacao(
      json['Idc'] as int,
      json['Nome'] as String,
    );

InfoEstoque _$InfoEstoqueFromJson(Map<String, dynamic> json) => InfoEstoque(
      json['Idc'] as int,
      json['IdcSite'] as int,
      json['IdcProprietario'] as int,
      json['IdcUMA'] as int,
      json['IdcGrupoCaracteristica'] as int?,
      DateTime.parse(json['DataFabricacao'] as String),
      DateTime.parse(json['DataValidade'] as String),
      DateTime.parse(json['DataRecebimento'] as String),
      json['IdcEmbalagem'] as int,
      (json['Quantidade'] as num).toDouble(),
      Estoque$Pessoa.fromJson(json['Proprietario'] as Map<String, dynamic>),
      Estoque$SKU$Mercadoria.fromJson(
          json['Embalagem'] as Map<String, dynamic>),
      json['OrdemEntrada'] == null
          ? null
          : Estoque$OrdemEntrada.fromJson(
              json['OrdemEntrada'] as Map<String, dynamic>),
      (json['Caracteristicas'] as List<dynamic>)
          .map(
              (e) => Estoque$Caracteristica.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$InfoEstoqueToJson(InfoEstoque instance) =>
    <String, dynamic>{
      'Idc': instance.idc,
      'IdcSite': instance.idcSite,
      'IdcProprietario': instance.idcProprietario,
      'IdcUMA': instance.idcUMA,
      'IdcGrupoCaracteristica': instance.idcGrupoCaracteristica,
      'DataFabricacao': instance.dataFabricacao.toIso8601String(),
      'DataValidade': instance.dataValidade.toIso8601String(),
      'DataRecebimento': instance.dataRecebimento.toIso8601String(),
      'IdcEmbalagem': instance.idcEmbalagem,
      'Quantidade': instance.quantidade,
      'Proprietario': instance.proprietario,
      'Embalagem': instance.embalagem,
      'OrdemEntrada': instance.ordemEntrada,
      'Caracteristicas': instance.caracteristicas,
    };

Estoque$Pessoa _$Estoque$PessoaFromJson(Map<String, dynamic> json) =>
    Estoque$Pessoa(
      json['Idc'] as int,
      json['Codigo'] as String,
      json['Nome'] as String,
    );

Map<String, dynamic> _$Estoque$PessoaToJson(Estoque$Pessoa instance) =>
    <String, dynamic>{
      'Idc': instance.idc,
      'Codigo': instance.codigo,
      'Nome': instance.nome,
    };

Estoque$SKU _$Estoque$SKUFromJson(Map<String, dynamic> json) => Estoque$SKU(
      json['Idc'] as int,
      json['Nome'] as String,
      json['Valor'] as int,
      (json['CodigosDeBarras'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$Estoque$SKUToJson(Estoque$SKU instance) =>
    <String, dynamic>{
      'Idc': instance.idc,
      'Nome': instance.nome,
      'Valor': instance.valor,
      'CodigosDeBarras': instance.codigosDeBarras,
    };

Estoque$SKU$Mercadoria _$Estoque$SKU$MercadoriaFromJson(
        Map<String, dynamic> json) =>
    Estoque$SKU$Mercadoria(
      json['Idc'] as int,
      json['Nome'] as String,
      json['Valor'] as int,
      (json['CodigosDeBarras'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      Estoque$Mercadoria.fromJson(json['Mercadoria'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$Estoque$SKU$MercadoriaToJson(
        Estoque$SKU$Mercadoria instance) =>
    <String, dynamic>{
      'Idc': instance.idc,
      'Nome': instance.nome,
      'Valor': instance.valor,
      'CodigosDeBarras': instance.codigosDeBarras,
      'Mercadoria': instance.mercadoria,
    };

Estoque$Mercadoria _$Estoque$MercadoriaFromJson(Map<String, dynamic> json) =>
    Estoque$Mercadoria(
      json['Idc'] as int,
      json['Codigo'] as String,
      json['Nome'] as String,
      json['Mensuravel'] as bool,
      json['PrazoValidade'] as int,
      (json['Embalagens'] as List<dynamic>)
          .map((e) => Estoque$SKU.fromJson(e as Map<String, dynamic>))
          .toList(),
      (json['Caracteristicas'] as List<dynamic>)
          .map((e) =>
              Mercadoria$Caracteristica.fromJson(e as Map<String, dynamic>))
          .toList(),
      (json['EnderecosApanha'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$Estoque$MercadoriaToJson(Estoque$Mercadoria instance) =>
    <String, dynamic>{
      'Idc': instance.idc,
      'Codigo': instance.codigo,
      'Nome': instance.nome,
      'Mensuravel': instance.mensuravel,
      'PrazoValidade': instance.prazoValidade,
      'Embalagens': instance.embalagens,
      'Caracteristicas': instance.caracteristicas,
      'EnderecosApanha': instance.enderecosApanha,
    };

Mercadoria$Caracteristica _$Mercadoria$CaracteristicaFromJson(
        Map<String, dynamic> json) =>
    Mercadoria$Caracteristica(
      json['Idc'] as int,
      json['Nome'] as String,
      json['Obrigatoria'] as bool,
    );

Map<String, dynamic> _$Mercadoria$CaracteristicaToJson(
        Mercadoria$Caracteristica instance) =>
    <String, dynamic>{
      'Idc': instance.idc,
      'Nome': instance.nome,
      'Obrigatoria': instance.obrigatoria,
    };

Estoque$OrdemEntrada _$Estoque$OrdemEntradaFromJson(
        Map<String, dynamic> json) =>
    Estoque$OrdemEntrada(
      json['Idc'] as int,
      json['NumeroOrdem'] as String,
      Estoque$Pessoa.fromJson(json['Fornecedor'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$Estoque$OrdemEntradaToJson(
        Estoque$OrdemEntrada instance) =>
    <String, dynamic>{
      'Idc': instance.idc,
      'NumeroOrdem': instance.numeroOrdem,
      'Fornecedor': instance.fornecedor,
    };

Estoque$Caracteristica _$Estoque$CaracteristicaFromJson(
        Map<String, dynamic> json) =>
    Estoque$Caracteristica(
      json['Idc'] as int,
      json['Nome'] as String,
      json['Valor'] as String,
    );

Map<String, dynamic> _$Estoque$CaracteristicaToJson(
        Estoque$Caracteristica instance) =>
    <String, dynamic>{
      'Idc': instance.idc,
      'Nome': instance.nome,
      'Valor': instance.valor,
    };

InfoEndereco _$InfoEnderecoFromJson(Map<String, dynamic> json) => InfoEndereco(
      json['Idc'] as int,
      json['Mascara'] as String,
      json['Finalidade'] as String,
      json['MaiorValidade'] == null
          ? null
          : DateTime.parse(json['MaiorValidade'] as String),
    );

UMAEstoque _$UMAEstoqueFromJson(Map<String, dynamic> json) => UMAEstoque(
      json['Idc'] as int,
      json['IdcSite'] as int,
      json['Codigo'] as String,
      json['Posicao'] as int?,
      json['QuantidadeItens'] as int,
      json['InfoMercadorias'] as String,
      json['MotivoBloqueio'] as int?,
      json['Situacao'] == null
          ? null
          : UMAEstoque$Situacao.fromJson(
              json['Situacao'] as Map<String, dynamic>),
      UMAEstoque$Endereco.fromJson(json['Endereco'] as Map<String, dynamic>),
      UMAEstoque$Dispositivo.fromJson(
          json['Dispositivo'] as Map<String, dynamic>),
      UMAEstoque$Proprietario.fromJson(
          json['Proprietario'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$UMAEstoqueToJson(UMAEstoque instance) =>
    <String, dynamic>{
      'Idc': instance.idc,
      'IdcSite': instance.idcSite,
      'Codigo': instance.codigo,
      'Posicao': instance.posicao,
      'QuantidadeItens': instance.quantidadeItens,
      'InfoMercadorias': instance.infoMercadorias,
      'MotivoBloqueio': instance.motivoBloqueio,
      'Situacao': instance.situacao,
      'Endereco': instance.endereco,
      'Dispositivo': instance.dispositivo,
      'Proprietario': instance.proprietario,
    };

UMAEstoque$Situacao _$UMAEstoque$SituacaoFromJson(Map<String, dynamic> json) =>
    UMAEstoque$Situacao(
      json['Idc'] as int,
      json['Nome'] as String,
    );

Map<String, dynamic> _$UMAEstoque$SituacaoToJson(
        UMAEstoque$Situacao instance) =>
    <String, dynamic>{
      'Idc': instance.idc,
      'Nome': instance.nome,
    };

UMAEstoque$Endereco _$UMAEstoque$EnderecoFromJson(Map<String, dynamic> json) =>
    UMAEstoque$Endereco(
      json['Idc'] as int,
      json['Mascara'] as String,
    );

Map<String, dynamic> _$UMAEstoque$EnderecoToJson(
        UMAEstoque$Endereco instance) =>
    <String, dynamic>{
      'Idc': instance.idc,
      'Mascara': instance.mascara,
    };

UMAEstoque$Dispositivo _$UMAEstoque$DispositivoFromJson(
        Map<String, dynamic> json) =>
    UMAEstoque$Dispositivo(
      json['Idc'] as int,
      json['Codigo'] as String,
      json['Nome'] as String,
    );

Map<String, dynamic> _$UMAEstoque$DispositivoToJson(
        UMAEstoque$Dispositivo instance) =>
    <String, dynamic>{
      'Idc': instance.idc,
      'Codigo': instance.codigo,
      'Nome': instance.nome,
    };

UMAEstoque$Proprietario _$UMAEstoque$ProprietarioFromJson(
        Map<String, dynamic> json) =>
    UMAEstoque$Proprietario(
      json['Idc'] as int,
      json['Codigo'] as String,
      json['Nome'] as String,
    );

Map<String, dynamic> _$UMAEstoque$ProprietarioToJson(
        UMAEstoque$Proprietario instance) =>
    <String, dynamic>{
      'Idc': instance.idc,
      'Codigo': instance.codigo,
      'Nome': instance.nome,
    };
