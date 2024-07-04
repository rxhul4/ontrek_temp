// import 'dart:async';
// import 'dart:convert';
// import 'package:flutter/material.dart';
// // import 'package:flutter_activity_recognition/flutter_activity_recognition.dart' as userActivity;
// import 'package:flutter_background_service/flutter_background_service.dart';
// import 'package:flutter_jailbreak_detection/flutter_jailbreak_detection.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:intl/intl.dart';
// import 'package:ontrek/core/background_service_model/activity_model.dart';
// import 'package:ontrek/core/background_service_model/bulk_activity_request_moodel.dart';
// import 'package:ontrek/core/background_service_model/bulk_activity_response_model.dart';
// import 'package:ontrek/core/background_service_model/create_route_history_model.dart';
// import 'package:ontrek/core/background_service_model/offline_route_model.dart';
// import 'package:ontrek/core/services/Throttler.dart';
// import 'package:ontrek/core/services/api_constants.dart';
// import 'package:ontrek/core/services/intenetAndGpsEventLisnters.dart';
// import 'package:ontrek/core/services/local_notification.dart';
// import 'package:ontrek/core/services/network_repository.dart';
// import 'package:ontrek/core/storage/db_service.dart';
// import 'package:ontrek/core/storage/preference_helper.dart';
// import 'package:ontrek/core/utils/App_utils.dart';
// import 'package:ontrek/core/utils/app_constant.dart';
// import 'package:ontrek/features/attendance/model/get_last_activity_model.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:flutter_background_service_android/flutter_background_service_android.dart';
//
// const notificationChannelId = 'my_foreground';
// const notificationId = 888;
// const notificationIdDevMode = 777;
//
// LastActivityData? lastActivityData;
// List<Activity>? listOfAllActivity;
//
// String physicalActivity = "";
//
// double? prevLatitude = null;
// double? prevLongitude = null;
// double? currentLatitude = null;
// double? currentLongitude = null;
// double? liveTrackingLat = null;
// double? liveTrackingLong = null;
//
// bool isInternetAvailable = false;
// bool isGpsAvailable = false;
//
//
// bool isCheckIn = false;
// bool isInRadius = false;
//
// String? waitingStartTime = "";
// double? lastWaitingLat;
// double? lastWaitingLong;
// StreamSubscription<Activity>? activityStreamSubscription;
//
// int? waitingTime = 10;
//
// final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
// FlutterLocalNotificationsPlugin();
//
// class BackgroundService {
//   Future<void> initializeService() async {
//     final service = FlutterBackgroundService();
//
//     const AndroidNotificationChannel channel = AndroidNotificationChannel(
//       notificationChannelId, // id
//       'Background Service', // title
//       description: 'Activated', // description
//       importance: Importance.low,
//     );
//
//     final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
//
//     await flutterLocalNotificationsPlugin
//         .resolvePlatformSpecificImplementation<
//         AndroidFlutterLocalNotificationsPlugin>()
//         ?.createNotificationChannel(channel);
//
//     await service.configure(
//       iosConfiguration: IosConfiguration(),
//       androidConfiguration: AndroidConfiguration(
//         onStart: onStart,
//         autoStart: false,
//         isForegroundMode: true,
//         notificationChannelId: notificationChannelId,
//         initialNotificationTitle: 'Background Location',
//         initialNotificationContent: 'Initializing',
//         foregroundServiceNotificationId: notificationId,
//       ),
//     );
//   }
//
// }
//
//
//
//
//
// @pragma('vm:entry-point')
// void onStart(ServiceInstance service) async {
//
//   WidgetsFlutterBinding.ensureInitialized();
//
//   // final _activityStreamController = StreamController<userActivity.Activity>();
//   StreamSubscription<Activity>? _activityStreamSubscription;
//
//   registerEventsToListener(service);
//
//   var connectivityListener =  await InternetAndGpsListener(
//
//     onLocationServiceChange: (status) async{
//       print("onLocationServiceChange$status");
//       isGpsAvailable = status;
//       await ManageGpsOperations();
//       if(isInternetAvailable == true) {
//         // await syncSqlData();
//       }
//     },
//     // onActivityChange:(userActivity.Activity activity) {
//     //     print('Activity Detected >> ${activity.toJson()}');
//     //     physicalActivity  =  activity.type.toString();
//     //     print('Activity Detected >> ${physicalActivity}');
//     //
//     //     _activityStreamController.sink.add(activity);
//     // },
//     onInternetStatusChange: (status)async{
//       print("onConnectivityChanged$status");
//       isInternetAvailable = status;
//       if(isInternetAvailable == true){
//         await ManageInternetOperations();
//         // await syncRouteHistory();
//         //await syncSqlData();
//       }else{
//         String internetOffTime = AppUtils.getDate(date: DateTime.now().toString(), format: AppConstant.dateFormat);
//         if(isGpsAvailable == true){
//           if(currentLatitude == null || currentLatitude == 0.0 || currentLatitude == null || currentLongitude == 0.0){
//             if(prevLatitude == null ||  prevLatitude == 0.0 ||  prevLongitude == null || prevLongitude == 0.0){
//               Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
//               currentLatitude = position.latitude;
//               currentLongitude = position.longitude;
//               prevLatitude = position.latitude;
//               prevLongitude = position.longitude;
//             }
//           }
//         }
//         PreferenceHelper.setDouble(PreferenceHelper.LAST_INTERNET_OFF_LAT, currentLatitude ?? (prevLatitude ?? 0.0));
//         PreferenceHelper.setDouble(PreferenceHelper.LAST_INTERNET_OFF_LONG, currentLongitude ?? (prevLongitude ?? 0.0));
//         PreferenceHelper.setString(PreferenceHelper.LAST_INTERNET_OFF_TIME, internetOffTime);
//
//       }
//     },
//
//   );
//
//   await connectivityListener.startListening();
//
//   PreferenceHelper.load().then((value) {
//     int? liveLocationInterval = value?.getInt(PreferenceHelper.LIVE_LOCATION_INTERVAL) ?? 30;
//     waitingTime = value?.getInt(PreferenceHelper.WAITING_TIME_INTERVAL);
//     print("waitingTime$waitingTime");
//     bool? isWaitingAllowed = value?.getBool(PreferenceHelper.ALLOW_WAITING);
//
//     // Instantiate the throttler with the desired interval
//     Throttler throttlerOfflineDataAdd = Throttler(seconds: 20);
//     Throttler throttlerSyncData = Throttler(seconds: liveLocationInterval);
//
//     Timer.periodic(Duration(seconds: 20),(timer) async {
//         try
//         {
//
//           throttlerOfflineDataAdd.run(() async {
//
//             await PreferenceHelper.reload();
//             waitingStartTime = PreferenceHelper.getString(PreferenceHelper.WAITING_START_TIME);
//             lastWaitingLat = PreferenceHelper.getDouble(PreferenceHelper.LAST_LAT);
//             lastWaitingLong = PreferenceHelper.getDouble(PreferenceHelper.LAST_LONG);
//
//             await setLastActivityData();
//
//             if (lastActivityData != null) {
//
//               isInRadius = await isWithinRadius(
//                   prevLat: prevLatitude,
//                   prevLong: prevLongitude,
//                   currentLat: currentLatitude,
//                   currentLong: currentLongitude,
//                   radiusMtr: AppConstant.waitingEndRadius);
//
//
//
//               if(physicalActivity != "ActivityType.STILL" || physicalActivity == ""){
//               await ManageRouteHistory();
//               }
//
//               if (!isCheckIn && isWaitingAllowed == true) {
//                 await ManageWaitingOperation();
//               }
//             }
//           });
//
//           throttlerSyncData.run(()async {
//                  bool isLocationAlwaysOn = false;
//                  bool isBatteryOptimizationDisabled = false;
//                  NotificationService notificationService = NotificationService();
//                   bool developerMode = await FlutterJailbreakDetection.developerMode;
//                   var locationAlwaysStatus = await Permission.locationAlways.status;
//                   var ignoreBatteryOptimizationsStatus = await Permission.ignoreBatteryOptimizations.status;
//                   if(locationAlwaysStatus.isGranted){
//                     isLocationAlwaysOn = true;
//                   }
//                  if(ignoreBatteryOptimizationsStatus.isGranted){
//                    isBatteryOptimizationDisabled = true;
//                  }
//                  if(developerMode)
//                   {
//                     notificationService.showNotification(
//                       id: 2,
//                       title: "On Trek Developer Mode On Alert !",
//                       body: "Kindly turn off Developer Options.",
//                       payload: "",
//                     );
//                   }
//                   if(!isGpsAvailable)
//                   {
//                     notificationService.showNotification(
//                       id: 3,
//                       title: "On Trek GPS Off Alert !",
//                       body: "Kindly turn on GPS.",
//                       payload: "",
//                     );
//                   }
//
//                   if(isInternetAvailable){
//                     await syncRouteHistory();
//                     await syncSqlData();
//                     sendLastStatus(developerMode,isLocationAlwaysOn,isBatteryOptimizationDisabled);
//                   }
//
//                  // Stop service between 11:50 to 12:00 Midnight
//                  await stopServiceAtNight(service, timer);
//                  // Set notification icon
//                  await setBgNotificationIcon(service);
//                 },);
//         }
//         catch (e)
//         {
//           print(e);
//         }
//      },
//     );
//   });
// }
//
//
// sendLastStatus(bool developerMode, /*bool isFakeLocation*/bool isLocationAlwaysOn,bool? isBatteryOptimizationDisabled ){
//   Map<String,dynamic> body =
//     {
//       "userId": lastActivityData?.fieldUserId,
//       "isGpsOn": isGpsAvailable,
//       "isDevModeOn": developerMode,
//       "isFakeLocation": false,
//       "isLocationAlwaysOn": isLocationAlwaysOn,
//       "isBatteryOptimizationDisabled" : isBatteryOptimizationDisabled
//     };
//
//   if (body != null) {
//     String endPoint = ApiConstants.sendLastStatus;
//     try {
//       callPostMethodForDevmode(endPoint, body);
//     } catch (e) {
//       print("Error during sendLastStatus: $e");
//     }
//   }
// }
//
// dayEndProccess(ServiceInstance service)async{
//   final DatabaseService databaseService = DatabaseService();
//   PreferenceHelper.remove(PreferenceHelper.WAITING_START_TIME);
//   PreferenceHelper.remove(PreferenceHelper.LAST_LAT);
//   PreferenceHelper.remove(PreferenceHelper.LAST_LONG);
//   PreferenceHelper.remove(PreferenceHelper.LAST_INTERNET_OFF_TIME);
//   PreferenceHelper.remove(PreferenceHelper.LAST_INTERNET_OFF_LAT);
//   PreferenceHelper.remove(PreferenceHelper.LAST_INTERNET_OFF_LONG);
//   await databaseService.deleteAllRoutes();
//   await databaseService.deleteAllActivities();
//   service.stopSelf();
// }
//
// ManageRouteHistory() async {
//
//   if (isGpsAvailable && !isInRadius) {
//     final DatabaseService databaseService = DatabaseService();
//
//     OfflineRouteModel dataPoint = OfflineRouteModel(
//       latitude: liveTrackingLat ?? (prevLatitude ?? 0.0),
//       longitude:  liveTrackingLong ?? (prevLongitude ?? 0.0),
//       offlineTime: AppUtils.getDate(date: DateTime.now().toString(), format: AppConstant.dateFormat));
//
//     if (dataPoint.latitude != 0.0 && dataPoint.longitude != 0.0) {
//       await databaseService.insertRoute(dataPoint);
//     }
//   }
// }
//
// ManageGpsOperations() async{
//
//   DatabaseService dbService = DatabaseService();
//
//   var activity = Activity(
//       pkId: 0,
//       sessionId: lastActivityData?.sessionId ?? "",
//       latitude: currentLatitude ?? (prevLatitude ?? 0),
//       longitude: currentLongitude ?? (prevLongitude ?? 0),
//       activityDate: AppUtils.getDateTimeNow(),
//       isSync: false,
//       isEventCompleted: false);
//
//   if (isGpsAvailable == true) {
//     activity.eventCode = AppConstant.gpsOnEvent;
//     activity.isSync = false;
//     await  dbService.insertGpsActivity(activity);
//   }
//
//   if (isGpsAvailable == false) {
//     activity.eventCode = AppConstant.gpsOffEvent;
//     activity.isSync = false;
//     await dbService.insertGpsActivity(activity);
//   }
// }
//
// ManageInternetOperations() async {
//
//   double? internetOffLat = PreferenceHelper.getDouble(PreferenceHelper.LAST_INTERNET_OFF_LAT);
//   double? internetOffLong =  PreferenceHelper.getDouble(PreferenceHelper.LAST_INTERNET_OFF_LONG);
//   String? internetOffTIme = PreferenceHelper.getString(PreferenceHelper.LAST_INTERNET_OFF_TIME);
//
//   if(internetOffTIme == null){
//     return;
//   }
//
//   if(internetOffLat == null || internetOffLat == 0 && internetOffLat == 0.0 || internetOffLong == null || internetOffLong ==0.0 && internetOffLong == 0){
//     Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
//     internetOffLat = position.latitude;
//     internetOffLong = position.longitude;
//   }
//
//   DatabaseService dbService = DatabaseService();
//
//   var internetOffActivity = Activity(
//       pkId: 0,
//       sessionId: lastActivityData?.sessionId ?? "",
//       eventCode: AppConstant.internetOffEvent,
//       latitude: internetOffLat ?? (currentLatitude ?? (prevLatitude ?? 0.0)),
//       longitude: internetOffLong ?? (currentLongitude ?? (prevLongitude ?? 0.0)),
//       activityDate: internetOffTIme,
//       isSync: false,
//       isEventCompleted: true);
//
//   var internetOnActivity = Activity(
//       pkId: 0,
//       sessionId: lastActivityData?.sessionId ?? "",
//       eventCode: AppConstant.internetOnEvent,
//       latitude: currentLatitude ?? (prevLatitude ?? 0),
//       longitude: currentLongitude ?? (prevLongitude ?? 0),
//       activityDate: AppUtils.getDateTimeNow(),
//       isSync: false,
//       isEventCompleted: true);
//
//       bool isDifferenceLessTwoMinutes = await  isDifferenceLessFiveMinutes(internetOffActivity.activityDate ?? "", internetOnActivity.activityDate ?? "");
//       if(!isDifferenceLessTwoMinutes){
//
//         var internetOffPkId = await dbService.getMaxPkId();
//         internetOffActivity.pkId = internetOffPkId + 1;
//
//         await dbService.insertInternetActivity(internetOffActivity);
//
//         var internetOnPkId = await dbService.getMaxPkId();
//         internetOnActivity.pkId = internetOnPkId + 1;
//         internetOnActivity.parentId = internetOffActivity.pkId;
//
//         await dbService.insertInternetActivity(internetOnActivity);
//       }
// }
//
// ManageWaitingOperation() async {
//
//   DatabaseService dbService = DatabaseService();
//
//   var activity = Activity(
//       pkId: 0,
//       sessionId: lastActivityData?.sessionId ?? "",
//       latitude: currentLatitude ?? (prevLatitude ?? 0),
//       longitude: currentLongitude ?? (prevLongitude ?? 0),
//       isSync: false,
//       isEventCompleted: false);
//
//        if (isGpsAvailable == true) {
//             //Waiting Start Event
//             if (isInRadius && waitingStartTime != null)
//             {
//                 print("isInRadius$isInRadius");
//                 print("waitingStartTime$waitingStartTime");
//                 if (DateTime.now() .difference(DateTime.parse(waitingStartTime ?? "")).inMinutes >= (waitingTime ?? 10))
//                 {
//                     //add waiting start  event
//                     activity.eventCode = AppConstant.trackingWaitingStartEvent;
//                     activity.latitude = lastWaitingLat ?? 0;
//                     activity.longitude = lastWaitingLong ?? 0;
//                     activity.activityDate = AppUtils.getDate(date: waitingStartTime.toString(),format: AppConstant.dateFormat);
//                     await dbService.insertWaitingActivity(activity);
//                 }
//             }
//             else
//             {
//               //Waiting End Event
//               double? prevLat =  PreferenceHelper.getDouble(PreferenceHelper.LAST_LAT);
//               double? prevLong =  PreferenceHelper.getDouble(PreferenceHelper.LAST_LONG);
//
//               if(prevLat != null && prevLong != null){
//                 var IsWaitingInRadius = await isWithinRadius(prevLat: prevLat, prevLong: prevLong,currentLat: currentLatitude,currentLong: currentLongitude, radiusMtr: AppConstant.waitingEndRadius);
//
//                 if (!IsWaitingInRadius) {
//                   activity.eventCode = AppConstant.trackingWaitingStopEvent;
//                   activity.activityDate = AppUtils.getDateTimeNow();
//                   await dbService.insertWaitingActivity(activity);
//                 }
//               }
//
//               PreferenceHelper.setString(PreferenceHelper.WAITING_START_TIME, AppUtils.getDate(date: DateTime.now().toString(), format: AppConstant.dateFormat));
//               PreferenceHelper.setDouble(PreferenceHelper.LAST_LAT, currentLatitude ?? (prevLatitude  ?? 0));
//               PreferenceHelper.setDouble(PreferenceHelper.LAST_LONG, currentLongitude ?? (prevLongitude  ?? 0));
//             }
//   }
// }
//
// registerEventsToListener(ServiceInstance service) {
//   try {
//     if (service is AndroidServiceInstance) {
//       service.on('setAsForeground').listen((event) {
//         service.setAsForegroundService();
//       });
//
//       service.on('setAsBackground').listen((event) {
//         service.setAsBackgroundService();
//       });
//
//       service.on('stopService').listen((event) async {
//         await dayEndProccess(service);
//       });
//
//       service.on('dayStart').listen((event) async {
//         Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
//         PreferenceHelper.setString(PreferenceHelper.WAITING_START_TIME, AppUtils.getDate(date: DateTime.now().toString(), format: AppConstant.dateFormat));
//         PreferenceHelper.setDouble(PreferenceHelper.LAST_LAT, currentLatitude ?? position.latitude);
//         PreferenceHelper.setDouble(PreferenceHelper.LAST_LONG, currentLongitude ?? position.longitude);
//       });
//
//       service.on("checkIn_beforeEvent").listen((event) async {
//         await manualWaitingEndEvent();
//       });
//
//       service.on("checkIn_afterEvent").listen((event) {
//         PreferenceHelper.setBool(PreferenceHelper.checkIn, true);
//         PreferenceHelper.reload();
//         isCheckIn = PreferenceHelper.getBool(PreferenceHelper.checkIn);
//       });
//
//       service.on('checkOut_event').listen((event) {
//         PreferenceHelper.setBool(PreferenceHelper.checkIn, false);
//         isCheckIn = PreferenceHelper.getBool(PreferenceHelper.checkIn);
//         print("isCheckIn$isCheckIn");
//         PreferenceHelper.setString(PreferenceHelper.WAITING_START_TIME, AppUtils.getDate(date: DateTime.now().toString(), format: AppConstant.dateFormat));
//         PreferenceHelper.setDouble(PreferenceHelper.LAST_LAT,  currentLatitude ?? (prevLatitude  ?? 0));
//         PreferenceHelper.setDouble(PreferenceHelper.LAST_LONG,  currentLongitude ?? (prevLongitude  ?? 0));
//       });
//     }
//   } catch (e) {
//     print("registerEventsToListener");
//   }
// }
//
// manualWaitingEndEvent() async{
//    DatabaseService databaseService = DatabaseService();
//    await databaseService.removeSyncedNotCompletedEvents();
//    PreferenceHelper.setString(PreferenceHelper.WAITING_START_TIME,AppUtils.getDate(date: DateTime.now().toString(), format: AppConstant.dateFormat));
//    PreferenceHelper.setDouble(PreferenceHelper.LAST_LAT,  currentLatitude ?? (prevLatitude  ?? 0));
//    PreferenceHelper.setDouble(PreferenceHelper.LAST_LONG,  currentLongitude ?? (prevLongitude  ?? 0));
// }
//
// syncRouteHistory() async {
//   CreateRouteHistoryModel? createRouteHistoryModel;
//
//   try {
//
//     final DatabaseService databaseService = DatabaseService();
//
//     List<OfflineRouteModel> offlineData = await databaseService.getRoutes();
//
//     List<OfflineMapData> offlineDataMaps = offlineData
//         .map((route) => OfflineMapData(
//       lattitude: route.latitude,
//       longitude: route.longitude,
//       offlineTime: route.offlineTime,
//     )).toList();
//
//     if (offlineDataMaps == null ||
//         offlineDataMaps.length < 1 ||
//         offlineDataMaps == []) {
//       return;
//     }
//
//     Map<String, dynamic> body = {
//       "userId": lastActivityData?.fieldUserId,
//       "sessionId": lastActivityData?.sessionId,
//       "offlineMapData": offlineDataMaps
//     };
//
//     String endPoint = ApiConstants.createRouteHistory;
//
//     var response = await callPostMethod(endPoint, body);
//
//     createRouteHistoryModel =
//         CreateRouteHistoryModel.fromJson(json.decode(response));
//
//     if (createRouteHistoryModel.isError == false && createRouteHistoryModel.isValidationFailed == false) {
//
//       await databaseService.deleteAllRoutes();
//
//     }
//   } catch (e) {
//     print("createRouteHistory");
//   }
// }
//
// syncSqlData() async {
//
//   BulkActivityResponseModel? bulkActivityResponseModel;
//   BulkActivityRequestModel? bulkActivityRequestModel;
//
//   try {
//
//     DatabaseService databaseService = DatabaseService();
//     List<Activity>? listOfAllActivity = await databaseService.getAllSyncedActivity();
//     String currentSessionId = lastActivityData?.sessionId??"";
//
//     var listOfflineData = listOfAllActivity?.where((element) => element.isSync == false && element.sessionId==currentSessionId).toList();
//
//     if (listOfflineData == null || listOfflineData.length < 1)
//     {
//       return;
//     } else {
//
//       List<CreateActivityList> createActivityLists = [];
//
//       for (var activity in listOfflineData) {
//         int batteryLevel = await AppUtils.getBatteryLevel();
//
//         var createActivityList = CreateActivityList(
//           pkId: activity.pkId,
//           parentId: activity.parentId,
//           userId: lastActivityData?.fieldUserId,
//           longitude: activity.longitude,
//           lattitude: activity.latitude,
//           totTrackingEventId: activity.eventCode,
//           activityDateTime: activity.activityDate,
//           batteryLevel: batteryLevel,
//           sessionId: lastActivityData?.sessionId,
//           visitNoteRequestForm: null,
//         );
//
//         createActivityLists.add(createActivityList);
//       }
//
//       bulkActivityRequestModel = BulkActivityRequestModel(createActivityList: createActivityLists);
//
//       if (createActivityLists.isNotEmpty) {
//         Map<String, dynamic>? body = bulkActivityRequestModel.toJson();
//         if (body != null) {
//           String endPoint = ApiConstants.bulkActivity;
//           try {
//             final response = await callPostMethod(endPoint, body);
//
//             bulkActivityResponseModel = BulkActivityResponseModel.fromJson(json.decode(response));
//
//             if (bulkActivityResponseModel.isError == false) {
//
//               bulkActivityResponseModel.data?.forEach((element) async {
//                 await databaseService.syncRecord(element.localPkId ?? 0);
//               });
//
//               print("all Activity Data cleared");
//             }
//           } catch (e) {
//             print("Error during all bulk activity request: $e");
//           }
//         }
//       }
//     }
//   } catch (e) {
//     print("syncData$e");
//   }
// }
//
// setBgNotificationIcon(ServiceInstance service) async {
//   try {
//     if (service is AndroidServiceInstance) {
//       if (await service.isForegroundService()) {
//         flutterLocalNotificationsPlugin.show(
//           notificationId,
//           'On Trek Background Service',
//           'Background location capturing initiated.',
//           const NotificationDetails(
//             android: AndroidNotificationDetails(
//               notificationChannelId,
//               'MY FOREGROUND SERVICE',
//               icon: 'app_icon',
//               ongoing: true,
//             ),
//           ),
//         );
//       }
//     }
//   } catch (e) {
//     print("setBgNotificationIcon");
//   }
// }
//
// stopServiceAtNight(ServiceInstance service, Timer timer) async {
//   try {
//     var now = DateTime.now();
//     if (now.hour == 23 && now.minute >= 55 && now.minute <= 59) {
//       PreferenceHelper.clear();
//       await dayEndProccess(service);
//       service.stopSelf();
//       timer.cancel(); // Stop the timer
//     }
//   } catch (e) {
//     print("stopServiceAtNight");
//   }
// }
//
// isWithinRadius(
//     {double? currentLat,
//       double? currentLong,
//       double? prevLat,
//       double? prevLong,
//       int? radiusMtr}) async {
//   try {
//     if (prevLat == null || prevLong == null || prevLat == 0 || prevLong == 0) {
//       return false;
//     }
//
//     if (currentLat == null ||
//         currentLong == null ||
//         currentLong == 0 ||
//         currentLong == 0) {
//       return false;
//     }
//
//     double distance = 121;
//     distance = Geolocator.distanceBetween(
//         prevLat ?? 0, prevLong ?? 0, currentLat ?? 0, currentLong ?? 0);
//     if ((distance) < (radiusMtr ?? AppConstant.waitingEndRadius)) {
//       return true;
//     } else {
//       return false;
//     }
//   } catch (e) {
//     print("isWithinRadius");
//   }
// }
//
// setLastActivityData() async {
//
//   PreferenceHelper.reload();
//   Map<String, dynamic> lastActivityMap = PreferenceHelper.getObject(PreferenceHelper.LastActivity);
//
//   if (lastActivityMap != null) {
//     lastActivityData = LastActivityData.fromJson(lastActivityMap);
//   } else {
//
//     lastActivityData = null;
//   }
//   if (lastActivityData != null) {
//     String? sessionId = lastActivityData?.sessionId;
//
//     if (sessionId != null) {
//       if (prevLatitude == null) {
//         prevLatitude = lastActivityData?.lastActivityLat;
//       }
//
//       if (prevLongitude == null) {
//         prevLongitude = lastActivityData?.lastActivityLong;
//       }
//
//       if (currentLatitude == null) {
//         currentLatitude = lastActivityData?.lastActivityLat;
//       }
//
//       if (currentLongitude == null) {
//         currentLongitude = lastActivityData?.lastActivityLong;
//       }
//       if (isGpsAvailable) {
//         prevLatitude = currentLatitude;
//         prevLongitude = currentLongitude;
//         Position position1 = await Geolocator.getCurrentPosition(
//             desiredAccuracy: LocationAccuracy.best);
//         currentLatitude = position1.latitude;
//         currentLongitude = position1.longitude;
//         liveTrackingLat = currentLatitude;
//         liveTrackingLong = currentLongitude;
//
//         lastActivityData?.lastLocationLat =
//             currentLatitude ?? (prevLatitude ?? 0);
//         lastActivityData?.lastLocationLong =
//             currentLongitude ?? (prevLongitude ?? 0);
//
//         PreferenceHelper.setObject<LastActivityData>(PreferenceHelper.LastActivity, lastActivityData);
//       }
//     }
//   }
// }
//
// bool isDifferenceLessFiveMinutes(String time1, String time2) {
//   // Define the format
//   final format = DateFormat(AppConstant.dateFormat);
//
//   // Parse the time strings
//   DateTime dateTime1 = format.parse(time1);
//   DateTime dateTime2 = format.parse(time2);
//
//   // Calculate the difference
//   Duration difference = dateTime1.difference(dateTime2).abs();
//   if (difference.inMinutes < 2) {
//     return true;
//   } else {
//     return false;
//   }
// }
//
