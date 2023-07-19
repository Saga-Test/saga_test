import '../saga_lib/sa_api.dart';
import '../saga_lib/sa_json.dart';

part 'barcode_api.g.dart';

//---------------------------------------------------------------------------------------------
// BarcodeAPI
//---------------------------------------------------------------------------------------------
class BarcodeAPI extends SAApi {
  Future<List<InfoFormatoEAN>> getFormatosEAN(int idcSite) async {
    final list = await getList(
      '/api/Barcode/ListarFormatosEAN',
      {
        'idcste': idcSite,
        'idcprc': 13,
        'idclot': null,
        'idcend': null,
        'idcuma': null,
      },
      (json) => InfoFormatoEAN.fromJson(json),
    );
    return list;
  }

  Future<List<InfoCampoEAN>> getCamposEAN(int idcSite, int idcFmtEan) async {
    final list = await getList(
      '/api/Barcode/ListarCamposEAN',
      {'idcsite': idcSite, 'idcfmtean': idcFmtEan},
      (json) => InfoCampoEAN.fromJson(json),
    );
    return list;
  }

  Future<InfoTabelaRGU?> getTabelaRGU(String codigoRGU) async {
    final result = await get(
      '/api/Barcode/ListarTabelaRGU',
      {'codigoRGU': codigoRGU},
      (json) => InfoTabelaRGU.fromJson(json),
    );
    return result;
  }

  Future<String> getMascaraRGU() async {
    final result = await getString('/api/Barcode/ListarMascaraRGU', {});
    return result;
  }

  Future<List<ParametrosAtividade>> getParametrosAtividades() async {
    final list = await getList(
      '/api/Barcode/ListarParametrosAtividades',
      {},
      (json) => ParametrosAtividade.fromJson(json),
    );
    return list;
  }
}

@JsonResult()
class InfoFormatoEAN {
  InfoFormatoEAN(this.idcFmtEan, this.nomFmtEan, this.lstAim);

  final int idcFmtEan;
  final String nomFmtEan;
  final String? lstAim;

  String get nomeID => '$idcFmtEan - $nomFmtEan';

  factory InfoFormatoEAN.fromJson(Map<String, dynamic> json) => _$InfoFormatoEANFromJson(json);
}

@JsonResult()
class InfoCampoEAN {
  InfoCampoEAN(
    this.codAplEan,
    this.nomBrrBar,
    this.tamMax,
    this.nroSeq,
    this.idcFmtEan,
    this.idcTipCarMer,
    this.fmtVarEan,
    this.nroSeqBarCmp,
  );

  final String codAplEan;
  final String nomBrrBar;
  final int tamMax;
  final int? nroSeq;
  final int idcFmtEan;
  final int? idcTipCarMer;
  final int? nroSeqBarCmp;
  final String fmtVarEan;

  factory InfoCampoEAN.fromJson(Map<String, dynamic> json) => _$InfoCampoEANFromJson(json);
}

@JsonResult()
class InfoTabelaRGU {
  InfoTabelaRGU(
    this.codIdt,
    this.codBrr,
    this.datVal,
    this.fmtVarEanDatVal,
    this.codMer,
    this.idcTipCarMer,
    this.valCarMer,
  );

  final String codIdt;
  final String codBrr;
  final String datVal;
  final String fmtVarEanDatVal;
  final String codMer;
  final int idcTipCarMer;
  final String valCarMer;

  factory InfoTabelaRGU.fromJson(Map<String, dynamic> json) => _$InfoTabelaRGUFromJson(json);
}

@JsonResult()
class ParametrosAtividade {
  ParametrosAtividade(
    this.idcAtividade,
    this.nome,
    this.nomeAbreviado,
    this.permiteDigitarEndereco,
    this.permiteDigitarUMA,
    this.permiteDigitarMercadoria,
  );

  final int idcAtividade;
  final String nome;
  final String nomeAbreviado;
  final bool permiteDigitarEndereco;
  final bool permiteDigitarUMA;
  final bool permiteDigitarMercadoria;

  factory ParametrosAtividade.fromJson(Map<String, dynamic> json) =>
      _$ParametrosAtividadeFromJson(json);
}
