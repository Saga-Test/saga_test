import 'package:flutter/material.dart';
import '../saga_lib/sa_error.dart';

import '../main/app.dart';
import '../utils/dialogs.dart';
import '../workflow/work_page.dart';

import 'distribuicao_api.dart';
export 'distribuicao_api.dart';

/// ---
/// DISTRIBUIÇÃO
/// ---
/// 1. Pede UMA origem;
/// 2. Escolhe 1 ou vários estoques da UMA;
/// 3. Se escolheu apenas um estoque, pede quantidade;
///     - se escolheu mais de um estoque, vai distribuir eles completos;
/// 4. Pede UMA de destino. Pode criar uma nova;
///     - UMA destino NÃO pode ser a mesma da ORIGEM;
/// 5. Se destino for UMA nova, pede dispositivo;
/// 6. Se UMA origem ESTIVER bloqueada, pergunta se quer levar os bloqueios para o destino;
///     - se UMA origem NÃO ESTIVER bloqueada, pode escolher um motivo para bloquear;
///     - para mexer com bloqueio tem que ter PERMISSÃO;
///     - se não tiver permissão, pede um usuário que tenha;
/// 7. Se for uma NOVA UMA, pedir o endereço dela;
/// 8. Efetuar a transferência;
///     - retornar para UMA origem.
///     - se ela não tiver mais estoques, pede nova UMA origem;
///
enum Etapa {
  pedeUMAOrigem,
  exibeEnderecos,
  escolheEstoques, // pode escolher 1 ou vários estoques...
  pedeQuantidade, // se escolheu UM ÚNICO estoque...
  pedeUMADestino,
  pedeDispositivo, // se DESTINO for nova UMA (permite bloquear ela)...
  bloqueiaUMADestino, // se origem está bloqueada ou se for uma nova UMA...
  pedeEnderecoUMA, // se DESTINO for nova UMA (permite bloquear ela)...
  finaliza, // retorna para escolheEstoques - se estoques acabaram, pedeUMAOrigem....
}

class Distribuicao {
  Distribuicao(Operador operador) {
    api = DistribuicaoAPI(operador);
  }

  // valores REPETIDOS entre operações...
  static String lastDispositivo = '';

  late DistribuicaoAPI api;

  // UMA de origem...
  late InfoUMA umaOrigem;
  double quantidade = 0; // quantidade, se for apenas 1 estoque...

  // UMA de destino existe...
  InfoUMA? umaDestino;
  // nova UMA de destino...
  String codigoUMADestino = '';
  InfoDispositivo? infoDispositivo;
  String enderecoDestino = '';

  // informações sobre a UMA de destino (ela pode não existir)...
  bool get novaUMA => umaDestino == null;
  bool get podeSerBloqueada => novaUMA || umaOrigem.bloqueios.isNotEmpty;
  String get destinoToShow {
    return umaDestino == null
        ? infoDispositivo == null
            ? codigoUMADestino
            : '$codigoUMADestino (${infoDispositivo!.nome})'
        : '${umaDestino!.codigo} (${umaDestino!.dispositivo.nome})';
  }

  // bloqueios...
  bool mantemBloqueios = false;
  InfoMotivoBloqueio? novoBloqueio;
  String get bloqueioToShow =>
      mantemBloqueios ? 'SIM (os mesmos da origem)' : novoBloqueio?.descricao ?? 'NÃO';

  // endereço de destino da UMA...
  ConfirmaDestinoDTO? confirmaDestino;

  // exibição de endereços
  bool inverterOrdenacao = false;
  Map<String, List<InfoEndereco>> enderecosMercadorias = {};
  String enderecoSelecionado = '';

  Future<void> informaUMAOrigem(TextEditingController input) async {
    final codigoUMA = checkInputValue(input);
    umaOrigem = await api.confirmaUMAOrigem(codigoUMA);
  }

