import 'package:intl/intl.dart';
import 'package:ontrek/core/background_service_model/activity_model.dart';
import 'package:ontrek/core/background_service_model/app_off_time_model.dart';
import 'package:ontrek/core/background_service_model/offline_route_model.dart';
import 'package:ontrek/core/utils/app_constant.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:uuid/uuid.dart';

class DatabaseService {
    // Database instance
  Future<Database> initializeOnTrekDB() async {
    String path = await getDatabasesPath();
    return openDatabase(
      join(path, 'OnTrek.db'),
      onCreate: (database, version) async {
        createTables(database);
      },
      version: 1,
    );
  }


  Future<void> createTables(db) async {
    await db.execute('''
      CREATE TABLE offline_routes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        latitude REAL,
        longitude REAL,
        offlineTime TEXT
      );
    ''');

    await db.execute('''
      CREATE TABLE App_Off_Time (
        pkId TEXT PRIMARY KEY,
        startTime TEXT,
        stopTime TEXT
      );
    ''');

    await db.execute('''
      CREATE TABLE Activity (
        PkId INTEGER PRIMARY KEY,
        SessionId TEXT NOT NULL,
        EventCode TEXT,
        Latitude REAL NOT NULL,
        Longitude REAL NOT NULL,
        ActivityDate TEXT,
        ParentId INTEGER,
        IsSync BOOLEAN NOT NULL,
        IsEventCompleted BOOLEAN NOT NULL,
        WaitingStart INTEGER
      );
    ''');
  }



  Future<void> insertOrUpdateAppOffTime(Database db, AppOffTime newAppOffTime) async {
    final uuid = Uuid();
    final newGuid = uuid.v4();
    newAppOffTime.pkId = newGuid;

    final latestAppOffTime = await getLatestAppOffTime(db);

    if (latestAppOffTime != null) {
      final previousEndTime = DateTime.parse(latestAppOffTime.stopTime);
      final newStartTime = DateTime.parse(newAppOffTime.startTime);

      final difference = newStartTime.difference(previousEndTime);

      if (difference.inMinutes > 2) {
        // Insert a new row with the new GUID
        await db.insert(
          'App_Off_Time',
          newAppOffTime.toMap(),
        );
      } else {
        // Update the existing row
        await db.update(
          'App_Off_Time',
          {
            'stopTime': newAppOffTime.stopTime,
          },
          where: 'pkId = ?',
          whereArgs: [latestAppOffTime.pkId],
        );
      }
    } else {
      // Insert the first row if there is no previous entry, with the new GUID
      await db.insert(
        'App_Off_Time',
        newAppOffTime.toMap(),
      );
    }
  }



  Future<AppOffTime?> getLatestAppOffTime(Database db) async {
    final List<Map<String, dynamic>> maps = await db.query(
      'App_Off_Time',
      orderBy: 'PkId DESC',
      limit: 1,
    );

    if (maps.isNotEmpty) {
      return AppOffTime.fromMap(maps.first);
    } else {
      return null;
    }
  }

  Future<List<AppOffTime>> getAllAppOffTime(Database db, ) async {
    //final Database db = await initializeOnTrekDB();

    final List<Map<String, dynamic>> maps = await db.query('App_Off_Time');

    return maps.map((json) => AppOffTime.fromMap(json)).toList();
  }




  Future<int> insertRoute(Database db, OfflineRouteModel route) async {
    //final Database db = await initializeOnTrekDB();

    return await db.insert('offline_routes', route.toJson());
  }

  Future<List<OfflineRouteModel>> getRoutes(Database db, ) async {
    //final Database db = await initializeOnTrekDB();

    final List<Map<String, dynamic>> maps = await db.query('offline_routes');

    return maps.map((json) => OfflineRouteModel.fromJson(json)).toList();
  }

  Future<void> insertGpsActivity(Database db, Activity activity) async {
    //final Database db = await initializeOnTrekDB();

     List<Map<String, dynamic>> gpsOff;

     gpsOff = await db.query(
      'Activity',
      where: 'IsEventCompleted = ? AND EventCode = ?',
      whereArgs: [0, AppConstant.gpsOffEvent]
    );

    List<Activity> gpsOffActivity = gpsOff.map((json) => Activity.fromJson(json)).toList();

    if (gpsOffActivity.length > 1) {
      for (var i = 1; i < gpsOffActivity.length; i++) {
        await db.delete(
          'Activity',
          where: 'PkId = ?',
          whereArgs: [gpsOffActivity[i].pkId],
        );
      }
    }

    gpsOff = await db.query(
      'Activity',
      where: 'IsEventCompleted = ? AND EventCode = ?',
      whereArgs: [0, AppConstant.gpsOffEvent],
    );

    gpsOffActivity = gpsOff.map((json) => Activity.fromJson(json)).toList();

    if (activity.eventCode == AppConstant.gpsOffEvent && gpsOffActivity.isEmpty) {
      final result = await db.rawQuery('SELECT MAX(PkId) AS max_pkid FROM Activity');
      final maxPkid = (result.first['max_pkid'] as int?) ?? 0;
      activity.pkId = maxPkid + 1;
      activity.isSync = false;
      activity.isEventCompleted = false;

      await db.insert('Activity', activity.toJson());
    }

    if (activity.eventCode == AppConstant.gpsOnEvent) {
      final List<Map<String, Object?>> gpsOn = await db.query(
        'Activity',
        where: 'IsEventCompleted = ? AND EventCode = ?',
        whereArgs: [0, AppConstant.gpsOnEvent],
      );

      if (gpsOn.isEmpty && gpsOff.length == 1) {

        final result = await db.rawQuery('SELECT MAX(PkId) AS max_pkid FROM Activity');
        final maxPkid = (result.first['max_pkid'] as int?) ?? 0;

        gpsOffActivity[0].isEventCompleted = true;

        activity.parentId =  gpsOffActivity[0].pkId;
        activity.isEventCompleted = true;
        activity.pkId = maxPkid + 1;

        await db.rawQuery('update Activity set IsEventCompleted=1 where PkId=' + gpsOffActivity[0].pkId.toString() + '');
        await db.insert('Activity', activity.toJson());
      }
    }
  }

