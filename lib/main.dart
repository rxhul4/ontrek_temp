import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:battery_plus/battery_plus.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
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
import 'package:ontrek/features/leads/provider/lead_provider.dart';
import 'package:ontrek/features/salesman_tracker/provider/salesmen_tracking_timeline_provider.dart';
import 'package:ontrek/features/task_list/provider/task_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
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
  ChangeNotifierProvider<SalemenTimeLineProvider>(
    create: (_) => SalemenTimeLineProvider(),
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
  ChangeNotifierProvider<LeadProvider>(
    create: (_) => LeadProvider(),
  ),
];

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  PreferenceHelper.load().then((value) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
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
          PreferenceHelper.load().then((value) async {
            bool? checkIn = PreferenceHelper.getBool(PreferenceHelper.checkIn);
            String? userId = value?.getString(PreferenceHelper.USER_UID);
            print("userId$userId");
            print("checkIn$checkIn");
            bool? gpsBool = PreferenceHelper.getBool(PreferenceHelper.GPS_BOOL);
            bool? internetBool =
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
              print("is_Gps_bool $gpsBool");
              await callInternetAndGpsActivityApi(
                userId: userId,
                isGps: true,
                isGpsOn: false,
                isInternet: false,
                isInternetOn: false,
              );
              Future.delayed(Duration(milliseconds: 500));
              await callInternetAndGpsActivityApi(
                userId: userId,
                isGps: true,
                isGpsOn: true,
                isInternet: false,
                isInternetOn: false,
              );
            }
            Future.delayed(const Duration(milliseconds: 500));
            if (internetBool) {
              print("is_internet_bool $internetBool");
              await callInternetAndGpsActivityApi(
                userId: userId,
                isGps: false,
                isGpsOn: false,
                isInternet: true,
                isInternetOn: false,
              );
              Future.delayed(const Duration(milliseconds: 500));
              await callInternetAndGpsActivityApi(
                userId: userId,
                isGps: false,
                isGpsOn: false,
                isInternet: true,
                isInternetOn: true,
              );
            }
            await callCreateRouteHistory(userId: userId);
          });
        } else if (isGPSEnabled && !isInternetAvailable) {
          print("internet is not available ");
          bool internetBool =
              PreferenceHelper.getBool(PreferenceHelper.INTERNET_BOOL);
          if (internetBool == false) {
            Position positionData = await Geolocator.getCurrentPosition(
                desiredAccuracy: LocationAccuracy.medium);
            PreferenceHelper.setString(
                PreferenceHelper.LAST_INTERNET_OFF_TIME,
                AppUtils.dateFormat(
                    date: DateTime.now(), dateFormat: AppConstant.dateFormat));

            PreferenceHelper.setDouble(
                PreferenceHelper.LAST_INTERNET_OFF_LAT, positionData.latitude);
            PreferenceHelper.setDouble(PreferenceHelper.LAST_INTERNET_OFF_LONG,
                positionData.longitude);
            PreferenceHelper.setBool(PreferenceHelper.INTERNET_BOOL, true);
          }

          String? lastGpsTime =
              PreferenceHelper.getString(PreferenceHelper.LAST_GPS_OFF_TIME);
          if (lastGpsTime != "" && lastGpsTime != null) {
            PreferenceHelper.setString(
                PreferenceHelper.LAST_GPS_ON_TIME,
                AppUtils.dateFormat(
                    date: DateTime.now(), dateFormat: AppConstant.dateFormat));
          }
        } else if (!isGPSEnabled && isInternetAvailable) {
          // internetOnTime = DateTime.now();
          print("gps is not available");
          print("call gps off data api");
          bool gpsBool = PreferenceHelper.getBool(PreferenceHelper.GPS_BOOL);
          if (gpsBool == false) {
            Position? positionData = await Geolocator.getLastKnownPosition();
            print("latLong$positionData");
            PreferenceHelper.setString(
                PreferenceHelper.LAST_GPS_OFF_TIME,
                AppUtils.dateFormat(
                    date: DateTime.now(), dateFormat: AppConstant.dateFormat));
            PreferenceHelper.setDouble(
                PreferenceHelper.LAST_GPS_OFF_LAT, positionData?.latitude ?? 0);
            PreferenceHelper.setDouble(PreferenceHelper.LAST_GPS_OFF_LONG,
                positionData?.longitude ?? 0);
            PreferenceHelper.setBool(PreferenceHelper.GPS_BOOL, true);
          }
        } else if (!isGPSEnabled && !isInternetAvailable) {
          bool gpsBool = PreferenceHelper.getBool(PreferenceHelper.GPS_BOOL);
          if (gpsBool == false) {
            PreferenceHelper.setString(
                PreferenceHelper.LAST_GPS_OFF_TIME,
                AppUtils.dateFormat(
                    date: DateTime.now(), dateFormat: AppConstant.dateFormat));
            double? lastLat =
                PreferenceHelper.getDouble(PreferenceHelper.LAST_LAT);
            double? lastLong =
                PreferenceHelper.getDouble(PreferenceHelper.LAST_LONG);
            PreferenceHelper.setDouble(
                PreferenceHelper.LAST_GPS_OFF_LAT, lastLat ?? 0);
            PreferenceHelper.setDouble(
                PreferenceHelper.LAST_GPS_OFF_LONG, lastLong ?? 0);
            PreferenceHelper.setBool(PreferenceHelper.GPS_BOOL, true);
          }

          bool internetBool =
              PreferenceHelper.getBool(PreferenceHelper.INTERNET_BOOL);
          if (internetBool == false) {
            PreferenceHelper.setString(
                PreferenceHelper.LAST_INTERNET_OFF_TIME,
                AppUtils.dateFormat(
                    date: DateTime.now(), dateFormat: AppConstant.dateFormat));
            double? lastLat =
                PreferenceHelper.getDouble(PreferenceHelper.LAST_LAT);
            double? lastLong =
                PreferenceHelper.getDouble(PreferenceHelper.LAST_LONG);
            PreferenceHelper.setDouble(
                PreferenceHelper.LAST_GPS_OFF_LAT, lastLat ?? 0);
            PreferenceHelper.setDouble(
                PreferenceHelper.LAST_GPS_OFF_LONG, lastLong ?? 0);
            PreferenceHelper.setBool(PreferenceHelper.INTERNET_BOOL, true);
          }

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
final Battery battery = Battery();


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
      PreferenceHelper.reload().then((value) {
        bool? isWaiting = PreferenceHelper.getBool(PreferenceHelper.ISWAITING);
        if (isWaiting == true) {
        } else {
          PreferenceHelper.setString(
              PreferenceHelper.WAITING_START_TIME, DateTime.now().toString());
        }

        PreferenceHelper.setDouble(
            PreferenceHelper.LAST_LAT, position?.latitude ?? 0);
        PreferenceHelper.setDouble(
            PreferenceHelper.LAST_LONG, position?.longitude ?? 0);
      });
    }
  } catch (e) {
    print("inCatch ${createRouteHistoryModel?.message}");
    print("inCatchE ${e}");
  }
}

