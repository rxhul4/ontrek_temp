import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'package:flutter_background_geolocation/flutter_background_geolocation.dart'
    as bg;
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:ontrek/core/background_service_model/bulk_activity_response_model.dart';
import 'package:ontrek/core/background_service_model/create_route_history_model.dart';
import 'package:ontrek/core/background_service_model/offline_route_model.dart';
import 'package:ontrek/core/services/api_constants.dart';
import 'package:ontrek/core/services/background_service_operations.dart';
import 'package:ontrek/core/services/network_repository.dart';
import 'package:ontrek/core/storage/db_service.dart';
import 'package:ontrek/core/storage/preference_helper.dart';
import 'package:ontrek/core/utils/App_utils.dart';
import 'package:ontrek/core/utils/app_constant.dart';
import 'package:ontrek/features/attendance/model/get_last_activity_model.dart';
import 'package:ontrek/features/track_function/model/salemen_list_model.dart';
import 'package:sqflite/sqflite.dart';
import '../background_service_model/activity_model.dart';
import '../background_service_model/bulk_activity_request_moodel.dart';

bool isInternetAvailable = false;
bool isGpsAvailable = false;
String? waitingStartTime;

LastActivityData? lastActivityData;
BackgroundServiceOperations bgOps =BackgroundServiceOperations();
DatabaseService dbServiece = new DatabaseService();
late Database db;
class BackgroundServiceIos {
  Future<void> initialize() async {

    db = await dbServiece.initializeOnTrekDB();

    if(db==null)
    {
      print("Database object not created;");
      return;
    }

    bg.BackgroundGeolocation.setConfig(bg.Config(
        desiredAccuracy: bg.Config.DESIRED_ACCURACY_HIGH, // Minimal accuracy to avoid frequent updates
        distanceFilter: 50, // Only get updates when the user moves more than 100 meters
        stopOnTerminate: false, // Keep tracking even if the app is terminated
        startOnBoot: false, // Don't start on boot
        foregroundService: true, // Run as a foreground service
        debug: true, // Enable debugging
        autoSync: false, // Disable automatic syncing
        showsBackgroundLocationIndicator: true, // Show location indicator
        stationaryRadius: 50, // Radius to define the stationary state
        useSignificantChangesOnly: false, // Use significant changes
        disableMotionActivityUpdates: false, // Disable motion activity updates to avoid walking updates
        locationUpdateInterval: 10000, // Update interval (not critical due to distance filter)
        activityRecognitionInterval: 10000, // Check activity every 10 seconds
        stopTimeout: 1, // Consider the user stationary after 1 minute of no movement
        logLevel: bg.Config.LOG_LEVEL_VERBOSE, // Verbose logging for debugging
        preventSuspend: true // Prevent the app from suspending
    )).then((bg.State state) async {

    });
    listenGeofenceEvents();

    bg.BackgroundGeolocation.onConnectivityChange((bg.ConnectivityChangeEvent event) async
    {
      var lastActivityDataMap = PreferenceHelper.getObject(
          PreferenceHelper.LastActivity);
      lastActivityData = LastActivityData.fromJson(lastActivityDataMap);
      var lastLat = PreferenceHelper.getDouble(PreferenceHelper.LAST_LAT) ??
          0.0;
      var lastLong = PreferenceHelper.getDouble(PreferenceHelper.LAST_LONG) ??
          0.0;

      if (event.connected == true) {
        PreferenceHelper.setBool(PreferenceHelper.INTERNET_BOOL, true);
        if (lastActivityData == null) {
          return;
        }
        await bgOps.ManageInternetOperations(db,lastActivityData!);
        PreferenceHelper.remove(PreferenceHelper.LAST_INTERNET_OFF_TIME);
        PreferenceHelper.remove(PreferenceHelper.LAST_INTERNET_OFF_LAT);
        PreferenceHelper.remove(PreferenceHelper.LAST_INTERNET_OFF_LONG);
      } else {
        String internetOffTime = AppUtils.getDate(
            date: DateTime.now().toString(), format: AppConstant.dateFormat);
        PreferenceHelper.setString(
            PreferenceHelper.LAST_INTERNET_OFF_TIME, internetOffTime);
        PreferenceHelper.setDouble(
            PreferenceHelper.LAST_INTERNET_OFF_LAT, lastLat);
        PreferenceHelper.setDouble(
            PreferenceHelper.LAST_INTERNET_OFF_LONG, lastLong);
        PreferenceHelper.setBool(PreferenceHelper.INTERNET_BOOL, false);
      }
    });
    bg.BackgroundGeolocation.onProviderChange((bg.ProviderChangeEvent event) async
    {
      var lastActivityDataMap = PreferenceHelper.getObject(
          PreferenceHelper.LastActivity);
      if (lastActivityDataMap == null) {
        return;
      }
      lastActivityData = LastActivityData.fromJson(lastActivityDataMap);

      if (event.enabled == true) {
        PreferenceHelper.setBool(PreferenceHelper.GPS_BOOL, true);
      } else {
        PreferenceHelper.setBool(PreferenceHelper.GPS_BOOL, false);
      }
      if (lastActivityData == null) {
        return;
      }
      await bgOps.ManageGpsOperations(db,lastActivityData!);
    });

    bg.BackgroundGeolocation.onLocation((bg.Location location) async {
      var lastActivityDataMap = PreferenceHelper.getObject(PreferenceHelper.LastActivity);
      LastActivityData lastActivityData = LastActivityData.fromJson(lastActivityDataMap);
      LatLng currentLatLng = LatLng(location.coords.latitude, location.coords.longitude);
      PreferenceHelper.setDouble(PreferenceHelper.LAST_LAT, location.coords.latitude);
      PreferenceHelper.setDouble(PreferenceHelper.LAST_LONG, location.coords.longitude);


      print("OnLocationTime${DateTime.now().toString()}");
      print("OnLocationIsMoving${location.isMoving}");
      print("OnLocationActivity${location.activity.type.toString()}");

      if (location.isMoving == false && location.activity.type == "still" && location.activity.confidence == 100)
      {
        await setDynamicGeofence(currentLatLng.latitude, currentLatLng.longitude);
      }

      if(location.isMoving == true && (location.activity.type == "in_vehicle" || location.activity.type == "on_bicycle") && location.activity.confidence == 100)
      {
        print("ManageRouteHistoryStart");
        await bgOps.ManageRouteHistory(db,location);
        print("ManageRouteHistoryEnd");
      }

      //Timer inside this function

      if(isInternetAvailable == true){
        print("syncDataStart");
        await SyncData(lastActivityData);
        print("syncDataEnd");
      }


    });

    // bg.BackgroundGeolocation.onHeartbeat((bg.HeartbeatEvent heart) async {
    //   print('[heartRate] - ${heart.location}');
    //
    //   if(heart.location?.activity.type =="still"){
    //     await setDynamicGeofence(heart.location?.coords.latitude ?? 0, heart.location?.coords.longitude ?? 0);
    //   }
    //
    //   var lastActivityDataMap = PreferenceHelper.getObject(PreferenceHelper.LastActivity);
    //   lastActivityData = LastActivityData.fromJson(lastActivityDataMap);
    //   if(lastActivityData == null) {
    //      return;
    //   }
    //
    //   isInternetAvailable = PreferenceHelper.getBool(PreferenceHelper.INTERNET_BOOL);
    //
    //   if (isInternetAvailable && lastActivityData != null) {
    //     print("syncSqlData");
    //     await bgOps.syncSqlData(db,lastActivityData!);
    //     print("syncRouteData");
    //     await bgOps.syncRouteHistory(db,lastActivityData!);
    //   }
    // });
  }


