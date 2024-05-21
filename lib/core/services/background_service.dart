import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:ontrek/core/background_service_model/create_route_history_model.dart';
import 'package:ontrek/core/services/api_constants.dart';
import 'package:ontrek/core/services/local_notification.dart';
import 'package:ontrek/core/services/network_repository.dart';
import 'package:ontrek/core/storage/preference_helper.dart';
import 'package:ontrek/core/utils/App_utils.dart';
import 'package:ontrek/core/utils/app_constant.dart';
import 'package:ontrek/features/attendance/model/add_activity_model.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:shared_preferences/shared_preferences.dart';

const notificationChannelId = 'my_foreground';

const notificationId = 888;

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

  SharedPreferences preferences = await SharedPreferences.getInstance();
  await preferences.reload();
  final log = preferences.getStringList('log') ?? <String>[];
  log.add(DateTime.now().toIso8601String());
  await preferences.setStringList('log', log);

  return true;
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  service.on("update").listen((event) {
    if (event != null) {
      bool isWaiting = event["isWaiting"];
      PreferenceHelper.setBool(PreferenceHelper.isWaiting, isWaiting);
    }
  });
  service.on("background").listen((event) {
    if(event != null){
      String sessionId  =  event["sessionId"];
      PreferenceHelper.setString(PreferenceHelper.SESSION_ID, sessionId);
    }

  });
  service.on("checkout_update").listen((event) {
    if (event != null) {
      String waitingStartTime = event["waitingStartTime"];
      double lastLat = event["lastLat"];
      double lastLong = event["lastLong"];
      PreferenceHelper.setString(
          PreferenceHelper.WAITING_START_TIME, waitingStartTime);
      PreferenceHelper.setDouble(PreferenceHelper.LAST_LAT, lastLat);
      PreferenceHelper.setDouble(PreferenceHelper.LAST_LONG, lastLong);
    }
  });

  if (service is AndroidServiceInstance) {
    service.on('setAsForeground').listen((event) {
      service.setAsForegroundService();
    });

    service.on('setAsBackground').listen((event) {
      service.setAsBackgroundService();
    });
  }
  service.on('stopService').listen((event) {
    service.stopSelf();
  });

  PreferenceHelper.load().then((value) {
    int? waitingIntervalTime;
    int? liveLocationInterval =
        value?.getInt(PreferenceHelper.LIVE_LOCATION_INTERVAL);
    int? waitingTime = value?.getInt(PreferenceHelper.WAITING_TIME_INTERVAL);
    bool? isWaitingAllowed = value?.getBool(PreferenceHelper.ALLOW_WAITING);
    String? userId = value?.getString(PreferenceHelper.USER_ID);
    String? sessionId = value?.getString(PreferenceHelper.SESSION_ID);
    print("userId1$userId");
    print("sessionId$sessionId");
    if (waitingTime != null && waitingTime != 0) {
      waitingIntervalTime = (waitingTime * 60);
    }

    Timer.periodic(
      Duration(
          seconds: liveLocationInterval != null || liveLocationInterval != 0
              ? liveLocationInterval ?? 15
              : 15),
      (timer) async {
        var now = DateTime.now();
        if (now.hour == 23 && now.minute >= 50 && now.minute <= 59) {
          service.stopSelf();
          timer.cancel(); // Stop the timer
        }
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
        try {
          final connectivityResult = await Connectivity().checkConnectivity();
          var isInternetAvailable = connectivityResult == ConnectivityResult.mobile ||
                  connectivityResult == ConnectivityResult.wifi;
          var isGPSEnabled =
              await Permission.locationAlways.serviceStatus.isEnabled &&
                  await Permission.location.serviceStatus.isEnabled;

          if (isInternetAvailable && isGPSEnabled) {
            PreferenceHelper.reload().then((value) async {
              Position position;
              double distance = 81;
              ValueNotifier<bool?> isWaiting = ValueNotifier(false);
              position = await Geolocator.getCurrentPosition(
                  desiredAccuracy: LocationAccuracy.best);
              double? lastLat =
                  PreferenceHelper.getDouble(PreferenceHelper.LAST_LAT);
              double? lastLong =
                  PreferenceHelper.getDouble(PreferenceHelper.LAST_LONG);
              distance = Geolocator.distanceBetween(lastLat ?? 0, lastLong ?? 0,
                  position.latitude, position.longitude);
              bool? checkIn = value?.getBool(PreferenceHelper.checkIn) ?? false;
              if (value != null) {
                isWaiting.value = value.getBool(PreferenceHelper.isWaiting);
              }
              if (checkIn == false || checkIn == null) {
                await handleInternetAndGPSApi(userId: userId,sessionId: sessionId);
              }
              print("distance${distance}");
              print("waiting${isWaiting.value}");
              if ((distance) > 80) {
                if (isWaitingAllowed == true) {
                  if (isWaiting.value == true) {
                    await waitingEndApi(service: service,userId: userId,sessionId: sessionId);
                  }
                }
                await updateRouteHistory(userId: userId,sessionId: sessionId);
              } else {
                bool? checkIn =
                    value?.getBool(PreferenceHelper.checkIn) ?? false;
                print("waiting_Allowed${isWaitingAllowed}");
                if (isWaitingAllowed == true) {
                  isWaiting.value =
                      PreferenceHelper.getBool(PreferenceHelper.isWaiting);
                  print("waiting${isWaiting.value}");
                  String? waitingStartTime = PreferenceHelper.getString(
                      PreferenceHelper.WAITING_START_TIME);
                  print("waitingStartTime${waitingStartTime}");
                  String? sessionId = PreferenceHelper.getString(PreferenceHelper.SESSION_ID);
                  print("sessionId${sessionId}");
                  double? lastLat =
                      PreferenceHelper.getDouble(PreferenceHelper.LAST_LAT);
                  double? lastLong =
                      PreferenceHelper.getDouble(PreferenceHelper.LAST_LONG);
                  if (checkIn == false && isWaiting.value == false) {
                    print("waiting${isWaiting.value}");
                    try {
                      int? idealMarkerTime = waitingIntervalTime != null ||
                              waitingIntervalTime != 0
                          ? waitingIntervalTime ?? 300
                          : 300;
                      print("idealMarkerTime${idealMarkerTime}");
                      print("idealMarkerTime1${DateTime.now()
                          .difference(
                          DateTime.parse(waitingStartTime ?? ""))
                          .inSeconds}");
                      if (DateTime.now()
                              .difference(
                                  DateTime.parse(waitingStartTime ?? ""))
                              .inSeconds >
                          idealMarkerTime) {
                        print("idealMarkerTime2${DateTime.now()
                            .difference(
                            DateTime.parse(waitingStartTime ?? ""))
                            .inSeconds}");
                        await waitingStartApi(
                            service: service,
                            waitingStartTime: waitingStartTime,
                            lastLat: lastLat,
                            lastLong: lastLong,userId: userId,sessionId: sessionId);
                      }
                    } catch (e) {}
                  } else {
                    if(isWaiting.value == true && checkIn == false){
                      if (DateTime.now()
                          .difference(DateTime.parse(waitingStartTime ?? ""))
                          .inMinutes >=
                          30) {
                        NotificationService().showNotification(
                            title: "Excessive Waiting Alert!",
                            body:
                            "Hey there! It looks like you've been inactive for a while. Just a friendly reminder to keep moving to ensure your productivity.",
                            id: 0);
                        PreferenceHelper.setString(
                            PreferenceHelper.WAITING_START_TIME,
                            DateTime.now().toString());
                      }
                    }

                  }
                }
              }
            });
          } else if (isGPSEnabled && !isInternetAvailable) {
            handleGpsAndInternetOffData(serviceType: "internet");
            storeLocationDataWhenOffline();

            String? lastGpsTime =
                PreferenceHelper.getString(PreferenceHelper.LAST_GPS_OFF_TIME);
            if (lastGpsTime != "" && lastGpsTime != null) {
              PreferenceHelper.setString(
                  PreferenceHelper.LAST_GPS_ON_TIME,
                  AppUtils.dateFormat(
                      date: DateTime.now(),
                      dateFormat: AppConstant.dateFormat));
            }
          } else if (!isGPSEnabled && isInternetAvailable) {
            handleGpsAndInternetOffData(serviceType: "gps");
          } else if (!isGPSEnabled && !isInternetAvailable) {
            bool gpsBool = PreferenceHelper.getBool(PreferenceHelper.GPS_BOOL);
            bool internetBool =
                PreferenceHelper.getBool(PreferenceHelper.INTERNET_BOOL);
            if (gpsBool == false && internetBool == false) {
              handleGpsAndInternetOffData(serviceType: "gps");
              handleGpsAndInternetOffData(serviceType: "internet");
              PreferenceHelper.reload().then((value) async {
                bool? checkIn = value?.getBool(PreferenceHelper.checkIn);
                double? lastLat =
                    PreferenceHelper.getDouble(PreferenceHelper.LAST_LAT);
                double? lastLong =
                    PreferenceHelper.getDouble(PreferenceHelper.LAST_LONG);
                if (checkIn == false || checkIn == null) {
                  try {
                    bool internetBool = PreferenceHelper.getBool(
                        PreferenceHelper.INTERNET_BOOL);
                    if (internetBool == false) {
                      PreferenceHelper.setString(
                          PreferenceHelper.LAST_INTERNET_OFF_TIME,
                          AppUtils.dateFormat(
                              date: DateTime.now(),
                              dateFormat: AppConstant.dateFormat));
                      PreferenceHelper.setDouble(
                          PreferenceHelper.LAST_INTERNET_OFF_LAT, lastLat ?? 0);
                      PreferenceHelper.setDouble(
                          PreferenceHelper.LAST_INTERNET_OFF_LONG,
                          lastLong ?? 0);
                      PreferenceHelper.setBool(
                          PreferenceHelper.INTERNET_BOOL, true);
                      bool internetBool = PreferenceHelper.getBool(
                          PreferenceHelper.INTERNET_BOOL);

                    }
                  } catch (e) {}
                }
              });
            }
          }
        } catch (e) {}
      },
    );
  });
}

