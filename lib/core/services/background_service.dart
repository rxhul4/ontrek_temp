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
List<String> offlineData = [];
List<Activity>? offLineActivities;
double? prevLatitude = null;
double? prevLongitude = null;
double? currentLatitude = null;
double? currentLongitude = null;

bool isInternetAvailable = true;
bool isGpsAvailable=true;

DateTime? waitingStartTime = null;
bool? isWaiting = false;

bool? isGpsOff = false;
bool isGpsOffSendToServer = false;
bool isGpsOnSendToServer = false;

bool isCheckIn = PreferenceHelper.getBool(PreferenceHelper.checkIn);
bool isInRadius=false;

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
    int? liveLocationInterval =
        value?.getInt(PreferenceHelper.LIVE_LOCATION_INTERVAL);
    waitingTime = value?.getInt(PreferenceHelper.WAITING_TIME_INTERVAL);
    print("waitingTime$waitingTime");
    bool? isWaitingAllowed = value?.getBool(PreferenceHelper.ALLOW_WAITING);
    var isServiceFirstCall = true;
    Timer.periodic(
      Duration(
          seconds: liveLocationInterval != null || liveLocationInterval != 0
              ? liveLocationInterval ?? 30
              : 30),
      (timer) async {
        try {
         isCheckIn = PreferenceHelper.getBool(PreferenceHelper.checkIn);
          // Stop service between 11:50 to 12:00 Midnight
          stopServiceAtNight(service, timer);
          //Set notification icon
          setBgNotificationIcon(service);

          if (isServiceFirstCall) {
            await getLastActivityFromApi();
            isServiceFirstCall = false;
            // waitingStartTime = DateTime.now().add(Duration(minutes: 2));
          }

            dynamic result = PreferenceHelper.getObject("last_activity");

            if (result != null)
            {
              lastActivityData = LastActivityData.fromJson(result);
            }

            isInternetAvailable = await isInternetOn();
            isGpsAvailable = await isGpsOn();

            if (lastActivityData != null) {
                if (isGpsAvailable)
                {
                  prevLatitude = currentLatitude;
                  prevLongitude = currentLongitude;
                  Position position1 = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
                  currentLatitude = position1.latitude;
                  currentLongitude = position1.longitude;
                }
          }
          isInRadius = isWithinRadius( prevLat: prevLatitude, prevLong: prevLongitude, currentLat: currentLatitude, currentLong: currentLongitude, radiusMtr: 80);

         await ManageRouteHistory();

         print("checkin$isCheckIn");

          if(isCheckIn==false)
          {
            ManageInternetOperations();
            ManageGpsOperations();
            if(isWaitingAllowed == true){
              ManageWaitingOperation();
            }

          }else{
            PreferenceHelper.setStringList("offline_gps_activities", []);
            PreferenceHelper.setStringList("offline_internet_activities", []);
          }


          if(isInternetAvailable)
          {
            await syncInternetData();
            await syncGpsData();
            if(isWaitingAllowed == true){
              await syncWaitingData();
            }

          }

        } catch (e) {
          print(e);
        }
      },
    );
  });
}

ManageRouteHistory() async
{
  if(isGpsAvailable && !isInRadius){
    if(isInternetAvailable)
    {
      await createRouteHistory();
    }else
    {
      storeLocationDataWhenOffline();
    }
  }
}

ManageGpsOperations()
{
  //send gps off data server
    List<Activity> listOfflineData = geAllGpsActivitiesFromPrefOffLine();
    var activity = Activity(
        pkId: listOfflineData.length + 1,
        sessionId: lastActivityData?.sessionId ?? "",
        latitude: currentLatitude ?? 0,
        longitude: currentLongitude ?? 0,
        activityDate: AppUtils.getDateTimeNow(),
        isSync: false,
        isEventCompleted: false
        );


      if(isGpsAvailable == true)
      {
        var gpsOffData = listOfflineData.where((element) => element.eventCode == AppConstant.gpsOffEvent && element.isEventCompleted == false).firstOrNull;
        var gpsOnData = listOfflineData.where((element) => element.eventCode == AppConstant.gpsOnEvent && element.parentId == gpsOffData?.pkId).firstOrNull;

        if(gpsOnData == null && gpsOffData != null)
        {
          // update parent gps off event
          gpsOffData?.isEventCompleted = true;

          //add gps on event
          activity.parentId = gpsOffData?.pkId;
          activity.eventCode = AppConstant.gpsOnEvent;
          activity.isEventCompleted= true;
          activity.isSync = false;

          listOfflineData.add(activity);
          setGpsActivityListToPref(listOfflineData);
        }
      }

      if(isGpsAvailable == false)
      {
        var gpsOffData = listOfflineData.where((element) => element.eventCode == AppConstant.gpsOffEvent && element.isEventCompleted == false ).firstOrNull;
        if(gpsOffData == null)
        {
          //add gps on event
           activity.eventCode = AppConstant.gpsOffEvent;
           activity.isEventCompleted= false;
           activity.parentId = null;
           activity.isSync = false;
           listOfflineData.add(activity);
           setGpsActivityListToPref(listOfflineData);
         }
      }


}

