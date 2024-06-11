import 'dart:convert';

import 'package:flutter_background_geolocation/flutter_background_geolocation.dart' as bg;
import 'package:geolocator/geolocator.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:ontrek/core/background_service_model/offline_route_model.dart';
import 'package:ontrek/core/storage/db_service.dart';
import 'package:ontrek/core/storage/preference_helper.dart';
import 'package:ontrek/core/utils/App_utils.dart';
import 'package:ontrek/core/utils/app_constant.dart';
import 'package:ontrek/features/attendance/model/get_last_activity_model.dart';
import 'package:permission_handler/permission_handler.dart';

import '../background_service_model/activity_model.dart';

class BackgroundServiceIos {


  Future<void> initialize() async {

   var  isInternetAvailable = await checkInternetConnectivity();
    var isGpsAvailable = await isGpsOn();


    // Configure the plugin.
    bg.BackgroundGeolocation.ready(bg.Config(
      desiredAccuracy: bg.Config.DESIRED_ACCURACY_HIGH,
      distanceFilter: 80,
      stopOnTerminate: false,
      startOnBoot: false,
      debug: true,
      logLevel: bg.Config.LOG_LEVEL_VERBOSE,
    )).then((bg.State state) {
      if (!state.enabled) {
        // Start the plugin.
        bg.BackgroundGeolocation.start();
      }
    });

    // Listen to location updates.
    bg.BackgroundGeolocation.onLocation((bg.Location location) {
      print('[location] - $location');
      // Handle the location update (e.g., save to database, send to server, etc.)
    });

    // Listen to motion change events.
    bg.BackgroundGeolocation.onMotionChange((bg.Location location) {
      print('[motionchange] - $location');
      if(isGpsAvailable){
        if(location.isMoving){
          ManageRouteHistory(location);
          PreferenceHelper.setString(PreferenceHelper.WAITING_START_TIME, AppUtils.getDate(date: DateTime.now().toString(), format: AppConstant.dateFormat));
          PreferenceHelper.setDouble(PreferenceHelper.LAST_LAT, location.coords.latitude);
          PreferenceHelper.setDouble(PreferenceHelper.LAST_LONG,  location.coords.longitude);
        }else{
          ManageWaitingOperation(location);
        }
      }
    });

    // Listen to activity change events.
    bg.BackgroundGeolocation.onActivityChange((bg.ActivityChangeEvent event) {
      print('[activitychange] - ${event.activity}');
    });



    // Listen to errors.
    // bg.BackgroundGeolocation.onError((bg.Error error) {
    //   print('[error] - $error');
    // });
  }

  void start() {
    bg.BackgroundGeolocation.start();
  }

  void stop() {
    bg.BackgroundGeolocation.stop();
  }


  ManageRouteHistory(bg.Location location) async {
    // if (isGpsAvailable && !isInRadius) {

      final DatabaseService databaseService = DatabaseService();

      // List<String>? offlineData =
      //     PreferenceHelper.getStringList('offline_route_data');

      OfflineRouteModel dataPoint = OfflineRouteModel(
        latitude: location.coords.latitude ,
        longitude: location.coords.longitude ,
        offlineTime: AppUtils.getDate(
            date: DateTime.now().toString(), format: AppConstant.dateFormat),
      );

      if (dataPoint.latitude != 0.0 && dataPoint.longitude != 0.0) {
        await databaseService.insertRoute(dataPoint);
      }
    // }
  }

