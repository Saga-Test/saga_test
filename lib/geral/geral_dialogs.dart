import 'package:flutter/material.dart';

import '../geral/geral_api.dart';
import '../saga_lib/sa_dialogs.dart';
import '../saga_lib/sa_widgets.dart';

import '../main/app.dart';

GeralAPI api = GeralAPI(App.operador);

// Future<void> dialogImpressora(
//   BuildContext context,
//   int idcAtv, {
//   int? idcUmaRGU,
//   int? idcPrc,
//   int? idcMer,
//   int? idcEmb,
//   String? codigoRGU,
//   Servico? serv,
//   bool isUMAE = false,
//   bool fimLote = false,
// }) async {
//   final inputCopias = TextEditingController();
//   inputCopias.text = "1";

//   List<InfoImpressora> listImpressoras = await api.getImpressoras();

//   InfoImpressora? impressoraSelecionada;
//   int _selectedItem = -1;

//   bool isRecebimento = idcAtv == Atividade.ATIVIDADE_RECEBIMENTO ||
//       idcAtv == Atividade.ATIVIDADE_RECEBIMENTO_PRODUCAO;

//   int tipoEtiqueta = isRecebimento ? ETIQUETA_PRODUTO : ETIQUETA_UMA_BASICA;
//   String radioValue = isRecebimento ? 'Produto' : 'UMA';