  void listenGeofenceEvents() {
    bg.BackgroundGeolocation.onGeofence((bg.GeofenceEvent event) async {
      var lastActivityDataMap = PreferenceHelper.getObject(PreferenceHelper.LastActivity);
      LastActivityData lastActivityData = LastActivityData.fromJson(lastActivityDataMap);
      if (event.action == 'ENTER') {
        await handleGeofenceEnter(event,lastActivityData);
      } else if (event.action == 'EXIT') {
        await handleGeofenceExit(event,lastActivityData);
      }
    });
  }

  Future<void> setDynamicGeofence(double latitude, double longitude) async {
    // Optionally, remove previous geofences if needed
    bool isInGeoFence = await bg.BackgroundGeolocation.geofenceExists("100m-radius-geofence");
    if(isInGeoFence ==true){
      return;
    }
    await bg.BackgroundGeolocation.removeGeofence("100m-radius-geofence");
    // Add new geofence at the current location
    await bg.BackgroundGeolocation.addGeofence(bg.Geofence(
        identifier: "100m-radius-geofence",
        radius: 100.0,
        latitude: latitude,
        longitude: longitude,
        notifyOnEntry: true,
        notifyOnExit: true,
        notifyOnDwell: false,
        loiteringDelay: 60000,
    ));


  }

