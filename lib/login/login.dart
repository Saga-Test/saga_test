import 'package:saga_test/login/parametros.dart';

import '../main/app.dart';
import '../saga_lib/sa_network.dart';
import 'login_api.dart';

class Login {
  Future<void> _saveDadosLogin(
    String usuario,
    String posto,
    String codigoSite,
    String equipamento,
  ) async {
    //salva os dados de login no SharedPreferences
    Parametros.usuario = usuario;
    Parametros.posto = posto;
    Parametros.site = codigoSite;
    Parametros.equipamento = equipamento;
    await Parametros.save();
  }

  Future<void> execute(
    String usuario,
    String senha,
    String codigoSite,
    String posto,
    String equipamento,
  ) async {
    final ip = await SANetwork.ip;

    await _saveDadosLogin(usuario, posto, codigoSite, equipamento);

    final infoLogin = await LoginAPI().login(
      usuario: usuario,
      senha: senha,
      site: codigoSite,
      posto: posto,
      equipamento: equipamento,
      ip: ip,
    );

    final infoSAGA = await LoginAPI().getInfoSAGA();
    final infoConfigSite = await LoginAPI().getConfigSite(infoLogin.idcSite);

    await App.start(infoSAGA, infoLogin, infoConfigSite);
  }
}
