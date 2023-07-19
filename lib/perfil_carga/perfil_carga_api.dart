// ignore_for_file: public_member_api_docs, sort_constructors_first
import '../main/app.dart';
import '../saga_lib/sa_api.dart';
import '../saga_lib/sa_json.dart';

part 'perfil_carga_api.g.dart';

class PerfilCargaApi extends SAApi {
  PerfilCargaApi(this.operador);

  final Operador operador;

  Future<List<InfoPerfilCarga>> listarPerfilCarga(String idcLot) async {
    final list = await getList<InfoPerfilCarga>(
      '/api/PerfilCarga/ListarPerfilCarga',
      {
        'idcLot': idcLot,
      },
      (json) => InfoPerfilCarga.fromJson(json),
    );
    return list;
  }
}

@JsonResult()
class InfoPerfilCarga {
  InfoPerfilCarga(
    this.idcLot,
    this.strBox,
    this.nomCarLgt,
    this.movExp,
    this.picking,
    this.codPlaVec,
    this.nomPss,
  );

  final String idcLot;
  final String strBox;
  final String? nomCarLgt;
  final String movExp;
  final String picking;
  final String? codPlaVec;
  final String? nomPss;

  factory InfoPerfilCarga.fromJson(Map<String, dynamic> json) =>
      _$InfoPerfilCargaFromJson(json);
}
