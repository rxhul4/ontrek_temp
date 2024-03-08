import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:battery_plus/battery_plus.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:ontrek/core/background_service_model/create_route_history_model.dart';
import 'package:ontrek/core/services/api_constants.dart';
import 'package:ontrek/core/services/network_repository.dart';
import 'package:ontrek/core/storage/preference_helper.dart';
import 'package:ontrek/core/utils/App_utils.dart';
import 'package:ontrek/core/utils/app_constant.dart';
import 'package:ontrek/features/attendance/model/add_activity_model.dart';
import 'package:ontrek/features/attendance/provider/attendance_provider.dart';
import 'package:ontrek/features/authentication/providers/auth_provider.dart';
import 'package:ontrek/features/authentication/screens/splash_screen.dart';
import 'package:ontrek/features/check_out/provider/check_out_form_provider.dart';
import 'package:ontrek/features/dashboard/provider/dashboard_provider.dart';
import 'package:ontrek/features/salesman_tracker/provider/salesmen_tracking_timeline_provider.dart';
import 'package:ontrek/features/task_list/provider/task_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:http/http.dart' as http;

import 'features/authentication/screens/login_with_phone_number.dart';
import 'features/track_function/provider/salesmen_list_provider.dart';

GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

List<SingleChildWidget> providers = [
  ChangeNotifierProvider<AttendanceProvider>(
    create: (_) => AttendanceProvider(),
  ),
  ChangeNotifierProvider<AuthenticationProvider>(
    create: (_) => AuthenticationProvider(),
  ),
  ChangeNotifierProvider<SalesMenListProvider>(
    create: (_) => SalesMenListProvider(),
  ),
  ChangeNotifierProvider<SaleMenTackingTimeLineProvider>(
    create: (_) => SaleMenTackingTimeLineProvider(),
  ),
  ChangeNotifierProvider<CheckOutProvider>(
    create: (_) => CheckOutProvider(),
  ),
  ChangeNotifierProvider<TaskProvider>(
    create: (_) => TaskProvider(),
  ),
  ChangeNotifierProvider<DashBoardProvider>(
    create: (_) => DashBoardProvider(),
  ),
];

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  PreferenceHelper.load().then((value) {
    runApp(MultiProvider(providers: providers, child: const MyApp()));
  });
  await initializeService();
}

