import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart' as SQL;

class SQLHelper {
  //create a table
  static Future<void> createTables(SQL.Database database) async {
    await database.execute("""CREATE TABLE items(
    id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
    title TEXT,
    description TEXT,
    createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
    )
    """);
  }

  //create a database with table
  static Future<SQL.Database> db() async {
    return SQL.openDatabase(
      "example.db",
      version: 1,
      onCreate: (SQL.Database database, int version) async {
        await createTables(database);
      },
    );
  }

  //create an item into table
  static Future<int> createItem(String title, String? description) async {
    final db = await SQLHelper.db();
    final data = {"title": title, "description": description};
    final id = await db.insert(
      "items",
      data,
      conflictAlgorithm: SQL.ConflictAlgorithm.replace,
    );
    return id;
  }

  //get items list from table
  static Future<List<Map<String, dynamic>>> getItems() async {
    final db = await SQLHelper.db();
    return db.query("items", orderBy: "id");
  }

  //get item by id from table
  static Future<List<Map<String, dynamic>>> getItemById(int id) async {
    final db = await SQLHelper.db();
    return db.query("items", where: "id = ?", whereArgs: [id], limit: 1);
  }

  //update an item by id in to the table
  static Future<int> updateItem(int id, String title, String? description) async {
    final db = await SQLHelper.db();
    final data = {"title": title, "description": description, "createdAt": DateTime.now().toString()};
    final result = await db.update("items", data, where: "id = ?", whereArgs: [id]);
    return result;
  }

  //delete an item by id from the table
  static Future<void> deleteItemById(int id) async {
    final db = await SQLHelper.db();
    try {
      await db.delete("items", where: "id = ?", whereArgs: [id]);
    } catch (error) {
      print("something went wrong when deleting an item:$error");
    }
  }
}
