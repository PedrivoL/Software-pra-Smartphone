import 'dart:async';
import 'package:flutter/material.dart';

void main() {
  runApp(const GerenciadorTarefasApp());
}

class GerenciadorTarefasApp extends StatelessWidget {
  const GerenciadorTarefasApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lista de Tarefas',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const ListaTarefasScreen(),
    );
  }
}

/// Modelo de dados de uma tarefa
class Tarefa {
  final String texto;
  bool concluida;
  bool pendenteExclusao;
  Timer? timerExclusao;

  Tarefa({
    required this.texto,
    this.concluida = false,
    this.pendenteExclusao = false,
    this.timerExclusao,
  });
}

class ListaTarefasScreen extends StatefulWidget {
  const ListaTarefasScreen({super.key});

  @override
  State<ListaTarefasScreen> createState() => _ListaTarefasScreenState();
}

class _ListaTarefasScreenState extends State<ListaTarefasScreen> {
  final List<Tarefa> _tarefas = [];
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    // Cancela quaisquer timers pendentes para evitar vazamento de memória
    for (final tarefa in _tarefas) {
      tarefa.timerExclusao?.cancel();
    }
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  /// Adiciona uma nova tarefa à lista
  void _adicionarTarefa() {
    final texto = _controller.text.trim();

    // Validação de entrada vazia ou apenas com espaços
    if (texto.isEmpty) {
      _mostrarMensagem('A tarefa não pode ser vazia!', Colors.orange);
      return;
    }

    // Validação de tarefa duplicada (utiliza o texto como chave de comparação)
    final existeDuplicada = _tarefas.any(
      (t) => t.texto.toLowerCase() == texto.toLowerCase(),
    );

    if (existeDuplicada) {
      _mostrarMensagem('Esta tarefa já existe na lista!', Colors.redAccent);
      return;
    }

    setState(() {
      final novaTarefa = Tarefa(texto: texto);

      // Encontra onde começa o bloco de tarefas concluídas
      final primeiroConcluidoIndex = _tarefas.indexWhere((t) => t.concluida);

      // As tarefas ativas são inseridas na ordem de criação antes das concluídas
      if (primeiroConcluidoIndex == -1) {
        _tarefas.add(novaTarefa);
      } else {
        _tarefas.insert(primeiroConcluidoIndex, novaTarefa);
      }

      _controller.clear();
    });

    _focusNode.requestFocus();
  }

  /// Alterna o estado de conclusão da tarefa
  void _alternarConclusao(Tarefa tarefa, bool? novoValor) {
    if (novoValor == null) return;

    setState(() {
      // Remove do posicionamento atual usando o texto como chave
      _tarefas.removeWhere((t) => t.texto == tarefa.texto);
      tarefa.concluida = novoValor;

      if (tarefa.concluida) {
        // Ao marcar como concluída, ela vai para após as não concluídas
        // e se torna a PRIMEIRA entre as concluídas.
        final primeiroConcluidoIndex = _tarefas.indexWhere((t) => t.concluida);
        if (primeiroConcluidoIndex == -1) {
          _tarefas.add(tarefa);
        } else {
          _tarefas.insert(primeiroConcluidoIndex, tarefa);
        }
      } else {
        // Ao desmarcar, volta para o final das tarefas ativas (não concluídas)
        final primeiroConcluidoIndex = _tarefas.indexWhere((t) => t.concluida);
        if (primeiroConcluidoIndex == -1) {
          _tarefas.add(tarefa);
        } else {
          _tarefas.insert(primeiroConcluidoIndex, tarefa);
        }
      }
    });
  }

