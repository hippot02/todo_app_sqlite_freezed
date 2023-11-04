import 'package:flutter/material.dart';
import 'package:todo_app_sqlite_freezed/models/todo_model.dart';
import 'package:todo_app_sqlite_freezed/database.dart';

class EditTaskPage extends StatefulWidget {
  final Todo task;

  EditTaskPage({required this.task});

  @override
  _EditTaskPageState createState() => _EditTaskPageState();
}

class _EditTaskPageState extends State<EditTaskPage> {
  final TextEditingController taskController = TextEditingController();

  @override
  void initState() {
    super.initState();
    taskController.text = widget.task.task;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Page de modification, tout ce qu'il y a de plus basique, on créer une copie avec les modifications souhaitées et on update la bdd.
      appBar: AppBar(
        title: Text("Modifier la tâche"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: taskController,
              decoration: const InputDecoration(labelText: "Tâche modifiée"),
            ),
            const SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () async {
                String updatedTask = taskController.text;
                if (updatedTask.isNotEmpty) {
                  final updatedTodo = widget.task.copyWith(task: updatedTask);
                  await DatabaseHelper.instance.update(updatedTodo);
                  Navigator.of(context).pop(updatedTodo);
                }
              },
              child: const Text("Enregistrer les modifications"),
            ),
          ],
        ),
      ),
    );
  }
}
