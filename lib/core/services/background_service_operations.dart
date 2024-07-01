import 'dart:convert';

import 'package:flutter_background_geolocation/flutter_background_geolocation.dart' as bg;
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:ontrek/core/background_service_model/activity_model.dart';
import 'package:ontrek/core/background_service_model/bulk_activity_request_moodel.dart';
import 'package:ontrek/core/background_service_model/bulk_activity_response_model.dart';
import 'package:ontrek/core/background_service_model/create_route_history_model.dart';
import 'package:ontrek/core/background_service_model/offline_route_model.dart';
import 'package:ontrek/core/services/api_constants.dart';
import 'package:ontrek/core/services/background_service_ios.dart';
import 'package:ontrek/core/services/network_repository.dart';
import 'package:ontrek/core/storage/db_service.dart';
import 'package:ontrek/core/storage/preference_helper.dart';
import 'package:ontrek/core/utils/App_utils.dart';
import 'package:ontrek/core/utils/app_constant.dart';
import 'package:ontrek/features/attendance/model/get_last_activity_model.dart';
import 'package:sqflite/sqflite.dart';

class BackgroundServiceOperations{
  LastActivityData? lastActivityData;
  BackgroundServiceOperations()
  {

  }

  stopServiceOperations(Database db)async{
    DatabaseService dbService = new DatabaseService();
    await dbService.deleteAllRoutes(db);
    await dbService.deleteAllActivities(db);
  }

  ManageRouteHistory(Database db,bg.Location location) async {
    final DatabaseService databaseService = DatabaseService();
    OfflineRouteModel dataPoint = OfflineRouteModel(
      latitude: location.coords.latitude,
      longitude: location.coords.longitude,
      offlineTime: AppUtils.getDate(
          date: DateTime.now().toString(), format: AppConstant.dateFormat),
    );

    if (dataPoint.latitude != 0.0 && dataPoint.longitude != 0.0) {
      print("InsertRouteStart");
      await databaseService.insertRoute(db,dataPoint);
      print("InsertRouteEnd");
    }
  }

