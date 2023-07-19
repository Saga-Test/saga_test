import 'dart:async';

import 'package:flutter/material.dart';

import '../login/parametros.dart';
import 'convocacao.dart';
import 'convocacao_api.dart';

///
/// Status do Usuário
///
enum StatusUsuario {
  naoUsado,
  livre,
  ocupado,
  recusandoServico,
}

class ConvocacaoExecutor {
  ConvocacaoExecutor(this.context, this.api);

  BuildContext context;
  late ConvocacaoApi api;
  late Timer timer;

  ValueNotifier<int> contadorController = ValueNotifier(1);
  ValueNotifier<Convocacao?> convController = ValueNotifier(null);

  Convocacao? conv;
  bool boolUsaVoz = Parametros.usuarioUsaVoz;
  bool timerisActive = false;
  bool timerWasActive = false;
  bool loading = false;

  Future<void> setStatus(int status) async {
    await tryExecute(() async {
      await api.atualizaSituacaoUsuario(status);
    });
  }

  Future<void> setStatusOcupado() async {
    await tryExecute(() async {
      await api.atualizaSituacaoUsuario(StatusUsuario.ocupado.index);
    });
  }

  Future<void> procuraExecucaoEmAndamento() async {
    conv = await api.buscaConvocacao(TipoConvocacao.emExecucao.index);

    if (conv != null) {
      loading = true;
    } else {
      timerWasActive = true;
      startConvocador();
    }
  }

  Future<void> startConvocador() async {
    if (timerisActive) return;
    timerisActive = true;

    conv = null;
    convController.value = conv;
    contadorController.value = 0;

    await setStatus(StatusUsuario.livre.index);

    timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      conv = await api.buscaConvocacao(TipoConvocacao.existente.index);

      contadorController.value++;

      if (conv != null) {
        convController.value = conv;
        esperaOperadorAceitar();
      }
    });
  }

  Future<void> esperaOperadorAceitar() async {
    await stopConvocador();

    timerisActive = true;
    if (conv != null && !timer.isActive) {
      timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
        if (timer.tick == 20) {
          await stopConvocador();
          startConvocador();
        }
      });
    }
  }

  Future<void> stopConvocador() async {
    if (timer.isActive) {
      timerisActive = false;
      contadorController.value++;
      do {
        timer.cancel();
      } while (timer.isActive);
    }
  }

  Future<void> setUsaVoz(bool usaVoz) async {
    boolUsaVoz = usaVoz;
    await stopConvocador();
    startConvocador();
  }

  Future<void> recusaConvocacao() async {
    await stopConvocador();

    await setStatus(StatusUsuario.recusandoServico.index);

    await tryExecute(() async {
      await api.recusaConvocacao();
    });

    startConvocador();
  }

  Future<void> aceitaConvocacao() async {
    loading = true;

    await stopConvocador();

    await tryExecute(() async {
      conv = await api.aceitaConvocacao(conv!.servicos.first.lote.idc);
    });
  }

  Future<void> tryExecute(Function callback) async {
    try {
      await callback();
    } catch (_) {}
  }
}
