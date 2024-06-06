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
import 'package:ontrek/core/services/api_constants.dart';
import 'package:ontrek/core/services/local_notification.dart';
import 'package:ontrek/core/services/network_repository.dart';
import 'package:ontrek/core/storage/preference_helper.dart';
import 'package:ontrek/core/utils/App_utils.dart';
import 'package:ontrek/core/utils/app_constant.dart';
import 'package:ontrek/features/attendance/model/get_last_activity_model.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
        value?.getInt(PreferenceHelper.LIVE_LOCATION_INTERVAL);
    waitingTime = value?.getInt(PreferenceHelper.WAITING_TIME_INTERVAL);
    print("waitingTime$waitingTime");
    bool? isWaitingAllowed = value?.getBool(PreferenceHelper.ALLOW_WAITING);
    Timer.periodic(
      Duration(
          seconds: liveLocationInterval != null || liveLocationInterval != 0
              ? liveLocationInterval ?? 30
              : 30),
      (timer) async {
        try {
          isInternetAvailable = await checkInternetConnectivity();
          isGpsAvailable = await isGpsOn();

          await PreferenceHelper.reload();
          waitingStartTime = PreferenceHelper.getString(PreferenceHelper.WAITING_START_TIME);
          lastWaitingLat = PreferenceHelper.getDouble(PreferenceHelper.LAST_LAT);
          lastWaitingLong = PreferenceHelper.getDouble(PreferenceHelper.LAST_LONG);

          // Stop service between 11:50 to 12:00 Midnight
          await stopServiceAtNight(service, timer);
          //Set notification icon
          await setBgNotificationIcon(service);
          await setLastActivityData();

          if (lastActivityData != null) {
            listOfAllActivity = geAllActivitiesFromPrefOffLine();

            if (isInternetAvailable) {
              //sync Route Data
              await syncRouteHistory();

              if (listOfAllActivity != null && (listOfAllActivity?.length ?? 0) > 0) {
                // Sync Event Data
                await syncData(listOfAllActivity ?? []);
              }
            }

            isInRadius = isWithinRadius(
                prevLat: prevLatitude,
                prevLong: prevLongitude,
                currentLat: currentLatitude,
                currentLong: currentLongitude,
                radiusMtr: 80);

            ManageRouteHistory();
            ManageInternetOperations(listOfAllActivity ?? []);
            ManageGpsOperations(listOfAllActivity ?? []);

            print("isCehckin$isCheckIn");
            if (isCheckIn == false) {
              if (isWaitingAllowed == true) {
                await ManageWaitingOperation(listOfAllActivity ?? []);
              }
            }
          }
        } catch (e) {
          print(e);
        }
      },
    );
  });
}

ManageRouteHistory() {
  if (isGpsAvailable && !isInRadius) {
    List<String>? offlineData =
        PreferenceHelper.getStringList('offline_route_data');

    OfflineRouteModel dataPoint = OfflineRouteModel(
      latitude: currentLatitude ?? 0,
      longitude: currentLongitude ?? 0,
      offlineTime: AppUtils.getDate(
          date: DateTime.now().toString(), format: AppConstant.dateFormat),
    );

    if (dataPoint.latitude != 0.0 && dataPoint.longitude != 0.0) {
      offlineData?.add(jsonEncode(dataPoint.toJson()));
      if (offlineData != null || offlineData != []) {
        PreferenceHelper.setStringList('offline_route_data', offlineData ?? []);
      }
    }
  }
}

ManageGpsOperations(List<Activity> listOfAllActivity) {
  //send gps off data server
  //   List<Activity> listOfflineData = geAllGpsActivitiesFromPrefOffLine();

  var activity = Activity(
      pkId: listOfAllActivity.length + 1,
      sessionId: lastActivityData?.sessionId ?? "",
      latitude: currentLatitude ?? (prevLatitude ?? 0),
      longitude: currentLongitude ?? (prevLongitude ?? 0),
      activityDate: AppUtils.getDateTimeNow(),
      isSync: false,
      isEventCompleted: false);

  if (isGpsAvailable == true) {
    var gpsOffData = listOfAllActivity
        .where((element) =>
            element.eventCode == AppConstant.gpsOffEvent &&
            element.isEventCompleted == false)
        .firstOrNull;
    var gpsOnData = listOfAllActivity
        .where((element) =>
            element.eventCode == AppConstant.gpsOnEvent &&
            element.parentId == gpsOffData?.pkId)
        .firstOrNull;

    if (gpsOnData == null && gpsOffData != null) {
      // update parent gps off event
      gpsOffData.isEventCompleted = true;

      //add gps on event
      activity.parentId = gpsOffData.pkId;
      activity.eventCode = AppConstant.gpsOnEvent;
      activity.isEventCompleted = true;
      activity.isSync = false;

      listOfAllActivity.add(activity);
      setAllActivityListToPref(listOfAllActivity);
    }
  }

  if (isGpsAvailable == false) {
    var gpsOffData = listOfAllActivity
        .where((element) =>
            element.eventCode == AppConstant.gpsOffEvent &&
            element.isEventCompleted == false)
        .firstOrNull;
    if (gpsOffData == null) {
      //add gps on event
      activity.eventCode = AppConstant.gpsOffEvent;
      activity.isEventCompleted = false;
      activity.parentId = null;
      activity.isSync = false;
      listOfAllActivity.add(activity);
      setAllActivityListToPref(listOfAllActivity);
    }
  }
}

