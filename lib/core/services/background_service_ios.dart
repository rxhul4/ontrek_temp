import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter_background_geolocation/flutter_background_geolocation.dart' as bg;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ontrek/core/background_service_model/app_off_time_model.dart';
import 'package:ontrek/core/services/background_service_operations.dart';
import 'package:ontrek/core/services/local_notification.dart';
import 'package:ontrek/core/storage/db_service.dart';
import 'package:ontrek/core/storage/preference_helper.dart';
import 'package:ontrek/core/utils/App_utils.dart';
import 'package:ontrek/core/utils/app_constant.dart';
import 'package:ontrek/features/attendance/model/get_last_activity_model.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sqflite/sqflite.dart';

bool isInternetAvailable = false;
bool isGpsAvailable = false;
LastActivityData? lastActivityData;
String? serviceStartTime;
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
        desiredAccuracy: bg.Config.DESIRED_ACCURACY_HIGH,
        heartbeatInterval: PreferenceHelper.getInt(PreferenceHelper.LIVE_LOCATION_INTERVAL),// Minimal accuracy to avoid frequent updates
        distanceFilter: 50, // Only get updates when the user moves more than 100 meters
        stopOnTerminate: false, // Keep tracking even if the app is terminated
        startOnBoot: false, // Don't start on boot
        foregroundService: true, // Run as a foreground service
        debug: false, // Enable debugging
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
      serviceStartTime = AppUtils.getDate(
          date: DateTime.now().toString(), format: AppConstant.dateFormat);
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

    bg.BackgroundGeolocation.onMotionChange((bg.Location location)async{
      LatLng currentLatLng = LatLng(location.coords.latitude, location.coords.longitude);
      bool? isWaitingAllowed = PreferenceHelper.getBool(PreferenceHelper.ALLOW_WAITING);
      if(isWaitingAllowed == true){
        if (location.isMoving == false  /*&& location.activity.type == "still" && location.activity.confidence == 100*/)
        {
          await setDynamicGeofence(currentLatLng.latitude, currentLatLng.longitude,"waitingGeoFence",100.0);
        }
      }

    });

    bg.BackgroundGeolocation.onLocation((bg.Location location) async {
      var lastActivityDataMap = PreferenceHelper.getObject(PreferenceHelper.LastActivity);
      LastActivityData lastActivityData = LastActivityData.fromJson(lastActivityDataMap);
      PreferenceHelper.setDouble(PreferenceHelper.LAST_LAT, location.coords.latitude);
      PreferenceHelper.setDouble(PreferenceHelper.LAST_LONG, location.coords.longitude);
      bool isCheckIn = PreferenceHelper.getBool(PreferenceHelper.checkIn);
      isInternetAvailable = PreferenceHelper.getBool(PreferenceHelper.INTERNET_BOOL);
      bool isAlwaysOnLocation = await Permission.locationAlways.isGranted;

      // bool? isCheckInGeoFenceExit = PreferenceHelper.getBool("isCheckInGeoFenceExit");
      // bool? isCheckOutReminder = PreferenceHelper.getBool(PreferenceHelper.CHECKOUT_REMINDER);
      // int? checkOutReminderMtr = PreferenceHelper.getInt(PreferenceHelper.CHECKOUT_REMINDER_METER);

      print("OnLocationTime${DateTime.now().toString()}");
      print("OnLocationIsMoving${location.isMoving}");
      print("OnLocationActivity${location.activity.type.toString()}");


      if(location.isMoving == true && (location.activity.type == "in_vehicle" || location.activity.type == "on_bicycle") && location.activity.confidence == 100)
      {
        print("ManageRouteHistoryStart");
        await bgOps.ManageRouteHistory(db,location);
        print("ManageRouteHistoryEnd");

        if (serviceStartTime != null) {
          await dbServiece.insertOrUpdateAppOffTime(
              db,
              AppOffTime(
                startTime: serviceStartTime ?? "",
                stopTime: AppUtils.dateFormat(
                    date: DateTime.now(),
                    dateFormat: AppConstant.dateFormat),
              ));
        }
      }

      print("syncDataStart");
      await SyncData(lastActivityData);
      await bgOps.sendLastStatus(lastActivityData!,isAlwaysOnLocation,isGpsAvailable);
      print("syncDataEnd");

      if(isCheckIn == true ){
        bgOps.manualWaitingEndEvent(db, location);
        await bg.BackgroundGeolocation.removeGeofence("waitingGeoFence");
        // if(isCheckOutReminder == true){
        //   if(isCheckInGeoFenceExit == false || isCheckInGeoFenceExit == null ){
        //     await setDynamicGeofence(location.coords.latitude, location.coords.longitude, "checkInGeoFence",checkOutReminderMtr?.toDouble() ?? 100.0);
        //   }
        // }

      }
    });

    bg.BackgroundGeolocation.onHeartbeat((bg.HeartbeatEvent heart) async {

      print('[heartRate] - ${heart.location}');

      var lastActivityDataMap = PreferenceHelper.getObject(PreferenceHelper.LastActivity);
      if(lastActivityDataMap == null || lastActivityDataMap == {}){
        return;
      }
      lastActivityData = LastActivityData.fromJson(lastActivityDataMap);
      isInternetAvailable = PreferenceHelper.getBool(PreferenceHelper.INTERNET_BOOL);
      bool isCheckIn = PreferenceHelper.getBool(PreferenceHelper.checkIn);
      bool isGpsAvailable = PreferenceHelper.getBool(PreferenceHelper.GPS_BOOL);
      bool? isWaitingAllowed = PreferenceHelper.getBool(PreferenceHelper.ALLOW_WAITING);
      bool isAlwaysOnLocation = await Permission.locationAlways.isGranted;
      // bool? isCheckInGeoFenceExit = PreferenceHelper.getBool("isCheckInGeoFenceExit");
      // bool? isCheckOutReminder = PreferenceHelper.getBool(PreferenceHelper.CHECKOUT_REMINDER);
      // int? checkOutReminderMtr = PreferenceHelper.getInt(PreferenceHelper.CHECKOUT_REMINDER_METER);
      if(lastActivityData == null) {
        return;
      }

      if (serviceStartTime != null) {
        await dbServiece.insertOrUpdateAppOffTime(
            db,
            AppOffTime(
              startTime: serviceStartTime ?? "",
              stopTime: AppUtils.dateFormat(
                  date: DateTime.now(),
                  dateFormat: AppConstant.dateFormat),
            ));
      }

      if (isInternetAvailable && lastActivityData != null) {
        print("syncSqlDataStart");
        await bgOps.syncSqlData(db,lastActivityData!);
        await bgOps.sendLastStatus(lastActivityData!,isAlwaysOnLocation,isGpsAvailable);
        print("syncSqlDataEnd");
        // await bgOps.syncRouteHistory(db,lastActivityData!);
      }

      if(isWaitingAllowed == true){
        if(heart.location?.activity.type =="still" && !isCheckIn){
          await setDynamicGeofence(heart.location?.coords.latitude ?? 0, heart.location?.coords.longitude ?? 0,"waitingGeoFence",100.0);
        }
      }


      if(isCheckIn == false)
      {
        // PreferenceHelper.setBool("isCheckInGeoFenceExit", false);
        // await bg.BackgroundGeolocation.removeGeofence("checkInGeoFence");
      }else{
        bgOps.manualWaitingEndEvent(db, heart.location);
        await bg.BackgroundGeolocation.removeGeofence("waitingGeoFence");
        // if(isCheckOutReminder == true){
        //   if(isCheckInGeoFenceExit == false || isCheckInGeoFenceExit == null ){
        //     await setDynamicGeofence( heart.location?.coords.latitude ?? 0,  heart.location?.coords.longitude ?? 0, "checkInGeoFence",checkOutReminderMtr?.toDouble() ?? 100.0);
        //   }
        // }
      }

      // if(isCheckIn == true && isCheckInGeoFenceExit){
      //   NotificationService  notificationService = NotificationService();
      //   notificationService.showNotification(id: 3, title: "Check Out Reminder", body: "Please perform check out as soon as possible.");
      // }

    });
  }


  void listenGeofenceEvents() {
    bg.BackgroundGeolocation.onGeofence((bg.GeofenceEvent event) async {
      try {
        var lastActivityDataMap = PreferenceHelper.getObject(PreferenceHelper.LastActivity);
        LastActivityData lastActivityData = LastActivityData.fromJson(lastActivityDataMap);
        bool? isCheckIn = PreferenceHelper.getBool(PreferenceHelper.checkIn);
        print("Geofence event: ${event.action} for identifier: ${event.identifier}");
        if (event.action == 'ENTER') {
          if(isCheckIn == false || isCheckIn == null) {
            print("Handling geofence enter");
            await handleGeofenceEnter(event, lastActivityData);
          }
        } else if (event.action == 'EXIT') {
          // if(isCheckIn == true){
          //   PreferenceHelper.setBool("isCheckInGeoFenceExit", true);
          // }
          print("Handling geofence exit");
          await handleGeofenceExit(event, lastActivityData, event.identifier);
        }
      } catch (e) {
        print("Error handling geofence event: $e");
      }
    });
  }

  Future<void> setDynamicGeofence(double latitude, double longitude, String geofenceId, double? geoFenceMeter) async {
    try {
      bool isInGeoFence = await bg.BackgroundGeolocation.geofenceExists(geofenceId);
      print("Geofence exists for $geofenceId: $isInGeoFence");

      if(isInGeoFence == true){
        return;
      }

      await bg.BackgroundGeolocation.removeGeofence(geofenceId);
      print("Removed existing geofence for $geofenceId");

      await bg.BackgroundGeolocation.addGeofence(bg.Geofence(
        identifier: geofenceId,
        radius: geoFenceMeter ?? 100.0,
        latitude: latitude,
        longitude: longitude,
        notifyOnEntry: true,
        notifyOnExit: true,
        notifyOnDwell: false,
        loiteringDelay: 60000,

      ));
      print("Added new geofence for $geofenceId at ($latitude, $longitude)");
    } catch (e) {
      print("Error setting dynamic geofence: $e");
    }
  }

  Future<void> handleGeofenceEnter(bg.GeofenceEvent event, LastActivityData lastActivityData) async {
    try {
      print('Geofence ENTER: ${event.identifier} at ${event.location.coords.latitude}, ${event.location.coords.longitude}');
      LatLng currentLatLng = LatLng(event.location.coords.latitude, event.location.coords.longitude);
      await bgOps.waitingStartEvent(db, lastActivityData, currentLatLng);
    } catch (e) {
      print("Error handling geofence enter: $e");
    }
  }

  Future<void> handleGeofenceExit(bg.GeofenceEvent event, LastActivityData lastActivityData, String geoFenceId) async {
    try {
      print('Geofence EXIT: ${event.identifier} at ${event.location.coords.latitude}, ${event.location.coords.longitude}');
      LatLng currentLatLng = LatLng(event.location.coords.latitude, event.location.coords.longitude);
      await bgOps.waitingEndEvent(db, lastActivityData, currentLatLng);
      await bg.BackgroundGeolocation.removeGeofence(geoFenceId);
      print("Removed geofence for $geoFenceId after exit");
    } catch (e) {
      print("Error handling geofence exit: $e");
    }
  }

  void start() async {
    bg.BackgroundGeolocation.start();
    var lastActivity = PreferenceHelper.getObject(PreferenceHelper.LastActivity);
    lastActivityData = LastActivityData.fromJson(lastActivity);
  }
   stop() async{
    await bg.BackgroundGeolocation.removeGeofence("waitingGeoFence");
    await bg.BackgroundGeolocation.removeGeofence("checkInGeoFence");
    await bgOps.stopServiceOperations(db);
    PreferenceHelper.remove(PreferenceHelper.LAST_LAT);
    PreferenceHelper.remove(PreferenceHelper.LAST_LONG);
    PreferenceHelper.remove("isCheckInGeoFenceExit");
    PreferenceHelper.remove("lastSyncTime");
    PreferenceHelper.setBool(PreferenceHelper.checkIn, false);
    PreferenceHelper.remove(PreferenceHelper.LastActivity);
    PreferenceHelper.remove(PreferenceHelper.LAST_INTERNET_OFF_TIME);
    PreferenceHelper.remove(PreferenceHelper.LAST_INTERNET_OFF_LAT);
    PreferenceHelper.remove(PreferenceHelper.LAST_INTERNET_OFF_LONG);

    await bg.BackgroundGeolocation.stop();
  }
  SyncData(LastActivityData lastActivityData) async
  {
    int liveLocationIntervalTime = PreferenceHelper.getInt(PreferenceHelper.LIVE_LOCATION_INTERVAL) ?? 0;
    if(liveLocationIntervalTime == 0){
      return;
    }
    String? lastSyncTime = PreferenceHelper.getString("lastSyncTime");
    bool isCheckIn = PreferenceHelper.getBool(PreferenceHelper.checkIn);
    isInternetAvailable = PreferenceHelper.getBool(PreferenceHelper.INTERNET_BOOL);
    bool? isCheckInGeoFenceExit = PreferenceHelper.getBool("isCheckInGeoFenceExit");
    if (lastSyncTime == null) {
      PreferenceHelper.setString("lastSyncTime", AppUtils.getDate(
          date: DateTime.now().toString(), format: AppConstant.dateFormat));
    } else {
      if(DateTime.now().difference(DateTime.parse(lastSyncTime)).inSeconds > liveLocationIntervalTime){
        if(isInternetAvailable == true){
          await bgOps.syncSqlData(db,lastActivityData);
          await bgOps.syncRouteHistory(db,lastActivityData);
        }

        if(isCheckIn == true && isCheckInGeoFenceExit){
          NotificationService  notificationService = NotificationService();
          notificationService.showNotification(id: 3, title: "Check Out Reminder", body: "Please Perform CheckOut.");
        }

        PreferenceHelper.setString("lastSyncTime", AppUtils.getDate(date: DateTime.now().toString(), format: AppConstant.dateFormat));
      }

    }
  }
}