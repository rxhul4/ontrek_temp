import 'package:intl/intl.dart';
import 'package:ontrek/core/background_service_model/activity_model.dart';
import 'package:ontrek/core/background_service_model/offline_route_model.dart';
import 'package:ontrek/core/utils/app_constant.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseService {
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


  Future<int> insertRoute(OfflineRouteModel route) async {
    final Database db = await initializeOnTrekDB();
    return await db.insert('offline_routes', route.toJson());
  }

  Future<List<OfflineRouteModel>> getRoutes() async {
    final Database db = await initializeOnTrekDB();
    final List<Map<String, dynamic>> maps = await db.query('offline_routes');

    return maps.map((json) => OfflineRouteModel.fromJson(json)).toList();
  }

  Future<void> insertGpsActivity(Transaction txn,Activity activity) async {

     List<Map<String, dynamic>> gpsOff;

     gpsOff = await txn.query(
      'Activity',
      where: 'IsEventCompleted = ? AND EventCode = ?',
      whereArgs: [0, AppConstant.gpsOffEvent]
    );

    List<Activity> gpsOffActivity = gpsOff.map((json) => Activity.fromJson(json)).toList();

    if (gpsOffActivity.length > 1) {
      for (var i = 1; i < gpsOffActivity.length; i++) {
        await txn.delete(
          'Activity',
          where: 'PkId = ?',
          whereArgs: [gpsOffActivity[i].pkId],
        );
      }
    }

    gpsOff = await txn.query(
      'Activity',
      where: 'IsEventCompleted = ? AND EventCode = ?',
      whereArgs: [0, AppConstant.gpsOffEvent],
    );

    gpsOffActivity = gpsOff.map((json) => Activity.fromJson(json)).toList();

    if (activity.eventCode == AppConstant.gpsOffEvent && gpsOffActivity.isEmpty) {
      final result = await txn.rawQuery('SELECT MAX(PkId) AS max_pkid FROM Activity');
      final maxPkid = (result.first['max_pkid'] as int?) ?? 0;
      activity.pkId = maxPkid + 1;
      activity.isSync = false;
      activity.isEventCompleted = false;

      await txn.insert('Activity', activity.toJson());
    }

    if (activity.eventCode == AppConstant.gpsOnEvent) {
      final List<Map<String, Object?>> gpsOn = await txn.query(
        'Activity',
        where: 'IsEventCompleted = ? AND EventCode = ?',
        whereArgs: [0, AppConstant.gpsOnEvent],
      );

      if (gpsOn.isEmpty && gpsOff.length == 1) {

        final result = await txn.rawQuery('SELECT MAX(PkId) AS max_pkid FROM Activity');
        final maxPkid = (result.first['max_pkid'] as int?) ?? 0;

        gpsOffActivity[0].isEventCompleted = true;

        activity.parentId =  gpsOffActivity[0].pkId;
        activity.isEventCompleted = true;
        activity.pkId = maxPkid + 1;

        await txn.rawQuery('update Activity set IsEventCompleted=1 where PkId=' + gpsOffActivity[0].pkId.toString() + '');
        await txn.insert('Activity', activity.toJson());
      }
    }
  }

  Future<void> insertInternetActivity(Transaction txn,Activity activity) async {

    List<Map<String, dynamic>> internetOff;

    internetOff = await txn.query(
        'Activity',
        where: 'IsEventCompleted = ? AND EventCode = ?',
        whereArgs: [0, AppConstant.internetOffEvent]
    );

    List<Activity> internetOffActivity = internetOff.map((json) => Activity.fromJson(json)).toList();

    if (internetOffActivity.length > 1) {
      for (var i = 1; i < internetOffActivity.length; i++) {
        await txn.delete(
          'Activity',
          where: 'PkId = ?',
          whereArgs: [internetOffActivity[i].pkId],
        );
      }
    }

    internetOff = await txn.query(
      'Activity',
      where: 'IsEventCompleted = ? AND EventCode = ?',
      whereArgs: [0, AppConstant.internetOffEvent],
    );

    internetOffActivity = internetOff.map((json) => Activity.fromJson(json)).toList();

    if (activity.eventCode == AppConstant.internetOffEvent && internetOffActivity.isEmpty) {
      final result = await txn.rawQuery('SELECT MAX(PkId) AS max_pkid FROM Activity');
      final maxPkid = (result.first['max_pkid'] as int?) ?? 0;
      activity.pkId = maxPkid + 1;
      activity.isSync = false;
      activity.isEventCompleted = false;

      await txn.insert('Activity', activity.toJson());
    }

    if (activity.eventCode == AppConstant.internetOnEvent) {
      final List<Map<String, Object?>> internetOn = await txn.query(
        'Activity',
        where: 'IsEventCompleted = ? AND EventCode = ?',
        whereArgs: [0, AppConstant.internetOnEvent],
      );

      if (internetOn.isEmpty && internetOff.length == 1) {

        bool isDifferenceLessTwoMinutes = isDifferenceLessFiveMinutes(internetOff[0]["ActivityDate"], activity.activityDate ?? "");
        if (isDifferenceLessTwoMinutes) {
          await txn.delete('Activity', where: 'pkId = ?', whereArgs: [internetOff[0]["pkId"]]);
        }else
        {
          final result = await txn.rawQuery('SELECT MAX(PkId) AS max_pkid FROM Activity');
          final maxPkid = (result.first['max_pkid'] as int?) ?? 0;

          internetOffActivity[0].isEventCompleted = true;

          activity.parentId =  internetOffActivity[0].pkId;
          activity.isEventCompleted = true;
          activity.pkId = maxPkid + 1;

          await txn.rawQuery('update Activity set IsEventCompleted=1 where PkId=' + internetOffActivity[0].pkId.toString() + '');
          await txn.insert('Activity', activity.toJson());
        }
      }
    }
  }

  Future<void> insertWaitingActivity(Transaction txn,Activity activity) async {

    List<Map<String, dynamic>> waitingStart;

    waitingStart = await txn.query(
        'Activity',
        where: 'IsEventCompleted = ? AND EventCode = ?',
        whereArgs: [0, AppConstant.trackingWaitingStartEvent]
    );

    List<Activity> waitingStartActivity = waitingStart.map((json) => Activity.fromJson(json)).toList();

    if (waitingStartActivity.length > 1) {
      for (var i = 1; i < waitingStartActivity.length; i++) {
        await txn.delete(
          'Activity',
          where: 'PkId = ?',
          whereArgs: [waitingStartActivity[i].pkId],
        );
      }
    }

    waitingStart = await txn.query(
      'Activity',
      where: 'IsEventCompleted = ? AND EventCode = ?',
      whereArgs: [0, AppConstant.trackingWaitingStartEvent],
    );

    waitingStartActivity = waitingStart.map((json) => Activity.fromJson(json)).toList();

    if (activity.eventCode == AppConstant.trackingWaitingStartEvent && waitingStartActivity.isEmpty) {
      final result = await txn.rawQuery('SELECT MAX(PkId) AS max_pkid FROM Activity');
      final maxPkid = (result.first['max_pkid'] as int?) ?? 0;
      activity.pkId = maxPkid + 1;
      activity.isSync = false;
      activity.isEventCompleted = false;

      await txn.insert('Activity', activity.toJson());
    }

    if (activity.eventCode == AppConstant.trackingWaitingStopEvent) {
      final List<Map<String, Object?>> waitingStop = await txn.query(
        'Activity',
        where: 'IsEventCompleted = ? AND EventCode = ?',
        whereArgs: [0, AppConstant.trackingWaitingStopEvent],
      );

      if (waitingStop.isEmpty && waitingStart.length == 1) {

          final result = await txn.rawQuery('SELECT MAX(PkId) AS max_pkid FROM Activity');
          final maxPkid = (result.first['max_pkid'] as int?) ?? 0;

          waitingStartActivity[0].isEventCompleted = true;

          activity.parentId =  waitingStartActivity[0].pkId;
          activity.isEventCompleted = true;
          activity.pkId = maxPkid + 1;

          await txn.rawQuery('update Activity set IsEventCompleted=1 where PkId=' + waitingStartActivity[0].pkId.toString() + '');
          await txn.insert('Activity', activity.toJson());

      }
    }
  }



  Future<void> syncRecord(int pkId) async {
    final Database db = await initializeOnTrekDB();
    await db.rawUpdate("UPDATE Activity SET IsSync = 1 WHERE PkId = ?", [pkId]);
  }

  Future<List<Activity>?> getAllSyncedActivity() async {
    final Database db = await initializeOnTrekDB();
    // final List<Map<String, Object?>> maps = await db.query(
    //   'Activity',
    //   where: 'isSync = ?',
    //   whereArgs: [0],
    // );

    final List<Map<String, Object?>> queryResult =
    await db.query('Activity', where: "IsSync = ?", whereArgs: [0]);

    if(queryResult != null && queryResult.length > 0)
      {
        return queryResult.map((json) => Activity.fromJson(json)).toList();
      }

    return null;
  }

  Future<int> deleteAllRoutes() async {
    final Database db = await initializeOnTrekDB();
    return await db.delete('offline_routes');
  }

  Future<int> deleteAllActivities() async {
    final Database db = await initializeOnTrekDB();
    return await db.delete('Activity');
  }

  bool isDifferenceLessFiveMinutes(String time1, String time2) {
    final format = DateFormat(AppConstant.dateFormat);

    DateTime dateTime1 = format.parse(time1);
    DateTime dateTime2 = format.parse(time2);

    Duration difference = dateTime1.difference(dateTime2).abs();
    return difference.inMinutes < 5;
  }
}
