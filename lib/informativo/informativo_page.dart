import 'package:flutter/material.dart';
import 'package:saga_test/informativo/informativo_controller.dart';
import 'package:saga_test/saga_lib/sa_page_card.dart';

import 'info_log.dart';
import 'informativo_content.dart';
import 'informativo_dialog.dart';

class InformativoPage extends StatefulWidget {
  const InformativoPage({Key? key}) : super(key: key);

  @override
  State<InformativoPage> createState() => _InformativoPageState();
}

enum Pages {
  emptyCard,
  logListCard,
  logCard,
  classCard,
}

class _InformativoPageState extends State<InformativoPage> {
  @override
  void initState() {
    super.initState();
  }

  var page = Pages.logListCard;
  InfoLog selectedLog = InfoLog();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (page == Pages.logListCard) ...[
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 100),
            switchInCurve: Curves.easeInOut,
            child: ValueListenableBuilder(
              valueListenable: InformativoController.logList,
              builder: (BuildContext context, List<InfoLog> list, Widget? child) {
                return Visibility(
                  visible: list.isNotEmpty,
                  replacement: const SaPageCard(
                    child: Center(
                      child: Text("Sem itens"),
                    ),
                  ),
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height * 0.85,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Expanded(
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: list.length,
                            itemBuilder: (context, index) {
                              final inverseIndex = (list.length - 1) - index;
                              final log = list[inverseIndex];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 16.0),
                                child: SizedBox(
                                  height: 40,
                                  child: Card(
                                    color: Colors.white,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    margin: EdgeInsets.zero,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 8.0,
                                        horizontal: 16.0,
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Flexible(
                                            child: Row(
                                              children: [
                                                Padding(
                                                  padding: const EdgeInsets.only(right: 12.0),
                                                  child: Icon(
                                                    log.isErro
                                                        ? Icons.error
                                                        : Icons.check_circle,
                                                    color:
                                                        log.isErro ? Colors.red : Colors.green,
                                                  ),
                                                ),
                                                Flexible(
                                                  child: Text(
                                                    log.nomeMetodo.toUpperCase(),
                                                    style: const TextStyle(
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Wrap(
                                            spacing: 12,
                                            children: [
                                              InkWell(
                                                onTap: () => informativoDialog(
                                                  context,
                                                  selectedLog: log,
                                                ),
                                                child: const Icon(Icons.aspect_ratio),
                                              ),
                                              InkWell(
                                                onTap: () => InformativoController.deleteLog(
                                                  log,
                                                ),
                                                child: const Icon(Icons.delete_outline),
                                              ),
                                              InkWell(
                                                onTap: () {
                                                  selectedLog = log;
                                                  setState(() => page = Pages.logCard);
                                                },
                                                child: const Icon(
                                                  Icons.arrow_drop_down,
                                                ),
                                              ),
                                            ],
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              StatefulBuilder(
                                builder: (BuildContext context, setState) {
                                  return Row(
                                    children: [
                                      const Text("Lista Automatica"),
                                      Checkbox(
                                        value: InformativoController.autoUpdate,
                                        onChanged: (value) {
                                          setState(
                                            () => InformativoController.autoUpdate = value!,
                                          );
                                        },
                                      ),
                                    ],
                                  );
                                },
                              ),
                              TextButton(
                                onPressed: () {
                                  InformativoController.clearList();
                                  InformativoController.autoUpdate = true;
                                },
                                child: const Text("Limpar Logs"),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
        if (page == Pages.logCard) ...[
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 100),
            switchInCurve: Curves.easeInOut,
            child: SaPageCard(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 8.0,
                  horizontal: 16.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(right: 12.0),
                              child: Icon(
                                selectedLog.isErro ? Icons.error : Icons.check_circle,
                                color: selectedLog.isErro ? Colors.red : Colors.green,
                              ),
                            ),
                            Text(
                              selectedLog.nomeMetodo.toUpperCase(),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Wrap(
                          spacing: 12,
                          children: [
                            InkWell(
                              onTap: () => informativoDialog(
                                context,
                                selectedLog: selectedLog,
                              ),
                              child: const Icon(Icons.aspect_ratio),
                            ),
                            InkWell(
                              onTap: () {
                                InformativoController.deleteLog(
                                  selectedLog,
                                );
                                setState(() => page = Pages.logListCard);
                              },
                              child: const Icon(Icons.delete_outline),
                            ),
                            InkWell(
                              onTap: () {
                                setState(() => page = Pages.logListCard);
                              },
                              child: const Icon(
                                Icons.arrow_drop_up,
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                    const Divider(),
                    Expanded(child: InformativoContent(selectedLog: selectedLog))
                  ],
                ),
              ),
            ),
          ),
        ]
      ],
    );
  }
}
