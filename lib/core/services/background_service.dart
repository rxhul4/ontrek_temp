import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_background_service_ios/flutter_background_service_ios.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:intl/intl.dart';
import 'package:ontrek/core/background_service_model/activity_model.dart';
import 'package:ontrek/core/background_service_model/bulk_activity_request_moodel.dart';
import 'package:ontrek/core/background_service_model/bulk_activity_response_model.dart';
import 'package:ontrek/core/background_service_model/create_route_history_model.dart';
import 'package:ontrek/core/background_service_model/offline_route_model.dart';
import 'package:ontrek/core/services/Throttler.dart';
import 'package:ontrek/core/services/api_constants.dart';
import 'package:ontrek/core/services/local_notification.dart';
import 'package:ontrek/core/services/network_repository.dart';
import 'package:ontrek/core/storage/db_service.dart';
import 'package:ontrek/core/storage/preference_helper.dart';
import 'package:ontrek/core/utils/App_utils.dart';
import 'package:ontrek/core/utils/app_constant.dart';
import 'package:ontrek/features/attendance/model/get_last_activity_model.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqlite_api.dart';

const notificationChannelId = 'my_foreground';
const notificationId = 888;

LastActivityData? lastActivityData;
List<Activity>? listOfAllActivity;

double? prevLatitude = null;
double? prevLongitude = null;
double? currentLatitude = null;
double? currentLongitude = null;

bool isInternetAvailable = false;
bool isGpsAvailable = false;

bool isCheckIn = false;
bool isInRadius = false;

String? waitingStartTime = "";
double? lastWaitingLat;
double? lastWaitingLong;

int? waitingTime = 10;

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

class BackgroundService {
  Future<void> initializeService() async {
    final service = FlutterBackgroundService();
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      notificationChannelId, // id
      'Background Service', // title
      description: 'Activated', // description
      importance: Importance.low,
    );
    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    await service.configure(
      iosConfiguration: IosConfiguration(
        // auto start service
        autoStart: false,
        // this will be executed when app is in foreground in separated isolate
        onForeground: onStart,
        // you have to enable background fetch capability on xcode project
        onBackground: onIosBackground,
      ),
      androidConfiguration: AndroidConfiguration(
        onStart: onStart,
        autoStart: false,
        isForegroundMode: true,

        notificationChannelId: notificationChannelId,
        // this must match with notification channel you created above.
        initialNotificationTitle: 'Background Location',
        initialNotificationContent: 'Initializing',
        foregroundServiceNotificationId: notificationId,
      ),
    );
  }
}

