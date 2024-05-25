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
import 'package:ontrek/core/background_service_model/activity_model.dart';
import 'package:ontrek/core/background_service_model/bulk_activity_model.dart';
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
import 'package:ontrek/features/attendance/model/add_activity_model.dart';
import 'package:ontrek/features/attendance/model/get_last_activity_model.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:shared_preferences/shared_preferences.dart';

const notificationChannelId = 'my_foreground';
const notificationId = 888;

LastActivityData? lastActivityData;
List<String> offlineData = [];
List<Activity>? offLineActivities;
double? prevLatitude = null;
double? prevLongitude = null;
double? currentLatitude = null;
double? currentLongitude = null;

DateTime? waitingStartTime = null;
bool? isWaiting = false;
bool? isCheckIn = false;

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

  registerEventsToListener(service);

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
    var isServiceFirstCall=true;
    Timer.periodic(
      Duration(
          seconds: liveLocationInterval != null || liveLocationInterval != 0
              ? liveLocationInterval ?? 30
              : 30),
      (timer) async {
        try {

          if(isServiceFirstCall)
          {
            await getLastActivityFromApi();
            isServiceFirstCall=false;
            waitingStartTime = DateTime.now().add(Duration(minutes: 2));
          }

          // Stop service between 11:50 to 12:00 Midnight
          stopServiceAtNight(service, timer);

          //Set notification icon
          setBgNotificationIcon(service);

          try
          {
            dynamic result = PreferenceHelper.getObject("last_activity");

            if (result != null) {
              lastActivityData = LastActivityData.fromJson(result);
            }
          }catch(e)
          {
            print("Format Exception : Kaushal");
          }
          if (lastActivityData != null) {
            var isInternetAvailable = await isInternetOn();
            var isGpsAvailable = await isGpsOn();

            if (isGpsAvailable) {
              prevLatitude = currentLatitude;
              prevLongitude = currentLongitude;
              Position position1 = await Geolocator.getCurrentPosition(
                  desiredAccuracy: LocationAccuracy.best);
              currentLatitude = position1.latitude;
              currentLongitude = position1.longitude;
            }


            if(isCheckIn == false)
            {
              List<Activity> listOfflineData = geAllActivitiesFromPrefOffLine();
              if (!isInternetAvailable || !isGpsAvailable) {
                if (!isInternetAvailable) {
                  var internetOffData = listOfflineData
                      .where((element) =>
                  element.eventCode == AppConstant.internetOffEvent &&
                      element.isEventCompleted == false)
                      .toList()
                      .firstOrNull;

                  if (internetOffData == null) {
                    listOfflineData.add(Activity(
                        pkId: listOfflineData.length + 1,
                        sessionId: lastActivityData?.sessionId ?? "111",
                        eventCode: AppConstant.internetOffEvent,
                        latitude: currentLatitude ?? 0,
                        longitude: currentLongitude ?? 0,
                        activityDate: AppUtils.getDateTimeNow(),
                        isSync: false,
                        isEventCompleted: false,
                        parentId: 0));
                    setActivityListToPref(listOfflineData);
                  }
                  storeLocationDataWhenOffline();

                } else {
                  var internetOnData = listOfflineData
                      .where((element) =>
                  element.eventCode == AppConstant.internetOnEvent &&
                      element.isEventCompleted == false)
                      .toList()
                      .firstOrNull;
                  var internetOffData = listOfflineData
                      .where((element) =>
                  element.eventCode == AppConstant.internetOffEvent &&
                      element.isEventCompleted == false)
                      .toList()
                      .firstOrNull;
                  if (internetOnData == null) {
                    if (internetOffData != null) {
                      internetOffData.isEventCompleted = true;
                      listOfflineData.add(Activity(
                          pkId: listOfflineData.length + 1,
                          sessionId: lastActivityData?.sessionId ?? "222",
                          eventCode: AppConstant.internetOnEvent,
                          latitude: currentLatitude ?? 0,
                          longitude: currentLongitude ?? 0,
                          activityDate: AppUtils.getDateTimeNow(),
                          isSync: false,
                          isEventCompleted: true,
                          parentId: internetOffData.pkId));
                      setActivityListToPref(listOfflineData);
                    }
                  }
                }

                if (!isGpsAvailable) {
                  var gpsOffData = listOfflineData
                      .where((element) =>
                  element.eventCode == AppConstant.gpsOffEvent &&
                      element.isEventCompleted == false)
                      .toList()
                      .firstOrNull;

                  if (gpsOffData == null) {
                    listOfflineData.add(Activity(
                        pkId: listOfflineData.length + 1,
                        sessionId: lastActivityData?.sessionId ?? "333",
                        eventCode: AppConstant.gpsOffEvent,
                        latitude: currentLatitude ?? 0,
                        longitude: currentLongitude ?? 0,
                        activityDate: AppUtils.getDateTimeNow(),
                        isSync: false,
                        isEventCompleted: false));
                    setActivityListToPref(listOfflineData);
                  }
                } else {
                  var gpsOnData = listOfflineData
                      .where((element) =>
                  element.eventCode == AppConstant.gpsOnEvent &&
                      element.isEventCompleted == false)
                      .toList()
                      .firstOrNull;
                  var gpsOffData = listOfflineData
                      .where((element) =>
                  element.eventCode == AppConstant.gpsOffEvent &&
                      element.isEventCompleted == false)
                      .toList()
                      .firstOrNull;
                  if (gpsOnData == null) {
                    if (gpsOffData != null) {
                      gpsOffData.isEventCompleted = true;
                      listOfflineData.add(Activity(
                          pkId: listOfflineData.length + 1,
                          sessionId: lastActivityData?.sessionId ?? "444",
                          eventCode: AppConstant.gpsOnEvent,
                          latitude: currentLatitude ?? 0,
                          longitude: currentLongitude ?? 0,
                          activityDate: AppUtils.getDateTimeNow(),
                          isSync: false,
                          isEventCompleted: true,
                          parentId: gpsOffData.pkId));
                      setActivityListToPref(listOfflineData);
                    }
                  }
                }
              }

              if (isInternetAvailable && isGpsAvailable)
              {
                bool isinRadius = isWithinRadius(prevLat: prevLatitude,prevLong: prevLongitude,currentLat: currentLatitude,currentLong: currentLongitude,radiusMtr: 80);

                if(!isinRadius)
                {
                  createRouteHistory();
                }

                if (isInternetAvailable) {
                  var internetOnData = listOfflineData
                      .where((element) =>
                  element.eventCode == AppConstant.internetOnEvent &&
                      element.isEventCompleted == false)
                      .toList()
                      .firstOrNull;
                  var internetOffData = listOfflineData
                      .where((element) =>
                  element.eventCode == AppConstant.internetOffEvent &&
                      element.isEventCompleted == false)
                      .toList()
                      .firstOrNull;
                  if (internetOnData == null) {
                    if (internetOffData != null) {
                      internetOffData.isEventCompleted = true;
                      listOfflineData.add(Activity(
                          pkId: listOfflineData.length + 1,
                          sessionId: lastActivityData?.sessionId ?? "",
                          eventCode: AppConstant.internetOnEvent,
                          latitude: currentLatitude ?? 0,
                          longitude: currentLongitude ?? 0,
                          activityDate: AppUtils.getDateTimeNow(),
                          isSync: false,
                          isEventCompleted: true,
                          parentId: internetOffData.pkId));
                      setActivityListToPref(listOfflineData);
                    }
                  }
                }

                if (isGpsAvailable) {
                  var gpsOnData = listOfflineData
                      .where((element) =>
                  element.eventCode == AppConstant.gpsOnEvent &&
                      element.isEventCompleted == false)
                      .toList()
                      .firstOrNull;
                  var gpsOffData = listOfflineData
                      .where((element) =>
                  element.eventCode == AppConstant.gpsOffEvent &&
                      element.isEventCompleted == false)
                      .toList()
                      .firstOrNull;
                  if (gpsOnData == null) {
                    if (gpsOffData != null) {
                      gpsOffData.isEventCompleted = true;
                      listOfflineData.add(Activity(
                          pkId: listOfflineData.length + 1,
                          sessionId: lastActivityData?.sessionId ?? "",
                          eventCode: AppConstant.gpsOnEvent,
                          latitude: currentLatitude ?? 0,
                          longitude: currentLongitude ?? 0,
                          activityDate: AppUtils.getDateTimeNow(),
                          isSync: false,
                          isEventCompleted: true,
                          parentId: gpsOffData.pkId));
                      setActivityListToPref(listOfflineData);
                    }
                  }
                }
                List<Activity> allData = geAllActivitiesFromPrefOffLine();
                if (allData == null || allData.length > 0) {
                  syncData();
                }
              }

              manageWaitingTime();
            }
          }
        }

        catch (e) {
          print(e);
        }
      },
    );
  });
}