  ManageWaitingOperation(bg.Location location) async {

    List<Activity> listOfAllActivity = geAllActivitiesFromPrefOffLine();

    var lastActivityData  =  PreferenceHelper.getObject("last_activity");

    var  lastWaitingLatitude = PreferenceHelper.getDouble(PreferenceHelper.LAST_LAT);
    var  lastWaitingLongitude = PreferenceHelper.getDouble(PreferenceHelper.LAST_LONG);
    var  waitingStartTime = PreferenceHelper.getString(PreferenceHelper.WAITING_START_TIME);
    //send waiting start data local storage
    var waitingStartData = listOfAllActivity
        .where((element) =>
    element.eventCode == AppConstant.trackingWaitingStartEvent &&
        element.isEventCompleted == false)
        .firstOrNull;
    var waitingStopData = listOfAllActivity
        .where((element) =>
    element.eventCode == AppConstant.trackingWaitingStopEvent &&
        element.parentId == waitingStartData?.pkId)
        .firstOrNull;

    var activity = Activity(
        pkId: listOfAllActivity.length + 1,
        sessionId: lastActivityData?.sessionId ?? "",
        latitude: location.coords.latitude,
        longitude:  location.coords.longitude,
        isSync: false,
        isEventCompleted: false);

      //Waiting Start Event
      if (!location.isMoving) {
        // print("waitingStartTime$waitingStartTime");
        //Waiting Start Event

        if (DateTime
            .now()
            .difference(DateTime.parse(waitingStartTime ?? ""))
            .inMinutes >=
            (5)) {
          if (waitingStartData == null) {
            //add waiting start  event
            activity.eventCode = AppConstant.trackingWaitingStartEvent;
            activity.isEventCompleted = false;
            activity.parentId = null;
            activity.isSync = false;
            activity.latitude = lastWaitingLatitude ?? 0;
            activity.longitude = lastWaitingLongitude ?? 0;
            activity.activityDate = AppUtils.getDate(
                date: waitingStartTime.toString(),
                format: AppConstant.dateFormat);
            if (activity.latitude != 0 &&
                activity.longitude != 0 &&
                activity.latitude != null &&
                activity.longitude != null) {
              listOfAllActivity.add(activity);
              setAllActivityListToPref(listOfAllActivity);
            }
          }
        }
      }else{
        //Waiting End Event
        if (waitingStartData != null) {
          var IsWaitingInRadius = isWithinRadius(
              prevLat: waitingStartData.latitude,
              prevLong: waitingStartData.longitude,
              currentLat: location.coords.latitude,
              currentLong: location.coords.longitude,
              radiusMtr: 80);

          // Below code is for testing waiting end event in debug mode do not remove
          // var waitingTestStartTime = DateTime.parse(waitingStartData.activityDate!);
          // if (DateTime.now().difference(waitingTestStartTime).inMinutes > 2) {
          //   IsWaitingInRadius = false;
          // }

          if (!IsWaitingInRadius) {
            if (waitingStartData != null && waitingStopData == null) {
              waitingStartData.isEventCompleted = true;

              activity.parentId = waitingStartData.pkId;
              activity.eventCode = AppConstant.trackingWaitingStopEvent;
              activity.isEventCompleted = true;
              activity.isSync = false;
              activity.activityDate = AppUtils.getDateTimeNow();

              listOfAllActivity.add(activity);
              setAllActivityListToPref(listOfAllActivity);
              PreferenceHelper.setString(PreferenceHelper.WAITING_START_TIME, AppUtils.getDate(date: DateTime.now().toString(), format: AppConstant.dateFormat));
              PreferenceHelper.setDouble(PreferenceHelper.LAST_LAT,  location.coords.latitude);
              PreferenceHelper.setDouble(PreferenceHelper.LAST_LONG, location.coords.longitude);
            }
          }
        }
      }
  }


  void setAllActivityListToPref(List<Activity> lstActivities) {
    try {
      List<String> activitiesJsonList =
      lstActivities.map((activity) => jsonEncode(activity.toJson())).toList();

      PreferenceHelper.setStringList('offline_activities', activitiesJsonList);
    } catch (e) {
      print("setGpsActivityListToPref error: $e");
    }
  }

  Future<bool> checkInternetConnectivity() async {
    try {
      bool isIntAvailable = false;
      isIntAvailable = await InternetConnectionChecker().hasConnection;
      return isIntAvailable;
    } catch (e) {
      print("isInternetOn: $e");
      return false; // Return false in case of an error
    }
  }