Future<void> initializeService() async {
  final service = FlutterBackgroundService();

  await service.configure(
      iosConfiguration: IosConfiguration(),
      androidConfiguration: AndroidConfiguration(
        onStart: onStart,
        autoStart: false,
        isForegroundMode: true,
      ));

  // await service.startService();
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) {
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

  // DateTime? internetOffTime;
  // DateTime? internetOnTime;

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

      final connectivityResult = await Connectivity().checkConnectivity();
      var isInternetAvailable =
          connectivityResult == ConnectivityResult.mobile ||
              connectivityResult == ConnectivityResult.wifi;
      var isGPSEnabled =
          await Permission.locationAlways.serviceStatus.isEnabled &&
              await Permission.location.serviceStatus.isEnabled;
      try {
        if (isGPSEnabled && isInternetAvailable) {
          print("BackGround Service is Running");
          PreferenceHelper.load().then((value) {
            String? userId = value?.getString(PreferenceHelper.USER_UID);
            print("userId${userId}");

            bool gpsBool = PreferenceHelper.getBool(PreferenceHelper.GPS_BOOL);
            bool internetBool =
                PreferenceHelper.getBool(PreferenceHelper.INTERNET_BOOL);

            if (gpsBool) {
              String? lastGpsTime = PreferenceHelper.getString(
                  PreferenceHelper.LAST_GPS_OFF_TIME);
              if (lastGpsTime != "" && lastGpsTime != null) {
                print("true came gps on time was null so adding it");
                PreferenceHelper.setString(
                    PreferenceHelper.LAST_GPS_ON_TIME,
                    AppUtils.dateFormat(
                        date: DateTime.now(),
                        dateFormat: AppConstant.dateFormat));
              }
              // callAddDataOffHistoryApi("GPS");
            }
            if (internetBool) {
              print("uuuuuuuuuuuuuuuuuuuuuu ");
              // callAddDataOffHistoryApi("Internet");
            }

            callCreateRouteHistory(userId: userId);
            // callCreateWaitingActivityApi(userId: userId);
          }
          );
        } else if (isGPSEnabled && !isInternetAvailable) {
          // print("internet is not available ");
          // bool internetBool =
          //     PreferenceHelper.getBool(PreferenceHelper.INTERNET_BOOL);
          // if (internetBool == false) {
          //   Position positionData = await Geolocator.getCurrentPosition(
          //       desiredAccuracy: LocationAccuracy.medium);
          //
          //   PreferenceHelper.setString(
          //       PreferenceHelper.LAST_INTERNET_OFF_TIME,
          //       AppUtils.dateFormat(
          //           date: DateTime.now(), dateFormat: AppConstant.dateFormat));
          //   PreferenceHelper.setDouble(
          //       PreferenceHelper.LAST_INTERNET_OFF_LAT, positionData.latitude);
          //   PreferenceHelper.setDouble(PreferenceHelper.LAST_INTERNET_OFF_LONG,
          //       positionData.longitude);
          //
          //   PreferenceHelper.setBool(PreferenceHelper.INTERNET_BOOL, true);
          // }
          //
          // String? lastGpsTime =
          //     PreferenceHelper.getString(PreferenceHelper.LAST_GPS_OFF_TIME);
          // if (lastGpsTime != "" && lastGpsTime != null) {
          //   PreferenceHelper.setString(
          //       PreferenceHelper.LAST_GPS_ON_TIME,
          //       AppUtils.dateFormat(
          //           date: DateTime.now(), dateFormat: AppConstant.dateFormat));
          // }
        } else if (!isGPSEnabled && isInternetAvailable) {
          // // internetOnTime = DateTime.now();
          // print("gps is not available");
          //
          // bool gpsBool = PreferenceHelper.getBool(PreferenceHelper.GPS_BOOL);
          // // bool internetBool =
          // //     PreferenceHelper.getBool(PreferenceHelper.INTERNET_BOOL);
          // if (gpsBool == false) {
          //   Position? positionData = await Geolocator.getLastKnownPosition();
          //   PreferenceHelper.setString(
          //       PreferenceHelper.LAST_GPS_OFF_TIME,
          //       AppUtils.dateFormat(
          //           date: DateTime.now(), dateFormat: AppConstant.dateFormat));
          //   PreferenceHelper.setDouble(
          //       PreferenceHelper.LAST_GPS_OFF_LAT, positionData?.latitude ?? 0);
          //   PreferenceHelper.setDouble(PreferenceHelper.LAST_GPS_OFF_LONG,
          //       positionData?.longitude ?? 0);
          //   PreferenceHelper.setBool(PreferenceHelper.GPS_BOOL, true);
          // }
          // // if(gpsBool ){
          // //   callAddDataOffHistoryApi("GPS");
          // // }
          // // if (internetBool) {
          // //   callAddDataOffHistoryApi("Internet");
          // // }
        } else if (!isGPSEnabled && !isInternetAvailable) {
          // bool gpsBool = PreferenceHelper.getBool(PreferenceHelper.GPS_BOOL);
          // if (gpsBool == false) {
          //   PreferenceHelper.setString(
          //       PreferenceHelper.LAST_GPS_OFF_TIME,
          //       AppUtils.dateFormat(
          //           date: DateTime.now(), dateFormat: AppConstant.dateFormat));
          //   double? lastLat =
          //       PreferenceHelper.getDouble(PreferenceHelper.LAST_LAT);
          //   double? lastLong =
          //       PreferenceHelper.getDouble(PreferenceHelper.LAST_LONG);
          //   PreferenceHelper.setDouble(
          //       PreferenceHelper.LAST_GPS_OFF_LAT, lastLat ?? 0);
          //   PreferenceHelper.setDouble(
          //       PreferenceHelper.LAST_GPS_OFF_LONG, lastLong ?? 0);
          //
          //   PreferenceHelper.setBool(PreferenceHelper.GPS_BOOL, true);
          // }
          //
          // bool internetBool =
          //     PreferenceHelper.getBool(PreferenceHelper.INTERNET_BOOL);
          // if (internetBool == false) {
          //   PreferenceHelper.setString(
          //       PreferenceHelper.LAST_INTERNET_OFF_TIME,
          //       AppUtils.dateFormat(
          //           date: DateTime.now(), dateFormat: AppConstant.dateFormat));
          //   // Position positionData = await Geolocator.getCurrentPosition(
          //   //     desiredAccuracy: LocationAccuracy.best);
          //
          //   double? lastLat =
          //       PreferenceHelper.getDouble(PreferenceHelper.LAST_LAT);
          //   double? lastLong =
          //       PreferenceHelper.getDouble(PreferenceHelper.LAST_LONG);
          //
          //   PreferenceHelper.setDouble(
          //       PreferenceHelper.LAST_INTERNET_OFF_LAT, lastLat ?? 0);
          //   PreferenceHelper.setDouble(
          //       PreferenceHelper.LAST_INTERNET_OFF_LONG, lastLong ?? 0);
          //
          //   PreferenceHelper.setBool(PreferenceHelper.INTERNET_BOOL, true);
          // }
          print("internet and gps is not available ");
        } else {
          print("do nothing");
        }
      } catch (e) {
        print("BackGround Catch---${e}");
      }
    },
  );
}