BulkActivityRequestModel? bulkActivityRequestModel;
OfflineRouteModel? offlineRouteModel;
BulkActivityResponseModel? bulkActivityResponseModel;

CreateRouteHistoryModel? createRouteHistoryModel;

Future<void> createRouteHistory() async {
  try {
    Map<String, dynamic> body = {
        "userId": lastActivityData?.fieldUserId,
        "sessionId": lastActivityData?.sessionId,
        "lattitude": currentLatitude,
        "longitude": currentLongitude,
        "modifiedOn": AppUtils.dateFormat(
            date: DateTime.now(), dateFormat: AppConstant.dateFormat)
      };

      String endPoint = ApiConstants.createRouteHistory;

      var response = await callPostMethod(endPoint, body);

      createRouteHistoryModel =
          CreateRouteHistoryModel.fromJson(json.decode(response));

      if (createRouteHistoryModel?.isError == false &&
          createRouteHistoryModel?.isValidationFailed == false) {

      }

  } catch (e) {
    print("createRouteHistory");
  }
}

syncData() async {
  try {

    List<Activity> listOfflineData = geAllActivitiesFromPrefOffLine();

    List<String>? offlineData = PreferenceHelper.getStringList('offline_data');
    List<OfflineMapData> offlineDataMaps = offlineData
            ?.map((data) => jsonDecode(data))
            .map((json) => OfflineMapData(
                lattitude: json['latitude'],
                longitude: json['longitude'],
                offlineTime: json['offlineTime']))
            .toList() ??
        [];

    List<CreateActivityList> createActivityLists = [];
    if (listOfflineData.isNotEmpty) {
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
          offlineMapData: activity.eventCode==AppConstant.internetOnEvent ? offlineDataMaps : null,
        );

        createActivityLists.add(createActivityList);
      }

      bulkActivityRequestModel = BulkActivityRequestModel(createActivityList: createActivityLists);

      if (createActivityLists.isNotEmpty) {
        Map<String, dynamic>? body = bulkActivityRequestModel?.toJson();
        if (body != null) {
          String endPoint = ApiConstants.bulkActivity;
          try {
            final response = await callPostMethod(endPoint, body);
            bulkActivityResponseModel = BulkActivityResponseModel.fromJson(json.decode(response));

            if (bulkActivityResponseModel?.isError == false) {
              print("Data processing successful");

              var waitingStartSaveResponse = bulkActivityResponseModel?.data?.where((element) => element.isSuccess== true && element.eventCode=='tracking_event_waiting_start').firstOrNull;

              if(waitingStartSaveResponse != null)
              {
                isWaiting=true;
              }else
              {
                isWaiting=false;
              }

              PreferenceHelper.setStringList("offline_activities", []);
              PreferenceHelper.setStringList("offline_data", []);
              bulkActivityRequestModel = BulkActivityRequestModel();
              createActivityLists.clear();
              print("Data cleared");
            }
          } catch (e) {
            print("Error during bulk activity request: $e");
          }
        }
      }
    }
  } catch (e) {
    print("syncData$e");
  }
}