@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();

  // final log = preferences.getStringList('log') ?? <String>[];
  // log.add(DateTime.now().toIso8601String());
  // await preferences.setStringList('log', log);

  return true;
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();

  registerEventsToListener(service);

  PreferenceHelper.load().then((value) {
    int? liveLocationInterval =
        value?.getInt(PreferenceHelper.LIVE_LOCATION_INTERVAL) ?? 30;
    waitingTime = value?.getInt(PreferenceHelper.WAITING_TIME_INTERVAL);
    print("waitingTime$waitingTime");
    bool? isWaitingAllowed = value?.getBool(PreferenceHelper.ALLOW_WAITING);

    // Instantiate the throttler with the desired interval
    Throttler throttler = Throttler(milliseconds: (liveLocationInterval + 5) * 1000);

    Timer.periodic(
      Duration(seconds: liveLocationInterval),
          (timer) async {
        try {

          throttler.run(() async {
            //add developer mode function here

            print("throttler_start${DateTime.now()}");
            isInternetAvailable = await checkInternetConnectivity();
            isGpsAvailable = await isGpsOn();

            await PreferenceHelper.reload();
            waitingStartTime = PreferenceHelper.getString(PreferenceHelper.WAITING_START_TIME);
            lastWaitingLat = PreferenceHelper.getDouble(PreferenceHelper.LAST_LAT);
            lastWaitingLong = PreferenceHelper.getDouble(PreferenceHelper.LAST_LONG);

            // Stop service between 11:50 to 12:00 Midnight
            await stopServiceAtNight(service, timer);
            // Set notification icon
            await setBgNotificationIcon(service);
            await setLastActivityData();

            if (lastActivityData != null) {

              isInRadius = await isWithinRadius(
                  prevLat: prevLatitude,
                  prevLong: prevLongitude,
                  currentLat: currentLatitude,
                  currentLong: currentLongitude,
                  radiusMtr: 80);

              DatabaseService dbService = DatabaseService();
              Database db = await dbService.initializeOnTrekDB();

              await db.transaction((txn) async {
                try {
                  await ManageRouteHistory();
                  await ManageInternetOperations(txn);
                  await ManageGpsOperations(txn);
                  print("isCehckin$isCheckIn");
                  if (!isCheckIn && isWaitingAllowed == true) {
                    await ManageWaitingOperation(txn);
                  }
                } on DatabaseException catch (e) {
                  if (e.isUniqueConstraintError()) {
                    print('Error: Duplicate primary key');
                  } else {
                    rethrow;
                  }
                }
              });

              if (isInternetAvailable) {
                // Sync Route Data
                await syncRouteHistory();
                // Sync Event Data
                await syncSqlData();
              }
            }
            print("throttler_end${DateTime.now()}");
          });

        } catch (e) {
          print(e);
        }
      },
    );
  });
}

ManageRouteHistory() async {

  if (isGpsAvailable && !isInRadius) {

    final DatabaseService databaseService = DatabaseService();

    OfflineRouteModel dataPoint = OfflineRouteModel(
      latitude: currentLatitude ?? 0,
      longitude: currentLongitude ?? 0,
      offlineTime: AppUtils.getDate(
          date: DateTime.now().toString(), format: AppConstant.dateFormat),
    );

    if (dataPoint.latitude != 0.0 && dataPoint.longitude != 0.0) {
      await databaseService.insertRoute(dataPoint);
    }
  }
}

ManageGpsOperations(Transaction txn) async{

  DatabaseService dbService = DatabaseService();

  var activity = Activity(
      pkId: 0,
      sessionId: lastActivityData?.sessionId ?? "",
      latitude: currentLatitude ?? (prevLatitude ?? 0),
      longitude: currentLongitude ?? (prevLongitude ?? 0),
      activityDate: AppUtils.getDateTimeNow(),
      isSync: false,
      isEventCompleted: false);

  if (isGpsAvailable == true) {
    activity.eventCode = AppConstant.gpsOnEvent;
    activity.isSync = false;
    await  dbService.insertGpsActivity(txn,activity);

  }

  if (isGpsAvailable == false) {
    activity.eventCode = AppConstant.gpsOffEvent;
    activity.isSync = false;
    await dbService.insertGpsActivity(txn,activity);
  }
}

ManageInternetOperations(Transaction txn) async {

  DatabaseService dbService = DatabaseService();

  var activity = Activity(
      pkId: 0,
      sessionId: lastActivityData?.sessionId ?? "",
      latitude: currentLatitude ?? (prevLatitude ?? 0),
      longitude: currentLongitude ?? (prevLongitude ?? 0),
      activityDate: AppUtils.getDateTimeNow(),
      isSync: false,
      isEventCompleted: false);

  if (isInternetAvailable == true) {
    activity.eventCode = AppConstant.internetOnEvent;
    activity.isSync = false;
    await dbService.insertInternetActivity(txn,activity);
  }

  if (isInternetAvailable == false) {
    activity.eventCode = AppConstant.internetOffEvent;
    activity.isSync = false;
    await dbService.insertInternetActivity(txn,activity);
  }
}

