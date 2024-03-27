import 'dart:convert';
import 'package:battery_plus/battery_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:geolocator/geolocator.dart';
import 'package:ontrek/core/services/api_constants.dart';
import 'package:ontrek/core/services/network_repository.dart';
import 'package:ontrek/core/storage/preference_helper.dart';

import 'package:ontrek/core/storage/sql_db_service.dart';
import 'package:ontrek/core/utils/App_utils.dart';
import 'package:ontrek/core/utils/app_constant.dart';
import 'package:ontrek/features/attendance/model/add_activity_model.dart';
import 'package:ontrek/main.dart';

class AttendanceProvider extends ChangeNotifier {
  bool _isFetching = false;
  bool _isLoading = false;
  bool _isUploading = false;
  bool _isAdding = false;

  bool get isFetching => _isFetching;

  bool get isLoading => _isLoading;

  bool get isUploading => _isUploading;

  bool get isAdding => _isAdding;

  CreateActivityModel? createActivityModel;
  final Battery battery = Battery();
  int batteryPercentage = 0;
  bool? isWaiting;
   DatabaseService? databaseService;



  loaderFnc(bool isLoading) {
    _isLoading = isLoading;
    notifyListeners();
  }

  fetchingFnc(bool isLoading) {
    _isFetching = isLoading;
    notifyListeners();
  }

  void navigatePushReplacementFnc(Widget screen) {
    navigatorKey.currentState!.pushReplacement(CupertinoPageRoute(
      builder: (context) => screen,
    ));
  }

  void navigatePushFnc(Widget screen) {
    navigatorKey.currentState!.push(CupertinoPageRoute(
      builder: (context) => screen,
    ));
  }

  Future<int?> getBatteryLevel() async {
    try {
      final batteryLevel = await battery.batteryLevel;

      batteryPercentage = batteryLevel;
      notifyListeners();
      return batteryPercentage;
    } catch (e) {
      rethrow;
    }
  }

  updateWaitingValue(){
    isWaiting =  PreferenceHelper.getBool(PreferenceHelper.ISWAITING);
    notifyListeners();
    return isWaiting;
  }

  Future<CreateActivityModel?> apiCallCreateActivity({
    bool? isFromCheckOut = false,
    String? picturePath,
    String? userId,
    double? latitude,
    double? longitude,
    String? totTrackingEventCode,
    String? activityDateTime,
    int? batteryLevel,
    String? customerName,
    String? visitDiscussion,
    String? companyName,
    String? customerPhoneNumber,
    String? visitTypeCode,
  }) async {
    loaderFnc(true);

    Map<String, dynamic> checkOutDataBody = {
      "customerName": customerName,
      "picturePath": "test.jpg",
      "visitDiscussion": visitDiscussion,
      "companyName": companyName,
      "customerPhoneNo": customerPhoneNumber,
      "totVisitTypeId": visitTypeCode,
    };
    Map<String, dynamic> body = {
      "userId": userId ?? "",
      "longitude": longitude,
      "lattitude": latitude,
      "totTrackingEventId": totTrackingEventCode,
      "activityDateTime": activityDateTime ??
          AppUtils.dateFormat(
              date: DateTime.now(), dateFormat: AppConstant.dateFormat),
      "batteryLevel": batteryLevel,
      "visitNoteRequestForm": isFromCheckOut ?? false ? checkOutDataBody : null
    };
    try {
      String endPoint = ApiConstants.createActivity;
      final response = await callPostMethod(endPoint, body);
      createActivityModel = CreateActivityModel.fromJson(json.decode(response));
      print("response : ${response}");
    } catch (e) {
      print("inCatch ${createActivityModel?.message}");
      print("inCatchE $e");
      bool isInternetAvailable = await AppUtils.checkInternetConnectivity();
      if (!isInternetAvailable) {
        createActivityModel = CreateActivityModel(
            message: "Internet is not available, please try again!");
      } else {
        createActivityModel =
            CreateActivityModel(message: "Something went wrong!");
      }
    }
    loaderFnc(false);
    return createActivityModel;
  }


  Future callCreateWaitingActivityApi(
      {String? userId,  Position? position}) async {
    // try {

    //
    //   Map<String, dynamic> body = {};
    //   double? lastLat = PreferenceHelper.getDouble(PreferenceHelper.LAST_LAT);
    //   double? lastLong = PreferenceHelper.getDouble(PreferenceHelper.LAST_LONG);
    //   String? waitingStartTime =
    //   PreferenceHelper.getString(PreferenceHelper.WAITING_START_TIME);
    //
    //   body = {
    //     "userId": userId,
    //     "lattitude": isWaitingStart ?? false ? lastLat : position?.latitude,
    //     "longitude": isWaitingStart ?? false ? lastLong : position?.longitude,
    //     "totTrackingEventId": isWaitingStart ?? false
    //         ? AppConstant.trackingWaitingStartEvent
    //         : AppConstant.trackingWaitingStopEvent,
    //     "activityDateTime": isWaitingStart ?? false
    //         ? AppUtils.getDate(
    //         date: waitingStartTime ?? "", format: AppConstant.dateFormat)
    //         : AppUtils.getDate(
    //         date: DateTime.now().toString(), format: AppConstant.dateFormat),
    //     "batteryLevel": 50,
    //   };
    //
    //   String endPoint = ApiConstants.createActivity;
    //   var response = await callPostMethod(endPoint, body);
    //   createActivityModel = CreateActivityModel?.fromJson(json.decode(response));
    //   if (createActivityModel?.isError == false &&
    //       createActivityModel?.isValidationFailed == false) {
    //       isWaitingStart ?? false
    //           ? await databaseService?.startWaiting()
    //           : await databaseService?.deleteWaiting();
    //       // ? PreferenceHelper.setBool(PreferenceHelper.ISWAITING, true)
    //       // : PreferenceHelper.setBool(PreferenceHelper.ISWAITING, false);
    //
    //       bool? isWaiting = await databaseService?.getWaitingStatus();
    //       print("getData$isWaiting");
    //
    //   }
    //   print("response at main : $response");
    // } catch (e) {
    //   rethrow;
    // }
  }
}