  Future<void> handleGeofenceEnter(bg.GeofenceEvent event,LastActivityData lastActivityData) async {
    print('Geofence ENTER: ${event.identifier} at ${event.location.coords
        .latitude}, ${event.location.coords.longitude}');
    LatLng currentLatLng = LatLng(event.location.coords.latitude, event.location.coords.longitude);
    await bgOps.waitingStartEvent(db,lastActivityData, currentLatLng);
  }

  Future<void> handleGeofenceExit(bg.GeofenceEvent event,LastActivityData lastActivityData) async {
    print('Geofence EXIT: ${event.identifier} at ${event.location.coords
        .latitude}, ${event.location.coords.longitude}');
    LatLng currentLatLng = LatLng(event.location.coords.latitude, event.location.coords.longitude);
    await bgOps.waitingEndEvent(db,lastActivityData, currentLatLng);
    await bg.BackgroundGeolocation.removeGeofence("100m-radius-geofence");
  }

  void start() async {
    bg.BackgroundGeolocation.start();
    bg.Location location = await bg.BackgroundGeolocation.getCurrentPosition();
    await setDynamicGeofence(location.coords.latitude,location.coords.longitude);
    var lastActivity = PreferenceHelper.getObject(PreferenceHelper.LastActivity);
    lastActivityData = LastActivityData.fromJson(lastActivity);
  }
  void stop() async{
    // final DatabaseService databaseService = DatabaseService();
    PreferenceHelper.remove(PreferenceHelper.LAST_LAT);
    PreferenceHelper.remove(PreferenceHelper.LAST_LONG);
    PreferenceHelper.remove(PreferenceHelper.LAST_INTERNET_OFF_TIME);
    PreferenceHelper.remove(PreferenceHelper.LAST_INTERNET_OFF_LAT);
    PreferenceHelper.remove(PreferenceHelper.LAST_INTERNET_OFF_LONG);
    await bgOps.stopServiceOperations(db);
    bg.BackgroundGeolocation.stop();
  }
  SyncData(LastActivityData lastActivityData) async
  {
    String? lastSyncTime = PreferenceHelper.getString("lastSyncTime");
    if (lastSyncTime == null) {
      PreferenceHelper.setString("lastSyncTime", AppUtils.getDate(
          date: DateTime.now().toString(), format: AppConstant.dateFormat));
    } else {
      bool isLastSyncLessThanTwoMinutes = bgOps
          .isTimeDiffLessThanAssignedTime(lastSyncTime, AppUtils.getDate(
          date: DateTime.now().toString(), format: AppConstant.dateFormat),
          1);
      if (isLastSyncLessThanTwoMinutes == false) {
        await bgOps.syncSqlData(db,lastActivityData);
        await bgOps.syncRouteHistory(db,lastActivityData);
        PreferenceHelper.setString("lastSyncTime", AppUtils.getDate(
            date: DateTime.now().toString(), format: AppConstant.dateFormat));
      }
    }
  }
}