ManageWaitingOperation(Transaction txn) async {

  DatabaseService dbService = DatabaseService();

  var activity = Activity(
      pkId: 0,
      sessionId: lastActivityData?.sessionId ?? "",
      latitude: currentLatitude ?? (prevLatitude ?? 0),
      longitude: currentLongitude ?? (prevLongitude ?? 0),
      isSync: false,
      isEventCompleted: false);



  if (isGpsAvailable == true) {
            //Waiting Start Event
            if (isInRadius)
            {
                print("isInRadius$waitingStartTime");
                print("waitingStartTime$waitingStartTime");

                if (DateTime.now() .difference(DateTime.parse(waitingStartTime ?? "")).inMinutes >=(2))
                {
                    //add waiting start  event
                    activity.eventCode = AppConstant.trackingWaitingStartEvent;
                    activity.latitude = lastWaitingLat ?? 0;
                    activity.longitude = lastWaitingLong ?? 0;
                    activity.activityDate = AppUtils.getDate(date: waitingStartTime.toString(),format: AppConstant.dateFormat);
                    await dbService.insertWaitingActivity(txn,activity);
                }
            }
            else
            {
              //Waiting End Event
              double? prevLat =  PreferenceHelper.getDouble(PreferenceHelper.LAST_LAT);
              double? prevLong =  PreferenceHelper.getDouble(PreferenceHelper.LAST_LONG);

              var IsWaitingInRadius = await isWithinRadius(prevLat: prevLat, prevLong: prevLong,currentLat: currentLatitude,currentLong: currentLongitude, radiusMtr: 80);

              if (!IsWaitingInRadius) {
                activity.eventCode = AppConstant.trackingWaitingStopEvent;
                activity.activityDate = AppUtils.getDateTimeNow();
                await dbService.insertWaitingActivity(txn, activity);
              }
              PreferenceHelper.setString(PreferenceHelper.WAITING_START_TIME, AppUtils.getDate(date: DateTime.now().toString(), format: AppConstant.dateFormat));
              PreferenceHelper.setDouble(PreferenceHelper.LAST_LAT, currentLatitude ?? (prevLatitude  ?? 0));
              PreferenceHelper.setDouble(PreferenceHelper.LAST_LONG, currentLongitude ?? (prevLongitude  ?? 0));
            }
  }
}

