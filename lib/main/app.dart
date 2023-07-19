import 'dart:io';

import 'package:package_info_plus/package_info_plus.dart';
import 'package:pub_semver/pub_semver.dart';

import '../saga_lib/sa_api.dart';
import '../saga_lib/sa_json.dart';

part 'app.g.dart';

class App {
  static Future init() async {
    _packageInfo = await PackageInfo.fromPlatform();
  }

  static Future start(
    InfoSAGA infoSAGA,
    InfoLogin infoLogin,
    InfoConfigSite infoConfigSite,
  ) async {
    _infoSAGA = infoSAGA;
    _info = infoLogin;
    _configuracao = infoLogin.configuracao!;
    _site = infoConfigSite;
  }

  static void setInfoLogin(InfoLogin infoLogin) {
    _info = infoLogin;
    // aqui não é retornada a "configuração" - ela vem NULL
  }

  static bool get isNullSafety => dartVersion >= Version(2, 12, 0);
  static Version get dartVersion {
    final parts = Platform.version.split(' ');
    final version = Version.parse(parts[0]);
    return version;
  }

  static Operador get operador => Operador(idcUsuario: App.idcUsuario, idcSite: App.idcSite);

  static String get baseUrl => baseURLUser;

  static InfoSAGA get infoSAGA => _infoSAGA;
  static late InfoSAGA _infoSAGA;

  static bool get v374 => infoSAGA.versaoSAGA >= parseVersion('3.74');
  static bool get v375 => infoSAGA.versaoSAGA >= parseVersion('3.75');
  static bool get v410 => infoSAGA.versaoSAGA >= parseVersion('4.10');

  static InfoLogin get info => _info;
  static late InfoLogin _info;

  // usuário...
  static int get idcUsuario => _info.idcUsuario;
  static String get codigoUsuario => _info.codigoUsuario;
  static String get nomeUsuario => _info.nomeUsuario;
  static String get codigoNomeUsuario => '$codigoUsuario - $nomeUsuario';
  // grupo de usuário...
  static int get idcGrupoUsuario => _info.idcGrupoUsuario;
  static String get codigoGrupoUsuario => _info.codigoGrupoUsuario;
  static String get nomeGrupoUsuario => _info.nomeGrupoUsuario;
  static String get codigoNomeGrupoUsuario => '$codigoGrupoUsuario - $nomeGrupoUsuario';
  // site...
  static int get idcSite => _info.idcSite;
  static String get codigoSite => _info.codigoSite;
  static String get nomeSite => _info.nomeSite;
  static String get codigoNomeSite => '$codigoSite - $nomeSite';
  static bool get obrigaSequenciaApanhaMultipla => _site.obrigaSequenciaApanhaMultipla;
  // posto...
  static int get idcPosto => _info.idcPosto;
  static String get codigoPosto => _info.codigoPosto;
  static String get nomePosto => _info.nomePosto;
  static String get codigoNomePosto => '$codigoPosto - $nomePosto';
  // equipamento...
  static int? get idcEquipamento => _info.idcEquipamento;
  static String? get codigoEquipamento => _info.codigoEquipamento;
  static String? get nomeEquipamento => _info.nomeEquipamento;
  static String get codigoNomeEquipamento =>
      codigoEquipamento == null ? '' : '$codigoEquipamento - $nomeEquipamento';

  static Configuracao get configuracao => _configuracao;
  static late Configuracao _configuracao;

  static InfoConfigSite get site => _site;
  static ConfigGeral get geral => _site.geral;
  static late InfoConfigSite _site;

  static PackageInfo get packageInfo => _packageInfo;
  static late PackageInfo _packageInfo;

  static String get versionTitle =>
      isExperimental ? '*** EXPERIMENTAL ***' : 'versão $versionName';
  static String get versionName => packageInfo.version;
  static int get versionNumber => int.parse(packageInfo.buildNumber);
  static bool get isExperimental => versionNumber == 999;
}

Version parseVersion(String versionStr) {
  // normaliza versão para X.Y.Z - OBRIGATÓRIO para o uso da classe Version!!!
  final list = versionStr.split('.');
  String value(int index) => list.length > index ? list[index] : '0';

  final versionXYZ = '${value(0)}.${value(1)}.${value(2)}';

  final version = Version.parse(versionXYZ);
  return version;
}

class Operador {
  Operador({required this.idcUsuario, required this.idcSite});

  final int idcUsuario;
  final int idcSite;
}

@JsonResult()
class InfoSAGA {
  InfoSAGA({required this.versaoStr}) : this.versaoSAGA = parseVersion(versaoStr);

  @JsonKey(name: 'VersaoSaga')
  final String versaoStr;
  final Version versaoSAGA;

  factory InfoSAGA.fromJson(Map<String, dynamic> json) => _$InfoSAGAFromJson(json);
}