geAllActivitiesFromPrefOffLine() {
  try
  {
    var offLineActivitiesStr = PreferenceHelper.getStringList("offline_activities") ?? [];

    List<Activity> offLinActivities = offLineActivitiesStr.map((data) {
      Map<String, dynamic> jsonData = jsonDecode(data);
      return Activity.fromJson(jsonData);
    }).toList();

    return offLinActivities;

  } catch (e) {
    print("geAllActivitiesFromPrefOffLine");
  }
}

void removeActivityFromPrefOffline(Activity activity) {
  try {
    var offLineActivitiesStr =
        PreferenceHelper.getStringList("offline_activities") ?? [];

    List<Activity> offLinActivities = offLineActivitiesStr.map((data) {
      Map<String, dynamic> jsonData = jsonDecode(data);
      return Activity.fromJson(jsonData);
    }).toList();

    // Find and remove the activity
    offLinActivities.removeWhere((a) => a == activity);

    setActivityListToPref(offLinActivities);
  } catch (e) {
    print("removeActivityFromPrefOffline error: $e");
  }
}

getEventActivitiesFromPrefOffLine(String eventCode) {
  try {
    List<Activity> listOfflineActivities = geAllActivitiesFromPrefOffLine();
    return listOfflineActivities
        .where((element) => element.eventCode == eventCode)
        .toList();
  } catch (e) {
    print("getEventActivitiesFromPrefOffLine");
  }
}

