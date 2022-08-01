import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:to_do_list_flutter/models/to_do.dart';

const toDoListKey = 'todo_list';

class TodoRepository {
  late SharedPreferences sharedPreferences;

  TodoRepository() {}

  Future<List<ToDo>> getToDoList() async {
    sharedPreferences = await SharedPreferences.getInstance();

    final String jsonString = sharedPreferences.getString(toDoListKey) ?? '[]';
    // Se não encontrou a lista no shared preferences ele seta como uma lista vazia

    final List jsonDecoded = json.decode(jsonString) as List;
    return jsonDecoded.map((e) => ToDo.fromJson(e)).toList();
  }

  void saveTodoList(List<ToDo> todos) {
    final String jsonString = jsonEncode(
        todos); // Passa a lista de tarefas para um texto, codificado no padrão JSON
    sharedPreferences.setString(toDoListKey,
        jsonString); // Armazendo a lista de tarefas no shared preferences
  }
}
