import 'dart:async';
import 'dart:convert';

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
  userId = PreferenceHelper.getString(PreferenceHelper.USER_UID) ?? "";

  WidgetsFlutterBinding.ensureInitialized();
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
    const Duration(seconds: 5),
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
        double? lastLat;
        double? lastLong;
        String? userId;
        bool? checkIn;
        String? waitingStartTime;

        PreferenceHelper.load().then((value) {
          lastLat = PreferenceHelper.getDouble(PreferenceHelper.LAST_LAT);
          lastLong = PreferenceHelper.getDouble(PreferenceHelper.LAST_LONG);
          userId = PreferenceHelper.getString(PreferenceHelper.USER_UID);
        });
        PreferenceHelper.reload().then((value) {
          checkIn = PreferenceHelper.getBool(PreferenceHelper.checkIn);
        });

        final connectivityResult = await Connectivity().checkConnectivity();

        var isInternetAvailable =
            connectivityResult == ConnectivityResult.mobile ||
                connectivityResult == ConnectivityResult.wifi;

        var isGPSEnabled =
            await Permission.locationAlways.serviceStatus.isEnabled &&
                await Permission.location.serviceStatus.isEnabled;

        Position position;
        double distance = 51;
        position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.best);

        distance = Geolocator.distanceBetween(
            lastLat ?? 0, lastLong ?? 0, position.latitude, position.longitude);

        print("_print_userId$userId");
        print("_print_checkIn$checkIn");
        if (isInternetAvailable && isGPSEnabled) {
          final databaseService = DatabaseService();
          bool? isWaiting = await databaseService.getWaitingStatus();
          handleInternetAndGPSApi(userId: userId);
          if ((distance) > 50) {
            print("_print_checkIn ttrue");
            await updateRouteHistory();
            if (isWaiting == true && checkIn == false) {
              await waitingEndApi();
            }
          } else {
            PreferenceHelper.reload().then((value) async{
             checkIn = value?.getBool(PreferenceHelper.checkIn);
              String? waitingStartTime =
                  value?.getString(PreferenceHelper.WAITING_START_TIME);
              if (checkIn == false && isWaiting == false) {
                if (DateTime.now().difference(DateTime.parse(waitingStartTime.toString() )).inSeconds > 30) {
                  await waitingStartApi();
                }
              }

            });

          }
          print("_print_checkIn ffalse");
        } else if (isGPSEnabled && !isInternetAvailable) {
          handleGpsAndInternetOffData(serviceType: "internet");
        } else if (!isGPSEnabled && isInternetAvailable) {
          handleGpsAndInternetOffData(serviceType: "gps");
        } else {
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

        // await callCreateRouteHistory();
        // if (isGPSEnabled && isInternetAvailable) {
        //    await handleInternetAndGPS(userId: PreferenceHelper.getString(PreferenceHelper.USER_UID));
        //   await callCreateRouteHistory(userId: userId);
        // } else if (isGPSEnabled && !isInternetAvailable) {
        //   await handleInternetAndGPS(
        //       userId: PreferenceHelper.getString(PreferenceHelper.USER_UID),
        //       isInternet: false,
        //       isInternetOn: false);
        // } else if (!isGPSEnabled && isInternetAvailable) {
        //   await handleInternetAndGPS(
        //       userId: PreferenceHelper.getString(PreferenceHelper.USER_UID),
        //       isGps: false,
        //       isGpsOn: false);
        // } else if (!isGPSEnabled && !isInternetAvailable) {
        //   await handleInternetAndGPS(
        //       userId: PreferenceHelper.getString(PreferenceHelper.USER_UID),
        //       isInternet: false,
        //       isInternetOn: false,
        //       isGps: false,
        //       isGpsOn: false);
        // }
      } catch (e) {
        rethrow;
      }
    },
  );
}