isInternetOn() async {
  try {
    bool isInternetAvailable = false;

    final connectivityResult = await Connectivity().checkConnectivity();
    isInternetAvailable = connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi;

    return isInternetAvailable;
  } catch (e) {
    print("isInternetOn");
  }
}

isGpsOn() async {
  try {
    var isGPSEnabled =
        await Permission.locationAlways.serviceStatus.isEnabled &&
            await Permission.location.serviceStatus.isEnabled;
    return isGPSEnabled;
  } catch (e) {
    print("isGpsOn");
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

stopServiceAtNight(ServiceInstance service, Timer timer) {
  try {
    var now = DateTime.now();
    if (now.hour == 23 && now.minute >= 50 && now.minute <= 59) {
      service.stopSelf();
      timer.cancel(); // Stop the timer
    }
  } catch (e) {
    print("stopServiceAtNight");
  }
}

isWithinRadius({double? currentLat, double? currentLong, double? prevLat, double? prevLong, int? radiusMtr}) {
  try {
    double distance = 81;
    distance = Geolocator.distanceBetween(prevLat ?? 0, prevLong ?? 0, currentLat ?? 0, currentLong ?? 0);
    if ((distance) < (radiusMtr ?? 50)) {
      return true;
    } else {
      return false;
    }
  } catch (e) {
    print("isWithinRadius");
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

      service.on('stopService').listen((event) {
        service.stopSelf();
      });

      //replace background with appLoad from ui : Kaushal
      service.on("appLoad").listen((event) {
        if (event != null) {
          // Assuming event is already a Map<String, dynamic>
          lastActivityData = LastActivityData.fromJson(event);
          setLastActivityData(lastActivityData);
        }
      });

      service.on('dayStart').listen((event) {
        waitingStartTime = DateTime.now().add(Duration(minutes: 2));
      });

      service.on("checkIn_beforeEvent").listen((event) {
        setWaitingEndToOffline();
        //callApi of waitingEnd;
      });

      //replace with update listener from ui : kaushal
      service.on("checkIn_afterEvent").listen((event) {
        manageWaitingOnCheckIn();
        isCheckIn= true;
      });

      service.on('checkOut_event').listen((event) {
        waitingStartTime = DateTime.now().add(Duration(minutes: 2));
        isCheckIn= false;
      });

      //checkout_update replace in ui code : kaushal
      service.on("dayEnd_beforeEvent").listen((event) {
        setWaitingEndToOffline();
        isWaiting = false;
        waitingStartTime = null;
        isCheckIn= false;
      });
    }
  } catch (e) {
    print("registerEventsToListener");
  }

}

GetLastActivityModel? getLastActivityModel;
Future<void> getLastActivityFromApi()async
{
  try
  {
    String? userId = PreferenceHelper.getString(PreferenceHelper.USER_ID);
    Map<String, dynamic> body = {
      "userId": userId,
      "currentDate": AppUtils.dateFormat(
          date: DateTime.now(), dateFormat: AppConstant.dateFormat)
    };
    String endPoint = ApiConstants.getLastActivity;
    final response = await callPostMethod(endPoint, body);
    getLastActivityModel = GetLastActivityModel.fromJson(json.decode(response));
    print("response_of_lastActivity: $response");
    setLastActivityData(getLastActivityModel);

  }
  catch(e)
  {

  }
}
void setLastActivityData(dynamic lastActivity)
{
  if (lastActivityData != null) {
    waitingStartTime = DateTime.now();
    String? sessionId = lastActivityData?.sessionId;
    // Store sessionId using PreferenceHelper
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
      PreferenceHelper.setObject<LastActivityData>("last_activity", lastActivityData);
    }
  }
}

void setActivityListToPref(List<Activity> lstActivities) {
  try {
    List<String> activitiesJsonList =
        lstActivities.map((activity) => jsonEncode(activity.toJson())).toList();

    PreferenceHelper.setStringList('offline_activities', activitiesJsonList);
  } catch (e) {
    print("setActivityListToPref error: $e");
  }
}

