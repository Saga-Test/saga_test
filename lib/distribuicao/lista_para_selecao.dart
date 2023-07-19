//--------------------------------------------------------------------------------------------
// Lista de disponíveis e escolhidos:
//  - se não escolheu NENHUM, é como se tivesse escolhido TODOS;
//
//  - findAll() procura entre os disponíveis.
//    Se não achar, procura entre os já escolhidos, se achar, retorna o 1o escolhido;.
//    Isto é feito para deixar o operador bipar VÁRIAS vezes no mesmo, SEM DAR erro.
//
//  - clear() reinicia o processo de escolha;
//--------------------------------------------------------------------------------------------
class ListaParaSelecao<T> {
  ListaParaSelecao(this.listaOriginal) {
    clear();
  }

  final List<T> listaOriginal;

  // lista de ainda disponíveis e já escolhidos...
  final List<T> disponiveis = [];
  final List<T> escolhidos = [];

  // lista final de selecionados (se não escolheu NENHUM, é como se escolhesse TODOS)...
  List<T> get selecionados => escolhidos.isEmpty ? disponiveis : escolhidos;
  bool get todos => selecionados.length == listaOriginal.length;
  bool get unico => selecionados.length == 1;

  T get single => selecionados.single;

  void clear() {
    disponiveis.clear();
    escolhidos.clear();

    disponiveis.addAll(listaOriginal);
  }

  List<T> findAll(bool Function(T) test) {
    final result = disponiveis.where((it) => test(it)).toList();

    // EVITA ERRO se escolher várias vezes...
    if (result.isEmpty) {
      // se já foi escolhida, retorna a 1a que atende...
      final jaEscolhidos = escolhidos.where((it) => test(it)).toList();
      if (jaEscolhidos.isNotEmpty) return [jaEscolhidos.first];
    }

    return result;
  }

  void addAll(List<T> list) {
    list.forEach((it) => add(it));
  }

  void add(T item) {
    // se não está disponível, ignora...
    if (!disponiveis.contains(item)) return;

    disponiveis.remove(item);
    escolhidos.add(item);
  }
}