handleGpsAndInternetOffData({String? serviceType}) async {
  Position positionData = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.medium);
  if (serviceType == "internet") {
    bool internetBool =
        PreferenceHelper.getBool(PreferenceHelper.INTERNET_BOOL);
    if (internetBool == false) {
      PreferenceHelper.setString(
          PreferenceHelper.LAST_INTERNET_OFF_TIME,
          AppUtils.dateFormat(
              date: DateTime.now(), dateFormat: AppConstant.dateFormat));
      PreferenceHelper.setDouble(
          PreferenceHelper.LAST_INTERNET_OFF_LAT, positionData.latitude);
      PreferenceHelper.setDouble(
          PreferenceHelper.LAST_INTERNET_OFF_LONG, positionData.longitude);
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
          PreferenceHelper.LAST_GPS_OFF_LAT, positionData.latitude);
      PreferenceHelper.setDouble(
          PreferenceHelper.LAST_GPS_OFF_LONG, positionData.longitude);
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

    if (createRouteHistoryModel?.isError == false &&
        createRouteHistoryModel?.isValidationFailed == false) {
      PreferenceHelper.setDouble(PreferenceHelper.LAST_LAT, position.latitude);
      PreferenceHelper.setDouble(
          PreferenceHelper.LAST_LONG, position.longitude);
      PreferenceHelper.setString(
          PreferenceHelper.WAITING_START_TIME, DateTime.now().toString());
    }
  } catch (e) {
    print("print_route_history_catch_$e");
  }
}

Future<void> waitingStartApi() async {
  final databaseService = DatabaseService();
  Position? position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.best);

  PreferenceHelper.load().then((value) {
    userId = PreferenceHelper.getString(PreferenceHelper.USER_UID) ?? "";
  });
  Map<String, dynamic> body = {};
  body = {
    "userId": userId,
    "lattitude": position.latitude,
    "longitude": position.longitude,
    "totTrackingEventId": AppConstant.trackingWaitingStartEvent,
    "activityDateTime": AppUtils.getDate(
        date: DateTime.now().toString(), format: AppConstant.dateFormat),
    "batteryLevel": AppUtils.getBatteryLevel(),
  };

  String endPoint = ApiConstants.createActivity;
  var response = await callPostMethod(endPoint, body);
  CreateActivityModel? createActivityModel =
      CreateActivityModel?.fromJson(json.decode(response));

  if (createActivityModel.isError == false &&
      createActivityModel.isValidationFailed == false) {
    await databaseService.startWaiting();
  }
}

Future<void> waitingEndApi() async {
  final databaseService = DatabaseService();
  double? lastLat = PreferenceHelper.getDouble(PreferenceHelper.LAST_LAT);
  double? lastLong = PreferenceHelper.getDouble(PreferenceHelper.LAST_LONG);
  String? waitingStartTime =
      PreferenceHelper.getString(PreferenceHelper.WAITING_START_TIME);

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
    "batteryLevel": AppUtils.getBatteryLevel(),
  };

  String endPoint = ApiConstants.createActivity;
  var response = await callPostMethod(endPoint, body);
  CreateActivityModel? createActivityModel =
      CreateActivityModel?.fromJson(json.decode(response));

  if (createActivityModel.isError == false &&
      createActivityModel.isValidationFailed == false) {
    await databaseService.deleteWaiting();
  }
}

Future<void> handleInternetAndGPSApi({
  required String? userId,
}) async {
  bool? gpsBool = PreferenceHelper.getBool(PreferenceHelper.GPS_BOOL);
  bool? internetBool = PreferenceHelper.getBool(PreferenceHelper.INTERNET_BOOL);
  if (gpsBool) {
    await callInternetAndGpsActivityApi(userId: userId,isGps: true,isGpsOn: false);
    await callInternetAndGpsActivityApi(userId: userId, isGps: true, isGpsOn: true);
  }
  if (internetBool) {
    await callInternetAndGpsActivityApi(userId: userId,isInternet: true,isInternetOn: false);
    await callInternetAndGpsActivityApi(userId: userId, isInternet: true, isInternetOn: true);
  }
}

Future<void> callInternetAndGpsActivityApi({
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
      "batteryLevel": AppUtils.getBatteryLevel(),
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
      "batteryLevel": AppUtils.getBatteryLevel(),
    };
  }

  try {
    String endPoint = ApiConstants.createActivity;
    var response = await callPostMethod(endPoint, body);
    CreateActivityModel? createActivityModel =
        CreateActivityModel?.fromJson(json.decode(response));
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
    } else {}
  } catch (e) {
    rethrow;
  }
}
