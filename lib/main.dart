import 'package:flutter/material.dart';
import 'package:todo_app_sqlite_freezed/models/todo_model.dart';
import 'package:todo_app_sqlite_freezed/pages/add_task.dart';
import 'package:todo_app_sqlite_freezed/pages/edit_task.dart';
import 'database.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
                      direction: DismissDirection.horizontal,
                      background: Container(
                        //Esthétique quand on swipe droite ou gauche avec icone et couleur différente pour faciliter la compréhension.
                        color: Colors.red,
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Icon(
                                Icons.delete,
                                color: Colors.white,
                                size: 32.0,
                              ),
                            ),
                          ],
                        ),
                      ),
                      secondaryBackground: Container(
                        color: Colors.blue,
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Icon(
                                Icons.edit,
                                color: Colors.white,
                                size: 32.0,
                              ),
                            ),
                          ],
                        ),
                      ),
                      onDismissed: (direction) async {
                        if (direction == DismissDirection.startToEnd) {
                          //Swipe vers la suppresion de la tâche
                          await DatabaseHelper.instance.delete(task.id!);
                          setState(() {
                            _data = DatabaseHelper.instance.getAllTodos();
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content:
                                    Text('Pouf ! ${task.task} disparait !')),
                          );
                        } else if (direction == DismissDirection.endToStart) {
                          // Swipe vers la modification de la tâche
                          final updatedTask = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditTaskPage(task: task),
                            ),
                          );

                          if (updatedTask != null) {
                            // Mise à jour de la liste des tâches après avoir apporté des modifications
                            setState(() {
                              _data = DatabaseHelper.instance.getAllTodos();
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Modification réussi !')),
                            );
                          }
                        }
                      },
                      child: ListTile(
                        title: Text(
                          task.task,
                          style: TextStyle(
                            //On verifié l'état de la tâche pour barer ou non la tache
                            color: isCompleted ? Colors.green : Colors.black,
                            decoration: isCompleted
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                          ),
                        ),
                        onTap: () async {
                          //Permet au clic, de modifier l'état de la tache
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
              return CircularProgressIndicator();
            }
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        //Bouton d'ajout d'une tâche, ouvre sur une nouvelle page et reactualise les tâches une fois ajoutée.
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