CreateActivityModel? createActivityModel;
CreateRouteHistoryModel? createRouteHistoryModel;

callCreteRouteHistoryApi({String? userId, Position? position}) async {
  if (kDebugMode) {
    print("userId---------${userId}");
  }
  Map<String, dynamic> body = {
    "userId": userId,
    "lattitude": position?.latitude,
    "longitude": position?.longitude,
    "modifiedOn": AppUtils.dateFormat(
        date: DateTime.now(), dateFormat: AppConstant.dateFormat)
  };
  try {
    print("userUid----- ${userId}");
    String endPoint = ApiConstants.createRouteHistory;
    var response = await callPostMethod(endPoint, body);
    createRouteHistoryModel =
        CreateRouteHistoryModel.fromJson(json.decode(response));
    print("isError--${createRouteHistoryModel?.isError}");
    print("isValidationFailed--${createRouteHistoryModel?.isValidationFailed}");
    print("response : $response");

    if (createRouteHistoryModel?.isError == false &&
        createRouteHistoryModel?.isValidationFailed == false) {
      bool isWaiting = PreferenceHelper.getBool(PreferenceHelper.ISWAITING);
      if(isWaiting == true){

      }else{
        PreferenceHelper.setString(PreferenceHelper.WAITING_START_TIME, DateTime.now().toString());
      }

      PreferenceHelper.setDouble(
          PreferenceHelper.LAST_LAT, position?.latitude ?? 0);
      PreferenceHelper.setDouble(
          PreferenceHelper.LAST_LONG, position?.longitude ?? 0);
      PreferenceHelper.setString(
          PreferenceHelper.LAST_ADD_ROUTE_DATETIME, DateTime.now().toString());
    }
  } catch (e) {
    print("inCatch ${createRouteHistoryModel?.message}");
    print("inCatchE ${e}");
  }
}