  /// Inicia o processo de exclusão de 3 segundos
  void _iniciarExclusao(Tarefa tarefa) {
    if (tarefa.pendenteExclusao) return;

    setState(() {
      tarefa.pendenteExclusao = true;
    });

    // Inicia timer individual de 3 segundos
    tarefa.timerExclusao?.cancel();
    tarefa.timerExclusao = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          // Remove da lista usando o texto da tarefa como chave única
          _tarefas.removeWhere((t) => t.texto == tarefa.texto);
        });
      }
    });
  }

  /// Desfaz o processo de exclusão
  void _desfazerExclusao(Tarefa tarefa) {
    setState(() {
      tarefa.timerExclusao?.cancel();
      tarefa.timerExclusao = null;
      tarefa.pendenteExclusao = false;
    });
  }

  void _mostrarMensagem(String msg, Color cor) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: cor,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Minhas Tarefas'),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Barra de inclusão de tarefas
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      focusNode: _focusNode,
                      decoration: const InputDecoration(
                        labelText: 'Nova Tarefa',
                        hintText: 'Digite e pressione Enter...',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                      ),
                      onSubmitted: (_) => _adicionarTarefa(),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton.icon(
                    onPressed: _adicionarTarefa,
                    icon: const Icon(Icons.add),
                    label: const Text('Incluir'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 14,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Área da lista com relevo, borda e cor distinta da barra superior
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.blueGrey.shade50, // Fundo diferenciado
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.indigo.shade200, width: 2), // Borda
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 8,
                        offset: Offset(0, 4), // Relevo
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: _tarefas.isEmpty
                        ? const Center(
                            child: Text(
                              'Nenhuma tarefa cadastrada.\nAdicione novas tarefas acima!',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.black54,
                                fontSize: 16,
                              ),
                            ),
                          )
                        : ListView.builder(
                            itemCount: _tarefas.length,
                            itemBuilder: (context, index) {
                              final tarefa = _tarefas[index];

                              // Cores alternadas na lista, com estado vermelho quando pendente de exclusão
                              final Color corFundoItem = tarefa.pendenteExclusao
                                  ? Colors.red.shade100
                                  : (index.isEven
                                      ? Colors.white
                                      : const Color(0xFFE8EEF5));

                              return Dismissible(
                                key: ValueKey(tarefa.texto),
                                // Arrastar para a direita: concluir
                                background: Container(
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.green.shade400,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  alignment: Alignment.centerLeft,
                                  padding: const EdgeInsets.only(left: 20),
                                  child: const Row(
                                    children: [
                                      Icon(Icons.check, color: Colors.white),
                                      SizedBox(width: 8),
                                      Text(
                                        'Concluir',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Arrastar para a esquerda: excluir
                                secondaryBackground: Container(
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.red.shade400,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  alignment: Alignment.centerRight,
                                  padding: const EdgeInsets.only(right: 20),
                                  child: const Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Text(
                                        'Excluir',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      Icon(Icons.delete, color: Colors.white),
                                    ],
                                  ),
                                ),
                                confirmDismiss: (direction) async {
                                  if (direction == DismissDirection.endToStart) {
                                    // Arrastou para a esquerda -> Aciona exclusão com atraso e desfazer
                                    _iniciarExclusao(tarefa);
                                    return false; // Retorna false para manter o widget visível com o timer
                                  } else if (direction == DismissDirection.startToEnd) {
                                    // Arrastou para a direita -> Alterna conclusão
                                    _alternarConclusao(tarefa, !tarefa.concluida);
                                    return false; // Retorna false para reposicionar sem desmontar bruscamente
                                  }
                                  return false;
                                },
                                child: Container(
                                  // Margens para que itens não toquem o topo ou as laterais
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 5,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: corFundoItem,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: tarefa.pendenteExclusao
                                          ? Colors.red
                                          : Colors.black12,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      // Checkbox de conclusão
                                      Checkbox(
                                        value: tarefa.concluida,
                                        onChanged: tarefa.pendenteExclusao
                                            ? null
                                            : (valor) => _alternarConclusao(
                                                  tarefa,
                                                  valor,
                                                ),
                                      ),
                                      // Texto da tarefa com estilo riscado (strike out) quando concluída
                                      Expanded(
                                        child: Text(
                                          tarefa.texto,
                                          style: TextStyle(
                                            fontSize: 16,
                                            decoration: tarefa.concluida
                                                ? TextDecoration.lineThrough
                                                : TextDecoration.none,
                                            color: tarefa.pendenteExclusao
                                                ? Colors.red.shade900
                                                : (tarefa.concluida
                                                    ? Colors.grey.shade600
                                                    : Colors.black87),
                                            fontWeight: tarefa.concluida
                                                ? FontWeight.normal
                                                : FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                      // Botão de Excluir ou Desfazer
                                      if (tarefa.pendenteExclusao)
                                        ElevatedButton.icon(
                                          onPressed: () =>
                                              _desfazerExclusao(tarefa),
                                          icon: const Icon(Icons.undo, size: 18),
                                          label: const Text('Desfazer'),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.white,
                                            foregroundColor: Colors.red,
                                            side: const BorderSide(
                                                color: Colors.red),
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 6,
                                            ),
                                          ),
                                        )
                                      else
                                        IconButton(
                                          icon: const Icon(
                                            Icons.delete_outline,
                                            color: Colors.redAccent,
                                          ),
                                          tooltip: 'Apagar tarefa',
                                          onPressed: () =>
                                              _iniciarExclusao(tarefa),
                                        ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}