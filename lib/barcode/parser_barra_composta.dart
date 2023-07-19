import './ai.dart';
import './barcode_api.dart';
import './barcode_result.dart';
import './parser.dart';

class ParserBarraComposta extends Parser {
  ParserBarraComposta(this.formato, this.listAIs, {required this.checkTamanho});

  final InfoFormatoEAN formato;
  final List<AI> listAIs;
  final bool checkTamanho;

  @override
  Future<BarcodeResult> execute(String buffer) async {
    // AIs que fazem parte da barra composta...
    final barraAIs = listAIs.where((it) => it.numSeqBarraComposta != null).toList();
    if (barraAIs.isEmpty) {
      throw ParserException('Formato não é de barra composta');
    }

    // se o tamanho não é o mesmo da barra composta...
    if (checkTamanho) {
      final barraLength = barraAIs.fold(0, (sum, it) => sum + it.maxLength);

      if (buffer.length != barraLength) {
        throw ParserException('Código de barras lido tem tamanho (${buffer.length}) '
            'diferente da barra composta ($barraLength)');
      }
    }

    // ordena os AIs...
    barraAIs.sort((a, b) => a.numSeqBarraComposta!.compareTo(b.numSeqBarraComposta!));
    mapValues.clear();

    var index = 0;
    for (final ai in barraAIs) {
      final value = buffer.substring(index, index + ai.maxLength);
      index += ai.maxLength;

      mapValues[ai.fieldName] = formatValue(ai, value);
    }

    return BarcodeResult(
      formato.idcFmtEan,
      formato.nomFmtEan,
      buffer,
      mapValues,
      BarcodeType.barraComposta,
    );
  }
}
