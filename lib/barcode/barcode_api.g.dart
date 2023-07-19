// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'barcode_api.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

InfoFormatoEAN _$InfoFormatoEANFromJson(Map<String, dynamic> json) =>
    InfoFormatoEAN(
      json['IdcFmtEan'] as int,
      json['NomFmtEan'] as String,
      json['LstAim'] as String?,
    );

InfoCampoEAN _$InfoCampoEANFromJson(Map<String, dynamic> json) => InfoCampoEAN(
      json['CodAplEan'] as String,
      json['NomBrrBar'] as String,
      json['TamMax'] as int,
      json['NroSeq'] as int?,
      json['IdcFmtEan'] as int,
      json['IdcTipCarMer'] as int?,
      json['FmtVarEan'] as String,
      json['NroSeqBarCmp'] as int?,
    );

InfoTabelaRGU _$InfoTabelaRGUFromJson(Map<String, dynamic> json) =>
    InfoTabelaRGU(
      json['CodIdt'] as String,
      json['CodBrr'] as String,
      json['DatVal'] as String,
      json['FmtVarEanDatVal'] as String,
      json['CodMer'] as String,
      json['IdcTipCarMer'] as int,
      json['ValCarMer'] as String,
    );

ParametrosAtividade _$ParametrosAtividadeFromJson(Map<String, dynamic> json) =>
    ParametrosAtividade(
      json['IdcAtividade'] as int,
      json['Nome'] as String,
      json['NomeAbreviado'] as String,
      json['PermiteDigitarEndereco'] as bool,
      json['PermiteDigitarUMA'] as bool,
      json['PermiteDigitarMercadoria'] as bool,
    );
