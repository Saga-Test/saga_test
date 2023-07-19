import 'package:flutter/foundation.dart';

import './barcode_api.dart';

import './ai.dart';
import './barcode_result.dart';
import './parser.dart';
import './parser_ean128.dart';
import './parser_barra_composta.dart';
import './parser_rgu.dart';

//---------------------------------------------------------------------------------------------
// BarcodeManager
//---------------------------------------------------------------------------------------------
class BarcodeManager {
  BarcodeManager._(this.idcSite);

  static late BarcodeManager instance;

  static Future<void> init(int idcSite) async {
    instance = BarcodeManager._(idcSite);
    await instance._loadFormatos();

    // permite digitar ou obriga usar coletor na atividade...
    await instance._loadPermissoes();
  }

  static Future<void> initForTests(int idcSite, List<FormatoEAN> formatos) async {
    instance = BarcodeManager._(idcSite);
    instance.formatosEAN.addAll(formatos);
    // não tem RGU...
  }

  final int idcSite;
  final List<FormatoEAN> formatosEAN = [];
  ParserRGU? parserRGU;

  final Map<int, ParametrosAtividade> permissoesAtividades = {};

  Future<void> _loadFormatos() async {
    final api = BarcodeAPI();
    try {
      final listaInfoEAN = await api.getFormatosEAN(idcSite);
      for (final infoEAN in listaInfoEAN) {
        final camposEAN = await api.getCamposEAN(idcSite, infoEAN.idcFmtEan);

        formatosEAN.add(FormatoEAN(infoEAN, camposEAN));
      }

      // site tem RGU???
      final mascaraRGU = await api.getMascaraRGU();
      if (mascaraRGU.isNotEmpty) {
        parserRGU = ParserRGU(mascaraRGU, (codigoRGU) => api.getTabelaRGU(codigoRGU));
      }
    } catch (ex) {
      debugPrint('Erro na criação do Barcode: $ex');
      rethrow;
    }
  }

  Future<void> _loadPermissoes() async {
    final api = BarcodeAPI();
    final lista = await api.getParametrosAtividades();

    permissoesAtividades.addAll({
      for (final item in lista) item.idcAtividade: item,
    });
  }

  Future<BarcodeResult> parse(String bufferWithAIM) async {
    var aim = '';
    var buffer = bufferWithAIM;

    // obtém prefixo identificador do barcode e o buffer sem o prefixo...
    if (buffer.startsWith(']')) {
      aim = bufferWithAIM.substring(0, 3);
      buffer = bufferWithAIM.substring(3);
    }

    for (final formato in formatosEAN) {
      try {
        debugPrint('\nTentando o formato: ${formato.formatoEAN.nomFmtEan}');

        BarcodeResult result;
        Parser parser;

        // decide qual o parser...
        if (formato.listGS1.contains(aim)) {
          parser = formato.parserEAN128;
        } else {
          if (parserRGU != null && parserRGU!.isRGU(buffer)) {
            parser = parserRGU!;
          } else {
            parser = formato.parserBarraComposta;
          }
        }

        try {
          // tenta parsear...
          result = await parser.execute(buffer);
        } catch (ex) {
          // 11.04.2022: ']C0' em barcode da 3 Corações???
          if (aim != ']C0') rethrow;

          // etiqueta da 3 Corações com prefixo EAN, mas é barra composta!!!
          parser = formato.parserBarraComposta3C;
          result = await parser.execute(buffer);
        }

        // print no resultado (para depurar)...
        debugPrint('resultado:\n$result');

        // lógica de LRU - usado mais recente para a ser o 1o da lista...
        formatosEAN.remove(formato);
        formatosEAN.insert(0, formato);

        return result;
      } catch (ex) {
        debugPrint('formato inválido: $ex');
        // vai tentar um próximo formatoEAN...
        continue;
      }
    }

    // se chegou até aqui, retorna o buffer lido como barra comum...
    return BarcodeResult(0, 'Barra Comum', buffer, {}, BarcodeType.barraComum);
  }
}

class FormatoEAN {
  FormatoEAN(this.formatoEAN, this.camposEAN) {
    listAIs = AI.getListAIs(camposEAN);

    final listAIM = formatoEAN.lstAim ?? '';
    listGS1 =
        listAIM.isEmpty ? [']C0', ']C1', ']e0', ']d2', ']Q1', ']Q3'] : listAIM.split(';');

    parserEAN128 = ParserEAN128(formatoEAN, listAIs);
    parserBarraComposta = ParserBarraComposta(formatoEAN, listAIs, checkTamanho: true);
    parserBarraComposta3C = ParserBarraComposta(formatoEAN, listAIs, checkTamanho: false);
  }

  InfoFormatoEAN formatoEAN;
  List<InfoCampoEAN> camposEAN;

  late List<AI> listAIs;
  late List<String> listGS1;

  late ParserEAN128 parserEAN128;
  late ParserBarraComposta parserBarraComposta;
  late ParserBarraComposta parserBarraComposta3C;
}