ManageInternetOperations(List<Activity> listOfAllActivity) {
  //send gps off data server

  var activity = Activity(
      pkId: listOfAllActivity.length + 1,
      sessionId: lastActivityData?.sessionId ?? "",
      latitude: currentLatitude ?? (prevLatitude ?? 0),
      longitude: currentLongitude ?? (prevLongitude ?? 0),
      activityDate: AppUtils.getDateTimeNow(),
      isSync: false,
      isEventCompleted: false);

  if (isInternetAvailable == true) {
    var internetOffData = listOfAllActivity
        .where((element) =>
            element.eventCode == AppConstant.internetOffEvent &&
            element.isEventCompleted == false)
        .firstOrNull;
    var internetOnData = listOfAllActivity
        .where((element) =>
            element.eventCode == AppConstant.internetOnEvent &&
            element.parentId == internetOffData?.pkId)
        .firstOrNull;

    if (internetOnData == null && internetOffData != null) {
      // update internet off event
      internetOffData.isEventCompleted = true;

      //add internet on event
      activity.parentId = internetOffData.pkId;
      activity.eventCode = AppConstant.internetOnEvent;
      activity.isEventCompleted = true;
      activity.isSync = false;

      listOfAllActivity.add(activity);
      setAllActivityListToPref(listOfAllActivity);
    }
  }

  if (isInternetAvailable == false) {
    var internetOffData = listOfAllActivity
        .where((element) =>
            element.eventCode == AppConstant.internetOffEvent &&
            element.isEventCompleted == false)
        .firstOrNull;
    if (internetOffData == null) {
      //add internet off event
      activity.eventCode = AppConstant.internetOffEvent;
      activity.isEventCompleted = false;
      activity.parentId = null;
      activity.isSync = false;
      listOfAllActivity.add(activity);
      setAllActivityListToPref(listOfAllActivity);
    }
  }
}