callCreateWaitingActivityApi(
    {String? userId, bool? isWaitingStart, Position? position}) async {
  try {
    Map<String, dynamic> body = {};

    double? lastLat = PreferenceHelper.getDouble(PreferenceHelper.LAST_LAT);
    double? lastLong = PreferenceHelper.getDouble(PreferenceHelper.LAST_LONG);
    String? waitingStartTime =
        PreferenceHelper.getString(PreferenceHelper.WAITING_START_TIME);

    body = {
      "userId": userId,
      "lattitude": isWaitingStart ?? false ? lastLat : position?.latitude,
      "longitude": isWaitingStart ?? false ? lastLong : position?.longitude,
      "totTrackingEventId": isWaitingStart ?? false
          ? AppConstant.trackingWaitingStartEvent
          : AppConstant.trackingWaitingStopEvent,
      "activityDateTime": isWaitingStart ?? false
          ? AppUtils.getDate(
              date: waitingStartTime ?? "", format: AppConstant.dateFormat)
          : AppUtils.getDate(
              date: DateTime.now().toString(), format: AppConstant.dateFormat),
      "batteryLevel": 50,
    };

    String endPoint = ApiConstants.createActivity;
    var response = await callPostMethod(endPoint, body);
    createActivityModel = CreateActivityModel?.fromJson(json.decode(response));
    if (createActivityModel?.isError == false &&
        createActivityModel?.isValidationFailed == false) {
      isWaitingStart ?? false
          ? PreferenceHelper.setBool(PreferenceHelper.ISWAITING, true)
          : PreferenceHelper.setBool(PreferenceHelper.ISWAITING, false);

      bool isWaiting = PreferenceHelper.getBool(PreferenceHelper.ISWAITING);
      print("getData$isWaiting");
    }
    print("response at main : $response");
  } catch (e) {
    print('catch at getAllOrders $e');
  }
}

