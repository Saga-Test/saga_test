import 'package:flutter/material.dart';

import 'package:saga_test/login/login_api.dart';

import '../saga_lib/sa_dialogs.dart';

class LoginDialogs {
  LoginDialogs(this.context);

  final BuildContext context;

  Future<InfoSite?> escolheSite() async {
    final result = await showList<InfoSite>(
      context: context,
      title: 'Sites',
      loadList: () => LoginAPI().getSites(),
      showItem: (item) {
        return Column(children: [
          ListTile(
            title: Text('${item.codigo} - ${item.nome}'),
          ),
          const Divider(),
        ]);
      },
    );

    return result;
  }

  Future<InfoPosto?> escolhePosto(String codigoSite, String usuario) async {
    final result = await showList<InfoPosto>(
      context: context,
      title: 'Postos',
      loadList: () => LoginAPI().getPostos(codigoSite, usuario),
      showItem: (item) {
        return Column(children: [
          ListTile(
            title: Text('${item.codigo} - ${item.nome}'),
          ),
          const Divider(),
        ]);
      },
    );

    return result;
  }

  Future<InfoEquipamento?> escolheEquipamento(String codigoSite, String usuario) async {
    final result = await showList<InfoEquipamento>(
      context: context,
      title: 'Equipamentos',
      loadList: () => LoginAPI().getEquipamentos(codigoSite, usuario),
      showItem: (item) {
        return Column(children: [
          ListTile(
            title: Text('${item.codigo} - ${item.nome}'),
          ),
          const Divider(),
        ]);
      },
    );

    return result;
  }
}
