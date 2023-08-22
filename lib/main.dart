import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter_sqflite_database/sql_helper.dart';

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
      theme: ThemeData(),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> todolist = [];

  bool isLoading = true;

  void getToDoList() async {
    final data = await SQLHelper.getItems();
    setState(() {
      todolist = data;
      isLoading = false;
    });
    print("no of items ${todolist.length}");
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getToDoList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("SQL CRUD by Sqflite"),
      ),
      body: ListView.builder(
          itemCount: todolist.length,
          itemBuilder: (context, index) {
            return Card(
              elevation: 2,
              child: ListTile(
                title: Text(todolist[index]["title"]),
                subtitle: Text(todolist[index]["description"]),
                trailing: SizedBox(
                  width: 100,
                  child: Row(
                    children: [
                      IconButton(
                          onPressed: () {
                            showForm(todolist[index]["id"]);
                          },
                          icon: Icon(Icons.edit)),
                      IconButton(
                          onPressed: () {
                            deleteItem(todolist[index]["id"]);
                          },
                          icon: Icon(Icons.delete)),
                    ],
                  ),
                ),
              ),
            );
          }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showForm(null),
        child: Icon(Icons.add),
      ),
    );
  }

  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  Future<void> addItem() async {
    String title = titleController.text.toString();
    String description = descriptionController.text.toString();
    await SQLHelper.createItem(title, description);
    getToDoList();
  }

  Future<void> updateItem(int id) async {
    String title = titleController.text.toString();
    String description = descriptionController.text.toString();
    await SQLHelper.updateItem(id, title, description);
    getToDoList();
  }

  Future<void> deleteItem(int id) async {
    await SQLHelper.deleteItemById(id);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Sucessfully deleted the item from database")));
    getToDoList();
  }

  void showForm(int? id) async {
    if (id != null) {
      final existingItem = todolist.firstWhere((element) => element["id"] == id);
      titleController.text = existingItem["title"];
      descriptionController.text = existingItem["description"];
    }

    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        elevation: 5,
        builder: (context) {
          return Container(
            padding: EdgeInsets.only(top: 15, right: 15, left: 15, bottom: MediaQuery.of(context).viewInsets.bottom + 120),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(hintText: "Title"),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: descriptionController,
                  decoration: InputDecoration(hintText: "Description"),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                    onPressed: () async {
                      if (id == null) {
                        await addItem();
                      } else {
                        await updateItem(id);
                      }
                      titleController.text = "";
                      descriptionController.text = "";
                      Navigator.of(context).pop();
                    },
                    child: Text(id == null ? "Create New" : "Update"))
              ],
            ),
          );
        });
  }
}