ManageInternetOperations()
{
  //send gps off data server
  List<Activity> listOfflineData = geAllInternetActivitiesFromPrefOffLine();
  var activity = Activity(
      pkId: listOfflineData.length + 1,
      sessionId: lastActivityData?.sessionId ?? "",
      latitude: currentLatitude ?? 0,
      longitude: currentLongitude ?? 0,
      activityDate: AppUtils.getDateTimeNow(),
      isSync: false,
      isEventCompleted: false
  );


  if(isInternetAvailable == true)
  {
    var internetOffData = listOfflineData.where((element) => element.eventCode == AppConstant.internetOffEvent && element.isEventCompleted == false).firstOrNull;
    var internetOnData = listOfflineData.where((element) => element.eventCode == AppConstant.internetOnEvent && element.parentId == internetOffData?.pkId).firstOrNull;

    if(internetOnData == null && internetOffData != null)
    {
      // update parent gps off event
      internetOffData.isEventCompleted = true;

      //add gps on event
      activity.parentId = internetOffData.pkId;
      activity.eventCode = AppConstant.internetOnEvent;
      activity.isEventCompleted= true;
      activity.isSync = false;

      listOfflineData.add(activity);
      setInternetActivityListToPref(listOfflineData);
    }
  }

  if(isInternetAvailable == false)
  {
    var internetOffData = listOfflineData.where((element) => element.eventCode == AppConstant.internetOffEvent && element.isEventCompleted == false ).firstOrNull;
    if(internetOffData == null)
    {
      //add gps on event
      activity.eventCode = AppConstant.internetOffEvent;
      activity.isEventCompleted= false;
      activity.parentId = null;
      activity.isSync = false;
      listOfflineData.add(activity);
      setInternetActivityListToPref(listOfflineData);
    }
  }


}


ManageWaitingOperation()
{


  //send waiting start data local storage
  List<Activity> listOfflineData = geAllWaitingActivitiesFromPrefOffLine();

  var waitingStartData = listOfflineData.where((element) => element.eventCode == AppConstant.trackingWaitingStartEvent && element.isEventCompleted == false ).firstOrNull;
  var waitingStopData = listOfflineData.where((element) => element.eventCode == AppConstant.trackingWaitingStopEvent && element.parentId == waitingStartData?.pkId).firstOrNull;

  var activity = Activity(
      pkId: listOfflineData.length + 1,
      sessionId: lastActivityData?.sessionId ?? "",
      latitude: currentLatitude ?? 0,
      longitude: currentLongitude ?? 0,
      isSync: false,
      isEventCompleted: false
  );

  if(isGpsAvailable == true)
  {
    if(isInRadius)
    {
      if(DateTime.now().difference(waitingStartTime!).inMinutes >= (waitingTime ?? 10) ){
        if(waitingStartData == null)
        {
          //add waiting start  event
          activity.eventCode = AppConstant.trackingWaitingStartEvent;
          activity.isEventCompleted= false;
          activity.parentId = null;
          activity.isSync = false;
          activity.activityDate = AppUtils.getDate(date: waitingStartTime.toString(), format: AppConstant.dateFormat);
          listOfflineData.add(activity);
          setWaitingActivityListToPref(listOfflineData);
        }
      }

    }else{
      waitingStartTime = DateTime.now();
    }

    if(waitingStartData != null){

      var IsWaitingInRadius = isWithinRadius(prevLat: waitingStartData.latitude,prevLong: waitingStartData.longitude,currentLat: currentLatitude,currentLong: currentLongitude,radiusMtr: 80);

      // Below code is for testing waiting end event in debug mode do not remove

      // var waitingStartTime = DateTime.parse(waitingStartData.activityDate!);
      // if (DateTime.now().difference(waitingStartTime).inMinutes > 2) {
      //   // Your code here
      //   IsWaitingInRadius = false;
      // }

      if(!IsWaitingInRadius) {

        if (waitingStartData != null && waitingStopData == null) {
          waitingStartData.isEventCompleted = true;

          activity.parentId = waitingStartData.pkId;
          activity.eventCode = AppConstant.trackingWaitingStopEvent;
          activity.isEventCompleted = true;
          activity.isSync = false;
          activity.activityDate = AppUtils.getDateTimeNow();

          listOfflineData.add(activity);
          setWaitingActivityListToPref(listOfflineData);
          waitingStartTime = DateTime.now().add(Duration(minutes: 2));
        }
      }
    }
  }
}