handleGpsAndInternetOffData({String? serviceType}) async {
  PreferenceHelper.reload().then((value) async {
    bool? checkIn = value?.getBool(PreferenceHelper.checkIn);
    if (checkIn == false || checkIn == null) {
      if (serviceType == "internet") {
        try {
          Position positionData = await Geolocator.getCurrentPosition(
              desiredAccuracy: LocationAccuracy.best);
          bool internetBool =
              PreferenceHelper.getBool(PreferenceHelper.INTERNET_BOOL);
          if (internetBool == false) {
            PreferenceHelper.setString(
                PreferenceHelper.LAST_INTERNET_OFF_TIME,
                AppUtils.dateFormat(
                    date: DateTime.now(), dateFormat: AppConstant.dateFormat));
            PreferenceHelper.setDouble(
                PreferenceHelper.LAST_INTERNET_OFF_LAT, positionData.latitude);
            PreferenceHelper.setDouble(PreferenceHelper.LAST_INTERNET_OFF_LONG,
                positionData.longitude);
            PreferenceHelper.setBool(PreferenceHelper.INTERNET_BOOL, true);
            bool internetBool =
                PreferenceHelper.getBool(PreferenceHelper.INTERNET_BOOL);
            print("internetBool$internetBool");
          }
        } catch (e) {

        }
      }
      if (serviceType == "gps") {
        double? lastLat = PreferenceHelper.getDouble(PreferenceHelper.LAST_LAT);
        double? lastLong =
            PreferenceHelper.getDouble(PreferenceHelper.LAST_LONG);
        bool? gpsBool = PreferenceHelper.getBool(PreferenceHelper.GPS_BOOL);
        if (gpsBool == false) {
          PreferenceHelper.setString(
              PreferenceHelper.LAST_GPS_OFF_TIME,
              AppUtils.dateFormat(
                  date: DateTime.now(), dateFormat: AppConstant.dateFormat));
          PreferenceHelper.setDouble(
              PreferenceHelper.LAST_GPS_OFF_LAT, lastLat ?? 0);
          PreferenceHelper.setDouble(
              PreferenceHelper.LAST_GPS_OFF_LONG, lastLong ?? 0);
          PreferenceHelper.setBool(PreferenceHelper.GPS_BOOL, true);
          bool? gpsBool = PreferenceHelper.getBool(PreferenceHelper.GPS_BOOL);
          print("gpsBool$gpsBool");
        }
      }
    }
  });
}

