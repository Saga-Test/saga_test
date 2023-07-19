// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'controle_doca_api.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

InfoDoca _$InfoDocaFromJson(Map<String, dynamic> json) => InfoDoca(
      json['IdcLoc'] as int,
      json['NomLoc'] as String,
    );

InfoVeiculo _$InfoVeiculoFromJson(Map<String, dynamic> json) => InfoVeiculo(
      json['IdcMov'] as int,
      json['IdcVec'] as int,
      json['IdcPss'] as int,
      json['IdcStsMovPrt'] as int,
      json['StsMovPrt'] as String?,
      json['NomMot'] as String,
      json['CodPlaVec'] as String,
      DateTime.parse(json['DatHorIni'] as String),
    );
