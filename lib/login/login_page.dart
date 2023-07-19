import 'package:flutter/material.dart';
import 'package:saga_test/home/home_page.dart';
import 'package:saga_test/informativo/informativo_dialog.dart';
import 'package:saga_test/login/login_api.dart';
import 'package:saga_test/login/login_dialogs.dart';
import 'package:saga_test/login/parametros.dart';
import 'package:saga_test/saga_lib/sa_page_card.dart';
import 'package:saga_test/saga_lib/sa_page.dart';

import '../main/app.dart';
import '../saga_lib/sa_button.dart';
import '../saga_lib/sa_input.dart';
import 'login.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  void initState() {
    _loadDadosLogin();

    exec = Login();
    dialogs = LoginDialogs(context);

    super.initState();
  }

  @override
  void dispose() {
    usuario.dispose();
    senha.dispose();
    nomeSite.dispose();
    posto.dispose();
    equipamento.dispose();

    super.dispose();
  }

  late Login exec;
  late LoginDialogs dialogs;

  final usuario = TextEditingController();
  final senha = TextEditingController();
  final nomeSite = TextEditingController();
  final posto = TextEditingController();
  final equipamento = TextEditingController();
  var codigoSite = '';

  void _loadDadosLogin() {
    //carrega os dados de login do SharedPreferences
    Parametros.load().then((_) async {
      usuario.text = Parametros.usuario;
      codigoSite = Parametros.site;
      posto.text = Parametros.posto;
      equipamento.text = Parametros.equipamento;

      try {
        LoginAPI().getSites().then((sites) {
          final site = sites.where((site) => site.codigo == codigoSite);

          if (site.isNotEmpty) {
            nomeSite.text = site.first.nome;
          }

          setState(() {});
        });
      } catch (ex) {
        await informativoDialog(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SaPage(
      title: "Login",
      children: [
        SaPageCard(
          child: Center(
            child: SizedBox(
              width: 400,
              child: ListView(
                shrinkWrap: true,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Image.asset(
                      "assets/logo.png",
                      color: Colors.black87,
                      width: 400,
                    ),
                  ),
                  const SizedBox(height: 48),
                  SaInput(
                    "Usuario",
                    usuario,
                  ),
                  SaInput(
                    "Senha",
                    senha,
                    isSecret: true,
                    autofocus: true,
                  ),
                  const SizedBox(height: 24),
                  SaInput(
                    "Site",
                    nomeSite,
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.arrow_drop_down),
                      onPressed: () async {
                        try {
                          final result = await dialogs.escolheSite();

                          if (result == null) return;

                          codigoSite = result.codigo;
                          nomeSite.text = result.nome;
                        } catch (_) {
                          await informativoDialog(context);
                        }
                      },
                    ),
                  ),
                  SaInput(
                    "Posto",
                    posto,
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.arrow_drop_down),
                      onPressed: () async {
                        try {
                          final result = await dialogs.escolhePosto(
                            codigoSite,
                            usuario.text,
                          );

                          if (result == null) return;

                          posto.text = result.codigo;
                        } catch (_) {
                          informativoDialog(context);
                        }
                      },
                    ),
                  ),
                  SaInput(
                    "Equipamento",
                    equipamento,
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.arrow_drop_down),
                      onPressed: () async {
                        try {
                          final result = await dialogs.escolheEquipamento(
                            codigoSite,
                            usuario.text,
                          );

                          if (result == null) return;

                          equipamento.text = result.codigo;
                        } catch (_) {
                          informativoDialog(context);
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 4),
                  SaButton(
                    label: "Entrar",
                    onPressed: () async {
                      try {
                        await exec.execute(
                          usuario.text,
                          senha.text,
                          codigoSite,
                          posto.text,
                          equipamento.text,
                        );

                        if (context.mounted) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => HomePage(operador: App.operador),
                            ),
                          );
                        }
                      } catch (_) {
                        informativoDialog(context);
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