CreateRouteHistoryModel? createRouteHistoryModel;

Future<void> updateRouteHistory({String? userId,String? sessionId}) async {
  print("userId$userId");
  try {
    PreferenceHelper.load().then((value) async {

      Position? position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.best);

      Map<String, dynamic> body = {
        "userId": userId,
        "sessionId": sessionId,
        "lattitude": position.latitude,
        "longitude": position.longitude,
        "modifiedOn": AppUtils.dateFormat(
            date: DateTime.now(), dateFormat: AppConstant.dateFormat)
      };

      String endPoint = ApiConstants.createRouteHistory;

      var response = await callPostMethod(endPoint, body);

      createRouteHistoryModel =
          CreateRouteHistoryModel.fromJson(json.decode(response));

      if (createRouteHistoryModel?.isError == false &&
          createRouteHistoryModel?.isValidationFailed == false) {
        PreferenceHelper.setDouble(
            PreferenceHelper.LAST_LAT, position.latitude);
        PreferenceHelper.setDouble(
            PreferenceHelper.LAST_LONG, position.longitude);
        PreferenceHelper.setString(
            PreferenceHelper.WAITING_START_TIME, DateTime.now().toString());
      }
    });
  } catch (e) {

  }
}

Future<void> waitingStartApi(
    {required ServiceInstance service,
    String? waitingStartTime,
    double? lastLat,
    double? lastLong,String? userId,String? sessionId}) async {
  int batteryLevel = await AppUtils.getBatteryLevel();

  PreferenceHelper.load().then((value) async {
    print("userId1$userId");
    print("sessionId$sessionId");
    Map<String, dynamic> body = {};
    body = {
      "userId": userId,
      "lattitude": lastLat,
      "longitude": lastLong,
      "sessionId": sessionId,
      "totTrackingEventId": AppConstant.trackingWaitingStartEvent,
      "activityDateTime": AppUtils.getDate(
          date: waitingStartTime.toString(), format: AppConstant.dateFormat),
      "batteryLevel": batteryLevel,
    };

    String endPoint = ApiConstants.createActivity;
    var response = await callPostMethod(endPoint, body);
    CreateActivityModel? createActivityModel =
        CreateActivityModel?.fromJson(json.decode(response));

    if (createActivityModel.isError == false &&
        createActivityModel.isValidationFailed == false) {
      PreferenceHelper.setBool(PreferenceHelper.isWaiting, true);
      PreferenceHelper.setString(
          PreferenceHelper.WAITING_START_TIME, DateTime.now().toString());
      service.invoke("update", {"isWaiting": true});
    }
  });
}

