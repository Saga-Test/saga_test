// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

InfoSAGA _$InfoSAGAFromJson(Map<String, dynamic> json) => InfoSAGA(
      versaoStr: json['VersaoSaga'] as String,
    );

InfoConfigSite _$InfoConfigSiteFromJson(Map<String, dynamic> json) =>
    InfoConfigSite(
      json['ValidaEnderecoOrigemMovRec'] as bool,
      json['TipoImpressora'] as String,
      json['TrocaUMAMovimentacao'] as bool,
      json['PermiteMovimentarMultiplaUMA'] as bool,
      json['CarregaUMAMovimentacaoExpedicao'] as bool,
      json['CodigoUMAMin'] as String,
      json['CodigoUMAMax'] as String,
      json['PermitePreencherEndDestinoMovExp'] as bool,
      json['DiretorioFoto'] as String,
      json['ObrigaSequenciaApanhaMultipla'] as bool,
      json['ValidaData'] as bool? ?? false,
      ConfigGeral.fromJson(json['Geral'] as Map<String, dynamic>),
      Expedicao.fromJson(json['Expedicao'] as Map<String, dynamic>),
      Transferencia.fromJson(json['Transferencia'] as Map<String, dynamic>),
      json['IdcEnderecoAvaria'] as String,
      json['EnderecoAvaria'] as String,
    );

ConfigGeral _$ConfigGeralFromJson(Map<String, dynamic> json) => ConfigGeral(
      json['QuantidadeCasasDecimais'] as int,
      json['UsaSagaLight'] as bool,
      json['NumeroDigitoValidacaoVoz'] as int,
      json['UsaVoz'] as bool,
      json['ExibeDicas'] as bool,
    );

Expedicao _$ExpedicaoFromJson(Map<String, dynamic> json) => Expedicao(
      json['ValidaVeiculo'] as bool,
      json['GeraUMAAutomaticamente'] as bool,
      json['ValidaBarrasMercadoriaNaEmbalagem'] as bool,
      json['GeraBoletimOcorrenciaEmbalagem'] as bool,
    );

Transferencia _$TransferenciaFromJson(Map<String, dynamic> json) =>
    Transferencia(
      json['PedeOrigemParaAbandonar'] as bool,
    );

InfoLogin _$InfoLoginFromJson(Map<String, dynamic> json) => InfoLogin(
      json['IdcUsuario'] as int,
      json['CodigoUsuario'] as String,
      json['NomeUsuario'] as String,
      json['IdcGrupoUsuario'] as int,
      json['CodigoGrupoUsuario'] as String,
      json['NomeGrupoUsuario'] as String,
      json['IdcSite'] as int,
      json['CodigoSite'] as String,
      json['NomeSite'] as String,
      json['IdcPosto'] as int,
      json['CodigoPosto'] as String,
      json['NomePosto'] as String,
      json['IdcEquipamento'] as int?,
      json['CodigoEquipamento'] as String?,
      json['NomeEquipamento'] as String?,
      json['Configuracao'] == null
          ? null
          : Configuracao.fromJson(json['Configuracao'] as Map<String, dynamic>),
    );

Configuracao _$ConfiguracaoFromJson(Map<String, dynamic> json) => Configuracao(
      json['PrefixoUMA'] as String,
      json['TamanhoUMA'] as int,
      json['ValidaTamMaxUMA'] as bool,
      json['ValidaPrefixoNumUMA'] as bool,
      json['InsereCaractUnicaRec'] as bool,
    );
