import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:saga_test/saga_lib/sa_expansive_card.dart';
import 'package:saga_test/saga_lib/sa_page.dart';
import 'package:saga_test/saga_lib/sa_page_card.dart';
import 'package:saga_test/saga_lib/sa_widgets.dart';

import '../informativo/informativo_dialog.dart';
import '../saga_lib/sa_dialogs.dart';
import '../saga_lib/sa_error.dart';

abstract class WorkPage extends StatefulWidget {
  const WorkPage({super.key});

  @override
  WorkState createState();
}

abstract class WorkState<T extends WorkPage> extends State<T> {
  @override
  void initState() {
    super.initState();

    loading = true;

    workflow = createWorkflow();
    goto(0);
  }

  int? atividade;

  late Map<int, WorkStep> workflow;

  String title = '';
  int _index = -1;

  int get step => _index;
  void goto(int newStep) {
    _goto(newStep, false);
  }

  void _goto(int newStep, bool backing) {
    // ignora chamadas repetidas...
    if (newStep == _index) return;
    // só dentro da faixa permitida...
    if (newStep < 0 || newStep > lastStep) return;

    // se está avançando ou fazendo goto...
    if (!backing && _index != -1) {
      final p = path.indexOf(newStep);
      if (p >= 0) {
        // se está voltando para um lugar que já esteve, remove tudo até lá inclusive...
        path = path.sublist(0, p);
      } else {
        // armazena o caminho percorrido...
        path.add(_index);
      }
    }

    _index = newStep;
    _showStep(_index);
  }

  void retry() => abort();

  void refresh() => _showStep(step);

  Future<void> close() async {
    await showMessage(
      context: context,
      title: 'Serviço FINALIZADO',
      message: 'Pressione OK para continuar...',
    );

    if (context.mounted) Navigator.pop(context);
  }

  int get numSteps => workflow.length;
  int get lastStep => workflow.length - 1;

  List<int> path = [];

  Future<void> prevStep() async {
    // desempilha o último passo executado...
    final index = path.removeLast();
    _goto(index, true);
  }

  Future<void> nextStep({WorkStep? wfsLocal}) async {
    // evita chamadas duplicadas...
    if (_executing) return;
    _executing = true;

    // salva step para ver se validate() vai modificar...
    final currIndex = _index;
    try {
      // se validate() NÃO mudar o step, vai pro próximo...
      wfsLocal != null ? wfsLocal.validate?.call() : wfs.validate?.call();
      // se fez goto() dentro do validate(), RESPEITA...
      if (_index != currIndex) return;

      // acabou???
      if (_index == lastStep) {
        await close();
        return;
      }

      goto(_index + 1);
    } on DioError catch (_) {
      informativoDialog(context);
    } catch (ex) {
      await showError(context, ex);
      // se deu pau no validate(),
      // RESTAURA eventual goto() dado dentro do validate()!!!
      goto(currIndex);
    } finally {
      _executing = false;
    }
  }

  bool _executing = false;

  Future<void> tryExecute(Function callback) async {
    try {
      await callback();
    } on DioError catch (_) {
      informativoDialog(context);
    } catch (ex) {
      await showError(context, ex);
    }
  }

  Map<int, WorkStep> createWorkflow();
  Future<List<Widget>> getBody(int step) async => <Widget>[];
  Future<List<Widget>> getActions(int step) async => <Widget>[];
  Future<List<Widget>> getAppBarActions(int step) async => <Widget>[];

  bool _starting = true;
  Future<int> starting() async => 0;

  Future<void> _showStep(int currIndex) async {
    bodyList = inputList = actionList = [];
    try {
      // apenas 1 vez - no início...
      if (_starting) {
        currIndex = await starting();
        // se starting trocou de step, atualiza o step da classe!!!
        _index = currIndex;
        _starting = false;
      }

      wfs = workflow[currIndex]!;

      // init step atual...
      await wfs.init?.call();
      // se init trocou de step, interrompe este...
      // if (_index != currIndex) return;

      bodyList = await getBody(currIndex);
      inputList = await wfs.input?.call() ?? <Widget>[];
      actionList = await getActions(currIndex);
      appBarActionList = await getAppBarActions(currIndex);

      loading = false;
      setState(() {});
    } catch (ex) {
      await showError(
        context,
        'Não foi possível carregar o passo, tente o passo anterior\n$ex',
      );
    }
  }

  var loading = true;
  late WorkStep wfs;
  var bodyList = <Widget>[];
  var inputList = <Widget>[];
  var actionList = <Widget>[];
  var appBarActionList = <Widget>[];

  final mainButtonKey = GlobalKey();

  bool expanded = false;

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }

    // bool showBack = workflow[step]!.canBack;
    // bool finalizando = step == lastStep;

    return SaPage(
      title: title,
      canBack: true,
      children: [
        SaPageCard(
            color: const Color(0xffF7F7F8),
            child: LayoutBuilder(
              builder: (_, constrains) {
                return ListView(
                  children: [
                    SaExpansiveCard(
                      title: "ETAPA ATUAL: ${wfs.etapa}",
                      children: [...bodyList],
                    ),
                    Wrap(
                      spacing: 16.0,
                      runAlignment: WrapAlignment.spaceBetween,
                      alignment: WrapAlignment.spaceBetween,
                      children: [
                        for (var item in workflow.entries) ...[
                          SizedBox(
                            width: constrains.maxWidth / 2.05,
                            child: SaExpansiveCard(
                              title: item.value.etapa ?? '',
                              isExpanded: item.value.etapa == wfs.etapa,
                              showStep: _showStep,
                              currIndex: item.key,
                              children: [
                                ...bodyList,
                                ...inputList,
                                if (item.key == _index) ...[...actionList],
                                saSpace(),
                                saButton(
                                  "Validar Passo",
                                  () => nextStep(wfsLocal: item.value),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                );
              },
            )),
      ],
    );
  }
}

class WorkStep {
  WorkStep({
    this.etapa,
    this.init,
    required this.input,
    this.validate,
    this.canBack = true,
  });
  final String? etapa;
  final bool canBack;

  final Future<void> Function()? init;
  final Future<List<Widget>> Function()? input;
  final Future<void> Function()? validate;
}

//--------------------------------------------------------------------------------------------
// Utils
//--------------------------------------------------------------------------------------------
void checkDoubleValue(double value, double minValue, double maxValue) {
  if (value < minValue || value > maxValue) {
    throw Exception('Valor deve estar entre $minValue e $maxValue');
  }
}

enum InputType { string, double, int }

dynamic checkInputValue(
  TextEditingController controller, {
  FocusNode? focus,
  InputType type = InputType.string,
  String messageError = 'Valor inválido',
  String messageIfEmpty = 'Campo obrigatório',
}) {
  final value = controller.text;

  if (focus != null) focus.requestFocus();

  if (value.isEmpty) {
    throw Exception(messageIfEmpty);
  }

  try {
    if (type == InputType.string) return value;
    if (type == InputType.int) return int.parse(value);
    if (type == InputType.double) return double.parse(value.replaceAll(',', '.'));
  } catch (ex) {
    throw Exception(messageError);
  }
}