Future<void> waitingEndApi({required ServiceInstance service,String? userId,String? sessionId}) async {
  Position? position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.best);

  int batteryLevel = await AppUtils.getBatteryLevel();

  PreferenceHelper.load().then((value) async {
    Map<String, dynamic> body = {};
    body = {
      "userId": userId,
      "lattitude": position.latitude,
      "longitude": position.longitude,
      "sessionId": sessionId,
      "totTrackingEventId": AppConstant.trackingWaitingStopEvent,
      "activityDateTime": AppUtils.getDate(
          date: DateTime.now().toString(), format: AppConstant.dateFormat),
      "batteryLevel": batteryLevel,
    };

    String endPoint = ApiConstants.createActivity;
    var response = await callPostMethod(endPoint, body);
    CreateActivityModel? createActivityModel =
        CreateActivityModel?.fromJson(json.decode(response));

    if (createActivityModel.isError == false &&
        createActivityModel.isValidationFailed == false) {
      PreferenceHelper.setBool(PreferenceHelper.isWaiting, false);
      PreferenceHelper.setString(
          PreferenceHelper.WAITING_START_TIME, DateTime.now().toString());
      service.invoke("update", {"isWaiting": false});
    }
  });
}

Future<void> handleInternetAndGPSApi({String? userId,String? sessionId}) async {
  PreferenceHelper.load().then((value) async {
    bool? gpsBool = PreferenceHelper.getBool(PreferenceHelper.GPS_BOOL);
    if (gpsBool) {
      String? lastGpsOffTime =
          PreferenceHelper.getString(PreferenceHelper.LAST_GPS_OFF_TIME);
      if (lastGpsOffTime != "" && lastGpsOffTime != null) {
        PreferenceHelper.setString(
            PreferenceHelper.LAST_GPS_ON_TIME,
            AppUtils.dateFormat(
                date: DateTime.now(), dateFormat: AppConstant.dateFormat));
      }
      await callInternetAndGpsActivityApi(
          userId: userId, isGps: true, isGpsOn: false,sessionId: sessionId);
      // await Future.delayed(const Duration(milliseconds: 500));
      await callInternetAndGpsActivityApi(
          userId: userId, isGps: true, isGpsOn: true,sessionId: sessionId);
    }
    bool? internetBool =
        PreferenceHelper.getBool(PreferenceHelper.INTERNET_BOOL);
    if (internetBool) {
      await callInternetAndGpsActivityApi(
          userId: userId, isInternet: true, isInternetOn: false,sessionId: sessionId);
      // Future.delayed(const Duration(milliseconds: 500));
      await callInternetAndGpsActivityApi(
          userId: userId, isInternet: true, isInternetOn: true,sessionId: sessionId);
    }
  });
}