registerEventsToListener(ServiceInstance service) {
  try {
    if (service is AndroidServiceInstance) {
      service.on('setAsForeground').listen((event) {
        service.setAsForegroundService();
      });

      service.on('setAsBackground').listen((event) {
        service.setAsBackgroundService();
      });

      service.on('stopService').listen((event) async {
        final DatabaseService databaseService = DatabaseService();
        if (isInternetAvailable) {
          if (listOfAllActivity != null &&
              (listOfAllActivity?.length ?? 0) > 0) {
            PreferenceHelper.remove(PreferenceHelper.WAITING_START_TIME);
            PreferenceHelper.remove(PreferenceHelper.LAST_LAT);
            PreferenceHelper.remove(PreferenceHelper.LAST_LONG);

            await databaseService.deleteAllRoutes();
            await databaseService.deleteAllActivities();

            // PreferenceHelper.setStringList("offline_route_data", []);
            service.stopSelf();
          } else {
            PreferenceHelper.remove(PreferenceHelper.WAITING_START_TIME);
            PreferenceHelper.remove(PreferenceHelper.LAST_LAT);
            PreferenceHelper.remove(PreferenceHelper.LAST_LONG);
            await databaseService.deleteAllRoutes();
            // PreferenceHelper.setStringList("offline_route_data", []);
            service.stopSelf();
          }
        }
      });

      service.on('dayStart').listen((event) async {
        Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.low);
        PreferenceHelper.setString(PreferenceHelper.WAITING_START_TIME, AppUtils.getDate(date: DateTime.now().toString(), format: AppConstant.dateFormat));
        PreferenceHelper.setDouble(PreferenceHelper.LAST_LAT, currentLatitude ?? position.latitude);
        PreferenceHelper.setDouble(PreferenceHelper.LAST_LONG, currentLongitude ?? position.longitude);
      });

      service.on("checkIn_beforeEvent").listen((event) async {

        DatabaseService dbService = DatabaseService();
        Database db = await dbService.initializeOnTrekDB();

        await db.transaction((txn) async {
          try {
            await manualWaitingEndEvent(txn);
            await manualInternetOnEvent(txn);
            await manualGpsOnEvent(txn);

          } on DatabaseException catch (e) {
            if (e.isUniqueConstraintError()) {
              print('Error: Duplicate primary key');
            } else {
              rethrow;
            }
          }
        });

      });

      service.on("checkIn_afterEvent").listen((event) {
        PreferenceHelper.setBool(PreferenceHelper.checkIn, true);
        PreferenceHelper.reload();
        isCheckIn = PreferenceHelper.getBool(PreferenceHelper.checkIn);
      });

      service.on('checkOut_event').listen((event) {
        PreferenceHelper.setBool(PreferenceHelper.checkIn, false);
        isCheckIn = PreferenceHelper.getBool(PreferenceHelper.checkIn);
        print("isCheckIn$isCheckIn");
        PreferenceHelper.setString(PreferenceHelper.WAITING_START_TIME, AppUtils.getDate(date: DateTime.now().toString(), format: AppConstant.dateFormat));
        PreferenceHelper.setDouble(PreferenceHelper.LAST_LAT,  currentLatitude ?? (prevLatitude  ?? 0));
        PreferenceHelper.setDouble(PreferenceHelper.LAST_LONG,  currentLongitude ?? (prevLongitude  ?? 0));
      });

      service.on("dayEnd_beforeEvent").listen((event) async {
        // await syncData(listOfAllActivity!);
      });
    }
  } catch (e) {
    print("registerEventsToListener");
  }
}

manualWaitingEndEvent(Transaction txn) async{
  DatabaseService databaseService = DatabaseService();
  var activity = Activity(
      pkId: 0,
      sessionId: lastActivityData?.sessionId ?? "",
      latitude: currentLatitude ?? (prevLatitude ?? 0),
      longitude: currentLongitude ?? (prevLongitude ?? 0),
      eventCode : AppConstant.trackingWaitingStopEvent,
      );
      await databaseService.insertWaitingActivity(txn,activity);
      PreferenceHelper.setString(PreferenceHelper.WAITING_START_TIME,AppUtils.getDate(date: DateTime.now().toString(), format: AppConstant.dateFormat));
}

manualInternetOnEvent(Transaction txn)async {
  DatabaseService databaseService = DatabaseService();
  var activity = Activity(
      pkId: 0,
      sessionId: lastActivityData?.sessionId ?? "",
      latitude: currentLatitude ?? (prevLatitude ?? 0),
      longitude: currentLongitude ?? (prevLongitude ?? 0),
      eventCode : AppConstant.internetOnEvent,
  );
      await databaseService.insertInternetActivity(txn,activity);
}

manualGpsOnEvent(Transaction txn) async{

  DatabaseService databaseService = DatabaseService();
  var activity = Activity(
    pkId: 0,
    sessionId: lastActivityData?.sessionId ?? "",
    latitude: currentLatitude ?? (prevLatitude ?? 0),
    longitude: currentLongitude ?? (prevLongitude ?? 0),
    eventCode : AppConstant.gpsOnEvent,
  );
    await databaseService.insertGpsActivity(txn,activity);
}

BulkActivityRequestModel? bulkActivityRequestModel;
OfflineRouteModel? offlineRouteModel;
BulkActivityResponseModel? bulkActivityResponseModel;

CreateRouteHistoryModel? createRouteHistoryModel;