Future<void> storeLocationDataWhenOffline() async {

  try{
    bool isInRadius = isWithinRadius(
        prevLat: prevLatitude,
        prevLong: prevLongitude,
        currentLat: currentLatitude,
        currentLong: currentLongitude,
        radiusMtr: 80);

    if (isInRadius)
    {
      List<String> offlineData = PreferenceHelper.getStringList('offline_data') ?? [];

      OfflineRouteModel dataPoint = OfflineRouteModel(
        latitude: currentLatitude ?? 0,
        longitude: currentLongitude ?? 0,
        offlineTime: AppUtils.getDate(
            date: DateTime.now().toString(), format: AppConstant.dateFormat),
      );

      offlineData.add(jsonEncode(dataPoint.toJson()));
      PreferenceHelper.setStringList('offline_data', offlineData);

      List<OfflineRouteModel> offlineDataMaps = offlineData
          .map((data) => OfflineRouteModel.fromJson(jsonDecode(data)))
          .toList();
      print("Offline data points: $offlineDataMaps");
    }
  }catch(e){
    print("storeLocationDataWhenOffline");
  }
}

manageWaitingOnCheckIn() {

  try{
    List<Activity> listOfflineData = geAllActivitiesFromPrefOffLine();

    var waitingStart = listOfflineData
        .where((element) =>
    element.eventCode == AppConstant.trackingWaitingStartEvent &&
        element.isEventCompleted == false)
        .toList()
        .firstOrNull;

    if (waitingStart != null) {
      setWaitingEndToOffline();
      waitingStartTime = null;
    }
  }catch(e){
    print("manageWaitingOnCheckIn");
  }





}

setWaitingStartToOfflinePref()
{
  try{
    List<Activity> listOfflineData = geAllActivitiesFromPrefOffLine();

    var waitingStart = listOfflineData
        .where((element) => element.eventCode == AppConstant.trackingWaitingStartEvent && element.isEventCompleted == false)
        .toList()
        .firstOrNull;

    if (waitingStart == null) {
      listOfflineData.add(Activity(
          pkId: listOfflineData.length + 1,
          sessionId: lastActivityData?.sessionId ?? "",
          eventCode: AppConstant.trackingWaitingStartEvent,
          latitude: currentLatitude ?? 0,
          longitude: currentLongitude ?? 0,
          activityDate: AppUtils.getDateTimeNow(),
          isSync: false,
          isEventCompleted: false,
          waitingStart: true));
      setActivityListToPref(listOfflineData);
    }
  }catch(e){
    print("setWaitingStartToOfflinePref");
  }
}

setWaitingEndToOffline() {
  try{
    List<Activity> listOfflineData = geAllActivitiesFromPrefOffLine();

    var waitingStop = listOfflineData
        .where((element) =>
    element.eventCode == AppConstant.trackingWaitingStopEvent &&
        element.isEventCompleted == false)
        .toList()
        .firstOrNull;

    var waitingStart = listOfflineData
        .where((element) =>
    element.eventCode == AppConstant.trackingWaitingStartEvent &&
        element.isEventCompleted == false)
        .toList()
        .firstOrNull;

    if (waitingStop == null) {
      if (waitingStart != null) {
        waitingStart.isEventCompleted = true;

        listOfflineData.add(Activity(
            pkId: listOfflineData.length + 1,
            sessionId: lastActivityData?.sessionId ?? "",
            eventCode: AppConstant.trackingWaitingStopEvent,
            latitude: currentLatitude ?? 0,
            longitude: currentLongitude ?? 0,
            activityDate: AppUtils.getDate(date: DateTime.now().subtract(Duration(minutes: 1)).toString(), format: AppConstant.dateFormat),
            isSync: false,
            isEventCompleted: true,
            parentId: waitingStart.pkId,
            waitingStart: false));
        setActivityListToPref(listOfflineData);
      }
    }
  }catch(e){
    print("setWaitingEndToOffline");
  }

}

Future<void> manageWaitingTime() async {

  try{
    bool isInRadius = isWithinRadius( prevLat: prevLatitude, prevLong: prevLongitude, currentLat: currentLatitude, currentLong: currentLongitude, radiusMtr: 80);

    if (waitingStartTime != null) {

      if (isInRadius && isWaiting==false && DateTime.now().difference(waitingStartTime!).inMinutes > 10) {
          setWaitingStartToOfflinePref();
          isWaiting=true;
        }

      }
    else
    {
          setWaitingEndToOffline();
    }

  }catch(e){
    print("manageWaitingTime");
  }
}
