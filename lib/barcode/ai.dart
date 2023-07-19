import './barcode_api.dart';

enum AIField {
  naoUsado, // 00= <não usado>
  coduma, // 01= Codigo da UMA
  codend, // 02= Mascara do Endereço
  codprp, // 03= Codigo do Proprietário
  codplavec, // 04= Codigo da Placa do Veículo
  codusr, // 05= Codigo do Usuário
  codste, // 06= Codigo do Site
  codeqp, // 07= Codigo do Equipamento
  codpst, // 08= Codigo do Posto
  coddsp, // 09= Codigo do Dispositivo
  codmtv, // 10= Codigo do Motivo
  codmer, // 11= Codigo da Mercadoria
  valembsku, // 12= Embalagem
  codbrr, // 13= Codigo de Barras do SKU
  qtd, // 14= Quantidade
  desmer, // 15= Descrição da Mercadoria
  datfab, // 16= Data de Fabricação
  datval, // 17= Data de Validade
  naoUsado18, // 18= <não usado>
  codidt, // 19= Tag/Item de Estoque
  qtdidtpri, // 20= Quantidade Primaria da Tag/Item de Estoque
  qtdidtsec, // 21= Quantidade Secundaria da Tag/Item de Estoque
  sscc, // 22= Código de série da unidade logística
  //
  // características...
  lotfab, // 23= lote de fabricação (idcTipCarMer = 0)...
  caracteristica, // 24= demais características...
}

//---------------------------------------------------------------------------------------------
// AI
//---------------------------------------------------------------------------------------------
class AI {
  AI(
    this.field,
    this.id,
    this.fieldName,
    this.maxLength,
    this.numSeq,
    this.idcCaracteristica,
    this.numSeqBarraComposta,
    this.format,
  );

  final AIField field; // field do barcode...
  final String id; // identificador do AI...
  final String fieldName; // nome do campo...
  final int maxLength; // tamanho máximo...
  final int? numSeq; // número sequencial do AI...
  final int? idcCaracteristica; // idc da característica...
  final int? numSeqBarraComposta; // número sequencial da barra composta...
  final String format; // formato...

  factory AI.fromEAN(InfoCampoEAN ean) {
    final fieldName = (ean.idcTipCarMer == 0 ? 'LOTFAB' : ean.nomBrrBar).toLowerCase();
    final field = ean.idcTipCarMer == null
        ? AIField.values.firstWhere(
            (it) => it.name == fieldName,
            orElse: () => AIField.naoUsado,
          )
        : ean.idcTipCarMer == 0
            ? AIField.lotfab
            : AIField.caracteristica;

    return AI(
      field,
      ean.codAplEan.trim(),
      fieldName,
      ean.tamMax,
      ean.nroSeq,
      ean.idcTipCarMer,
      ean.nroSeqBarCmp,
      ean.fmtVarEan,
    );
  }

  static List<AI> getListAIs(List<InfoCampoEAN> listEAN) {
    final listAIs = listEAN
        .map((ean) => AI.fromEAN(ean))
        .where((ai) => ai.field != AIField.naoUsado)
        .toList();
    return listAIs;
  }
}