ManageWaitingOperation(List<Activity> listOfAllActivity) async {
  //send waiting start data local storage
  var waitingStartData = listOfAllActivity
      .where((element) =>
          element.eventCode == AppConstant.trackingWaitingStartEvent &&
          element.isEventCompleted == false)
      .firstOrNull;
  var waitingStopData = listOfAllActivity
      .where((element) =>
          element.eventCode == AppConstant.trackingWaitingStopEvent &&
          element.parentId == waitingStartData?.pkId)
      .firstOrNull;

  var activity = Activity(
      pkId: listOfAllActivity.length + 1,
      sessionId: lastActivityData?.sessionId ?? "",
      latitude: currentLatitude ?? (prevLatitude ?? 0),
      longitude: currentLongitude ?? (prevLongitude ?? 0),
      isSync: false,
      isEventCompleted: false);

  if (isGpsAvailable == true) {
    //Waiting Start Event
    if (isInRadius) {
      // await PreferenceHelper.reload();

      // String? waitingStartTime = "";
      // double? lastWaitingLat = 0;
      // double? lastWaitingLong = 0;

      // waitingStartTime = PreferenceHelper.getString(PreferenceHelper.WAITING_START_TIME);
      print("waitingStartTime$waitingStartTime");
      // lastWaitingLat = PreferenceHelper.getDouble(PreferenceHelper.LAST_LAT);
      // lastWaitingLong = PreferenceHelper.getDouble(PreferenceHelper.LAST_LONG);

      if (DateTime.now()
              .difference(DateTime.parse(waitingStartTime ?? ""))
              .inMinutes >=
          (waitingTime ?? 10)) {
        if (waitingStartData == null) {
          //add waiting start  event
          activity.eventCode = AppConstant.trackingWaitingStartEvent;
          activity.isEventCompleted = false;
          activity.parentId = null;
          activity.isSync = false;
          activity.latitude = lastWaitingLat ?? 0;
          activity.longitude = lastWaitingLong ?? 0;
          activity.activityDate = AppUtils.getDate(
              date: waitingStartTime.toString(),
              format: AppConstant.dateFormat);
          if (activity.latitude != 0 &&
              activity.longitude != 0 &&
              activity.latitude != null &&
              activity.longitude != null) {
            listOfAllActivity.add(activity);
            setAllActivityListToPref(listOfAllActivity);
          }
        }
      }
    } else {
      PreferenceHelper.setString(PreferenceHelper.WAITING_START_TIME, AppUtils.getDate(date: DateTime.now().toString(), format: AppConstant.dateFormat));
      PreferenceHelper.setDouble(PreferenceHelper.LAST_LAT, currentLatitude ?? (prevLatitude  ?? 0));
      PreferenceHelper.setDouble(PreferenceHelper.LAST_LONG, currentLatitude ?? (prevLatitude  ?? 0));
      // waitingStartTime = DateTime.now();
    }

    //Waiting End Event
    if (waitingStartData != null) {
      var IsWaitingInRadius = isWithinRadius(
          prevLat: waitingStartData.latitude,
          prevLong: waitingStartData.longitude,
          currentLat: currentLatitude,
          currentLong: currentLongitude,
          radiusMtr: 80);

      // Below code is for testing waiting end event in debug mode do not remove
      // var waitingTestStartTime = DateTime.parse(waitingStartData.activityDate!);
      // if (DateTime.now().difference(waitingTestStartTime).inMinutes > 2) {
      //   IsWaitingInRadius = false;
      // }

      if (!IsWaitingInRadius) {
        if (waitingStartData != null && waitingStopData == null) {
          waitingStartData.isEventCompleted = true;

          activity.parentId = waitingStartData.pkId;
          activity.eventCode = AppConstant.trackingWaitingStopEvent;
          activity.isEventCompleted = true;
          activity.isSync = false;
          activity.activityDate = AppUtils.getDateTimeNow();

          listOfAllActivity.add(activity);
          setAllActivityListToPref(listOfAllActivity);
          PreferenceHelper.setString(PreferenceHelper.WAITING_START_TIME, AppUtils.getDate(date: DateTime.now().toString(), format: AppConstant.dateFormat));
          PreferenceHelper.setDouble(PreferenceHelper.LAST_LAT,  currentLatitude ?? (prevLatitude  ?? 0));
          PreferenceHelper.setDouble(PreferenceHelper.LAST_LONG, currentLatitude ?? (prevLatitude  ?? 0));
        }
      }
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
        if (isInternetAvailable) {
          if (listOfAllActivity != null &&
              (listOfAllActivity?.length ?? 0) > 0) {
            PreferenceHelper.remove(PreferenceHelper.WAITING_START_TIME);
            PreferenceHelper.remove(PreferenceHelper.LAST_LAT);
            PreferenceHelper.remove(PreferenceHelper.LAST_LONG);

            PreferenceHelper.setStringList("offline_activities", []);
            PreferenceHelper.setStringList("offline_route_data", []);
            service.stopSelf();
          } else {
            PreferenceHelper.remove(PreferenceHelper.WAITING_START_TIME);
            PreferenceHelper.remove(PreferenceHelper.LAST_LAT);
            PreferenceHelper.remove(PreferenceHelper.LAST_LONG);
            PreferenceHelper.setStringList("offline_route_data", []);
            service.stopSelf();
          }
        }
      });

      service.on('dayStart').listen((event) async {
        Position position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.low);
        PreferenceHelper.setString(
            PreferenceHelper.WAITING_START_TIME, AppUtils.getDate(date: DateTime.now().toString(), format: AppConstant.dateFormat));
        // waitingStartTime = PreferenceHelper.getString(PreferenceHelper.WAITING_START_TIME);
        PreferenceHelper.setDouble(PreferenceHelper.LAST_LAT, currentLatitude ?? position.latitude);
        // lastWaitingLat = PreferenceHelper.getDouble(PreferenceHelper.LAST_LAT);
        PreferenceHelper.setDouble(PreferenceHelper.LAST_LONG, currentLongitude ?? position.longitude);
        // lastWaitingLong = PreferenceHelper.getDouble(PreferenceHelper.LAST_LONG);
      });

      service.on("checkIn_beforeEvent").listen((event) async {
        List<Activity> listOfAllActivity = geAllActivitiesFromPrefOffLine();

        manualWaitingEndEvent(listOfAllActivity);

        manualInternetOnEvent(listOfAllActivity);

        manualGpsOnEvent(listOfAllActivity);
      });

      service.on("checkIn_afterEvent").listen((event) {
        PreferenceHelper.setBool(PreferenceHelper.checkIn, true);
        PreferenceHelper.reload();
        isCheckIn = PreferenceHelper.getBool(PreferenceHelper.checkIn);
        // PreferenceHelper.setString(PreferenceHelper.WAITING_START_TIME, AppUtils.getDate(date: DateTime.now().toString(), format: AppConstant.dateFormat));
      });

      service.on('checkOut_event').listen((event) {
        PreferenceHelper.setBool(PreferenceHelper.checkIn, false);
        isCheckIn = PreferenceHelper.getBool(PreferenceHelper.checkIn);
        print("isCheckIn$isCheckIn");
        PreferenceHelper.setString(PreferenceHelper.WAITING_START_TIME, AppUtils.getDate(date: DateTime.now().toString(), format: AppConstant.dateFormat));
        PreferenceHelper.setDouble(PreferenceHelper.LAST_LAT,  currentLatitude ?? (prevLatitude  ?? 0));
        PreferenceHelper.setDouble(PreferenceHelper.LAST_LONG,  currentLatitude ?? (prevLatitude  ?? 0));
      });

      service.on("dayEnd_beforeEvent").listen((event) async {
        // await syncData(listOfAllActivity!);
      });
    }
    if (service is IOSServiceInstance) {
      service.on('stopService').listen((event) async {
        if (isInternetAvailable) {
          if (listOfAllActivity != null &&
              (listOfAllActivity?.length ?? 0) > 0) {
            PreferenceHelper.remove(PreferenceHelper.WAITING_START_TIME);
            PreferenceHelper.remove(PreferenceHelper.LAST_LAT);
            PreferenceHelper.remove(PreferenceHelper.LAST_LONG);

            PreferenceHelper.setStringList("offline_activities", []);
            PreferenceHelper.setStringList("offline_route_data", []);
            service.stopSelf();
          } else {
            PreferenceHelper.remove(PreferenceHelper.WAITING_START_TIME);
            PreferenceHelper.remove(PreferenceHelper.LAST_LAT);
            PreferenceHelper.remove(PreferenceHelper.LAST_LONG);
            PreferenceHelper.setStringList("offline_route_data", []);
            service.stopSelf();
          }
        }
      });

      service.on('dayStart').listen((event) async {
        Position position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.low);
        PreferenceHelper.setString(
            PreferenceHelper.WAITING_START_TIME, AppUtils.getDate(date: DateTime.now().toString(), format: AppConstant.dateFormat));
        // waitingStartTime = PreferenceHelper.getString(PreferenceHelper.WAITING_START_TIME);
        PreferenceHelper.setDouble(PreferenceHelper.LAST_LAT, currentLatitude ?? position.latitude);
        // lastWaitingLat = PreferenceHelper.getDouble(PreferenceHelper.LAST_LAT);
        PreferenceHelper.setDouble(PreferenceHelper.LAST_LONG, currentLongitude ?? position.longitude);
        // lastWaitingLong = PreferenceHelper.getDouble(PreferenceHelper.LAST_LONG);
      });

      service.on("checkIn_beforeEvent").listen((event) async {
        List<Activity> listOfAllActivity = geAllActivitiesFromPrefOffLine();

        manualWaitingEndEvent(listOfAllActivity);

        manualInternetOnEvent(listOfAllActivity);

        manualGpsOnEvent(listOfAllActivity);
      });

      service.on("checkIn_afterEvent").listen((event) {
        PreferenceHelper.setBool(PreferenceHelper.checkIn, true);
        PreferenceHelper.reload();
        isCheckIn = PreferenceHelper.getBool(PreferenceHelper.checkIn);
        // PreferenceHelper.setString(PreferenceHelper.WAITING_START_TIME, AppUtils.getDate(date: DateTime.now().toString(), format: AppConstant.dateFormat));
      });

      service.on('checkOut_event').listen((event) {
        PreferenceHelper.setBool(PreferenceHelper.checkIn, false);
        isCheckIn = PreferenceHelper.getBool(PreferenceHelper.checkIn);
        print("isCheckIn$isCheckIn");
        PreferenceHelper.setString(PreferenceHelper.WAITING_START_TIME, AppUtils.getDate(date: DateTime.now().toString(), format: AppConstant.dateFormat));
        PreferenceHelper.setDouble(PreferenceHelper.LAST_LAT,  currentLatitude ?? (prevLatitude  ?? 0));
        PreferenceHelper.setDouble(PreferenceHelper.LAST_LONG,  currentLatitude ?? (prevLatitude  ?? 0));
      });

      service.on("dayEnd_beforeEvent").listen((event) async {
        // await syncData(listOfAllActivity!);
      });
    }
  } catch (e) {
    print("registerEventsToListener");
  }
}

