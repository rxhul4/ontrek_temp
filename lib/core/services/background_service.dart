import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:ontrek/core/background_service_model/create_route_history_model.dart';
import 'package:ontrek/core/services/api_constants.dart';
import 'package:ontrek/core/services/network_repository.dart';
import 'package:ontrek/core/storage/preference_helper.dart';
import 'package:ontrek/core/storage/sql_db_service.dart';
import 'package:ontrek/core/utils/App_utils.dart';
import 'package:ontrek/core/utils/app_constant.dart';
import 'package:ontrek/features/attendance/model/add_activity_model.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BackgroundService {
  Future<void> initializeService() async {
    final service = FlutterBackgroundService();
    await service.configure(
      iosConfiguration: IosConfiguration(),
      androidConfiguration: AndroidConfiguration(
        onStart: onStart,
        autoStart: false,
        isForegroundMode: true,
      ),
    );
  }
}

@pragma('vm:entry-point')
String userId = "";

void onStart(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();

  service.on("update").listen((event) {
    print("data_received${event?["isWaiting"]}");
    if (event != null) {
      bool isWaiting = event["isWaiting"];
      PreferenceHelper.setBool(PreferenceHelper.isWaiting, isWaiting);
      // BackgroundService().isWaiting.value = isWaiting;
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

  Timer.periodic(
    const Duration(seconds: 10),
    (timer) async {
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
          await handleInternetAndGPSApi();
          Position position;
          double distance = 51;
          position = await Geolocator.getCurrentPosition(
              desiredAccuracy: LocationAccuracy.best);

          double? lastLat =
              PreferenceHelper.getDouble(PreferenceHelper.LAST_LAT);
          double? lastLong =
              PreferenceHelper.getDouble(PreferenceHelper.LAST_LONG);
          ValueNotifier<bool?> isWaiting = ValueNotifier(false);

          distance = Geolocator.distanceBetween(lastLat ?? 0, lastLong ?? 0,
              position.latitude, position.longitude);
          PreferenceHelper.reload().then((value) async {
            bool? checkIn = value?.getBool(PreferenceHelper.checkIn) ?? false;
            if (value != null) {
              isWaiting.value = value.getBool(PreferenceHelper.isWaiting);
            }

            print("_______distance$distance");
            print("checkIn____$checkIn");
            if ((distance) > 50 && checkIn == false) {
              print("distance$distance");
              await updateRouteHistory();
              print("waiting_using_background_service${isWaiting.value}");
              if (isWaiting.value == true) {
                print("waiting${isWaiting.value}");
                await waitingEndApi(service);
              }
            } else {
              bool? checkIn = value?.getBool(PreferenceHelper.checkIn) ?? false;
              isWaiting.value =
                  PreferenceHelper.getBool(PreferenceHelper.isWaiting);

              print("checkInn$checkIn");
              print("newWaiting: ${isWaiting.value}");

              print("isWaiting${isWaiting.value}");

              String? waitingStartTime =
                  value?.getString(PreferenceHelper.WAITING_START_TIME);
              print("waitingStartTimedata$waitingStartTime");
              if (checkIn == false && isWaiting.value == false) {
                try {
                  if (DateTime.now()
                          .difference(DateTime.parse(waitingStartTime ?? ""))
                          .inSeconds >
                      30) {
                    print(
                        "waiting_time${DateTime.now().difference(DateTime.parse(waitingStartTime ?? "")).inSeconds}");
                    print("call_after_30 seconds${isWaiting.value}");
                    await waitingStartApi(service);
                  } else {
                    print("waiting_start_in_30 seconds");
                  }
                } catch (e) {
                  print("Error parsing waitingStartTime: $e");
                }
              }
            }
          });
        } else if (isGPSEnabled && !isInternetAvailable) {
          print("GPS ON & INTERNET OFF");
          handleGpsAndInternetOffData(serviceType: "internet");
        } else if (!isGPSEnabled && isInternetAvailable) {
          print("GPS OFF & INTERNET ON");

          handleGpsAndInternetOffData(serviceType: "gps");
        } else {
          print("GPS OFF & INTERNET OFF");

          bool gpsBool = PreferenceHelper.getBool(PreferenceHelper.GPS_BOOL);
          bool internetBool =
              PreferenceHelper.getBool(PreferenceHelper.INTERNET_BOOL);
          if (internetBool == false) {
            handleGpsAndInternetOffData(serviceType: "internet");
          }
          if (gpsBool == false) {
            handleGpsAndInternetOffData(serviceType: "gps");
          }
        }
      } catch (e) {
        rethrow;
      }
    },
  );
}

handleGpsAndInternetOffData({String? serviceType}) async {
  Position? positionData = await Geolocator.getLastKnownPosition();
  if (serviceType == "internet") {
    bool internetBool =
        PreferenceHelper.getBool(PreferenceHelper.INTERNET_BOOL);
    if (internetBool == false) {
      PreferenceHelper.setString(
          PreferenceHelper.LAST_INTERNET_OFF_TIME,
          AppUtils.dateFormat(
              date: DateTime.now(), dateFormat: AppConstant.dateFormat));
      PreferenceHelper.setDouble(
          PreferenceHelper.LAST_INTERNET_OFF_LAT, positionData?.latitude ?? 0);
      PreferenceHelper.setDouble(
          PreferenceHelper.LAST_INTERNET_OFF_LONG, positionData?.longitude ?? 0);
      PreferenceHelper.setBool(PreferenceHelper.INTERNET_BOOL, true);
    }
  }

  if (serviceType == "gps") {
    bool gpsBool = PreferenceHelper.getBool(PreferenceHelper.INTERNET_BOOL);
    if (gpsBool == false) {
      PreferenceHelper.setString(
          PreferenceHelper.LAST_GPS_OFF_TIME,
          AppUtils.dateFormat(
              date: DateTime.now(), dateFormat: AppConstant.dateFormat));
      PreferenceHelper.setDouble(
          PreferenceHelper.LAST_GPS_OFF_LAT, positionData?.latitude ?? 0);
      PreferenceHelper.setDouble(
          PreferenceHelper.LAST_GPS_OFF_LONG, positionData?.longitude ?? 0);
      PreferenceHelper.setBool(PreferenceHelper.GPS_BOOL, true);
    }
  }
}

CreateRouteHistoryModel? createRouteHistoryModel;

Future<void> updateRouteHistory() async {
  try {
    String? userId = "";
    PreferenceHelper.load().then((value) {
      userId = PreferenceHelper.getString(PreferenceHelper.USER_UID) ?? "";
    });
    Position? position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best);

    if (position == null || userId == "") return;

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
    PreferenceHelper.setDouble(PreferenceHelper.LAST_LAT, position.latitude);
    PreferenceHelper.setDouble(PreferenceHelper.LAST_LONG, position.longitude);
    PreferenceHelper.setString(
        PreferenceHelper.WAITING_START_TIME, DateTime.now().toString());
    if (createRouteHistoryModel?.isError == false &&
        createRouteHistoryModel?.isValidationFailed == false) {}
  } catch (e) {
    print("print_route_history_catch_$e");
  }
}