  Future<bool> isGpsOn() async {
    try {
      final locationAlwaysStatus = await Permission.locationAlways.serviceStatus;
      final locationStatus = await Permission.location.serviceStatus;

      bool isGPSEnabled =
          locationAlwaysStatus.isEnabled && locationStatus.isEnabled;

      return isGPSEnabled;
    } catch (e) {
      print("isGpsOn: $e");
      return false; // Return false in case of an error
    }
  }

  isWithinRadius(
      {double? currentLat,
        double? currentLong,
        double? prevLat,
        double? prevLong,
        int? radiusMtr}) {
    try {
      if (prevLat == null || prevLong == null || prevLat == 0 || prevLong == 0) {
        return false;
      }

      if (currentLat == null ||
          currentLong == null ||
          currentLong == 0 ||
          currentLong == 0) {
        return false;
      }

      double distance = 81;
      distance = Geolocator.distanceBetween(
          prevLat ?? 0, prevLong ?? 0, currentLat ?? 0, currentLong ?? 0);
      if ((distance) < (radiusMtr ?? 50)) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print("isWithinRadius");
    }
  }


  setLastActivityData(/*LastActivityData? lastActivity*/) async {
    var lastActivityData;
    Map<String, dynamic> lastActivityMap =
    PreferenceHelper.getObject("last_activity");
    if (lastActivityMap != null) {
       lastActivityData = LastActivityData.fromJson(lastActivityMap);
    } else {
      lastActivityData = null;
    }
    if (lastActivityData != null) {
      String? sessionId = lastActivityData?.sessionId;
      PreferenceHelper.setObject<LastActivityData>(
          "last_activity", lastActivityData);

      // if (sessionId != null) {
      //   if (prevLatitude == null) {
      //     prevLatitude = lastActivityData?.lastActivityLat;
      //   }
      //
      //   if (prevLongitude == null) {
      //     prevLongitude = lastActivityData?.lastActivityLong;
      //   }
      //
      //   if (currentLatitude == null) {
      //     currentLatitude = lastActivityData?.lastActivityLat;
      //   }
      //
      //   if (currentLongitude == null) {
      //     currentLongitude = lastActivityData?.lastActivityLong;
      //   }
      //   if (isGpsAvailable) {
      //     prevLatitude = currentLatitude;
      //     prevLongitude = currentLongitude;
      //     Position position1 = await Geolocator.getCurrentPosition(
      //         desiredAccuracy: LocationAccuracy.high);
      //     currentLatitude = position1.latitude;
      //     currentLongitude = position1.longitude;
      //     lastActivityData?.lastLocationLat =
      //         currentLatitude ?? (prevLatitude ?? 0);
      //     lastActivityData?.lastLocationLong =
      //         currentLongitude ?? (prevLongitude ?? 0);
      //
      //
      //   }
      // }
    }
  }

  // void setAllActivityListToPref(List<Activity> lstActivities) {
  //   try {
  //     List<String> activitiesJsonList =
  //     lstActivities.map((activity) => jsonEncode(activity.toJson())).toList();
  //
  //     PreferenceHelper.setStringList('offline_activities', activitiesJsonList);
  //   } catch (e) {
  //     print("setGpsActivityListToPref error: $e");
  //   }
  // }

  geAllActivitiesFromPrefOffLine() {
    try {
      var offLineActivitiesStr =
          PreferenceHelper.getStringList("offline_activities") ?? [];

      List<Activity> offLinActivities = offLineActivitiesStr.map((data) {
        Map<String, dynamic> jsonData = jsonDecode(data);
        return Activity.fromJson(jsonData);
      }).toList();
      return offLinActivities;
    } catch (e) {
      print("error : geAllGpsActivitiesFromPrefOffLine");
    }
  }

}