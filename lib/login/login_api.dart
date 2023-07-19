import '../saga_lib/sa_api.dart';
import '../saga_lib/sa_json.dart';

import '../main/app.dart';
part 'login_api.g.dart';

class LoginAPI extends SAApi {
  Future<InfoLogin> login({
    required String usuario,
    required String senha,
    required String site,
    required String posto,
    required String equipamento,
    required String ip,
  }) async {
    final result = await post(
      '/api/mobile/login',
      {
        'codigoUsuario': usuario,
        'senhaUsuario': senha,
        'codigoSite': site,
        'codigoPosto': posto,
        'codigoEquipamento': equipamento,
        'enderecoColetor': ip,
        'tipoConvocacao': ID_TIPO_CONVOCACAO_ANDROID,
      },
      fromJson: (json) => InfoLogin.fromJson(json),
      descricao: "Método que realiza o Login do operador",
    );
    return result!;
  }

  Future<InfoLogin> trocarDePosto({
    required int idcUsuario,
    required int idcSite,
    required int idcPosto,
  }) async {
    final result = await post(
      '/api/mobile/trocarDePosto',
      {
        'idcUsuario': idcUsuario,
        'idcSite': idcSite,
        'idcPosto': idcPosto,
      },
      fromJson: (json) => InfoLogin.fromJson(json),
    );
    return result!;
  }

  Future<InfoSAGA> getInfoSAGA() async {
    final result = await get(
      '/api/configuracoes/listarParametrosGeral',
      {},
      (json) => InfoSAGA.fromJson(json),
      descricao: "Método chamado após o login para listar os parametros em geral",
    );
    return result!;
  }

  Future<InfoConfigSite> getConfigSite(int idcSite) async {
    final list = await getList(
      '/api/configuracoes/listarParametrosSite',
      {'idcSite': idcSite},
      (json) => InfoConfigSite.fromJson(json),
      descricao: "Método chamado após o login para listar os parametros do site",
    );

    final result = list.first;
    return result;
  }

  Future<void> logout(int idcSite, int idcUsuario, int idcMotivo) async {
    await post(
      '/api/mobile/logout',
      {'idcSite': idcSite, 'idcUsuario': idcUsuario, 'idcMotivo': idcMotivo},
      descricao: "Método para realizar o logout da conta",
    );
  }

  Future<List<InfoSite>> getSites() async {
    final list = await getList(
      '/api/site/listar',
      {},
      (json) => InfoSite.fromJson(json),
      descricao: "Método para listar os sites disponivéis",
    );
    return list;
  }

  Future<List<InfoPosto>> getPostos(String codigoSite, String codigoUsuario) async {
    final list = await getList(
        '/api/mobile/listarPostosUsuario',
        {'codigoSite': codigoSite, 'codigoUsuario': codigoUsuario},
        (json) => InfoPosto.fromJson(json),
        descricao: "Método para listar os postos disponivéis");
    return list;
  }

  Future<List<InfoEquipamento>> getEquipamentos(
      String codigoSite, String codigoUsuario) async {
    final list = await getList(
        '/api/mobile/listarEquipamentosUsuario',
        {'codigoSite': codigoSite, 'codigoUsuario': codigoUsuario},
        (json) => InfoEquipamento.fromJson(json),
        descricao: "Método para listar os equipamentos disponivéis");
    return list;
  }

  Future<List<InfoMotivoLogout>> getMotivosLogout(int idcGrupoUsuario) async {
    final list = await getList('/api/mobile/listarMotivosLogout',
        {'idcGrupoUsuario': idcGrupoUsuario}, (json) => InfoMotivoLogout.fromJson(json),
        descricao: "Método para listar os motivos de logout disponivéis");
    return list;
  }
}

const int ID_TIPO_CONVOCACAO_ANDROID = 8;

@JsonResult()
class InfoSite {
  InfoSite({required this.idc, required this.codigo, required this.nome});

  final int idc;
  final String codigo;
  final String nome;

  factory InfoSite.fromJson(Map<String, dynamic> json) => _$InfoSiteFromJson(json);
}

@JsonResult()
class InfoPosto {
  InfoPosto({
    required this.idc,
    required this.codigo,
    required this.nome,
    required this.quantideServicos,
  });

  final int idc;
  final String codigo;
  final String nome;
  final int quantideServicos;

  factory InfoPosto.fromJson(Map<String, dynamic> json) => _$InfoPostoFromJson(json);
}

@JsonResult()
class InfoEquipamento {
  InfoEquipamento({required this.idc, required this.codigo, required this.nome});

  final int idc;
  final String codigo;
  final String nome;

  factory InfoEquipamento.fromJson(Map<String, dynamic> json) =>
      _$InfoEquipamentoFromJson(json);
}

@JsonResult()
class InfoMotivoLogout {
  InfoMotivoLogout({required this.idc, required this.nome});

  final int idc;
  final String nome;

  factory InfoMotivoLogout.fromJson(Map<String, dynamic> json) =>
      _$InfoMotivoLogoutFromJson(json);
}
