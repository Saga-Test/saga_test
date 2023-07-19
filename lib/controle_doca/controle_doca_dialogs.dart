import 'package:flutter/cupertino.dart';

import '../saga_lib/sa_dialogs.dart';
import '../saga_lib/sa_widgets.dart';
import 'controle_doca_api.dart';

class ControleDocaDialogs {
  ControleDocaDialogs(this.api);

  final ControleDocaApi api;

  Future<InfoDoca> getDoca(BuildContext context) async {
    final result = await showList<InfoDoca>(
      context: context,
      title: 'Local',
      loadList: () => api.getDocas(),
      showItem: (item) {
        return saCard(
          lines: [
            saSpace(2),
            SaField('', item.nomLoc),
            saSpace(2),
          ],
        );
      },
    );
    return result!;
  }
}