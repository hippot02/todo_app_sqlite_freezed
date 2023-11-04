import 'package:flutter/material.dart';
import 'package:todo_app_sqlite_freezed/models/todo_model.dart';
import 'package:todo_app_sqlite_freezed/database.dart';

class AddTaskPage extends StatefulWidget {
  @override
  _AddTaskPageState createState() => _AddTaskPageState();
}

class _AddTaskPageState extends State<AddTaskPage> {
  final TextEditingController taskController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // Permet d'ajouter une tâche
    return Scaffold(
      appBar: AppBar(
        title: Text("Ajouter une tâche"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: taskController,
              decoration: const InputDecoration(labelText: "Nouvelle tâche"),
            ),
            const SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () async {
                String newTask = taskController.text;
                if (newTask.isNotEmpty) {
                  final todo = Todo(task: newTask, isCompleted: false);
                  final result = await DatabaseHelper.instance.insert(todo);

                  if (result > 0) {
                    Navigator.of(context).pop(todo);
                  }
                }
              },
              child: const Text("Valider"),
            ),
          ],
        ),
      ),
    );
  }
}
