import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
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

class BackgroundService {

  Future<void> initializeService() async {
    int? liveLocationInterval =
        PreferenceHelper.getInt(PreferenceHelper.LIVE_LOCATION_INTERVAL);
    print("liveLocationInterval$liveLocationInterval");
    final service = FlutterBackgroundService();
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
  service.on("update").listen((event) {
    print("data_received${event?["isWaiting"]}");
    if (event != null) {
      bool isWaiting = event["isWaiting"];
      PreferenceHelper.setBool(PreferenceHelper.isWaiting, isWaiting);
    }
  });
  service.on("checkout_update").listen((event) {
    print("data_received${event?["waitingStartTime"]}");
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
    if(waitingTime != null && waitingTime != 0){
      waitingIntervalTime = (waitingTime * 60);
      print("waitingIntervalTime$waitingIntervalTime");
    }

    print("liveLocationInterval$liveLocationInterval");
    print("waitingTime$waitingTime");
    print("isWaitingAllowed$isWaitingAllowed");
    Timer.periodic(
      Duration(
          seconds: liveLocationInterval != null || liveLocationInterval != 0
              ? liveLocationInterval ?? 15
              : 15),
      (timer) async {
        var now = DateTime.now();
        print("current_TIME$now");
        if (now.hour == 23 && now.minute >= 50 && now.minute <= 59) {
          print("its_11:59:59");
          // If it's between 11:55:00 PM and 11:59:59 PM, clear preferences and stop the service
          PreferenceHelper.clear();
          service.stopSelf();
          timer.cancel(); // Stop the timer
        }

        if (service is AndroidServiceInstance) {
          if (await service.isForegroundService()) {
            service.setForegroundNotificationInfo(
              title: "Background Location",
              content: "Activated",
            );
          }
        }
        try {
          final connectivityResult = await Connectivity().checkConnectivity();
          var isInternetAvailable =
              connectivityResult == ConnectivityResult.mobile ||
                  connectivityResult == ConnectivityResult.wifi;
          var isGPSEnabled =
              await Permission.locationAlways.serviceStatus.isEnabled &&
                  await Permission.location.serviceStatus.isEnabled;

          if (isInternetAvailable && isGPSEnabled) {
            PreferenceHelper.reload().then((value) async {
              Position position;
              double distance = 51;
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
                await handleInternetAndGPSApi();
              }
              print("_______distance$distance");
              print("checkIn____$checkIn");
              if ((distance) > 50) {
                if(isWaitingAllowed == true){
                  String? waitingStartTime = PreferenceHelper.getString(
                      PreferenceHelper.WAITING_START_TIME);
                  print(
                      "waiting_Time_using_background_service1$waitingStartTime");
                  print("distance$distance");
                  print("waiting_using_background_service${isWaiting.value}");
                  if (isWaiting.value == true) {

                    print("waiting${isWaiting.value}");
                    await waitingEndApi(service: service);
                  }
                  print("waiting_Time_using_background_service$waitingStartTime");
                }
                await updateRouteHistory();

              } else {
                bool? checkIn = value?.getBool(PreferenceHelper.checkIn) ?? false;
                if (isWaitingAllowed == true) {
                  isWaiting.value =
                      PreferenceHelper.getBool(PreferenceHelper.isWaiting);
                  print("checkInn$checkIn");
                  print("isWaiting${isWaiting.value}");

                  String? waitingStartTime = PreferenceHelper.getString(
                      PreferenceHelper.WAITING_START_TIME);
                  double? lastLat =
                      PreferenceHelper.getDouble(PreferenceHelper.LAST_LAT);
                  double? lastLong =
                      PreferenceHelper.getDouble(PreferenceHelper.LAST_LONG);
                  print("waitingStartTimedata$waitingStartTime");
                  if (checkIn == false && isWaiting.value == false) {
                    try {
                      int? idealMarkerTime =
                      waitingIntervalTime != null || waitingIntervalTime != 0
                              ? waitingIntervalTime ?? 300
                              : 300;
                      print("waiting_Time$idealMarkerTime");
                      if (DateTime.now()
                              .difference(
                                  DateTime.parse(waitingStartTime ?? ""))
                              .inSeconds >
                          idealMarkerTime) {
                        print(
                            "waiting_time${DateTime.now().difference(DateTime.parse(waitingStartTime ?? "")).inSeconds}");
                        print("call_after_30_seconds${isWaiting.value}");
                        await waitingStartApi(
                            service: service,
                            waitingStartTime: waitingStartTime,
                            lastLat: lastLat,
                            lastLong: lastLong);
                      } else {
                        print("waiting_start_in_30 seconds");
                      }
                    } catch (e) {
                      print("Error parsing waitingStartTime: $e");
                    }
                  }else{
                    print("time_of_notification${DateTime.now().difference(DateTime.parse(waitingStartTime ?? "")).inMinutes}");
                    if(DateTime.now().difference(DateTime.parse(waitingStartTime ?? "")).inMinutes >= 30){
                      print("notifaction_code_here");
                      NotificationService().showNotification(title: "Waiting",body: "Your waiting period has started Before 30 min.", id: 0);
                      PreferenceHelper.setString(PreferenceHelper.WAITING_START_TIME, DateTime.now().toString());
                    }
                  }
                }
              }
            });
          } else if (isGPSEnabled && !isInternetAvailable) {
            print("GPS ON & INTERNET OFF");
            handleGpsAndInternetOffData(serviceType: "internet");
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
            print("GPS OFF & INTERNET ON");
            handleGpsAndInternetOffData(serviceType: "gps");
          } else if (!isGPSEnabled && !isInternetAvailable) {
            print("GPS OFF & INTERNET OFF");
            bool gpsBool = PreferenceHelper.getBool(PreferenceHelper.GPS_BOOL);
            bool internetBool =
                PreferenceHelper.getBool(PreferenceHelper.INTERNET_BOOL);
            if (gpsBool == false && internetBool == false) {
              print("trueeeeeeeeee");
              handleGpsAndInternetOffData(serviceType: "gps");
              handleGpsAndInternetOffData(serviceType: "internet");
              PreferenceHelper.reload().then((value) async {
                bool? checkIn = value?.getBool(PreferenceHelper.checkIn);
                double? lastLat =
                    PreferenceHelper.getDouble(PreferenceHelper.LAST_LAT);
                double? lastLong =
                    PreferenceHelper.getDouble(PreferenceHelper.LAST_LONG);
                print("Data_Off_history_CheckIn_$checkIn");
                if (checkIn == false || checkIn == null) {
                  try {
                    bool internetBool = PreferenceHelper.getBool(
                        PreferenceHelper.INTERNET_BOOL);
                    print("InterNetbool$internetBool");
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
                      print("InterNetbool$internetBool");
                    }
                  } catch (e) {
                    print("catch_at_internetoffData$e");
                  }
                }
              });
            }
          }
        } catch (e) {
          print("catch_atBackground_service$e");
        }
      },
    );
  });
}