syncRouteHistory() async {
  try {

    final DatabaseService databaseService = DatabaseService();

    List<OfflineRouteModel> offlineData = await databaseService.getRoutes();

    List<OfflineMapData> offlineDataMaps = offlineData
        .map((route) => OfflineMapData(
      lattitude: route.latitude,
      longitude: route.longitude,
      offlineTime: route.offlineTime,
    )).toList();

    if (offlineDataMaps == null ||
        offlineDataMaps.length < 1 ||
        offlineDataMaps == []) {
      return;
    }

    Map<String, dynamic> body = {
      "userId": lastActivityData?.fieldUserId,
      "sessionId": lastActivityData?.sessionId,
      "offlineMapData": offlineDataMaps
    };

    String endPoint = ApiConstants.createRouteHistory;

    var response = await callPostMethod(endPoint, body);

    createRouteHistoryModel =
        CreateRouteHistoryModel.fromJson(json.decode(response));

    if (createRouteHistoryModel?.isError == false &&
        createRouteHistoryModel?.isValidationFailed == false) {

      await databaseService.deleteAllRoutes();

    }
  } catch (e) {
    print("createRouteHistory");
  }
}

syncSqlData() async {
  try {

    DatabaseService databaseService = DatabaseService();
    List<Activity>? listOfAllActivity = await databaseService.getAllSyncedActivity();


    var listOfflineData = listOfAllActivity?.where((element) => element.isSync == false).toList();


    if (listOfflineData == null || listOfflineData.length < 1)
    {
      return;
    } else {



      List<CreateActivityList> createActivityLists = [];

      for (var activity in listOfflineData) {
        int batteryLevel = await AppUtils.getBatteryLevel();

        var createActivityList = CreateActivityList(
          pkId: activity.pkId,
          parentId: activity.parentId,
          userId: lastActivityData?.fieldUserId,
          longitude: activity.longitude,
          lattitude: activity.latitude,
          totTrackingEventId: activity.eventCode,
          activityDateTime: activity.activityDate,
          batteryLevel: batteryLevel,
          sessionId: lastActivityData?.sessionId,
          visitNoteRequestForm: null,
          // offlineMapData: activity.eventCode == AppConstant.internetOnEvent ? offlineDataMaps : null
        );

        createActivityLists.add(createActivityList);
      }

      bulkActivityRequestModel =
          BulkActivityRequestModel(createActivityList: createActivityLists);

      if (createActivityLists.isNotEmpty) {
        Map<String, dynamic>? body = bulkActivityRequestModel?.toJson();
        if (body != null) {
          String endPoint = ApiConstants.bulkActivity;
          try {
            final response = await callPostMethod(endPoint, body);
            bulkActivityResponseModel =
                BulkActivityResponseModel.fromJson(json.decode(response));

            if (bulkActivityResponseModel?.isError == false) {

              bulkActivityResponseModel?.data?.forEach((element) {
                databaseService.syncRecord(element.localPkId ?? 0);
              });

              print("all Activity Data cleared");
            }
          } catch (e) {
            print("Error during all bulk activity request: $e");
          }
        }
      }
    }
  } catch (e) {
    print("syncData$e");
  }
}

Future<bool> checkInternetConnectivity() async {
  try {
    bool isIntAvailable = false;
    isIntAvailable = await InternetConnectionChecker().hasConnection;
    return isIntAvailable;
  } catch (e) {
    print("isInternetOn: $e");
    return false; // Return false in case of an error
  }
}

Future<bool> isGpsOn() async {
  try {
    final locationAlwaysStatus = await Permission.locationAlways.serviceStatus;
    final locationStatus = await Permission.location.serviceStatus;

    bool isGPSEnabled =
        locationAlwaysStatus.isEnabled && locationStatus.isEnabled;

    return isGPSEnabled;
  } catch (e) {
    print("isGpsOn: $e");
    return false; // Return false in case of an error
  }
}

