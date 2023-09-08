import 'package:crud_aluno/sql_helper.dart';
import 'package:flutter/material.dart';
import 'package:quickalert/quickalert.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // controladores para os campos de texto
  final nomeController = TextEditingController();
  final emailController = TextEditingController();
  // faz referencia para a lista de objetos (aluno)
  List<Map<String, dynamic>> alunos = [];
  bool carregando = true;

  void _atualizaLista() async {
    carregando = true;
    alunos = await SqlHelper.getList();
    setState(() {
      carregando = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _atualizaLista();
  }

  void _gravar(BuildContext context, [int id = -1]) async {
    // pega os valores digitados no campo de texto
    String nome = nomeController.text;
    String email = emailController.text;
    // salva os registros
    int insertedId = await SqlHelper.gravar(nome, email, id);
    Navigator.of(context).pop();
    if (insertedId > 0) {
      _atualizaLista();
      final snackBar = SnackBar(
        content: const Text('Item salvo com Sucesso!'),
      );

      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Alunos'),
      ),
      body: carregando
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListView.separated(
                  separatorBuilder: (BuildContext context, int index) =>
                      const Divider(),
                  itemCount: alunos.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(alunos[index]['nome']),
                      subtitle: Text(alunos[index]['email']),
                      trailing: SizedBox(
                        width: 100,
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () =>
                                  _criarFormulario(alunos[index]['id']),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () => _deleteItem(alunos[index]),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          nomeController.text = '';
          emailController.text = '';
          _criarFormulario();
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  _editItem(Map aluno) {}

  _deleteItem(Map aluno) {
    String msg = "Tem certeza que deseja excluir o aluno ${aluno['nome']}? ";
    msg += "A exclusão será permanente!";
    QuickAlert.show(
        context: context,
        type: QuickAlertType.warning,
        text: msg,
        title: 'Atenção',
        confirmBtnText: 'Sim, excluir',
        showCancelBtn: true,
        cancelBtnText: 'Cancelar',
        onConfirmBtnTap: () async {
          Navigator.pop(context);
          if (await SqlHelper.deleteItem(aluno['id'])) {
            _atualizaLista();
            const snackBar = SnackBar(
              content: Text('Item removido com Sucesso!'),
            );

            ScaffoldMessenger.of(context).showSnackBar(snackBar);
          }
          return;
        });
  }

  void _criarFormulario([int id = -1]) async {
    if (id > 0) {
      // pega o aluno com id passado
      Map aluno = alunos.firstWhere((element) => element['id'] == id);
      nomeController.text = aluno['nome'];
      emailController.text = aluno['email'];
    }

    showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (context) {
          return Container(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nomeController,
                    decoration: const InputDecoration(
                      labelText: 'Nome:',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextField(
                    controller: emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email:',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        minimumSize: Size.fromHeight(50)),
                    onPressed: () => _gravar(context, id),
                    child: const Text('Gravar'),
                  )
                ],
              ),
            ),
          );
        });
  }
}