callCreateWaitingActivityApi({String? userId,bool? isWaitingEnd,Position? position}) async {
  try {
    Map<String, dynamic> body = {};
    double? lastLat = PreferenceHelper.getDouble(PreferenceHelper.LAST_LAT);
    double? lastLong = PreferenceHelper.getDouble(PreferenceHelper.LAST_LONG);
    body = {
      "userId": userId,
      "lattitude": isWaitingEnd ?? false ? position?.latitude : lastLat,
      "longitude":isWaitingEnd ?? false ? position?.longitude : lastLong,
      "totTrackingEventId": isWaitingEnd ?? false ? AppConstant.trackingWaitingStopEvent : AppConstant.trackingWaitingStartEvent,
      "eventDate": AppUtils.dateFormat(
          date: DateTime.now(), dateFormat: AppConstant.dateFormat),
      "eventTime": AppUtils.dateFormat(
          date: DateTime.now(), dateFormat: AppConstant.dateFormat),
      "batteryLevel": 50,
      "trackingAddress": "Business Hub",
      "activityStatus": null
    };

    String endPoint = ApiConstants.createActivity;
    var response = await callPostMethod(endPoint, body);
    createActivityModel = CreateActivityModel?.fromJson(json.decode(response));
    if (createActivityModel?.isError == false && createActivityModel?.isValidationFailed == false) {
      PreferenceHelper.setBool(PreferenceHelper.CHECK_END_TIME, false);
      isWaitingEnd  ?? false ? PreferenceHelper.setBool(PreferenceHelper.ISWAITING, false ):PreferenceHelper.setBool(PreferenceHelper.ISWAITING, true);
    }
    print("response at main : $response");
  } catch (e) {
    print('catch at getAllOrders $e');
  }
}

callCreateRouteHistory({String? userId}) async {


  Position position;
  double distance = 51;
  try {
    print("start testing");
    position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
    double? lastLat = PreferenceHelper.getDouble(PreferenceHelper.LAST_LAT);
    double? lastLong = PreferenceHelper.getDouble(PreferenceHelper.LAST_LONG);

    distance = Geolocator.distanceBetween(lastLat ?? 0, lastLong ?? 0,
        position.latitude, position.longitude); // distance in meter
    print("distance-- ${distance}");
  } catch (e) {
    position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best);
    print("catch at get latLong pref $e");
  }
  if ((distance) > 50) {
    bool isWaiting = PreferenceHelper.getBool(PreferenceHelper.ISWAITING);
    if(isWaiting == true){
      callCreateWaitingActivityApi(userId: userId,isWaitingEnd: true,position: position);
    }
    callCreteRouteHistoryApi(userId: userId, position: position);
  } else {
    PreferenceHelper.load().then((value) {
      bool? isCheckIn = value?.getBool(PreferenceHelper.checkIn);
      print("isCheckIn : $isCheckIn");
      if (isCheckIn == true) {

      }
      else{
        bool isWaiting = PreferenceHelper.getBool(PreferenceHelper.ISWAITING);
        if (kDebugMode) {
          // print("checkEndTime??? $checkEndTime");
          print("isWaiting??? $isWaiting");
        }
        if (isWaiting == false) {
          String? waitingStartTime = PreferenceHelper.getString(
              PreferenceHelper.WAITING_START_TIME);
          print("waiting_seconds_${DateTime
              .now()
              .difference(DateTime.parse(waitingStartTime ?? ' '))
              .inSeconds}");
          print("waiting_seconds_condition ${DateTime
              .now()
              .difference(DateTime.parse(waitingStartTime ?? ' '))
              .inSeconds > 30}");
          if (DateTime
              .now()
              .difference(DateTime.parse(waitingStartTime ?? ' '))
              .inSeconds > 30) {
            print("after 30 seconds");
            callCreateWaitingActivityApi(
                userId: userId, position: position, isWaitingEnd: false);
          }
        }
        else {
          bool checkEndTime = PreferenceHelper.getBool(
              PreferenceHelper.CHECK_END_TIME);
          if (checkEndTime == true) {
            PreferenceHelper.setString(PreferenceHelper.LAST_ADD_ROUTE_DATETIME,
                DateTime.now().toString());
          }
          PreferenceHelper.setString(
              PreferenceHelper.WAITING_START_TIME, DateTime.now().toString());
        }
      }
    });

  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // This widget is the root of your application.

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // getDeviceInfo();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'Project Base',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppConstant.btnColor),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
    );
  }
}