waitingEndOnCheckIn()async{
  List<Activity> listOfflineData = geAllWaitingActivitiesFromPrefOffLine();

  var waitingStartData = listOfflineData.where((element) => element.eventCode == AppConstant.trackingWaitingStartEvent && element.isEventCompleted == false ).firstOrNull;
  var waitingStopData = listOfflineData.where((element) => element.eventCode == AppConstant.trackingWaitingStopEvent && element.parentId == waitingStartData?.pkId).firstOrNull;

  if (waitingStartData != null && waitingStopData == null) {
    waitingStartData.isEventCompleted = true;
    var activity = Activity(

        pkId: listOfflineData.length + 1,
        sessionId: lastActivityData?.sessionId ?? "",
        latitude: currentLatitude ?? 0,
        longitude: currentLongitude ?? 0,
        isSync: false,
        isEventCompleted: true,
        parentId : waitingStartData.pkId,
        eventCode : AppConstant.trackingWaitingStopEvent,
       activityDate : AppUtils.getDate(date: DateTime.now().subtract(Duration(seconds: 30)).toString(), format: AppConstant.dateFormat)
    );


    listOfflineData.add(activity);
    setWaitingActivityListToPref(listOfflineData);
    waitingStartTime = DateTime.now().add(Duration(minutes: 2));
  }

  if(isInternetAvailable){
    await syncWaitingData();
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

      service.on('stopService').listen((event)async {
        await syncGpsData();
        await  syncInternetData();
        await syncWaitingData();
        PreferenceHelper.setStringList("offline_data", []);
        PreferenceHelper.setStringList("offline_gps_activities", []);
        PreferenceHelper.setStringList("offline_internet_activities", []);
        PreferenceHelper.setStringList("offline_Waiting_activities", []);
        service.stopSelf();
      });

      service.on("appLoad").listen((event) {
        if (event != null) {
          lastActivityData = LastActivityData.fromJson(event);
          setLastActivityData(lastActivityData);
        }
      });

      service.on('dayStart').listen((event) {
        waitingStartTime = DateTime.now().add(Duration(minutes: 2));
      });

      service.on("checkIn_beforeEvent").listen((event) async{
        await waitingEndOnCheckIn();
      });

      service.on("checkIn_afterEvent").listen((event) {
        PreferenceHelper.setBool(PreferenceHelper.checkIn, true);
     
      });

      service.on('checkOut_event').listen((event) {
        waitingStartTime = DateTime.now().add(Duration(minutes: 2));
        PreferenceHelper.setBool(PreferenceHelper.checkIn, false);

      });

      service.on("dayEnd_beforeEvent").listen((event) {
        isWaiting = false;
        waitingStartTime = null;
        PreferenceHelper.setBool(PreferenceHelper.checkIn, false);
      });
    }
  } catch (e) {
    print("registerEventsToListener");
  }
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

syncGpsData() async {

 try
  {

    List<Activity> listOfflineData = geAllGpsActivitiesFromPrefOffLine();

    listOfflineData =  listOfflineData.where((element) => element.isSync == false).toList();

    if (listOfflineData == null || listOfflineData.length < 1)
    {
      return;
    }
    else
    {

        List<CreateActivityList> createActivityLists = [];

        for (var activity in listOfflineData)
        {
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
              offlineMapData: null
            );

            createActivityLists.add(createActivityList);
       }

      bulkActivityRequestModel = BulkActivityRequestModel(createActivityList: createActivityLists);

        if (createActivityLists.isNotEmpty)
        {
          Map<String, dynamic>? body = bulkActivityRequestModel?.toJson();
          if (body != null) {
            String endPoint = ApiConstants.bulkActivity;
            try {
              final response = await callPostMethod(endPoint, body);
              bulkActivityResponseModel = BulkActivityResponseModel.fromJson(json.decode(response));

              if (bulkActivityResponseModel?.isError == false) {

                bulkActivityResponseModel?.data?.forEach((element) {
                  var recordToSync =  listOfflineData.where((x) => x.pkId == element.localPkId).firstOrNull;
                  recordToSync?.isSync = true;
                });
                List<String> gpsActivityList = listOfflineData.map((activity) => jsonEncode(activity.toJson())).toList();

                PreferenceHelper.setStringList("offline_gps_activities", gpsActivityList);

                print("GPS Data cleared");
              }
            } catch (e) {
              print("Error during gps bulk activity request: $e");
            }
          }
        }


    }
  } catch (e) {
    print("syncDataGps$e");
  }
}

