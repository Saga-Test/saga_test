import 'package:shared_preferences/shared_preferences.dart';

import '../saga_lib/sa_api.dart';

class Parametros {
  static const int idTipoConvocacaoAndroid = 8;

  static String url = '';
  static String usuario = '';
  static String site = '';
  static String posto = '';
  static String equipamento = '';
  static bool usuarioUsaVoz = false;

  static Future<void> save() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    prefs.setString(urlServidor, url);
    prefs.setString(usuarioLogin, usuario);
    prefs.setString(siteLogin, site);
    prefs.setString(postoLogin, posto);
    prefs.setString(equipamentoLogin, equipamento);
    prefs.setBool(usaVoz, usuarioUsaVoz);

    // após carregar a configuração, configura a framework...
    _initFramework();
  }

  static Future<void> load() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    url = prefs.getString(urlServidor) ?? '';
    usuario = prefs.getString(usuarioLogin) ?? '';
    site = prefs.getString(siteLogin) ?? '';
    posto = prefs.getString(postoLogin) ?? '';
    equipamento = prefs.getString(equipamentoLogin) ?? '';
    usuarioUsaVoz = prefs.getBool(usaVoz) ?? false;

    // após carregar a configuração, configura a framework...
    _initFramework();
  }

  static void _initFramework() {
    if (url.isNotEmpty) {
      baseURLUser = url;
    }
  }

  static const String urlServidor = 'URL_SERVIDOR_CONFIG';
  static const String usuarioLogin = 'USUARIO_LOGIN';
  static const String siteLogin = 'SITE_LOGIN';
  static const String postoLogin = 'POSTO_LOGIN';

  static const String equipamentoLogin = 'EQUIPAMENTO_LOGIN';

  static const String usaVoz = 'USUARIO_USA_VOZ';
}
