import 'package:sqflite/sqflite.dart' as sql;

class SqlHelper {
  // cria/abre a conexao com banco
  static Future<sql.Database> _getDataBase() async {
    return await sql.openDatabase('aluno',
        version: 1,
        onCreate: (database, index) => database.execute(_createTable()));
  }

  // sql que gera a tabela
  static String _createTable() {
    return '''
       CREATE TABLE aluno (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          nome TEXT NOT NULL,
          email TEXT NOT NULL
       );
    ''';
  }

  // cria ou atualiza um registro
  static Future<int> gravar(String nome, String email, [int id = -1]) async {
    final database = await _getDataBase();
    final values = {'nome': nome, 'email': email};
    if (id > 0) {
      return database.update('aluno', values, where: 'id = ?', whereArgs: [id]);
    } else {
      return database.insert('aluno', values);
    }
  }

  // busca um aluno pelo seu id
  static Future<List<Map<String, dynamic>>> getAluno(int id) async {
    final database = await _getDataBase();
    return database.query('aluno', where: "id = ?", whereArgs: [id], limit: 1);
  }

  static Future<List<Map<String, dynamic>>> getList() async {
    final database = await _getDataBase();
    return database.query('aluno', orderBy: 'nome');
  }

  static Future<bool> deleteItem(int id) async {
    final database = await _getDataBase();

    final linhasAfetadas =
        await database.delete("aluno", where: "id = ?", whereArgs: [id]);
    return linhasAfetadas > 0;
  }
}
