import './barcode_api.dart';
import './ai.dart';
import './barcode_result.dart';
import './parser.dart';

import './barcode_utils.dart';

class ParserRGU extends Parser {
  ParserRGU(this.mascaraRGU, this.getTabelaRGU);

  final String mascaraRGU;
  final Future<InfoTabelaRGU?> Function(String) getTabelaRGU;

  bool isRGU(String buffer) => mascaraRGU.isNotEmpty && buffer.startsWith(mascaraRGU);

  @override
  Future<BarcodeResult> execute(String buffer) async {
    mapValues.clear();

    final codigoRGU = buffer.substring(mascaraRGU.length);

    final rgu = await getTabelaRGU(codigoRGU);
    if (rgu == null) {
      throw ParserException('Não tem tabela RGU para "$codigoRGU"');
    }

    mapValues[AIField.codidt.name] = rgu.codIdt;
    mapValues[AIField.codbrr.name] = rgu.codBrr;
    mapValues[AIField.datval.name] = rgu.datVal.toDate(rgu.fmtVarEanDatVal, 31).toDDMMYY();
    mapValues[AIField.codmer.name] = rgu.codMer;
    mapValues[AIField.lotfab.name] = rgu.valCarMer;

    return BarcodeResult(0, 'Formato RGU', buffer, mapValues, BarcodeType.rgu);
  }
}
