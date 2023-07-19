// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'login_api.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

InfoSite _$InfoSiteFromJson(Map<String, dynamic> json) => InfoSite(
      idc: json['Idc'] as int,
      codigo: json['Codigo'] as String,
      nome: json['Nome'] as String,
    );

InfoPosto _$InfoPostoFromJson(Map<String, dynamic> json) => InfoPosto(
      idc: json['Idc'] as int,
      codigo: json['Codigo'] as String,
      nome: json['Nome'] as String,
      quantideServicos: json['QuantideServicos'] as int,
    );

InfoEquipamento _$InfoEquipamentoFromJson(Map<String, dynamic> json) =>
    InfoEquipamento(
      idc: json['Idc'] as int,
      codigo: json['Codigo'] as String,
      nome: json['Nome'] as String,
    );

InfoMotivoLogout _$InfoMotivoLogoutFromJson(Map<String, dynamic> json) =>
    InfoMotivoLogout(
      idc: json['Idc'] as int,
      nome: json['Nome'] as String,
    );
