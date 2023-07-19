import './ai.dart';
import './barcode_api.dart';
import './barcode_result.dart';
import './parser.dart';

class ParserEAN128 extends Parser {
  ParserEAN128(this.formato, this.listAIs);

  final InfoFormatoEAN formato;
  final List<AI> listAIs;

  @override
  Future<BarcodeResult> execute(String buffer) async {
    mapValues.clear();

    parseCode128(buffer);

    return BarcodeResult(
      formato.idcFmtEan,
      formato.nomFmtEan,
      buffer,
      mapValues,
      BarcodeType.code128,
    );
  }

  void checkMatches(List<RegExpMatch> matches) {
    var input = matches.first.input;
    for (final match in matches) {
      input = input.replaceRange(match.start, match.end, '.' * (match.end - match.start));
    }
    if (input != '.' * input.length) {
      throw ParserException('EAN não foi totalmente lido pelo formato. Faltou:\n $input');
    }
  }

  void parseCode128(String buffer) {
    // exemplo: \(02\)([^()\s\x1D]{1,10})

    final comParentesis = buffer.contains('(');
    final pattern = listAIs.map((ai) {
      final id = ai.id;
      final value = '[^()\\s\\x1D]{1,${ai.maxLength}}';
      return comParentesis ? '(\\(($id)\\)($value))' : '(($id)($value))';
    }).join('|');

    final regex = RegExp(pattern);
    final matches = regex.allMatches(buffer).toList();

    if (matches.length != listAIs.length) {
      throw ParserException(
        'FORMATO INVÁLIDO: AIs= ${listAIs.length}  matches= ${matches.length}',
      );
    }

    /*
      devido a PETRONAS ter barras de endereço IDENTIFICADAS pelo scanner como Code128,
      ex: ta]C001.01.027.001.05.01te (só coloquei os pontos para facilitar a leitura)
          AI= 01 value= 010270010501
      mas sem o AI - ou seja: é uma barra comum com o desenho de Code128 -
      estamos CONSIDERANDO COMO BARRA COMUM:
          se TEM UM ÚNICO AI e NÃO TEM o char(29)!!!
    */
    if (matches.length == 1 && !buffer.contains('\u001D')) {
      throw ParserException('Código de barras é FALSO Code 128');
    }

    checkMatches(matches);

    for (final match in matches) {
      final groups = <String>[];
      for (var i = 1; i <= match.groupCount; i++) {
        final value = match.group(i);
        if (value != null) groups.add(value);
      }

      final id = groups[1];
      final value = groups[2];

      final ai = listAIs.firstWhere((ai) => ai.id == id);
      mapValues[ai.fieldName] = formatValue(ai, value);
    }
  }
}