//   await showDialog(
//     context: context,
//     builder: (BuildContext context) {
//       return Scaffold(
//         appBar: AppBar(
//           title: const Text("Impressão de Etiquetas"),
//         ),
//         body: StatefulBuilder(
//           builder: (BuildContext context, setState) {
//             return Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.start,
//                 crossAxisAlignment: CrossAxisAlignment.stretch,
//                 children: [
//                   Wrap(
//                     children: [
//                       Visibility(
//                         visible: !fimLote && !isRecebimento,
//                         child: Row(
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             Radio(
//                               value: 'UMA',
//                               groupValue: radioValue,
//                               onChanged: (value) {
//                                 radioValue = value as String;
//                                 tipoEtiqueta = ETIQUETA_UMAE_BASICA;
//                                 setState(() {});
//                               },
//                             ),
//                             const Text('UMA')
//                           ],
//                         ),
//                       ),
//                       Visibility(
//                         visible: !fimLote && !isRecebimento,
//                         child: Row(
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             Radio(
//                               value: 'Volume',
//                               groupValue: radioValue,
//                               onChanged: (value) {
//                                 radioValue = value as String;
//                                 tipoEtiqueta = ETIQUETA_VOLUME;
//                                 setState(() {});
//                               },
//                             ),
//                             const Text('Volume')
//                           ],
//                         ),
//                       ),
//                       Visibility(
//                         visible: (idcMer != null || idcEmb != null) && !fimLote,
//                         child: Row(
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             Radio(
//                               value: 'Produto',
//                               groupValue: radioValue,
//                               onChanged: (value) {
//                                 radioValue = value!;
//                                 tipoEtiqueta = serv?.sku?.mercadoria?.idc != null
//                                     ? ETIQUETA_PRODUTO
//                                     : ETIQUETA_UMAE_BASICA;
//                                 setState(() {});
//                               },
//                             ),
//                             const Text('Produto')
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                   Visibility(
//                     visible: !fimLote,
//                     child: Padding(
//                       padding: const EdgeInsets.symmetric(horizontal: 8.0),
//                       child: saInput(
//                         'Cópias',
//                         inputCopias,
//                         autofocus: true,
//                       ),
//                     ),
//                   ),
//                   Flexible(
//                     child: Card(
//                       margin: const EdgeInsets.only(top: 16),
//                       elevation: 2,
//                       child: ListView.builder(
//                         itemCount: listImpressoras.length,
//                         itemBuilder: (context, index) {
//                           final impressora = listImpressoras[index];
//                           return Container(
//                             decoration: BoxDecoration(
//                               border: Border.all(
//                                 width: 3,
//                                 color:
//                                     _selectedItem == index ? Colors.deepOrange : Colors.white,
//                               ),
//                             ),
//                             padding: const EdgeInsets.only(bottom: 8),
//                             child: InkWell(
//                               onTap: () {
//                                 _selectedItem = index;
//                                 impressoraSelecionada = listImpressoras[index];
//                                 setState(() {});
//                               },
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Padding(
//                                     padding: const EdgeInsets.all(8.0),
//                                     child: Row(
//                                       children: [
//                                         const Icon(Icons.adf_scanner_outlined),
//                                         Expanded(
//                                           child: Padding(
//                                             padding: const EdgeInsets.only(left: 16.0),
//                                             child: Column(
//                                               crossAxisAlignment: CrossAxisAlignment.start,
//                                               children: [
//                                                 Text(
//                                                   impressora.nome,
//                                                   maxLines: 2,
//                                                   overflow: TextOverflow.ellipsis,
//                                                 ),
//                                                 saSpace(),
//                                                 Text(
//                                                   impressora.caminho,
//                                                   maxLines: 2,
//                                                   overflow: TextOverflow.ellipsis,
//                                                 ),
//                                               ],
//                                             ),
//                                           ),
//                                         )
//                                       ],
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           );
//                         },
//                       ),
//                     ),
//                   ),
//                   saButton(
//                     "IMPRIMIR",
//                     () async {
//                       try {
//                         if (impressoraSelecionada == null) {
//                           throw Exception("Necessário selecionar a impressora");
//                         }

//                         int? quantidadeEtiqueta = int.tryParse(inputCopias.text);
//                         await api.imprimeEtiqueta(
//                           impressoraSelecionada!.idc,
//                           tipoEtiqueta,
//                           idcUmaRGU,
//                           tipoEtiqueta == ETIQUETA_PRODUTO && !fimLote ? null : serv?.lote.idc,
//                           serv?.lote.processo?.idc,
//                           serv?.proprietario?.idc,
//                           idcMer,
//                           idcEmb,
//                           codigoRGU,
//                           quantidadeEtiqueta,
//                           isUMAE ? [serv?.umaDestino?.idc] : [serv?.umaOrigem?.idc],
//                         );

//                         showLongToast(msg: "Impressão enviada com sucesso");
//                       } catch (ex) {
//                         await showError(context, ex);
//                       }
//                     },
//                   )
//                 ],
//               ),
//             );
//           },
//         ),
//       );
//     },
//   );
// }

Future<void> showInfoLote(BuildContext context, int idcLote) async {
  await showList<GeralInfoLote>(
    context: context,
    title: 'LOTE $idcLote',
    canSelect: false,
    useFullScreen: true,
    loadList: () => api.listarDadosPedidoRecByLote(idcLote, null),
    showItem: (item) {
      return saCard(
        lines: [
          SaField('Pedido', item.numOrdem),
          saSpace(),
          SaField('Ordem Externa', item.numOrdemExterna),
          saSpace(),
          SaField('Agrupamento', item.numAgrupamento),
          saSpace(),
          SaField('Endereço', item.endereco),
          saSpace(),
          SaField('Qtd. UMAE finalizadas', item.qtd),
          saSpace(),
          SaField('Código Cliente/Fornecedor', item.codigoPessoa),
          saSpace(),
          SaField('Nome Cliente/Fornecedor', item.nomePessoa),
          saSpace(),
          SaField('UF', item.estado),
          saSpace(),
          SaField('Cidade', item.cidade),
          saDivider(),
          SaField('Código Transportadora', item.codigoTransportadora),
          saSpace(),
          SaField('Nome Transportadora', item.nomeTransportadora),
          saDivider(),
          SaField('Motorista', item.motorista),
          saSpace(),
          SaField('Placa', item.placaVeiculo),
          saDivider(),
          SaField('Observação', item.observacao),
        ],
      );
    },
  );
}

// Future<String?> calculoSku(
//   BuildContext context,
//   String nomeMercadoria,
//   double valorVenda,
//   bool mensuravel, {
//   bool isApanha = false,
//   double? quantidadeDesejada,
// }) async {
//   final inputUni = TextEditingController();
//   final inputQtd = TextEditingController();
//   final inputQtdDsj = TextEditingController();

//   if (valorVenda == 0) valorVenda = 1;
//   inputUni.text = valorVenda.toQuantidade(mensuravel);

//   if (quantidadeDesejada != null) {
//     inputQtd.text = quantidadeDesejada.toQuantidade(mensuravel);
//   }

//   return await showDialog(
//     context: context,
//     builder: (context) {
//       return AlertDialog(
//         title: const Text('Cálculo de SKU'),
//         content: SizedBox(
//           width: MediaQuery.of(context).size.width,
//           child: ListView(
//             shrinkWrap: true,
//             children: [
//               SaField('Mercadoria', nomeMercadoria),
//               saSpace(2),
//               if (isApanha) ...[
//                 saInput(
//                   'Quantidade desejada',
//                   inputQtdDsj,
//                   autofocus: false,
//                   readOnly: true,
//                 )
//               ],
//               saInput(
//                 'Unidade venda',
//                 inputUni,
//                 autofocus: false,
//                 readOnly: true,
//               ),
//               saInput(
//                 'Quantidade',
//                 inputQtd,
//                 mensuravel: mensuravel,
//               ),
//             ],
//           ),
//         ),
//         actions: [
//           ElevatedButton(
//             child: const Text("Cancelar"),
//             onPressed: () => Navigator.pop(context, null),
//           ),
//           ElevatedButton(
//             child: const Text("Salvar"),
//             onPressed: () {
//               double valorQtd = 0;
//               String qtd = inputQtd.text.replaceAll(',', '.');
//               String uni = inputUni.text.replaceAll(',', '.');

//               if (isApanha) {
//                 valorQtd = double.parse(qtd) / double.parse(uni);
//               } else {
//                 valorQtd = double.parse(uni) * double.parse(qtd);
//               }

//               Navigator.pop(context, valorQtd.toQuantidade(mensuravel));
//             },
//           ),
//         ],
//       );
//     },
//   );
// }

// Future<void> dialogInfoUMA(
//   BuildContext context,
//   ObservacaoUMA infoUMA,
//   String codUMA,
// ) async {
//   final inputVolume = TextEditingController();
//   final inputPeso = TextEditingController();
//   final inputObs = TextEditingController();

//   inputVolume.text = infoUMA.volume.toString();
//   inputPeso.text = infoUMA.peso.toString();
//   inputObs.text = infoUMA.observacao;

//   return await showDialog(
//     context: context,
//     builder: (context) {
//       return AlertDialog(
//         title: const Text('Informação UMA'),
//         content: SizedBox(
//           width: MediaQuery.of(context).size.width,
//           child: ListView(
//             shrinkWrap: true,
//             children: [
//               saTitle("UMA: " + codUMA),
//               saSpace(),
//               saInput("Volume", inputVolume, mensuravel: true, autofocus: false),
//               saSpace(),
//               saInput("Peso", inputPeso, mensuravel: true, autofocus: false),
//               saSpace(),
//               saInput("Observação", inputObs),
//             ],
//           ),
//         ),
//         actions: [
//           ElevatedButton(
//             child: const Text("SAIR"),
//             onPressed: () => Navigator.pop(context),
//           ),
//           ElevatedButton(
//             child: const Text("ENVIAR INFO"),
//             onPressed: () async {
//               final peso = await checkInputValue(inputPeso, type: InputType.double);
//               final volume = await checkInputValue(inputVolume, type: InputType.double);

//               if (peso < 0 || volume < 0) await showError(context, "Valores inválidos");

//               final result = await api.atualizaInfoUMA(
//                 infoUMA.idcUma,
//                 peso,
//                 volume,
//                 inputObs.text,
//               );
//               if (result) showLongToast(msg: "Observação enviada com sucesso");
//               Navigator.pop(context);
//             },
//           ),
//         ],
//       );
//     },
//   );
// }
