import './ai.dart';

enum BarcodeType {
  barraComum,
  code128,
  rgu,
  barraComposta,
}

//---------------------------------------------------------------------------------------------
// BarcodeResult
//---------------------------------------------------------------------------------------------
class BarcodeResult {
  BarcodeResult(
    this.idcFormato,
    this.nomeFormato,
    this.barcode,
    this.mapValues,
    this.barcodeType,
  );

  final int idcFormato;
  final String nomeFormato;
  final String barcode;
  final Map<String, String> mapValues;
  final BarcodeType barcodeType;

  bool hasField(AIField field) => mapValues.containsKey(field.name);
  String getValue(AIField field) => mapValues[field.name] ?? '';

  bool get isBarraComum => barcodeType == BarcodeType.barraComum;
  bool get isNotBarraComum => !isBarraComum;

  @override
  String toString() {
    final sb = StringBuffer('$idcFormato- $nomeFormato\n');
    sb.write('$barcodeType\n');

    if (barcodeType == BarcodeType.barraComum) {
      sb.write(barcode);
    } else {
      mapValues.forEach((key, value) => sb.write('$key= $value\n'));
    }

    return sb.toString();
  }
}