  Future<void> informaQuantidade(TextEditingController input, InfoEstoque unicoEstoque) async {
    quantidade = checkInputValue(input, type: InputType.double);

    if (quantidade > unicoEstoque.quantidade) {
      throw Exception('Quantidade maior que o estoque');
    }
  }

  List<InfoEstoque> estoquesVaiDistribuir(List<InfoEstoque> estoques) {
    // se for distribuir um único estoque, limita a quantidade...
    final result = estoques.length == 1
        ? [estoques.single.copyWith(quantidade: quantidade.toDouble())]
        : estoques;

    return result;
  }

  Future<void> informaUMADestino(
      TextEditingController input, List<InfoEstoque> estoques) async {
    final codigoUMA = checkInputValue(input);
    final vaiDistribuir = estoquesVaiDistribuir(estoques);

    umaDestino = await api.confirmaUMADestino(codigoUMA, vaiDistribuir);
    codigoUMADestino = codigoUMA;
  }

  Future<String> geraCodigoUMA(String prefix) async {
    final codigo = await api.geraCodigoUMA(prefix);
    return codigo;
  }

  Future<void> informaDispositivo(TextEditingController input) async {
    final codigo = checkInputValue(input);
    infoDispositivo = await api.findDispositivo(codigo: codigo);

    lastDispositivo = infoDispositivo!.codigo;
  }

  Future<void> informaBloqueio({bool mantemOrigem = false, InfoMotivoBloqueio? novo}) async {
    mantemBloqueios = mantemOrigem;
    novoBloqueio = novo;
  }

  Future<bool> operadorPodeBloquear(int idcMotivo) async =>
      await api.operadorPodeBloquear(idcMotivo);

  Future<bool> usuarioPodeBloquear(String usuario, String senha, int idcMotivo) async =>
      await api.usuarioPodeBloquear(usuario, senha, idcMotivo);

  Future<void> informaDestino(TextEditingController input, List<InfoEstoque> estoques) async {
    enderecoDestino = input.text;
    final vaiDistribuir = estoquesVaiDistribuir(estoques);

    confirmaDestino = await api.confirmaEnderecoDestino(
      enderecoDestino,
      vaiDistribuir,
      umaDestino?.idc,
      infoDispositivo?.idc,
      novoBloqueio?.idc,
    );
  }

  Future<void> executa(List<InfoEstoque> estoques) async {
    final vaiDistribuir = estoquesVaiDistribuir(estoques);

    await api.executaDistribuicao(
      umaOrigem.codigo,
      umaDestino?.codigo ?? codigoUMADestino,
      vaiDistribuir,
      infoDispositivo?.idc,
      novoBloqueio?.idc,
      mantemBloqueios,
      confirmaDestino?.endereco.idc,
    );
  }

  Future<void> cancela(BuildContext context, {bool pedeConfirmacao = false}) async {
    // se deve pedir confirmação para abandonar a Distribuição...
    if (pedeConfirmacao) {
      if (App.site.distribuicao.pedeOrigemParaAbandonar) {
        final confirma = await confirmaEnderecoDeOrigem(context, umaOrigem.endereco);
        if (!confirma) {
          abort();
          return; // acho que não precisa, porque abort() SEMPRE gera exception!!!
        }
      }
    }

    await api.liberaUMA(umaOrigem.idc);
  }

  Future<void> buscaEnderecos() async {
    for (var item in umaOrigem.estoquesOrdenadosPorApanha) {
      final list = await api.getEnderecosDaMercadoria(item);

      if (inverterOrdenacao) {
        final lastIndex = list.length - 1;

        enderecosMercadorias.addAll({
          item.embalagem.mercadoria.nome: list.sublist(
            list.length <= 3 ? 0 : lastIndex - 2,
            list.length,
          )
        });
      } else {
        enderecosMercadorias.addAll({
          item.embalagem.mercadoria.nome: list.sublist(
            0,
            list.length >= 3 ? 3 : list.length,
          )
        });
      }
    }
  }
}
