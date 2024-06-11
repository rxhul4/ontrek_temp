import 'package:ontrek/core/background_service_model/offline_route_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static Database? _database;

  factory DatabaseService() {
    return _instance;
  }

  DatabaseService._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'app_database.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE offline_routes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        latitude REAL,
        longitude REAL,
        offlineTime TEXT
      )
    ''');
  }

  Future<int> insertRoute(OfflineRouteModel route) async {
    final db = await database;
    return await db.insert('offline_routes', route.toJson());
  }

  Future<List<OfflineRouteModel>> getRoutes() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('offline_routes');

    return List.generate(maps.length, (i) {
      return OfflineRouteModel.fromJson(maps[i]);
    });
  }

  Future<int> deleteAllRoutes() async {
    final db = await database;
    return await db.delete('offline_routes');
  }

// Add update and delete methods if needed
}