  Future<void> insertInternetActivity(Database db, Activity activity) async {
    //final Database db = await initializeOnTrekDB();
    await db.insert('Activity', activity.toJson());
  }

  getMaxPkId(Database db, )async{
    //final Database db = await initializeOnTrekDB();

    final result = await db.rawQuery('SELECT MAX(PkId) AS max_pkid FROM Activity');
    final maxPkid = (result.first['max_pkid'] as int?) ?? 0;
    return maxPkid;
  }

  Future<void> insertWaitingActivity(Database db, Activity activity) async {
    //final Database db = await initializeOnTrekDB();
    List<Map<String, dynamic>> waitingStart;

    waitingStart = await db.query(
        'Activity',
        where: 'IsEventCompleted = ? AND EventCode = ?',
        whereArgs: [0, AppConstant.trackingWaitingStartEvent]
    );

    List<Activity> waitingStartActivity = waitingStart.map((json) => Activity.fromJson(json)).toList();

    if (waitingStartActivity.length > 1) {
      for (var i = 1; i < waitingStartActivity.length; i++) {
        await db.delete(
          'Activity',
          where: 'PkId = ?',
          whereArgs: [waitingStartActivity[i].pkId],
        );
      }
    }
    waitingStart = await db.query(
      'Activity',
      where: 'IsEventCompleted = ? AND EventCode = ?',
      whereArgs: [0, AppConstant.trackingWaitingStartEvent],
    );

    waitingStartActivity = waitingStart.map((json) => Activity.fromJson(json)).toList();

    if (activity.eventCode == AppConstant.trackingWaitingStartEvent && waitingStartActivity.isEmpty) {
      final result = await db.rawQuery('SELECT MAX(PkId) AS max_pkid FROM Activity');
      final maxPkid = (result.first['max_pkid'] as int?) ?? 0;
      activity.pkId = maxPkid + 1;
      activity.isSync = false;
      activity.isEventCompleted = false;
      await db.insert('Activity', activity.toJson());
    }

    if (activity.eventCode == AppConstant.trackingWaitingStopEvent) {
      final List<Map<String, Object?>> waitingStop = await db.query(
        'Activity',
        where: 'IsEventCompleted = ? AND EventCode = ?',
        whereArgs: [0, AppConstant.trackingWaitingStopEvent],
      );

      if (waitingStop.isEmpty && waitingStart.length == 1) {

          final result = await db.rawQuery('SELECT MAX(PkId) AS max_pkid FROM Activity');
          final maxPkid = (result.first['max_pkid'] as int?) ?? 0;

          waitingStartActivity[0].isEventCompleted = true;

          activity.parentId =  waitingStartActivity[0].pkId;
          activity.isEventCompleted = true;
          activity.pkId = maxPkid + 1;

          await db.rawQuery('update Activity set IsEventCompleted=1 where PkId=' + waitingStartActivity[0].pkId.toString() + '');
          await db.insert('Activity', activity.toJson());

      }
    }
  }

  Future<void> removeSyncedNotCompletedEvents(Database db, ) async
  {
   // final Database db = await initializeOnTrekDB();
    await db.rawQuery("delete from Activity where IsSync=1 AND IsEventCompleted=0");
  }

  Future<void> syncRecord(Database db, int pkId) async {
    //final Database db = await initializeOnTrekDB();
    await db.rawUpdate("UPDATE Activity SET IsSync = 1 WHERE PkId = ?", [pkId]);
  }

  Future<List<Activity>?> getAllSyncedActivity(Database db,) async {
    //final Database db = await initializeOnTrekDB();
    // final List<Map<String, Object?>> maps = await db.query(
    //   'Activity',
    //   where: 'isSync = ?',
    //   whereArgs: [0],
    // );

    final List<Map<String, Object?>> queryResult = await db.query('Activity', where: "IsSync = ?", whereArgs: [0]);

    if(queryResult != null && queryResult.length > 0)
      {
        return queryResult.map((json) => Activity.fromJson(json)).toList();
      }

    return null;
  }

  Future<int> deleteAllRoutes(Database db) async {
    //final Database db = await initializeOnTrekDB();
    return await db.delete('offline_routes');
  }
  Future<int> deleteAppOfTime(Database db) async {
    //final Database db = await initializeOnTrekDB();
    return await db.delete('App_Off_Time');
  }

  Future<int> deleteAllActivities(Database db) async {
    //final Database db = await initializeOnTrekDB();
    return await db.delete('Activity');
  }

  Future<Activity?> getUnSyncedWaitingStartActivity(Database db) async {
    //final Database db = await initializeOnTrekDB();
    final List<Map<String, Object?>> queryResult = await db.query('Activity', where: "IsEventCompleted = ? AND EventCode = ?", whereArgs: [0, AppConstant.trackingWaitingStartEvent], limit: 1,);

    if (queryResult.isNotEmpty) {
      return Activity.fromJson(queryResult.first);
    }

    return null;
  }

  Future<void> removeActivity(Database db,int pkID) async
  {
    //final Database db = await initializeOnTrekDB();
    await db.rawQuery("delete from Activity where PkId=$pkID");
  }
}