  waitingEndEvent(Database db,LastActivityData lastActivityData, LatLng currentLatLng) async {

    var waitingStartActivityMap = PreferenceHelper.getObject("waitingStartActivity");
    Activity? waitingStartActivity = Activity.fromJson(waitingStartActivityMap);
    if(waitingStartActivity == null){
      return;
    }

    var isWaitingInRadius = await isWithinRadius(
      radiusMtr: 200,
      prevLat: waitingStartActivity.latitude,
      prevLong: waitingStartActivity.longitude,
      currentLat: currentLatLng.latitude,
      currentLong: currentLatLng.longitude,
    );

    if(isWaitingInRadius == true){
      return;
    }

    DatabaseService dbService = DatabaseService();


    bool isWaitingLessThanFiveMinute = isTimeDiffLessThanAssignedTime(waitingStartActivity.activityDate ?? "", AppUtils.getDate(date: DateTime.now().toString(), format: AppConstant.dateFormat),5);


    if(isWaitingLessThanFiveMinute == true){
      //remove waitingStart Record and Return;
      await dbService.removeActivity(db,waitingStartActivity.pkId);
      PreferenceHelper.remove("waitingStartActivity");
      return;
    }

    var activity = Activity(
        pkId: 0,
        sessionId: lastActivityData.sessionId ?? "",
        latitude: currentLatLng.latitude,
        longitude: currentLatLng.longitude,
        eventCode: AppConstant.trackingWaitingStopEvent,
        activityDate: AppUtils.getDateTimeNow(),
        isSync: false,
        isEventCompleted: false);

    await dbService.insertWaitingActivity(db, activity);
  }

waitingStartEvent(Database db,LastActivityData lastActivityData, LatLng currentLatLng) async {

  DatabaseService dbService = DatabaseService();

  var activity = Activity(
      pkId: 0,
      sessionId: lastActivityData.sessionId ?? "",
      latitude: currentLatLng.latitude,
      longitude: currentLatLng.longitude,
      isSync: false,
      isEventCompleted: false);


  //add waiting start  event
  activity.eventCode = AppConstant.trackingWaitingStartEvent;
  activity.activityDate = AppUtils.getDate(date: DateTime.now().toString(), format: AppConstant.dateFormat);
  await dbService.insertWaitingActivity(db,activity);
  PreferenceHelper.setObject("waitingStartActivity", activity);
}


manualWaitingEndEvent(Database db,bg.Location? location) async {
  DatabaseService databaseService = DatabaseService();
  await databaseService.removeSyncedNotCompletedEvents(db);

}

isWithinRadius(
    {double? currentLat,
      double? currentLong,
      double? prevLat,
      double? prevLong,
      int? radiusMtr}) async {
  try {
    if (prevLat == null ||
        prevLong == null ||
        prevLat == 0 ||
        prevLong == 0) {
      return false;
    }

    if (currentLat == null ||
        currentLong == null ||
        currentLong == 0 ||
        currentLong == 0) {
      return false;
    }

    double distance = 121;
    distance = Geolocator.distanceBetween(
        prevLat ?? 0, prevLong ?? 0, currentLat ?? 0, currentLong ?? 0);
    if ((distance) < (radiusMtr ?? AppConstant.waitingEndRadius)) {
      return true;
    } else {
      return false;
    }
  } catch (e) {
    print("isWithinRadius");
  }
}

syncSqlData(Database db,LastActivityData lastActivityData) async {

  BulkActivityResponseModel? bulkActivityResponseModel;
  BulkActivityRequestModel? bulkActivityRequestModel;
  try {
    DatabaseService databaseService = DatabaseService();
    List<Activity>? listOfAllActivity = await databaseService.getAllSyncedActivity(db);
    String currentSessionId = lastActivityData.sessionId ?? "";

    var listOfflineData = listOfAllActivity
        ?.where((element) =>
    element.isSync == false && element.sessionId == currentSessionId)
        .toList();

    if (listOfflineData == null || listOfflineData.length < 1) {
      return;
    } else {
      List<CreateActivityList> createActivityLists = [];

      for (var activity in listOfflineData) {
        int batteryLevel = await AppUtils.getBatteryLevel();

        var createActivityList = CreateActivityList(
          pkId: activity.pkId,
          parentId: activity.parentId,
          userId: lastActivityData.fieldUserId,
          longitude: activity.longitude,
          lattitude: activity.latitude,
          totTrackingEventId: activity.eventCode,
          activityDateTime: activity.activityDate,
          batteryLevel: batteryLevel,
          sessionId: lastActivityData.sessionId,
          visitNoteRequestForm: null,
        );

        if(createActivityList.totTrackingEventId == AppConstant.trackingWaitingStartEvent){
          bool isWaitingLessThanFiveMinute = isTimeDiffLessThanAssignedTime(activity.activityDate ?? "", AppUtils.getDate(date: DateTime.now().toString(), format: AppConstant.dateFormat),5);
          if(isWaitingLessThanFiveMinute == false){
            createActivityLists.add(createActivityList);
          }
        }else{
          createActivityLists.add(createActivityList);
        }
      }

      bulkActivityRequestModel =
          BulkActivityRequestModel(createActivityList: createActivityLists);

      if (createActivityLists.isNotEmpty) {
        Map<String, dynamic>? body = bulkActivityRequestModel.toJson();
        if (body != null) {
          String endPoint = ApiConstants.bulkActivity;
          try {
            final response = await callPostMethod(endPoint, body);

            bulkActivityResponseModel =
                BulkActivityResponseModel.fromJson(json.decode(response));

            if (bulkActivityResponseModel.isError == false) {
              bulkActivityResponseModel.data?.forEach((element) async {
                await databaseService.syncRecord(db,element.localPkId ?? 0);
              });

              print("all Activity Data cleared");
            }
          } catch (e) {
            print("Error during all bulk activity request: $e");
          }
        }
      }
    }
  } catch (e) {
    print("syncData$e");
  }
}

syncRouteHistory(Database db,LastActivityData lastActivityData) async {
  CreateRouteHistoryModel? createRouteHistoryModel;

  try {
    final DatabaseService databaseService = DatabaseService();

    List<OfflineRouteModel> offlineData = await databaseService.getRoutes(db);

    List<OfflineMapData> offlineDataMaps = offlineData
        .map((route) => OfflineMapData(
      lattitude: route.latitude,
      longitude: route.longitude,
      offlineTime: route.offlineTime,
    ))
        .toList();

    if (offlineDataMaps.length < 1 ||
        offlineDataMaps == []) {
      return;
    }

    Map<String, dynamic> body = {
      "userId": lastActivityData.fieldUserId,
      "sessionId": lastActivityData.sessionId,
      "offlineMapData": offlineDataMaps
    };

    String endPoint = ApiConstants.createRouteHistory;

    var response = await callPostMethod(endPoint, body);

    createRouteHistoryModel =
        CreateRouteHistoryModel.fromJson(json.decode(response));

    if (createRouteHistoryModel.isError == false &&
        createRouteHistoryModel.isValidationFailed == false) {
      await databaseService.deleteAllRoutes(db);
    }
  } catch (e) {
    print("createRouteHistory");
  }
}

ManageGpsOperations(Database db,LastActivityData lastActivityData) async {
  DatabaseService dbService = DatabaseService();
  double? lastGpsOffLat = PreferenceHelper.getDouble(PreferenceHelper.LAST_LAT);
  double? lastGpsOffLong = PreferenceHelper.getDouble(PreferenceHelper.LAST_LONG);

  var activity = Activity(
      pkId: 0,
      sessionId: lastActivityData.sessionId ?? "",
      latitude: lastGpsOffLat ?? 0,
      longitude:  lastGpsOffLong ?? 0,
      activityDate: AppUtils.getDateTimeNow(),
      isSync: false,
      isEventCompleted: false);

  bool? isGpsAvailable = PreferenceHelper.getBool(PreferenceHelper.GPS_BOOL);


  if (isGpsAvailable == true) {
    Position position = await Geolocator.getCurrentPosition();
    activity.eventCode = AppConstant.gpsOnEvent;
    activity.isSync = false;
    activity.latitude = position.latitude;
    activity.longitude = position.longitude;
    await dbService.insertGpsActivity(db,activity);
  }

  if (isGpsAvailable == false) {
    activity.eventCode = AppConstant.gpsOffEvent;
    activity.latitude = lastGpsOffLat ?? 0;
    activity.longitude = lastGpsOffLong ?? 0;
    activity.isSync = false;
    await dbService.insertGpsActivity(db,activity);
  }
}

ManageInternetOperations(Database db,LastActivityData lastActivityData) async {

  String? internetOffTIme = PreferenceHelper.getString(PreferenceHelper.LAST_INTERNET_OFF_TIME) ?? "";
  if(internetOffTIme == ""){
    return;
  }
  double? internetOffLat = PreferenceHelper.getDouble(PreferenceHelper.LAST_INTERNET_OFF_LAT) ?? 0.0;
  double? internetOffLong = PreferenceHelper.getDouble(PreferenceHelper.LAST_INTERNET_OFF_LONG) ?? 0.0;
  double? lastLat = PreferenceHelper.getDouble(PreferenceHelper.LAST_LAT) ?? 0.0;
  double? lastLong = PreferenceHelper.getDouble(PreferenceHelper.LAST_LONG) ?? 0.0;

  bool isDifferenceLessTwoMinutes = await isTimeDiffLessThanAssignedTime(internetOffTIme,AppUtils.getDateTimeNow(),2);

  if (internetOffTIme == ""
      || lastLat == 0.0
      || lastLong == 0.0
      || internetOffLat == 0.0
      || internetOffLong == 0.0
  )
  {
    return;
  }

  if(isDifferenceLessTwoMinutes==true)
  {
    return;
  }

  DatabaseService dbService = DatabaseService();

  var internetOffActivity = Activity(
      pkId: 0,
      sessionId: lastActivityData.sessionId ?? "",
      eventCode: AppConstant.internetOffEvent,
      latitude: internetOffLat,
      longitude: internetOffLong,
      activityDate: internetOffTIme,
      isSync: false,
      isEventCompleted: true);

  var internetOnActivity = Activity(
      pkId: 0,
      sessionId: lastActivityData.sessionId ?? "",
      eventCode: AppConstant.internetOnEvent,
      latitude: lastLat ?? 0,
      longitude: lastLong ?? 0,
      activityDate: AppUtils.getDateTimeNow(),
      isSync: false,
      isEventCompleted: true);

  var internetOffPkId = await dbService.getMaxPkId(db);
  internetOffActivity.pkId = internetOffPkId + 1;

  await dbService.insertInternetActivity(db,internetOffActivity);

  var internetOnPkId = await dbService.getMaxPkId(db);
  internetOnActivity.pkId = internetOnPkId + 1;
  internetOnActivity.parentId = internetOffActivity.pkId;
  await dbService.insertInternetActivity(db,internetOnActivity);
}

bool isTimeDiffLessThanAssignedTime(String time1, String time2, int diffMinute) {
  // Define the format
  final format = DateFormat(AppConstant.dateFormat);

  // Parse the time strings
  DateTime dateTime1 = format.parse(time1);
  DateTime dateTime2 = format.parse(time2);

  // Calculate the difference
  Duration difference = dateTime1.difference(dateTime2).abs();
  if (difference.inMinutes < diffMinute) {
    return true;
  } else {
    return false;
  }
}
}