handleGpsAndInternetOffData({String? serviceType}) async {
  PreferenceHelper.reload().then((value) async {
    bool? checkIn = value?.getBool(PreferenceHelper.checkIn);
    print("Data_Off_history_CheckIn_$checkIn");
    if (checkIn == false || checkIn == null) {
      if (serviceType == "internet") {
        try {
          Position positionData = await Geolocator.getCurrentPosition(
              desiredAccuracy: LocationAccuracy.best);
          bool internetBool =
              PreferenceHelper.getBool(PreferenceHelper.INTERNET_BOOL);
          print("InterNetbool$internetBool");
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
            print("InterNetbool$internetBool");
          }
        } catch (e) {
          print("catch_at_internetoffData$e");
        }
      }
      if (serviceType == "gps") {
        double? lastLat = PreferenceHelper.getDouble(PreferenceHelper.LAST_LAT);
        double? lastLong =
            PreferenceHelper.getDouble(PreferenceHelper.LAST_LONG);
        bool? gpsBool = PreferenceHelper.getBool(PreferenceHelper.GPS_BOOL);
        if (gpsBool == false) {
          print("GPS$gpsBool");
          PreferenceHelper.setString(
              PreferenceHelper.LAST_GPS_OFF_TIME,
              AppUtils.dateFormat(
                  date: DateTime.now(), dateFormat: AppConstant.dateFormat));
          PreferenceHelper.setDouble(
              PreferenceHelper.LAST_GPS_OFF_LAT, lastLat ?? 0);
          PreferenceHelper.setDouble(
              PreferenceHelper.LAST_GPS_OFF_LONG, lastLong ?? 0);
          PreferenceHelper.setBool(PreferenceHelper.GPS_BOOL, true);
          bool? gpsBooll = PreferenceHelper.getBool(PreferenceHelper.GPS_BOOL);
          print("GpsBool$gpsBooll");
        }
      }
    }
  });
}

CreateRouteHistoryModel? createRouteHistoryModel;

