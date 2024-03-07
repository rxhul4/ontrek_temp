import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:battery_plus/battery_plus.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:ontrek/core/services/api_constants.dart';
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
    const Duration(seconds: 15),
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
            int? userUid = value?.getInt(PreferenceHelper.USER_UID);
            print("employeeId${userUid}");

            bool GpsBool = PreferenceHelper.getBool(PreferenceHelper.GPS_BOOL);
            bool InternetBool =
                PreferenceHelper.getBool(PreferenceHelper.INTERNET_BOOL);

            if (GpsBool) {
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
              callAddActivityApi();
            }
            if (InternetBool) {
              print("uuuuuuuuuuuuuuuuuuuuuu ");
              // callAddDataOffHistoryApi("Internet");
            }

            // callAddCoordinatesApi(employeeId: employeeId);
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

          bool gpsBool = PreferenceHelper.getBool(PreferenceHelper.GPS_BOOL);
          // bool internetBool =
          //     PreferenceHelper.getBool(PreferenceHelper.INTERNET_BOOL);
          if (gpsBool == false) {
            Position? positionData = await Geolocator.getLastKnownPosition();
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
          // if(gpsBool ){
          //   callAddDataOffHistoryApi("GPS");
          // }
          // if (internetBool) {
          //   callAddDataOffHistoryApi("Internet");
          // }
        } else if (!isGPSEnabled && !isInternetAvailable) {
          bool gpsBool = PreferenceHelper.getBool(PreferenceHelper.GPS_BOOL);
          if (gpsBool == false) {
            PreferenceHelper.setString(
                PreferenceHelper.LAST_GPS_OFF_TIME,
                AppUtils.dateFormat(
                    date: DateTime.now(), dateFormat: AppConstant.dateFormat));
            // Position? positionData = await Geolocator.getLastKnownPosition();
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
            // Position positionData = await Geolocator.getCurrentPosition(
            //     desiredAccuracy: LocationAccuracy.best);

            double? lastLat =
                PreferenceHelper.getDouble(PreferenceHelper.LAST_LAT);
            double? lastLong =
                PreferenceHelper.getDouble(PreferenceHelper.LAST_LONG);

            PreferenceHelper.setDouble(
                PreferenceHelper.LAST_INTERNET_OFF_LAT, lastLat ?? 0);
            PreferenceHelper.setDouble(
                PreferenceHelper.LAST_INTERNET_OFF_LONG, lastLong ?? 0);

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
callAddActivityApi({String? totTrackingEventCode}) async {
  try {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    AndroidDeviceInfo? androidInfo;
    var battery = Battery();
    int? batteryLevel;
    var userUid = PreferenceHelper.getString(PreferenceHelper.USER_UID);
    String? lastInternetOffTime =
        PreferenceHelper.getString(PreferenceHelper.LAST_INTERNET_OFF_TIME);
    String? lastGpsOffTime =
        PreferenceHelper.getString(PreferenceHelper.LAST_GPS_OFF_TIME);
    String? lastGpsOnTime =
        PreferenceHelper.getString(PreferenceHelper.LAST_GPS_ON_TIME);
    double? lastLat = PreferenceHelper.getDouble(PreferenceHelper.LAST_LAT);
    double? lastLong = PreferenceHelper.getDouble(PreferenceHelper.LAST_LONG);
    double? lastInternetOffLat =
        PreferenceHelper.getDouble(PreferenceHelper.LAST_INTERNET_OFF_LAT);
    double? lastInternetOffLong =
        PreferenceHelper.getDouble(PreferenceHelper.LAST_INTERNET_OFF_LONG);
    var dateOfDayStart = AppUtils.dateFormat(date: DateTime.now(), dateFormat: "yyyy-MM-dd");
    var timeOfDayStart = AppUtils.dateFormat(date: DateTime.now(), dateFormat: AppConstant.dateFormat);
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium);
    deviceInfo.androidInfo.then((value) {
      androidInfo = value;
    });
    battery.batteryLevel.then((value) {
      batteryLevel = value;
      print("battery_level${batteryLevel}");
    });




    var request =
    http.MultipartRequest('POST', Uri.parse(ApiConstants.createActivity));


    if(totTrackingEventCode == AppConstant.gpsOffEvent && lastGpsOnTime == null || lastGpsOnTime == ""){
      print(" in if ${totTrackingEventCode}");
      if(userUid != null){
        request.fields['user_uid'] = userUid;
      }
      request.fields['lattitude'] = position.latitude.toString();
      request.fields['longitude'] = position.longitude.toString();
      request.fields['tot_tracking_event_code'] = totTrackingEventCode.toString();
      request.fields['event_date'] = dateOfDayStart.toString();
      request.fields['event_time'] = timeOfDayStart.toString();
      request.fields['battery_level'] = batteryLevel.toString();
      request.fields['device_id'] = androidInfo?.id.toString() ?? "";
      request.fields['device_name'] = androidInfo?.brand.toString() ?? "";
      request.fields['loc_accuracy'] = "1";
      request.fields['tracking_address'] = "Dwarkesh Business hub";
    }else{
      if(userUid != null){
        request.fields['user_uid'] = userUid;
      }
      request.fields['lattitude'] = position.latitude.toString();
      request.fields['longitude'] = position.longitude.toString();
      request.fields['tot_tracking_event_code'] = totTrackingEventCode.toString();
      request.fields['event_date'] = dateOfDayStart.toString();
      request.fields['event_time'] = timeOfDayStart.toString();
      request.fields['battery_level'] = batteryLevel.toString();
      request.fields['device_id'] = androidInfo?.id.toString() ?? "";
      request.fields['device_name'] = androidInfo?.brand.toString() ?? "";
      request.fields['loc_accuracy'] = "1";
      request.fields['tracking_address'] = "Dwarkesh Business hub";

    }

    print("request is ${request.fields}");
    print("request is ${request.url}");
    var response = await request.send();
    print('---------response$response');
    var responsed = await http.Response.fromStream(response);
    print("SUCCESS  ${responsed.body}");
    print("SUCCESS  ${json.decode(responsed.body)}");
    createActivityModel =
        CreateActivityModel.fromJson(json.decode(responsed.body));
    print(createActivityModel?.data);
    if(createActivityModel?.isError == false && createActivityModel?.isValidationFailed == false){
      if (totTrackingEventCode == AppConstant.internetOffEvent) {
        PreferenceHelper.remove(PreferenceHelper.LAST_INTERNET_OFF_TIME);
        PreferenceHelper.setBool(PreferenceHelper.INTERNET_BOOL, false);
      } else {
        PreferenceHelper.remove(PreferenceHelper.LAST_GPS_OFF_TIME);
        PreferenceHelper.remove(PreferenceHelper.LAST_GPS_ON_TIME);
        PreferenceHelper.setBool(PreferenceHelper.GPS_BOOL, false);
      }
    }
    print("reponse at main : $response");
  } catch (e) {
    print("catch At Background Data Of Service${e}");
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
