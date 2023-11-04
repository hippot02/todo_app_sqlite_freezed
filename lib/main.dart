import 'package:flutter/material.dart';
import 'package:todo_app_sqlite_freezed/models/todo_model.dart';
import 'package:todo_app_sqlite_freezed/pages/add_task.dart';
import 'database.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Ma TodoList'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // Initialisez _data avec une liste vide au départ
  late Future<List<Todo>> _data = DatabaseHelper.instance.getAllTodos();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: FutureBuilder(
          future: _data,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                return ListView.builder(
                  itemCount: snapshot.data?.length,
                  itemBuilder: (context, index) {
                    final task = snapshot.data![index];
                    final isCompleted = task.isCompleted;
                    return Dismissible(
                      key: Key(task.toString()),
                      onDismissed: (direction) async {
                        await DatabaseHelper.instance.delete(task.id!);
                        setState(() {
                          _data = DatabaseHelper.instance.getAllTodos();
                        });
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text('Pouf ! ${task.task} disparait !')));
                      },
                      background: Container(color: Colors.red),
                      child: ListTile(
                        title: Text(
                          task.task,
                          style: TextStyle(
                            color: isCompleted ? Colors.green : Colors.black,
                            decoration: isCompleted
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                          ),
                        ),
                        onTap: () async {
                          final updatedTask =
                              task.copyWith(isCompleted: !isCompleted);
                          await DatabaseHelper.instance.update(updatedTask);
                          setState(() {
                            _data = DatabaseHelper.instance.getAllTodos();
                          });
                        },
                      ),
                    );
                  },
                );
              } else {
                return const Text('Aucune tâche trouvée.');
              }
            } else if (snapshot.hasError) {
              return Text('Erreur : ${snapshot.error}');
            } else {
              return const CircularProgressIndicator();
            }
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newTask = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddTaskPage(),
            ),
          );
          if (newTask != null) {
            setState(() {
              _data = DatabaseHelper.instance.getAllTodos();
            });
          }
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