setBgNotificationIcon(ServiceInstance service) async {
  try {
    if (service is AndroidServiceInstance) {
      if (await service.isForegroundService()) {
        flutterLocalNotificationsPlugin.show(
          notificationId,
          'On Trek Background Service',
          'Background location capturing initiated.',
          const NotificationDetails(
            android: AndroidNotificationDetails(
              notificationChannelId,
              'MY FOREGROUND SERVICE',
              icon: 'app_icon',
              ongoing: true,
            ),
          ),
        );
      }
    }
  } catch (e) {
    print("setBgNotificationIcon");
  }
}

stopServiceAtNight(ServiceInstance service, Timer timer) async {
  try {
    var now = DateTime.now();
    if (now.hour == 23 && now.minute >= 55 && now.minute <= 59) {
      PreferenceHelper.clear();
      service.stopSelf();
      timer.cancel(); // Stop the timer
    }
  } catch (e) {
    print("stopServiceAtNight");
  }
}

isWithinRadius(
    {double? currentLat,
      double? currentLong,
      double? prevLat,
      double? prevLong,
      int? radiusMtr}) async {
  try {
    if (prevLat == null || prevLong == null || prevLat == 0 || prevLong == 0) {
      return false;
    }

    if (currentLat == null ||
        currentLong == null ||
        currentLong == 0 ||
        currentLong == 0) {
      return false;
    }

    double distance = 81;
    distance = Geolocator.distanceBetween(
        prevLat ?? 0, prevLong ?? 0, currentLat ?? 0, currentLong ?? 0);
    if ((distance) < (radiusMtr ?? 50)) {
      return true;
    } else {
      return false;
    }
  } catch (e) {
    print("isWithinRadius");
  }
}

setLastActivityData() async {
  Map<String, dynamic> lastActivityMap =
  PreferenceHelper.getObject("last_activity");
  if (lastActivityMap != null) {
    lastActivityData = LastActivityData.fromJson(lastActivityMap);
  } else {
    lastActivityData = null;
  }
  if (lastActivityData != null) {
    String? sessionId = lastActivityData?.sessionId;

    if (sessionId != null) {
      if (prevLatitude == null) {
        prevLatitude = lastActivityData?.lastActivityLat;
      }

      if (prevLongitude == null) {
        prevLongitude = lastActivityData?.lastActivityLong;
      }

      if (currentLatitude == null) {
        currentLatitude = lastActivityData?.lastActivityLat;
      }

      if (currentLongitude == null) {
        currentLongitude = lastActivityData?.lastActivityLong;
      }
      if (isGpsAvailable) {
        prevLatitude = currentLatitude;
        prevLongitude = currentLongitude;
        Position position1 = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high);
        currentLatitude = position1.latitude;
        currentLongitude = position1.longitude;
        lastActivityData?.lastLocationLat =
            currentLatitude ?? (prevLatitude ?? 0);
        lastActivityData?.lastLocationLong =
            currentLongitude ?? (prevLongitude ?? 0);

        PreferenceHelper.setObject<LastActivityData>(
            "last_activity", lastActivityData);
      }
    }
  }
}

void setAllActivityListToPref(List<Activity> lstActivities) {
  try {
    List<String> activitiesJsonList = lstActivities.map((activity) => jsonEncode(activity.toJson())).toList();

    PreferenceHelper.setStringList('offline_activities', activitiesJsonList);
  } catch (e) {
    print("setGpsActivityListToPref error: $e");
  }
}

bool isDifferenceLessFiveMinutes(String time1, String time2) {
  // Define the format
  final format = DateFormat(AppConstant.dateFormat);

  // Parse the time strings
  DateTime dateTime1 = format.parse(time1);
  DateTime dateTime2 = format.parse(time2);

  // Calculate the difference
  Duration difference = dateTime1.difference(dateTime2).abs();
  if (difference.inMinutes < 2) {
    return true;
  } else {
    return false;
  }
}

