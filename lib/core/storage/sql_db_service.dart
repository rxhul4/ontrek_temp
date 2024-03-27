import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseService {
  Database? _database;

  Future<void> initializeDatabase() async {
    String path = await getDatabasesPath();
    String databasePath = join(path, 'onTrek.db');

    _database = await openDatabase(
      databasePath,
      version: 1,
      onCreate: (Database db, int version) async {
        await db.execute(
          'CREATE TABLE onTrek (id INTEGER PRIMARY KEY, isWaiting INTEGER)',
        );
      },
    );
  }

  Future<void> startWaiting() async {
    if (_database == null) {
      await initializeDatabase();
    }
    await _database?.rawInsert(
      'INSERT OR REPLACE INTO onTrek(id, isWaiting) VALUES(1, 1)'
    );
  }
  Future<void> deleteWaiting() async {

    if (_database == null) {
      await initializeDatabase();
    }
      await _database?.rawDelete('DELETE FROM onTrek');

  }


  Future<bool> getWaitingStatus() async {
    try {

      if (_database == null) {
        await initializeDatabase();
      }

      List<Map<String, dynamic>>? result = await _database?.rawQuery(
        'SELECT isWaiting FROM onTrek LIMIT 1',
      );

      if (result != null && result.isNotEmpty) {
        return true;
      }


      return false;
    } catch (e) {
      // Handle any potential errors (e.g., database not initialized, query failed)
      print('Error fetching waiting status: $e');
      return false;
    }
  }
}