Future<void> updateRouteHistory() async {
  try {
    PreferenceHelper.load().then((value) async {
      String? userId = PreferenceHelper.getString(PreferenceHelper.USER_ID);

      Position? position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.best);

      Map<String, dynamic> body = {
        "userId": userId,
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
    print("print_route_history_catch_$e");
  }
}

Future<void> waitingStartApi(
    {required ServiceInstance service,
    String? waitingStartTime,
    double? lastLat,
    double? lastLong}) async {
  print("waitingStartApi_waitingStartTime$waitingStartTime");
  print("waitingStartApi_LastLat$lastLat");
  print("waitingStartApi_LastLong$lastLong");

  int batteryLevel = await AppUtils.getBatteryLevel();
  print("batteryLevel$batteryLevel");

  PreferenceHelper.load().then((value) async {
    String? userId = PreferenceHelper.getString(PreferenceHelper.USER_ID);
    Map<String, dynamic> body = {};
    body = {
      "userId": userId,
      "lattitude": lastLat,
      "longitude": lastLong,
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

Future<void> waitingEndApi({required ServiceInstance service}) async {
  Position? position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.best);

  int batteryLevel = await AppUtils.getBatteryLevel();
  print("battery_Level${batteryLevel}");

  PreferenceHelper.load().then((value) async {
    String? userId = PreferenceHelper.getString(PreferenceHelper.USER_ID);
    Map<String, dynamic> body = {};
    body = {
      "userId": userId,
      "lattitude": position.latitude,
      "longitude": position.longitude,
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

Future<void> handleInternetAndGPSApi() async {
  PreferenceHelper.load().then((value) async {
    String? userId = PreferenceHelper.getString(PreferenceHelper.USER_ID);
    bool? gpsBool = PreferenceHelper.getBool(PreferenceHelper.GPS_BOOL);

    if (gpsBool) {
      String? lastGpsOffTime =
          PreferenceHelper.getString(PreferenceHelper.LAST_GPS_OFF_TIME);
      if (lastGpsOffTime != "" && lastGpsOffTime != null) {
        print("GPSboollllllllllll$gpsBool");
        PreferenceHelper.setString(
            PreferenceHelper.LAST_GPS_ON_TIME,
            AppUtils.dateFormat(
                date: DateTime.now(), dateFormat: AppConstant.dateFormat));
      }
      await callInternetAndGpsActivityApi(
          userId: userId, isGps: true, isGpsOn: false);
      await Future.delayed(const Duration(milliseconds: 500));
      await callInternetAndGpsActivityApi(
          userId: userId, isGps: true, isGpsOn: true);
    }
    bool? internetBool =
        PreferenceHelper.getBool(PreferenceHelper.INTERNET_BOOL);
    if (internetBool) {
      print("INTERNET$internetBool");
      await callInternetAndGpsActivityApi(
          userId: userId, isInternet: true, isInternetOn: false);
      Future.delayed(const Duration(milliseconds: 500));
      await callInternetAndGpsActivityApi(
          userId: userId, isInternet: true, isInternetOn: true);
    }
  });
}

callInternetAndGpsActivityApi({
  required String? userId,
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

  if (isInternet == true) {
    body = {
      "userId": userId,
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
      "batteryLevel": await AppUtils.getBatteryLevel()
    };
  }

  if (isGps == true) {
    body = {
      "userId": userId,
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
    print("endpoint$endPoint");
    print("body---$body");
    var response = await callPostMethod(endPoint, body);
    print("response$response");
    createActivityModel = CreateActivityModel?.fromJson(json.decode(response));
    if (createActivityModel.isError == false &&
        createActivityModel.isValidationFailed == false) {
      if (isInternet == true) {
        PreferenceHelper.remove(PreferenceHelper.UNIVERSAL_LAST_SAVED_TIME);
        PreferenceHelper.setString(
            PreferenceHelper.WAITING_START_TIME, DateTime.now().toString());
        PreferenceHelper.setBool(PreferenceHelper.INTERNET_BOOL, false);
      } else {
        PreferenceHelper.remove(PreferenceHelper.LAST_GPS_OFF_TIME);
        PreferenceHelper.remove(PreferenceHelper.LAST_GPS_ON_TIME);
        PreferenceHelper.setString(
            PreferenceHelper.WAITING_START_TIME, DateTime.now().toString());
        PreferenceHelper.setBool(PreferenceHelper.GPS_BOOL, false);
      }
    } else {}
  } catch (e) {
    print("catch at dataOffHistory$e");
  }
}

Future<void> setWaitingState(bool isWaiting) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setBool(PreferenceHelper.isWaiting, isWaiting);
}
