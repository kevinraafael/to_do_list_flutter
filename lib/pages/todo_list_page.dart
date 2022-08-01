import 'package:flutter/material.dart';
import 'package:to_do_list_flutter/core/app_colors.dart';
import 'package:to_do_list_flutter/repositories/todo_repository.dart';

import '../models/to_do.dart';
import '../widgets/to_do_list_item.dart';

class ToDoListPage extends StatefulWidget {
  ToDoListPage({Key? key}) : super(key: key);

  @override
  State<ToDoListPage> createState() => _ToDoListPageState();
}

class _ToDoListPageState extends State<ToDoListPage> {
  final TextEditingController toDoController = TextEditingController();
  final TodoRepository todoRepository = TodoRepository();

  List<ToDo> toDos = [];

  ToDo? deletedTodo;
  int? deletedTodoPosition;
  String? errorText;

  @override
  void initState() {
    super.initState();

    todoRepository.getToDoList().then((value) {
      setState(() {
        toDos = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text('To Do '),
          centerTitle: true,
          backgroundColor: AppColors.primaryColor,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextField(
                        controller: toDoController,
                        decoration: InputDecoration(
                          labelText: 'Adicione uma tarefa',
                          border: OutlineInputBorder(),
                          hintText: 'Ex: estudar Flutter',
                          errorText: errorText,
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: AppColors.primaryColor,
                              width: 2,
                            ),
                          ),
                          labelStyle: TextStyle(
                            color: AppColors.primaryText,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        String text = toDoController.text;
                        if (text.isEmpty) {
                          setState(() {
                            errorText = 'o texto não pode estar vazio';
                          });
                          return;
                        }
                        setState(() {
                          ToDo newToDo =
                              ToDo(title: text, dateTime: DateTime.now());
                          toDos.add(newToDo);
                          errorText = null;
                        });
                        toDoController.clear();
                        todoRepository.saveTodoList(toDos);
                      },
                      child: Icon(
                        Icons.add,
                        size: 30,
                      ),
                      style: ElevatedButton.styleFrom(
                        primary: AppColors.primaryColor,
                        padding: EdgeInsets.all(14),
                      ),
                    )
                  ],
                ),
                SizedBox(height: 16),
                //o Flexible ajuda a ajustar o tamanho máximo que a lista pode ocupar na tela
                //sem ele a lista ocupava todo espaço e quebrava o layout
                Flexible(
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      //Para cada tarefa na minha lista de tarefas, adicionar um lisTile
                      for (ToDo todos in toDos)
                        TodoListItem(
                          todo: todos,
                          onDelete: onDelete,
                        ),
                    ],
                  ),
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Você possui ${toDos.length} tarefas pendentes',
                        style: TextStyle(
                            color: AppColors.tasksText,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                    SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        showDeleToDosConfirmationDialog();
                      },
                      style: ElevatedButton.styleFrom(
                        primary: AppColors.primaryColor,
                        padding: EdgeInsets.all(14),
                      ),
                      child: Text('Limpar tudo'),
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void onDelete(ToDo todo) {
    deletedTodo = todo;
    deletedTodoPosition = toDos.indexOf(todo);
    setState(() {
      toDos.remove(todo);
    });
    todoRepository.saveTodoList(toDos);

    ScaffoldMessenger.of(context).clearSnackBars();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Tarefa ${todo.title} removida com sucesso',
          style: TextStyle(
            color: AppColors.taskTitle,
          ),
        ),
        backgroundColor: AppColors.snackBar,
        action: SnackBarAction(
          label: 'desfazer',
          textColor: AppColors.primaryColor,
          onPressed: () {
            setState(() {
              toDos.insert(deletedTodoPosition!, deletedTodo!);
            });
            todoRepository.saveTodoList(toDos);
          },
        ),
        duration: Duration(seconds: 5),
      ),
    );
  }

  void showDeleToDosConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Limpar tudo?'),
        content: Text('Você tem certeza que deseja remover todas as tarefas?'),
        actions: [
          TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancelar')),
          TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                deleteAllTodos();
              },
              child: Text('Limpar Tudo')),
        ],
      ),
    );
  }

  void deleteAllTodos() {
    setState(() {
      toDos.clear();
    });
    todoRepository.saveTodoList(toDos);
  }
}