manualWaitingEndEvent(List<Activity> listOfAllActivity) {
  var activity = Activity(
      pkId: listOfAllActivity.length + 1,
      sessionId: lastActivityData?.sessionId ?? "",
      latitude: currentLatitude ?? (prevLatitude ?? 0),
      longitude: currentLongitude ?? (prevLongitude ?? 0),
      isSync: false,
      isEventCompleted: false);

  var waitingStartData = listOfAllActivity
      .where((element) =>
          element.eventCode == AppConstant.trackingWaitingStartEvent &&
          element.isEventCompleted == false)
      .firstOrNull;

  if (waitingStartData != null) {
    var waitingStopData = listOfAllActivity
        .where((element) =>
            element.eventCode == AppConstant.trackingWaitingStopEvent &&
            element.isEventCompleted == false &&
            element.isSync == false)
        .firstOrNull;

    if (waitingStopData == null) {
      waitingStartData.isEventCompleted = true;
      activity.parentId = waitingStartData.pkId;
      activity.eventCode = AppConstant.trackingWaitingStopEvent;
      activity.isEventCompleted = true;
      activity.isSync = waitingStartData.isSync;
      activity.activityDate = AppUtils.getDateTimeNow();

      listOfAllActivity.add(activity);
      setAllActivityListToPref(listOfAllActivity);
      PreferenceHelper.setString(PreferenceHelper.WAITING_START_TIME,AppUtils.getDate(date: DateTime.now().toString(), format: AppConstant.dateFormat));
    }
  }
}

