import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:local_auth/local_auth.dart';
import 'package:ontrek/core/background_service_model/bulk_activity_model.dart';
import 'package:ontrek/core/common_widgets/textfield_widget.dart';
import 'package:ontrek/core/services/api_constants.dart';
import 'package:ontrek/core/services/background_service_ios.dart';
import 'package:ontrek/core/services/network_repository.dart';
import 'package:ontrek/core/storage/preference_helper.dart';

import 'package:ontrek/core/utils/App_utils.dart';
import 'package:ontrek/core/utils/app_constant.dart';
import 'package:ontrek/features/attendance/model/add_activity_model.dart';
import 'package:ontrek/features/attendance/model/dayend_manual_request_model.dart';
import 'package:ontrek/features/attendance/model/get_check_panding_dayend.dart';
import 'package:ontrek/features/attendance/model/get_last_activity_model.dart';
import 'package:ontrek/features/attendance/model/get_last_activity_model.dart';
import 'package:ontrek/features/attendance/model/get_last_activity_model.dart';
import 'package:ontrek/features/attendance/screen/pending_dayend_screen.dart';
import 'package:ontrek/features/dashboard/screens/dashboard_screen.dart';
import 'package:ontrek/main.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

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
  GetLastActivityModel? getLastActivityModel;
  GetLastPendingDayEnd? getLastPendingDayEnd;
  DayEndManualRequestModel? dayEndManualRequestModel;
  int? battery;
  PanelController panelController = PanelController();
  ValueNotifier<bool> isDayStart = ValueNotifier(false);
  ValueNotifier<bool> isCheckIn = ValueNotifier(false);
  ValueNotifier<bool> isDayEnd = ValueNotifier(false);
  ValueNotifier<bool> isWaiting = ValueNotifier(false);
  bool? isAllowCheckInCheckOut;
  LocalAuthentication localAuthentication = LocalAuthentication();
  bool isBiometricAvailable = false;
  AnimationController? controller;
  FlutterBackgroundService service = FlutterBackgroundService();
  // BackgroundServiceIos iosService = BackgroundServiceIos();
  bool? isInternetAvailable;
  TextEditingController dateController = TextEditingController();
  TextEditingController timeController = TextEditingController();
  TextEditingController reasonController = TextEditingController();
  TextEditingController dayStartTimeController = TextEditingController();
  bool? isLocationRestricted;
  double? restrictedLocationLat;
  double? restrictedLocationLong;
  int? restrictedLocationMeter;
  String? userId;
  String? orgName;
  String? userName;
  bool? isAllowFgAuth;
  Position? position;

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

  void toggleButtons() {
    isDayEnd.value = !isDayEnd.value;
    notifyListeners();
  }

  void navigatePushFnc(Widget screen) {
    navigatorKey.currentState!.push(CupertinoPageRoute(
      builder: (context) => screen,
    ));
  }

  // Future<bool?> getWaitingValue() async {
  //   isWaiting.value =
  //       await PreferenceHelper.getBool(PreferenceHelper.isWaiting);
  //   notifyListeners();
  //   return isWaiting.value;
  // }

  batteryPercentage() async {
    battery = await AppUtils.getBatteryLevel();
  }

  checkBiometricAvailable() async {
    isBiometricAvailable = await localAuthentication.canCheckBiometrics;
  }

  doLocalVerification(
      {required Function() afterSuccessfulVerificationFnc}) async {
    if (isBiometricAvailable) {
      bool isAuthenticated = await localAuthentication.authenticate(
          localizedReason: "Authenticate using Biometrics",
          options: const AuthenticationOptions(
              stickyAuth: true, useErrorDialogs: true));
      if (isAuthenticated) {
        afterSuccessfulVerificationFnc();
      } else {
        AppUtils.showDialogBoxWithOneButton(
            context: navigatorKey.currentContext,
            text: "Authentication Fail! Please Try Again");
      }
    } else {
      AppUtils.showDialogBoxWithOneButton(
          context: navigatorKey.currentContext,
          text: "Biometric Auth is not available on this device");
    }
  }

  Future<Position?> getCurrentLocation() async {
    bool isLocationServiceAvailable =
        await AppUtils.checkLocationServiceAvailability();
    if (isLocationServiceAvailable) {
      try {
        position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.low);
      } catch (e) {
        AppUtils.showDialogBoxWithOneButton(
            context: navigatorKey.currentContext,
            text: "Please Enable Your Location Service");
      }
    }
    return position;
  }
  Future<CreateActivityModel?> apiCallCreateActivity({
    bool? isFromCheckOut = false,
    String? checkOutSessionId,
    String? picturePath,
    String? totTrackingEventCode,
    String? activityDateTime,
    String? customerName,
    String? visitDiscussion,
    Position? positionData,
    String? companyName,
    String? customerPhoneNumber,
    String? visitTypeCode,
  }) async {
    loaderFnc(true);
    // print("sessionIdAtCreateActivity$sessionId");
    String? userid = PreferenceHelper.getString(PreferenceHelper.USER_ID);
    String? sessionId = PreferenceHelper.getString(PreferenceHelper.SESSION_ID);
    position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best);
    Map<String, dynamic> checkOutDataBody = {
      "customerName": customerName,
      "picturePath": picturePath,
      "visitDiscussion": visitDiscussion,
      "companyName": companyName,
      "customerPhoneNo": customerPhoneNumber,
      "totVisitTypeId": visitTypeCode,
    };

    Map<String, dynamic> body = {
      "createActivity": {
        "userId": userid ?? "",
        "longitude": isFromCheckOut == true
            ? positionData?.longitude ?? 0
            : position?.longitude,
        "lattitude": isFromCheckOut == true
            ? positionData?.latitude ?? 0
            : position?.latitude,
        "sessionId": sessionId == null || sessionId == "" ? null :sessionId,
        "totTrackingEventId": totTrackingEventCode,
        "activityDateTime": activityDateTime ??
            AppUtils.dateFormat(
                date: DateTime.now(), dateFormat: AppConstant.dateFormat),
        "batteryLevel": battery,
        "visitNoteRequestForm":
            isFromCheckOut ?? false ? checkOutDataBody : null
      }
    };
    try {
      String endPoint = ApiConstants.createActivity;
      final response = await callPostMethod(endPoint, body);
      createActivityModel = CreateActivityModel.fromJson(json.decode(response));
      print("response : ${response}");

    } catch (e) {
      if (isInternetAvailable == false) {
        AppUtils.showDialogBoxWithOneButton(
            titleText: "Internet Off Alert",
            text:
                "Internet is not available. Please Enable Mobile data or wifi.",
            context: navigatorKey.currentState!.context);
      }
    }
    loaderFnc(false);
    return createActivityModel;
  }

    callGetLastActivity({bool? isDayEnd,bool? DayStart}) async {
    loaderFnc(true);
    String? userId = PreferenceHelper.getString(PreferenceHelper.USER_ID);
    Map<String, dynamic> body = { "userId": userId,"currentDate": AppUtils.dateFormat(date: DateTime.now(), dateFormat: AppConstant.dateFormat)};

    try
    {
      String endPoint = ApiConstants.getLastActivity;
      final response = await callPostMethod(endPoint, body);

      getLastActivityModel = GetLastActivityModel.fromJson(json.decode(response));

      if (getLastActivityModel?.isError == false && getLastActivityModel?.isValidationFailed == false)
      {

        EventUpdateProcess(getLastActivityModel?.data);

        String? sessionStartDateStr = AppUtils.getDate(date: getLastActivityModel?.data?.sessionStartDateTime ?? "", format: "dd-MM-yyyy");
        DateTime sessionStartDate = DateFormat("dd-MM-yyyy").parse(sessionStartDateStr);
        DateTime today = DateTime.now();
        DateTime todayWithoutTime = DateTime(today.year, today.month, today.day);

        if (sessionStartDate.isBefore(todayWithoutTime)) {
            if (getLastActivityModel?.data?.alreadyRequested == false && getLastActivityModel?.data?.isSessionActive == true) {
              dateController.text = sessionStartDateStr;
              dayStartTimeController.text = AppUtils.getDate(date: getLastActivityModel?.data?.sessionStartDateTime ?? "",format: "hh:mm a");
              navigatePushFnc(PendingDayEndScreen(sessionId: getLastActivityModel?.data?.sessionId,sessionStartDate:getLastActivityModel?.data?.sessionStartDateTime ?? "",));
            }
        }

      } else {
        if (getLastActivityModel?.isError == true) {
          AppUtils.showDialogBoxWithOneButton(
              titleText: "Error",
              context: navigatorKey.currentState!.context,
              text: "Something went wrong, Please try again later!");
        }
      }
    } catch (e) {
      print("inCatch ${getLastActivityModel?.message}");
      print("inCatchE $e");
      bool isInternetAvailable = await AppUtils.checkInternetConnectivity();
      if (isInternetAvailable == false) {
        AppUtils.showDialogBoxWithOneButton(
            titleText: "Internet Off Alert",
            text:
            "Internet is not available. Please Enable Mobile data or wifi.",
            context: navigatorKey.currentState!.context);
      }
    }
    loaderFnc(false);
    return getLastActivityModel;
  }

  Future<DayEndManualRequestModel?> apiCallDayEndManualRequest(
      {String? sessionId, String? sessionEndDate}) async {
    String? userId = PreferenceHelper.getString(PreferenceHelper.USER_ID);
    String? orgId = PreferenceHelper.getString(PreferenceHelper.ORG_ID);

    loaderFnc(true);
    Map<String, dynamic> body = {
      "orgId": orgId,
      "userId": userId,
      "sessionId": sessionId,
      "sessionEndDateTime": sessionEndDate,
      "comment": reasonController.text
    };
    try {
      String endPoint = ApiConstants.dayEndManualRequest;
      final response = await callPostMethod(endPoint, body);
      dayEndManualRequestModel =
          DayEndManualRequestModel.fromJson(json.decode(response));
      print("response : ${response}");
      if (dayEndManualRequestModel?.data == true) {
        navigatePushReplacementFnc(DashBoard());
      }
    } catch (e) {
      AppUtils.showDialogBoxWithOneButton(
          text: AppConstant.errorText,
          context: navigatorKey.currentState!.context);
      print("inCatch ${dayEndManualRequestModel?.message}");
      print("inCatchE $e");
      isInternetAvailable = await AppUtils.checkInternetConnectivity();
      if (isInternetAvailable == false) {
        AppUtils.showDialogBoxWithOneButton(
            titleText: "Internet Off Alert",
            text:
                "Internet is not available. Please Enable Mobile data or wifi.",
            context: navigatorKey.currentState!.context);
      } else {
        AppUtils.showDialogBoxWithOneButton(
            titleText: "Error",
            text: "Something went wrong!",
            context: navigatorKey.currentState!.context);
      }
    }
    loaderFnc(false);
    return dayEndManualRequestModel;
  }

  checkValidationOfRequestNote(
      {String? sessionId, String? sessionEndDate}) async {
    if (timeController.text.isEmpty) {
      AppUtils.showSnackBarWithColor(
          message: "Please select day end Time",
          context: navigatorKey.currentState!.context,
          giveColor: AppConstant.appPrimaryColor);
    } else if (reasonController.text.isEmpty) {
      AppUtils.showSnackBarWithColor(
          message: "Please Enter reason",
          context: navigatorKey.currentState!.context,
          giveColor: AppConstant.appPrimaryColor);
    } else {
      await apiCallDayEndManualRequest(
          sessionId: sessionId, sessionEndDate: sessionEndDate);
    }
  }

  clearController() {
    timeController.clear();
    reasonController.clear();
  }

  EventUpdateProcess(LastActivityData? lastActivityData) async
  {
    await SetUIButtons(lastActivityData);
    await SetPrefHelpeAndServiceManageEvents(lastActivityData);
  }

  SetUIButtons(LastActivityData? lastActivityData) async
  {
    if(lastActivityData == null)
    {
      isDayStart.value=false;
      return;
    }

    String? totEventCode = lastActivityData.trackingEventId;
    String? sessionStartDateStr = AppUtils.getDate(date: lastActivityData.sessionStartDateTime ?? "", format: "dd-MM-yyyy");
    DateTime sessionStartDate = DateFormat("dd-MM-yyyy").parse(sessionStartDateStr);
    DateTime today = DateTime.now();
    DateTime todayWithoutTime = DateTime(today.year, today.month, today.day);

    if(lastActivityData?.isSessionActive==false || sessionStartDate.isBefore(todayWithoutTime))
    {
      isDayStart.value=false;
      return;
    }

    switch (totEventCode)
    {
      case AppConstant.dayStartEvent:
        isDayStart.value = true;
        break;
      case AppConstant.checkInEvent:
        isDayStart.value = true;
        isCheckIn.value = true;
        PreferenceHelper.setBool(PreferenceHelper.checkIn, true);
        break;
      case AppConstant.checkOutEvent:
        isDayStart.value = true;
        isCheckIn.value = false;
        PreferenceHelper.setBool(PreferenceHelper.checkIn, false);
        break;
      case AppConstant.dayEndEvent:
        isDayStart.value = false;
        isCheckIn.value = false;
        isDayEnd.value = false;
        PreferenceHelper.setBool(PreferenceHelper.checkIn, false);
        break;
      case AppConstant.trackingWaitingStartEvent:
      case AppConstant.trackingWaitingStopEvent:
      case AppConstant.gpsOffEvent:
      case AppConstant.gpsOnEvent:
      case AppConstant.internetOffEvent:
      case AppConstant.internetOnEvent:
        isDayStart.value = true;
        isCheckIn.value = false;
      default:
        print('Unknown eventCode$totEventCode');
        isDayStart.value = false;
        isCheckIn.value = false;
    }
    notifyListeners();
  }

  SetPrefHelpeAndServiceManageEvents(LastActivityData? lastActivityData) async
  {

     if(lastActivityData==null) {
       PreferenceHelper.setObject<LastActivityData>(PreferenceHelper.LastActivity, null);
       PreferenceHelper.setString(PreferenceHelper.SESSION_ID, "");
       if(Platform.isAndroid){
         service.invoke("stopService");

       }else{
         // await iosService.stop();
       }
       return;
     }

     String? totEventCode = lastActivityData?.trackingEventId;
     String? sessionStartDateStr = AppUtils.getDate(date: lastActivityData?.sessionStartDateTime ?? "", format: "dd-MM-yyyy");
     DateTime sessionStartDate = DateFormat("dd-MM-yyyy").parse(sessionStartDateStr);
     DateTime today = DateTime.now();
     DateTime todayWithoutTime = DateTime(today.year, today.month, today.day);

     if(lastActivityData?.isSessionActive==false || sessionStartDate.isBefore(todayWithoutTime))
     {
       PreferenceHelper.setObject<LastActivityData>(PreferenceHelper.LastActivity, null);
       PreferenceHelper.setString(PreferenceHelper.SESSION_ID, "");
       if(Platform.isAndroid){
         service.invoke("stopService");

       }else{
         // await iosService.stop();
       }
       return;
     }

    if (sessionStartDateStr == AppUtils.getDate(date: DateTime.now().toString(), format: "dd-MM-yyyy") && lastActivityData?.isSessionActive==true )
    {

        PreferenceHelper.setObject<LastActivityData>(PreferenceHelper.LastActivity, lastActivityData);
        PreferenceHelper.setString(PreferenceHelper.SESSION_ID, lastActivityData.sessionId ?? "");
        bool? liveLocationTracking = PreferenceHelper.getBool(PreferenceHelper.LIVE_LOCATION_TRACKING);


         if (liveLocationTracking == true) {
           if(Platform.isAndroid){
             await service.startService();
           }else{
             PreferenceHelper.setString(PreferenceHelper.WAITING_START_TIME, AppUtils.getDate(date: DateTime.now().toString(), format: AppConstant.dateFormat));
             PreferenceHelper.setDouble(PreferenceHelper.LAST_LAT, lastActivityData.lastActivityLat ?? 0);
             PreferenceHelper.setDouble(PreferenceHelper.LAST_LONG, lastActivityData.lastActivityLong ?? 0);
             // iosService.start();

           }

        }
    }
  }

  setDataAccordingToLastActivity(String? totEventCode) {
    // switch (totEventCode) {
    //   case AppConstant.dayStartEvent:
    //     PreferenceHelper.setBool(PreferenceHelper.DayStart, true);
    //     isDayStart.value = PreferenceHelper.getBool(PreferenceHelper.DayStart);
    //     break;
    //   case AppConstant.checkInEvent:
    //     PreferenceHelper.setBool(PreferenceHelper.DayStart, true);
    //     PreferenceHelper.setBool(PreferenceHelper.checkIn, true);
    //     isDayStart.value = PreferenceHelper.getBool(PreferenceHelper.DayStart);
    //     isCheckIn.value = PreferenceHelper.getBool(PreferenceHelper.checkIn);
    //     break;
    //   case AppConstant.checkOutEvent:
    //     PreferenceHelper.setBool(PreferenceHelper.DayStart, true);
    //     PreferenceHelper.setBool(PreferenceHelper.checkIn, false);
    //     isDayStart.value = PreferenceHelper.getBool(PreferenceHelper.DayStart);
    //     isCheckIn.value = PreferenceHelper.getBool(PreferenceHelper.checkIn);
    //     break;
    //   case AppConstant.dayEndEvent:
    //     PreferenceHelper.setBool(PreferenceHelper.DayStart, false);
    //     PreferenceHelper.setBool(PreferenceHelper.checkIn, false);
    //     isDayStart.value = PreferenceHelper.getBool(PreferenceHelper.DayStart);
    //     isCheckIn.value = PreferenceHelper.getBool(PreferenceHelper.checkIn);
    //     break;
    //   case AppConstant.trackingWaitingStartEvent:
    //     PreferenceHelper.setBool(PreferenceHelper.DayStart, true);
    //     PreferenceHelper.setBool(PreferenceHelper.isWaiting, true);
    //     PreferenceHelper.setBool(PreferenceHelper.checkIn, false);
    //     isDayStart.value = PreferenceHelper.getBool(PreferenceHelper.DayStart);
    //     isCheckIn.value = PreferenceHelper.getBool(PreferenceHelper.checkIn);
    //     isWaiting.value = PreferenceHelper.getBool(PreferenceHelper.isWaiting);
    //     break;
    //   case AppConstant.trackingWaitingStopEvent:
    //     PreferenceHelper.setBool(PreferenceHelper.DayStart, true);
    //     PreferenceHelper.setBool(PreferenceHelper.checkIn, false);
    //     PreferenceHelper.setBool(PreferenceHelper.isWaiting, false);
    //     isDayStart.value = PreferenceHelper.getBool(PreferenceHelper.DayStart);
    //     isCheckIn.value = PreferenceHelper.getBool(PreferenceHelper.checkIn);
    //     isWaiting.value = PreferenceHelper.getBool(PreferenceHelper.isWaiting);
    //     break;
    //   case AppConstant.internetOffEvent:
    //     PreferenceHelper.setBool(PreferenceHelper.DayStart, true);
    //     PreferenceHelper.setBool(PreferenceHelper.checkIn, false);
    //     isDayStart.value = PreferenceHelper.getBool(PreferenceHelper.DayStart);
    //     isCheckIn.value = PreferenceHelper.getBool(PreferenceHelper.checkIn);
    //     break;
    //   case AppConstant.internetOnEvent:
    //     PreferenceHelper.setBool(PreferenceHelper.DayStart, true);
    //     PreferenceHelper.setBool(PreferenceHelper.checkIn, false);
    //     isDayStart.value = PreferenceHelper.getBool(PreferenceHelper.DayStart);
    //     isCheckIn.value = PreferenceHelper.getBool(PreferenceHelper.checkIn);
    //     break;
    //   case AppConstant.gpsOffEvent:
    //     PreferenceHelper.setBool(PreferenceHelper.DayStart, true);
    //     PreferenceHelper.setBool(PreferenceHelper.checkIn, false);
    //     isDayStart.value = PreferenceHelper.getBool(PreferenceHelper.DayStart);
    //     isCheckIn.value = PreferenceHelper.getBool(PreferenceHelper.checkIn);
    //     break;
    //   case AppConstant.gpsOnEvent:
    //     PreferenceHelper.setBool(PreferenceHelper.DayStart, true);
    //     PreferenceHelper.setBool(PreferenceHelper.checkIn, false);
    //     isDayStart.value = PreferenceHelper.getBool(PreferenceHelper.DayStart);
    //     isCheckIn.value = PreferenceHelper.getBool(PreferenceHelper.checkIn);
    //     break;
    //   default:
    //     print('Unknown eventCode$totEventCode');
    //     PreferenceHelper.setBool(PreferenceHelper.DayStart, false);
    //     PreferenceHelper.setBool(PreferenceHelper.isWaiting, false);
    //     PreferenceHelper.setBool(PreferenceHelper.checkIn, false);
    //     isDayStart.value = PreferenceHelper.getBool(PreferenceHelper.DayStart);
    //     isCheckIn.value = PreferenceHelper.getBool(PreferenceHelper.checkIn);
    //     isWaiting.value = PreferenceHelper.getBool(PreferenceHelper.isWaiting);
    // }
    notifyListeners();
  }

  getAllConfiguration() {
    userId = PreferenceHelper.getString(PreferenceHelper.USER_ID);
    orgName = PreferenceHelper.getString(PreferenceHelper.ORG_NAME);
    userName = PreferenceHelper.getString(PreferenceHelper.USER_NAME);
    isAllowFgAuth = PreferenceHelper.getBool(PreferenceHelper.ALLOW_FG_AUTH);
    isLocationRestricted =
        PreferenceHelper.getBool(PreferenceHelper.LOCATION_RESTRICTION);
    restrictedLocationLat =
        PreferenceHelper.getDouble(PreferenceHelper.LOCATION_RESTRICTION_LAT);
    restrictedLocationLong =
        PreferenceHelper.getDouble(PreferenceHelper.LOCATION_RESTRICTION_LONG);
    restrictedLocationMeter =
        PreferenceHelper.getInt(PreferenceHelper.RESTRICTED_LOCATION_METER);
  }


  //
  // offlineBtnChangeFnc(LastActivityData lastActivityData)async{
  //   isActiveSession = lastActivityData.isSessionActive;
  //   print("isActiveSession${isActiveSession}");
  //   print("totEvent${lastActivityData.trackingEventId}");
  //   String? totEventCode = lastActivityData.trackingEventId;
  //   String? sessionStartDateStr = AppUtils.getDate(
  //       date: lastActivityData.sessionStartDateTime ?? "",
  //       format: "dd-MM-yyyy");
  //   print("startDate$sessionStartDateStr");
  //
  //   if (lastActivityData == null) {
  //     print("data_is_null");
  //     setDataAccordingToLastActivity("");
  //   }
  //   if (sessionStartDateStr ==
  //       AppUtils.getDate(
  //           date: DateTime.now().toString(), format: "dd-MM-yyyy")) {
  //     sessionId = lastActivityData.sessionId;
  //     print("sessionId$sessionId");
  //     PreferenceHelper.setString(
  //         PreferenceHelper.SESSION_ID, sessionId ?? "");
  //
  //     setDataAccordingToLastActivity(totEventCode);
  //     if (isDayStart.value == true) {
  //       bool? liveLocationTracking = PreferenceHelper.getBool(
  //           PreferenceHelper.LIVE_LOCATION_TRACKING);
  //
  //       if (liveLocationTracking == true) {
  //         await service.startService();
  //         print("dtaaadasd${lastActivityData.toJson()}");
  //         // PreferenceHelper.setObject<LastActivityData>("last_activity", getLastActivityModel?.data?.toJson());
  //         // service.invoke("appLoad", getLastActivityModel?.data?.toJson());
  //       }
  //     }
  //   }
  // }
}
