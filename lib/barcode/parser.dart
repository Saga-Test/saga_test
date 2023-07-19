import './ai.dart';
import './barcode_result.dart';
import './barcode_utils.dart';

//---------------------------------------------------------------------------------------------
// Parser
//---------------------------------------------------------------------------------------------
abstract class Parser {
  final Map<String, String> mapValues = {};

  Future<BarcodeResult> execute(String buffer);

  String formatValue(AI ai, String value) {
    switch (ai.field) {
      case AIField.valembsku:
        return int.parse(value).toString();
      case AIField.qtd:
        return formatNumeric(value.toDecimal(ai.format));
      case AIField.qtdidtpri:
      case AIField.qtdidtsec:
        return formatNumeric(value.toDecimal(ai.format));
      case AIField.datfab:
        return value.toDate(ai.format, 1).toDDMMYY();
      case AIField.datval:
        return value.toDate(ai.format, 31).toDDMMYY();
      default:
        return value;
    }
  }
}

class ParserException implements Exception {
  ParserException(this.message);

  final String message;

  @override
  String toString() => 'ParserException: $message';
}