@JsonResult()
class InfoConfigSite {
  InfoConfigSite(
    this.validaEnderecoOrigemMovRec,
    this.tipoImpressora,
    this.trocaUMAMovimentacao,
    this.permiteMovimentarMultiplaUMA,
    this.carregaUMAMovimentacaoExpedicao,
    this.codigoUMAMin,
    this.codigoUMAMax,
    this.permitePreencherEndDestinoMovExp,
    this.diretorioFoto,
    this.obrigaSequenciaApanhaMultipla,
    this.validaData,
    this.geral,
    this.expedicao,
    this.transferencia,
    this.idcEnderecoAvariaStr,
    this.enderecoAvaria,
  );

  final bool validaEnderecoOrigemMovRec;
  final String tipoImpressora;
  final bool trocaUMAMovimentacao;
  final bool permiteMovimentarMultiplaUMA;
  final bool carregaUMAMovimentacaoExpedicao;
  final String codigoUMAMin;
  final String codigoUMAMax;
  final bool permitePreencherEndDestinoMovExp;
  final String diretorioFoto;
  final bool obrigaSequenciaApanhaMultipla;

  @JsonKey(defaultValue: false)
  final bool validaData;

  final ConfigGeral geral;
  final Expedicao expedicao;
  final Transferencia transferencia;

  @JsonKey(name: 'IdcEnderecoAvaria')
  final String idcEnderecoAvariaStr;
  int? get idcEnderecoAvaria =>
      idcEnderecoAvariaStr.isEmpty ? null : int.parse(idcEnderecoAvariaStr);
  final String enderecoAvaria;

  // HOJE, os parâmetros de Distribuição são iguais aos de Transferência...
  Transferencia get distribuicao => this.transferencia;

  static const int TIPO_IMPRESSAO_POR_APANHA = 1;
  static const int TIPO_IMPRESSAO_POR_LOTE = 2;

  factory InfoConfigSite.fromJson(Map<String, dynamic> json) => _$InfoConfigSiteFromJson(json);
}

@JsonResult()
class ConfigGeral {
  ConfigGeral(
    this.quantidadeCasasDecimais,
    this.usaSagaLight,
    this.numeroDigitoValidacaoVoz,
    this.usaVoz,
    this.exibeDicas,
  );

  final int quantidadeCasasDecimais;
  final bool usaSagaLight;
  final int numeroDigitoValidacaoVoz;
  final bool usaVoz;
  final bool exibeDicas;

  factory ConfigGeral.fromJson(Map<String, dynamic> json) => _$ConfigGeralFromJson(json);
}

@JsonResult()
class Expedicao {
  Expedicao(
    this.validaVeiculo,
    this.geraUMAAutomaticamente,
    this.validaBarrasMercadoriaNaEmbalagem,
    this.geraBoletimOcorrenciaEmbalagem,
  );

  final bool validaVeiculo;
  final bool geraUMAAutomaticamente;
  final bool validaBarrasMercadoriaNaEmbalagem;
  final bool geraBoletimOcorrenciaEmbalagem;

  factory Expedicao.fromJson(Map<String, dynamic> json) => _$ExpedicaoFromJson(json);
}

@JsonResult()
class Transferencia {
  Transferencia(this.pedeOrigemParaAbandonar);

  final bool pedeOrigemParaAbandonar;

  factory Transferencia.fromJson(Map<String, dynamic> json) => _$TransferenciaFromJson(json);
}

@JsonResult()
class InfoLogin {
  InfoLogin(
    this.idcUsuario,
    this.codigoUsuario,
    this.nomeUsuario,
    this.idcGrupoUsuario,
    this.codigoGrupoUsuario,
    this.nomeGrupoUsuario,
    this.idcSite,
    this.codigoSite,
    this.nomeSite,
    this.idcPosto,
    this.codigoPosto,
    this.nomePosto,
    this.idcEquipamento,
    this.codigoEquipamento,
    this.nomeEquipamento,
    this.configuracao,
  );

  final int idcUsuario;
  final String codigoUsuario;
  final String nomeUsuario;
  final int idcGrupoUsuario;
  final String codigoGrupoUsuario;
  final String nomeGrupoUsuario;
  final int idcSite;
  final String codigoSite;
  final String nomeSite;
  final int idcPosto;
  final String codigoPosto;
  final String nomePosto;
  final int? idcEquipamento;
  final String? codigoEquipamento;
  final String? nomeEquipamento;
  final Configuracao? configuracao;

  factory InfoLogin.fromJson(Map<String, dynamic> json) => _$InfoLoginFromJson(json);
}

@JsonResult()
class Configuracao {
  Configuracao(
    this.prefixoUMA,
    this.tamanhoUMA,
    this.validaTamMaxUMA,
    this.validaPrefixoNumUMA,
    this.insereCaractUnicaRec,
  );

  final String prefixoUMA;
  final int tamanhoUMA;
  final bool validaTamMaxUMA;
  final bool validaPrefixoNumUMA;
  final bool insereCaractUnicaRec;

  factory Configuracao.fromJson(Map<String, dynamic> json) => _$ConfiguracaoFromJson(json);
}