callInternetAndGpsActivityApi(
    {bool? isInternet,
    bool? isGps,
    String? userId,
    bool? isInternetOn,
    bool? isGpsOn}) async {
  String? lastInternetOffTime =
      PreferenceHelper.getString(PreferenceHelper.LAST_INTERNET_OFF_TIME);
  String? lastGpsOffTime =
      PreferenceHelper.getString(PreferenceHelper.LAST_GPS_OFF_TIME);

  double? lastLat = PreferenceHelper.getDouble(PreferenceHelper.LAST_LAT);
  double? lastLong = PreferenceHelper.getDouble(PreferenceHelper.LAST_LONG);

  Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.best);
  print("innnnnnnnnnnnnnn");
  Map<String, dynamic> body = {};

  if (isInternet == true) {
    print("innnnnnnnnnnnnnn2");
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
      "batteryLevel": 50,
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
      "batteryLevel": 50,
    };
  }

  try {
    String endPoint = ApiConstants.createActivity;
    var response = await callPostMethod(endPoint, body);
    createActivityModel = CreateActivityModel?.fromJson(json.decode(response));
    if (createActivityModel?.isError == false &&
        createActivityModel?.isValidationFailed == false) {
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
    print("catch at dataOffHistory$e");
  }
}

callCreateRouteHistory({String? userId}) async {
  Position position;
  double distance = 51;
  bool? isWaiting = PreferenceHelper.getBool(PreferenceHelper.ISWAITING);
  PreferenceHelper.reload().then((value) async{
    bool? checkIn = value?.getBool(PreferenceHelper.checkIn);


    try {
      print("start testing");
      position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.best);

      double? lastLat = PreferenceHelper.getDouble(PreferenceHelper.LAST_LAT);
      double? lastLong = PreferenceHelper.getDouble(PreferenceHelper.LAST_LONG);
      distance = Geolocator.distanceBetween(lastLat ?? 0, lastLong ?? 0,
          position.latitude, position.longitude); // distance in meter
      print("distance-- $distance");

      if ((distance) > 50) {
        if(checkIn == false){
          print("checkin________$checkIn");
          if (isWaiting) {
            callCreateWaitingActivityApi(
                userId: userId, position: position, isWaitingStart: false);
          }
          callCreteRouteHistoryApi(userId: userId, position: position);
        }

      } else {
        PreferenceHelper.reload().then((pref) {
          bool? checkIn = pref?.getBool(PreferenceHelper.checkIn);
          bool? isWaiting = pref?.getBool(PreferenceHelper.ISWAITING);
          print("checkin________$checkIn");
          print("waiting---$isWaiting");
          if (checkIn ?? false) {
            print("checkin________$checkIn");
            print("waiting------$isWaiting");

          } else {
            String? waitingStartTime = pref?.getString(PreferenceHelper.WAITING_START_TIME);
            print("waitingStartTime_________$waitingStartTime");
            if (waitingStartTime != null) {
              print("waiting_________$isWaiting");
              if (isWaiting == false) {
                print("isWaiting__________$isWaiting");
                if (DateTime.now()
                    .difference(DateTime.parse(waitingStartTime ?? ''))
                    .inSeconds >
                    30) {
                  print(
                      "data${DateTime.now().difference(DateTime.parse(waitingStartTime ?? '')).inSeconds}");
                  callCreateWaitingActivityApi(
                      userId: userId,
                      position: position,
                      isWaitingStart: true);
                } else {
                  print("not===30 second");
                }
              }
            } else {
              PreferenceHelper.setString(PreferenceHelper.WAITING_START_TIME,
                  DateTime.now().toString());
            }
          }
        });
      }
    } catch (e) {
      position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.best);
      print("catch at get latLong pref $e");
    }
  });


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
