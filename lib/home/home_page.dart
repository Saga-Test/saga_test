import 'package:flutter/material.dart';
import 'package:saga_test/associacao_rg/associacao_rg_page.dart';
import 'package:saga_test/controle_doca/controle_doca_page.dart';
import 'package:saga_test/convoca/convocacao_page.dart';
import 'package:saga_test/distribuicao/distribuicao_page.dart';
import 'package:saga_test/embalagem/embalagem_page.dart';

import 'package:saga_test/main/app.dart';
import 'package:saga_test/perfil_carga/perfil_carga_page.dart';
import 'package:saga_test/saga_lib/sa_page.dart';
import 'package:saga_test/saga_lib/sa_page_card.dart';
import 'package:saga_test/saga_lib/sa_widgets.dart';

class HomePage extends StatelessWidget {
  const HomePage({
    Key? key,
    required this.operador,
  }) : super(key: key);

  final Operador operador;

  @override
  Widget build(BuildContext context) {
    return SaPage(
      title: "Tela de Seleção",
      canBack: true,
      children: [
        SaPageCard(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ConvocacaoPage(App.operador),
                    ),
                  );
                },
                child: const Text("Convocação Ativa"),
              ),
              saSpace(2),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EmbalagemPage(App.operador),
                    ),
                  );
                },
                child: const Text("Embalagem"),
              ),
              saSpace(2),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AssociacaoPage(App.operador),
                    ),
                  );
                },
                child: const Text("Associação de RGU"),
              ),
              saSpace(2),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ControleDocaPage(App.operador),
                    ),
                  );
                },
                child: const Text("Controle de Doca"),
              ),
              saSpace(2),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DistribuicaoPage(App.operador),
                    ),
                  );
                },
                child: const Text("Distribuição"),
              ),
              saSpace(2),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PerfilCargaPage(App.operador),
                    ),
                  );
                },
                child: const Text("Perfil Carga"),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
