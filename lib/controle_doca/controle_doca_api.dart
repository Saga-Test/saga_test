import '../main/app.dart';
import '../saga_lib/sa_api.dart';
import '../saga_lib/sa_json.dart';

part 'controle_doca_api.g.dart';

class ControleDocaApi extends SAApi {
  ControleDocaApi(this.operador);

  final Operador operador;

  Future<List<InfoDoca>> getDocas() async {
    final list = await getList(
      '/api/ControleDoca/ListarDocas',
      {
        "IdcSite": App.idcSite,
      },
      (json) => InfoDoca.fromJson(json),
    );
    return list;
  }

  Future<InfoDoca> findDoca(String doca) async {
    final list = await getDocas();
    final result = list.where((el) => el.nomLoc.startsWith(doca));

    if (result.isEmpty) throw Exception('Doca inválida');

    if (result.length > 1) throw Exception('Há muitas docas com esse prefixo');

    return result.first;
  }

  Future<List<InfoVeiculo>> getVeiculos(
    int idcProcesso,
    int idcEndBox,
    int listIdcPatio,
  ) async {
    final list = await getList<InfoVeiculo>(
      '/api/ControleDoca/ListarVeiculosDoca',
      {
        'IdcSite': App.idcSite,
        'IdcPrc': idcProcesso,
        'IdcEndBox': idcEndBox,
        'LstIdcPatios': listIdcPatio,
      },
      (json) => InfoVeiculo.fromJson(json),
    );
    return list;
  }

  Future<bool> confirmaChegadaVeiculoDoca(int idcMov) async {
    final result = await post(
      '/api/ControleDoca/ConfirmaChegadaVeiculoDoca',
      {
        "IdcMov": idcMov,
        "StsMovPrt": 3,
      },
    );
    return result;
  }
}

@JsonResult()
class InfoDoca {
  InfoDoca(
    this.idcLoc,
    this.nomLoc,
  );

  final int idcLoc;
  final String nomLoc;

  factory InfoDoca.fromJson(Map<String, dynamic> json) =>
      _$InfoDocaFromJson(json);
}

@JsonResult()
class InfoVeiculo {
  InfoVeiculo(
    this.idcMov,
    this.idcVec,
    this.idcPss,
    this.idcStsMovPrt,
    this.stsMovPrt,
    this.nomMot,
    this.codPlaVec,
    this.datHorIni,
  );

  final int idcMov;
  final int idcVec;
  final int idcPss;
  final int idcStsMovPrt;
  final String? stsMovPrt;
  final String nomMot;
  final String codPlaVec;
  final DateTime datHorIni;

  factory InfoVeiculo.fromJson(Map<String, dynamic> json) =>
      _$InfoVeiculoFromJson(json);
}