manualInternetOnEvent(List<Activity> listOfAllActivity) {
  var activity = Activity(
      pkId: listOfAllActivity.length + 1,
      sessionId: lastActivityData?.sessionId ?? "",
      latitude: currentLatitude ?? (prevLatitude ?? 0),
      longitude: currentLongitude ?? (prevLongitude ?? 0),
      isSync: false,
      isEventCompleted: false);

  var internetOffData = listOfAllActivity
      .where((element) =>
          element.eventCode == AppConstant.internetOffEvent &&
          element.isEventCompleted == false)
      .firstOrNull;
  if (internetOffData != null) {
    var internetOnData = listOfAllActivity
        .where((element) =>
            element.eventCode == AppConstant.internetOnEvent &&
            element.isEventCompleted == false &&
            element.isSync == false)
        .firstOrNull;

    if (internetOnData == null) {
      internetOffData.isEventCompleted = true;

      activity.parentId = internetOffData.pkId;
      activity.eventCode = AppConstant.internetOnEvent;
      activity.isEventCompleted = true;
      activity.isSync = internetOffData.isSync;
      activity.activityDate = AppUtils.getDateTimeNow();

      listOfAllActivity.add(activity);
      setAllActivityListToPref(listOfAllActivity);
    }
  }
}

manualGpsOnEvent(List<Activity> listOfAllActivity) {
  var activity = Activity(
      pkId: listOfAllActivity.length + 1,
      sessionId: lastActivityData?.sessionId ?? "",
      latitude: currentLatitude ?? (prevLatitude ?? 0),
      longitude: currentLongitude ?? (prevLongitude ?? 0),
      isSync: false,
      isEventCompleted: false);

  var gpsOffData = listOfAllActivity
      .where((element) =>
          element.eventCode == AppConstant.gpsOffEvent &&
          element.isEventCompleted == false)
      .firstOrNull;

  if (gpsOffData != null) {
    var gpsOnData = listOfAllActivity
        .where((element) =>
            element.eventCode == AppConstant.gpsOnEvent &&
            element.isEventCompleted == false &&
            element.isSync == false)
        .firstOrNull;
    if (gpsOnData == null) {
      gpsOffData.isEventCompleted = true;
      activity.parentId = gpsOffData.pkId;
      activity.eventCode = AppConstant.gpsOnEvent;
      activity.isEventCompleted = true;
      activity.isSync = gpsOffData.isSync;
      activity.activityDate = AppUtils.getDateTimeNow();

      listOfAllActivity.add(activity);
      setAllActivityListToPref(listOfAllActivity);
    }
  }
}

