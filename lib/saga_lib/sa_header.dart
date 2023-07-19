// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:saga_test/informativo/informativo_dialog.dart';

import 'package:saga_test/login/login_page.dart';
import 'package:saga_test/saga_lib/sa_api.dart';
import 'package:saga_test/saga_lib/sa_button.dart';
import 'package:saga_test/saga_lib/sa_dialogs.dart';
import 'package:saga_test/saga_lib/sa_popup_menu.dart';
import 'package:saga_test/saga_lib/sa_input.dart';
import 'package:saga_test/saga_lib/sa_widgets.dart';

import '../login/login_api.dart';
import '../login/parametros.dart';
import '../main/app.dart';

class SaHeader extends StatelessWidget {
  const SaHeader({
    Key? key,
    required this.title,
    this.noIcons = false,
    this.canBack = false,
    this.showInfoLogin = false,
  }) : super(key: key);

  final String title;
  final bool noIcons;
  final bool canBack;
  final bool showInfoLogin;

  @override
  Widget build(BuildContext context) {
    final urlConexao = TextEditingController();

    Future<void> carregaUrl() async => urlConexao.text = baseURLUser;

    return Padding(
      padding: const EdgeInsets.fromLTRB(48.0, 4, 48, 4),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              child: Row(
                children: [
                  if (canBack) ...[
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0, right: 12.0),
                      child: InkWell(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(
                          Icons.arrow_back,
                        ),
                      ),
                    ),
                  ],
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 24,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (!noIcons) ...[
            if (showInfoLogin) ...[
              SaPopupMenu(
                title: "Dados Login",
                height: 250,
                content: [
                  SaField("Usuário", App.nomeUsuario),
                  SaField("Site", App.nomeSite),
                  SaField("Posto", App.nomePosto),
                  SaField("Equipamento", App.nomeEquipamento),
                  Container(
                    alignment: Alignment.bottomRight,
                    child: IconButton(
                      onPressed: () async {
                        final result = await showList<InfoMotivoLogout>(
                          context: context,
                          title: 'Equipamentos',
                          loadList: () => LoginAPI().getMotivosLogout(App.idcGrupoUsuario),
                          showItem: (item) {
                            return Column(children: [
                              ListTile(
                                title: Text(item.nome),
                              ),
                              const Divider(),
                            ]);
                          },
                        );

                        if (result == null) return;

                        await LoginAPI().logout(
                          App.idcSite,
                          App.idcUsuario,
                          result.idc,
                        );

                        if (context.mounted) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LoginPage(),
                            ),
                          );
                        }
                      },
                      icon: const Icon(Icons.logout_rounded),
                    ),
                  )
                ],
                child: SizedBox(
                  key: GlobalKey(),
                  height: 48,
                  width: 48,
                  child: const Icon(Icons.person_rounded),
                ),
              ),
            ],
            SaPopupMenu(
              title: "Configurações de API",
              height: 230,
              initStateFunction: () async => await carregaUrl(),
              content: [
                const SizedBox(height: 8),
                SaInput(
                  "API",
                  urlConexao,
                  autofocus: true,
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SaButton(
                      label: "Alterar",
                      onPressed: () async {
                        try {
                          final url = urlConexao.text;

                          await SAApi(
                            baseURL: url,
                            connectTimeout: const Duration(seconds: 5),
                            receiveTimeout: const Duration(seconds: 5),
                          ).get(
                            '/api/mobile/GetVersoes',
                            {},
                            null,
                            descricao: "Lista as versões",
                          );

                          baseURLUser = url;
                          Parametros.url = url;
                          Parametros.save();

                          await Future.delayed(const Duration(seconds: 1));

                          if (context.mounted) Navigator.pop(context);
                        } catch (_) {
                          informativoDialog(context);
                        }
                      },
                    ),
                  ],
                ),
              ],
              child: SizedBox(
                key: GlobalKey(),
                child: const Icon(Icons.wifi_find_rounded),
              ),
            ),
          ]
        ],
      ),
    );
  }
}