syncInternetData() async {

  try
  {

    List<Activity> listOfflineData = geAllInternetActivitiesFromPrefOffLine();

    listOfflineData =  listOfflineData.where((element) => element.isSync == false).toList();

    List<String>? offlineData = PreferenceHelper.getStringList('offline_data');
    List<OfflineMapData> offlineDataMaps = offlineData
        ?.map((data) => jsonDecode(data))
        .map((json) => OfflineMapData(
        lattitude: json['latitude'],
        longitude: json['longitude'],
        offlineTime: json['offlineTime']))
        .toList() ??
        [];

    if (listOfflineData == null || listOfflineData.length < 1)
    {
      return;
    }
    else
    {

      List<CreateActivityList> createActivityLists = [];

      for (var activity in listOfflineData)
      {
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
            offlineMapData: activity.eventCode == AppConstant.internetOnEvent ? offlineDataMaps : []
        );

        createActivityLists.add(createActivityList);
      }

      bulkActivityRequestModel = BulkActivityRequestModel(createActivityList: createActivityLists);

      if (createActivityLists.isNotEmpty)
      {
        Map<String, dynamic>? body = bulkActivityRequestModel?.toJson();
        if (body != null) {
          String endPoint = ApiConstants.bulkActivity;
          try {
            final response = await callPostMethod(endPoint, body);
            bulkActivityResponseModel = BulkActivityResponseModel.fromJson(json.decode(response));

            if (bulkActivityResponseModel?.isError == false) {

              bulkActivityResponseModel?.data?.forEach((element) {
                var recordToSync =  listOfflineData.where((x) => x.pkId == element.localPkId).firstOrNull;
                recordToSync?.isSync = true;
              });
              List<String> internetActivity = listOfflineData.map((activity) => jsonEncode(activity.toJson())).toList();

              PreferenceHelper.setStringList("offline_internet_activities", internetActivity);
              PreferenceHelper.setStringList("offline_data", []);
              print("Internet Data cleared");
            }
          } catch (e) {
            print("Error during gps bulk activity request: $e");
          }
        }
      }


    }
  } catch (e) {
    print("syncDataInternet$e");
  }
}

syncWaitingData() async {
  try
  {

    List<Activity> listOfflineData = geAllWaitingActivitiesFromPrefOffLine();

    listOfflineData =  listOfflineData.where((element) => element.isSync == false).toList();

    if (listOfflineData == null || listOfflineData.length < 1)
    {
      return;
    }
    else
    {

      List<CreateActivityList> createActivityLists = [];

      for (var activity in listOfflineData)
      {
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
            offlineMapData: null
        );

        createActivityLists.add(createActivityList);
      }

      bulkActivityRequestModel = BulkActivityRequestModel(createActivityList: createActivityLists);

      if (createActivityLists.isNotEmpty)
      {
        Map<String, dynamic>? body = bulkActivityRequestModel?.toJson();
        if (body != null) {
          String endPoint = ApiConstants.bulkActivity;
          try {
            final response = await callPostMethod(endPoint, body);
            bulkActivityResponseModel = BulkActivityResponseModel.fromJson(json.decode(response));

            if (bulkActivityResponseModel?.isError == false) {

              bulkActivityResponseModel?.data?.forEach((element) {
                var recordToSync =  listOfflineData.where((x) => x.pkId == element.localPkId).firstOrNull;
                recordToSync?.isSync = true;
              });
              List<String> waitingActivityList = listOfflineData.map((activity) => jsonEncode(activity.toJson())).toList();

              PreferenceHelper.setStringList("offline_Waiting_activities", waitingActivityList);
              //PreferenceHelper.setStringList("offline_data", []);
              print("Waiting Data cleared");
            }
          } catch (e) {
            print("Error during gps bulk activity request: $e");
          }
        }
      }
    }
  } catch (e) {
    print("syncDataGps$e");
  }
}