BulkActivityRequestModel? bulkActivityRequestModel;
OfflineRouteModel? offlineRouteModel;
BulkActivityResponseModel? bulkActivityResponseModel;

CreateRouteHistoryModel? createRouteHistoryModel;

syncRouteHistory() async {
  try {
    List<String>? offlineData =
        PreferenceHelper.getStringList('offline_route_data');

    List<OfflineMapData> offlineDataMaps = offlineData
            ?.map((data) => jsonDecode(data))
            .map((json) => OfflineMapData(
                lattitude: json['latitude'],
                longitude: json['longitude'],
                offlineTime: json['offlineTime']))
            .toList() ??
        [];

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
      PreferenceHelper.setStringList("offline_route_data", []);
    }
  } catch (e) {
    print("createRouteHistory");
  }
}

syncData(List<Activity> listOfAllActivity) async {
  try {
    var listOfflineData = listOfAllActivity.where((element) => element.isSync == false).toList();


    if (listOfflineData == null || listOfflineData.length < 1)
    {
      return;
    } else {

      var internetOff = listOfAllActivity
          .where((element) =>
      element.eventCode == AppConstant.internetOffEvent &&
          element.isSync == false)
          .firstOrNull;
      var internetOn = listOfAllActivity
          .where((element) =>
      element.eventCode == AppConstant.internetOnEvent &&
          element.isSync == false &&
          element.parentId == internetOff?.pkId)
          .firstOrNull;

      if (internetOn != null && internetOff != null) {
        bool? isDifferenceLessTwoMinutes = isDifferenceLessFiveMinutes(
            internetOff.activityDate ?? "", internetOn.activityDate ?? "");
        if (isDifferenceLessTwoMinutes) {
          internetOff.isSync = true;
          internetOff.isEventCompleted=true;
          internetOn.isSync=true;
          internetOn.isEventCompleted=true;
          setAllActivityListToPref(listOfflineData);
          listOfflineData = listOfAllActivity.where((element) => element.isSync == false).toList();
        }
      }

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

        if(createActivityList.totTrackingEventId == AppConstant.internetOffEvent)
         {
           if(internetOn != null && internetOn.isSync == false){
             createActivityLists.add(createActivityList);
           }
         }else
          {
            createActivityLists.add(createActivityList);
          }
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

                var recordToSync = listOfAllActivity
                    .where((x) => x.pkId == element.localPkId)
                    .firstOrNull;
                recordToSync?.isSync = true;
              });

              List<String> allActivityList = listOfAllActivity
                  .map((activity) => jsonEncode(activity.toJson()))
                  .toList();

              PreferenceHelper.setStringList("offline_activities", allActivityList);
              listOfAllActivity = geAllActivitiesFromPrefOffLine();
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

geAllActivitiesFromPrefOffLine() {
  try {
    var offLineActivitiesStr =
        PreferenceHelper.getStringList("offline_activities") ?? [];

    List<Activity> offLinActivities = offLineActivitiesStr.map((data) {
      Map<String, dynamic> jsonData = jsonDecode(data);
      return Activity.fromJson(jsonData);
    }).toList();
    return offLinActivities;
  } catch (e) {
    print("error : geAllGpsActivitiesFromPrefOffLine");
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
    if (service is IOSServiceInstance) {
      flutterLocalNotificationsPlugin.show(
        notificationId,
        'On Trek Background Service',
        'Background location capturing initiated.',
        NotificationDetails(
          iOS: DarwinNotificationDetails(
              presentAlert: true,
              presentBadge: true,
              presentSound: true,
              badgeNumber: 1,
              subtitle: 'Background location capturing initiated.',
              sound: 'default'),
        ),
      );
    }
  } catch (e) {
    print("setBgNotificationIcon");
  }
}

stopServiceAtNight(ServiceInstance service, Timer timer) {
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
    int? radiusMtr}) {
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

setLastActivityData(/*LastActivityData? lastActivity*/) async {
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
    List<String> activitiesJsonList =
        lstActivities.map((activity) => jsonEncode(activity.toJson())).toList();

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