callInternetAndGpsActivityApi({
  required String? userId,
  String? sessionId,
  bool? isInternet,
  bool? isGps,
  bool? isInternetOn,
  bool? isGpsOn,
}) async {
  String? lastInternetOffTime =
      PreferenceHelper.getString(PreferenceHelper.LAST_INTERNET_OFF_TIME);
  String? lastGpsOffTime =
      PreferenceHelper.getString(PreferenceHelper.LAST_GPS_OFF_TIME);

  double? lastLat = PreferenceHelper.getDouble(PreferenceHelper.LAST_LAT);
  double? lastLong = PreferenceHelper.getDouble(PreferenceHelper.LAST_LONG);

  Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.best);
  Map<String, dynamic> body = {};
  CreateActivityModel? createActivityModel;

  // Retrieve the existing offline data or initialize an empty list if none exists
  List<String> offlineData = PreferenceHelper.getStringList('offline_data') ?? [];
  List offlineDataMaps = offlineData.map((data) => jsonDecode(data)).toList();
  print("offlineDataMaps$offlineDataMaps");


  if (isInternet == true) {
    body = {
      "userId": userId,
      "sessionId" : sessionId,
      "lattitude": isInternetOn ?? false ? position.latitude : lastLat,
      "longitude": isInternetOn ?? false ? position.longitude : lastLong,
      "totTrackingEventId": isInternetOn ?? false
          ? AppConstant.internetOnEvent
          : AppConstant.internetOffEvent,
      "activityDateTime": isInternetOn ?? false
          ? AppUtils.getDate(
              date: DateTime.now().toString(), format: AppConstant.dateFormat)
          : AppUtils.getDate(
              date: lastInternetOffTime ?? "", format: AppConstant.dateFormat),
      "batteryLevel": await AppUtils.getBatteryLevel(),
      "offlineMapData" : isInternetOn== true ? offlineDataMaps != null ?  offlineDataMaps : null : null
    };
  }

  if (isGps == true) {
    body = {
      "userId": userId,
      "sessionId" : sessionId,
      "lattitude": isGpsOn == true ? position.latitude : lastLat,
      "longitude": isGpsOn == true ? position.longitude : lastLong,
      "totTrackingEventId":
          isGpsOn == true ? AppConstant.gpsOnEvent : AppConstant.gpsOffEvent,
      "activityDateTime": isGpsOn == true
          ? AppUtils.getDate(
              date: DateTime.now().toString(), format: AppConstant.dateFormat)
          : AppUtils.getDate(
              date: lastGpsOffTime ?? "", format: AppConstant.dateFormat),
      "batteryLevel": await AppUtils.getBatteryLevel()
    };
  }

  try {
    String endPoint = ApiConstants.createActivity;
    var response = await callPostMethod(endPoint, body);
    createActivityModel = CreateActivityModel?.fromJson(json.decode(response));
    if (createActivityModel.isError == false &&
        createActivityModel.isValidationFailed == false) {
      if (isInternet == true) {
        if(isInternetOn == true){
          PreferenceHelper.remove("offline_data");
        }
        PreferenceHelper.remove(PreferenceHelper.LAST_INTERNET_OFF_TIME);
        PreferenceHelper.remove(PreferenceHelper.LAST_INTERNET_ON_TIME);
        PreferenceHelper.setString(PreferenceHelper.WAITING_START_TIME, DateTime.now().toString());
        PreferenceHelper.setBool(PreferenceHelper.INTERNET_BOOL, false);
      } else {
        PreferenceHelper.remove(PreferenceHelper.LAST_GPS_OFF_TIME);
        PreferenceHelper.remove(PreferenceHelper.LAST_GPS_ON_TIME);
        PreferenceHelper.setString(PreferenceHelper.WAITING_START_TIME, DateTime.now().toString());
        PreferenceHelper.setBool(PreferenceHelper.GPS_BOOL, false);
      }
    }
  } catch (e) {}


}

Future<void> storeLocationDataWhenOffline() async {
  // Get the current position with the desired accuracy
double distance  = 81;
  double? lastLat =
  PreferenceHelper.getDouble(PreferenceHelper.LAST_LAT);
  double? lastLong =
  PreferenceHelper.getDouble(PreferenceHelper.LAST_LONG);

  Position positionData = await Geolocator.getCurrentPosition(
    desiredAccuracy: LocationAccuracy.best,
  );

  distance = Geolocator.distanceBetween(lastLat ?? 0, lastLong ?? 0,
      positionData.latitude, positionData.longitude);
  // if((distance) > 80){

    List<String> offlineData = PreferenceHelper.getStringList('offline_data') ?? [];


    Map<String, dynamic> dataPoint = {
      'lattitude': positionData.latitude,
      'longitude': positionData.longitude,
      'offlineTime': AppUtils.getDate(date: DateTime.now().toString(), format: AppConstant.dateFormat),
    };

    offlineData.add(jsonEncode(dataPoint));
    PreferenceHelper.setStringList('offline_data', offlineData);
    List offlineDataMaps = offlineData.map((data) => jsonDecode(data)).toList();
    print("Offline data points:$offlineDataMaps");
  // }else{
  //   print("you are in under meter");
  // }


}