Future<void> waitingStartApi(ServiceInstance service) async {
  Position? position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.best);

  int batteryLevel = await AppUtils.getBatteryLevel();
  print("battery_Level${batteryLevel}");

  PreferenceHelper.load().then((value) async {
    String? userId = PreferenceHelper.getString(PreferenceHelper.USER_UID);
    Map<String, dynamic> body = {};
    body = {
      "userId": userId,
      "lattitude": position.latitude,
      "longitude": position.longitude,
      "totTrackingEventId": AppConstant.trackingWaitingStartEvent,
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
      PreferenceHelper.setBool(PreferenceHelper.isWaiting, true);
      service.invoke("update", {"isWaiting": true});
    }
  });
}

Future<void> waitingEndApi(ServiceInstance service) async {
  double? lastLat = PreferenceHelper.getDouble(PreferenceHelper.LAST_LAT);
  double? lastLong = PreferenceHelper.getDouble(PreferenceHelper.LAST_LONG);
  String? waitingStartTime =
      PreferenceHelper.getString(PreferenceHelper.WAITING_START_TIME);
  int batteryLevel = await AppUtils.getBatteryLevel();
  print("batteryLevel$batteryLevel");

  PreferenceHelper.load().then((value) {
    userId = PreferenceHelper.getString(PreferenceHelper.USER_UID) ?? "";
  });
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
    // PreferenceHelper.setBool(PreferenceHelper.ISWAITING, false);
    setWaitingState(false);
    service.invoke("update", {"isWaiting": true});
  }
}

Future<void> handleInternetAndGPSApi() async {
  PreferenceHelper.load().then((value) async {
    String? userId = PreferenceHelper.getString(PreferenceHelper.USER_UID);
    bool? gpsBool = PreferenceHelper.getBool(PreferenceHelper.GPS_BOOL);
    bool? internetBool =
        PreferenceHelper.getBool(PreferenceHelper.INTERNET_BOOL);
    if (gpsBool) {
      print("GPS$gpsBool");
      // Future.delayed(const Duration(milliseconds: 500));
      await callInternetAndGpsActivityApi(
          userId: userId, isGps: true, isGpsOn: false);
      await Future.delayed(const Duration(milliseconds: 500));
      await callInternetAndGpsActivityApi(
          userId: userId, isGps: true, isGpsOn: true);
    }
    if (internetBool) {
      print("INTERNET$internetBool");

      // Future.delayed(const Duration(milliseconds: 500));
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
      "lattitude": isGpsOn ?? false ? position.latitude : lastLat,
      "longitude": isGpsOn ?? false ? position.longitude : lastLong,
      "totTrackingEventId":
          isGpsOn ?? false ? AppConstant.gpsOnEvent : AppConstant.gpsOffEvent,
      "activityDateTime": isGpsOn ?? false
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
      if (isInternet ?? false) {
        PreferenceHelper.remove(PreferenceHelper.UNIVERSAL_LAST_SAVED_TIME);
        PreferenceHelper.setBool(PreferenceHelper.INTERNET_BOOL, false);
      } else {
        PreferenceHelper.remove(PreferenceHelper.LAST_GPS_OFF_TIME);
        PreferenceHelper.remove(PreferenceHelper.LAST_GPS_ON_TIME);
        PreferenceHelper.setBool(PreferenceHelper.GPS_BOOL, false);
      }
    } else {

    }
  } catch (e) {
    print("catch at dataOffHistory$e");
  }
}

Future<void> setWaitingState(bool isWaiting) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setBool(PreferenceHelper.isWaiting, isWaiting);
}