geAllGpsActivitiesFromPrefOffLine() {
  try
  {

    var offLineActivitiesStr = PreferenceHelper.getStringList("offline_gps_activities") ?? [];

    List<Activity> offLinActivities = offLineActivitiesStr.map((data) {
      Map<String, dynamic> jsonData = jsonDecode(data);
      return Activity.fromJson(jsonData);
    }).toList();

    return offLinActivities.where((element) =>  (element.eventCode == AppConstant.gpsOnEvent || element.eventCode == AppConstant.gpsOffEvent)).toList();

  }
  catch (e)
  {
    print("geAllGpsActivitiesFromPrefOffLine");
  }
}

geAllInternetActivitiesFromPrefOffLine() {
  try
  {

    var offLineActivitiesStr = PreferenceHelper.getStringList("offline_internet_activities") ?? [];

    List<Activity> offLinActivities = offLineActivitiesStr.map((data) {
      Map<String, dynamic> jsonData = jsonDecode(data);
      return Activity.fromJson(jsonData);
    }).toList();

    return offLinActivities.where((element) =>  (element.eventCode == AppConstant.internetOnEvent || element.eventCode == AppConstant.internetOffEvent)).toList();

  }
  catch (e)
  {
    print("geAllInternetActivitiesFromPrefOffLine");
  }
}

geAllWaitingActivitiesFromPrefOffLine() {
  try
  {

    var offLineActivitiesStr = PreferenceHelper.getStringList("offline_Waiting_activities") ?? [];

    List<Activity> offLinActivities = offLineActivitiesStr.map((data) {
      Map<String, dynamic> jsonData = jsonDecode(data);
      return Activity.fromJson(jsonData);
    }).toList();

    return offLinActivities.where((element) =>  (element.eventCode == AppConstant.trackingWaitingStartEvent || element.eventCode == AppConstant.trackingWaitingStopEvent)).toList();

  }
  catch (e)
  {
    print("geAllWaitingActivitiesFromPrefOffLine");
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
      PreferenceHelper.clear();
      service.stopSelf();
      timer.cancel(); // Stop the timer
    }
  } catch (e) {
    print("stopServiceAtNight");
  }
}

isWithinRadius({double? currentLat, double? currentLong, double? prevLat, double? prevLong, int? radiusMtr}) {
  try {

    if(prevLat==null || prevLong==null || prevLat==0 || prevLong==0)
    {
      return false;
    }

    if(currentLat== null || currentLong== null || currentLong==0 || currentLong==0)
    {
      return false;
    }

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



GetLastActivityModel? getLastActivityModel;

Future<void> getLastActivityFromApi() async {
  try {
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
  } catch (e) {
    print("getLastActivityFromApi");
  }
}

void setLastActivityData(dynamic lastActivity) {
  if (lastActivityData != null) {

    waitingStartTime = DateTime.parse(AppUtils.getDate(date: lastActivityData?.lastLocationTime ?? "",format: AppConstant.dateFormat)).add(Duration(minutes: 1));

    String? sessionId = lastActivityData?.sessionId;

    if (sessionId != null) {

      if(isWaiting != null && lastActivityData?.trackingEventId == AppConstant.trackingWaitingStartEvent){
        isWaiting = true;
      }

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


void setGpsActivityListToPref(List<Activity> lstActivities) {
  try {
    List<String> activitiesJsonList =
    lstActivities.map((activity) => jsonEncode(activity.toJson())).toList();

    PreferenceHelper.setStringList('offline_gps_activities', activitiesJsonList);
  } catch (e) {
    print("setGpsActivityListToPref error: $e");
  }
}

void setInternetActivityListToPref(List<Activity> lstActivities) {
  try {
    List<String> activitiesJsonList =
    lstActivities.map((activity) => jsonEncode(activity.toJson())).toList();

    PreferenceHelper.setStringList('offline_internet_activities', activitiesJsonList);
  } catch (e) {
    print("setGpsActivityListToPref error: $e");
  }
}

void setWaitingActivityListToPref(List<Activity> lstActivities) {
  try {
    List<String> activitiesJsonList =
    lstActivities.map((activity) => jsonEncode(activity.toJson())).toList();

    PreferenceHelper.setStringList('offline_Waiting_activities', activitiesJsonList);
  } catch (e) {
    print("setWaitingActivityListToPref error: $e");
  }
}

Future<void> storeLocationDataWhenOffline() async {
  try {
      List<String> offlineData =
          PreferenceHelper.getStringList('offline_data') ?? [];

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

  } catch (e) {
    print("storeLocationDataWhenOffline");
  }
}








