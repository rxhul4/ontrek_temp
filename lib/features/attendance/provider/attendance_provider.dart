import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:local_auth/local_auth.dart';
import 'package:ontrek/core/background_service_model/bulk_activity_model.dart';
import 'package:ontrek/core/common_widgets/textfield_widget.dart';
import 'package:ontrek/core/services/api_constants.dart';
import 'package:ontrek/core/services/network_repository.dart';
import 'package:ontrek/core/storage/preference_helper.dart';

import 'package:ontrek/core/utils/App_utils.dart';
import 'package:ontrek/core/utils/app_constant.dart';
import 'package:ontrek/features/attendance/model/add_activity_model.dart';
import 'package:ontrek/features/attendance/model/dayend_manual_request_model.dart';
import 'package:ontrek/features/attendance/model/get_check_panding_dayend.dart';
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

  Future<bool?> getWaitingValue() async {
    isWaiting.value =
        await PreferenceHelper.getBool(PreferenceHelper.isWaiting);
    notifyListeners();
    return isWaiting.value;
  }

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
    Position? position;

    if (isLocationServiceAvailable) {
      try {
        position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.medium);
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
    print("sessionIdAtCreateActivity$sessionId");
    String? userid = PreferenceHelper.getString(PreferenceHelper.USER_ID);
    Position position = await Geolocator.getCurrentPosition(
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
      "userId": userid ?? "",
      "longitude": isFromCheckOut == true
          ? positionData?.longitude ?? 0
          : position.longitude,
      "lattitude": isFromCheckOut == true
          ? positionData?.latitude ?? 0
          : position.latitude,
      "sessionId": isFromCheckOut == true
          ? checkOutSessionId
          : isActiveSession == true
              ? sessionId
              : null,
      "totTrackingEventId": totTrackingEventCode,
      "activityDateTime": activityDateTime ??
          AppUtils.dateFormat(
              date: DateTime.now(), dateFormat: AppConstant.dateFormat),
      "batteryLevel": battery,
      "visitNoteRequestForm": isFromCheckOut ?? false ? checkOutDataBody : null
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
      } else {
        AppUtils.showDialogBoxWithOneButton(
            titleText: "Error",
            text: "Something went wrong!",
            context: navigatorKey.currentState!.context);
      }
    }
    loaderFnc(false);
    return createActivityModel;
  }

  bool? isActiveSession;
  String? sessionId;

  Future<GetLastActivityModel?> callGetLastActivity() async {
    loaderFnc(true);
    String? userId = PreferenceHelper.getString(PreferenceHelper.USER_ID);
    Map<String, dynamic> body = {
      "userId": userId,
      "currentDate": AppUtils.dateFormat(
          date: DateTime.now(), dateFormat: AppConstant.dateFormat)
    };
    try {
      String endPoint = ApiConstants.getLastActivity;
      final response = await callPostMethod(endPoint, body);
      getLastActivityModel =
          GetLastActivityModel.fromJson(json.decode(response));
      print("response_of_lastActivity: $response");
      if (getLastActivityModel?.isError == false &&
          getLastActivityModel?.isValidationFailed == false) {
        isActiveSession = getLastActivityModel?.data?.isSessionActive;
        print("isActiveSession${isActiveSession}");
        print("totEvent${getLastActivityModel?.data?.trackingEventId}");
        String? totEventCode = getLastActivityModel?.data?.trackingEventId;
        String? sessionStartDateStr = AppUtils.getDate(
            date: getLastActivityModel?.data?.sessionStartDateTime ?? "",
            format: "dd-MM-yyyy");
        print("startDate$sessionStartDateStr");

        if (getLastActivityModel?.data == null) {
          print("data_is_null");
          setDataAccordingToLastActivity("");
        }
        DateTime sessionStartDate =
            DateFormat("dd-MM-yyyy").parse(sessionStartDateStr);
        DateTime today = DateTime.now();
        DateTime todayWithoutTime =
            DateTime(today.year, today.month, today.day);
        if (sessionStartDate.isBefore(todayWithoutTime)) {
          if (getLastActivityModel?.data?.isSessionActive == true) {
            if (getLastActivityModel?.data?.alreadyRequested == false) {
              dateController.text = sessionStartDateStr;
              dayStartTimeController.text = AppUtils.getDate(
                  date: getLastActivityModel?.data?.sessionStartDateTime ?? "",
                  format: "hh:mm a");
              navigatePushFnc(PendingDayEndScreen(
                sessionId: getLastActivityModel?.data?.sessionId,
                sessionStartDate:
                    getLastActivityModel?.data?.sessionStartDateTime ?? "",
              ));
            }
          } else {
            setDataAccordingToLastActivity("");
          }
        }
        if (sessionStartDateStr == AppUtils.getDate(date: DateTime.now().toString(), format: "dd-MM-yyyy")) {
          sessionId = getLastActivityModel?.data?.sessionId;
          print("sessionId$sessionId");
          PreferenceHelper.setString(PreferenceHelper.SESSION_ID, sessionId ?? "");
          // service.invoke("background", {
          //   "lastLat": 0,
          //   "lastLong": 0,
          //   "waitingStartTime": 0,
          //   "sessionId" : sessionId
          // });
          setDataAccordingToLastActivity(totEventCode);
          if (isDayStart.value == true) {
            bool? liveLocationTracking = PreferenceHelper.getBool(
                PreferenceHelper.LIVE_LOCATION_TRACKING);

            if (liveLocationTracking == true) {
              await service.startService();
            }
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
      AppUtils.showDialogBoxWithOneButton(
          context: navigatorKey.currentState!.context,
          text: "Something went wrong, Please try again later!");
      bool isInternetAvailable = await AppUtils.checkInternetConnectivity();
      if (isInternetAvailable == false) {
        AppUtils.showDialogBoxWithOneButton(
            titleText: "Internet Off Alert",
            text:
                "Internet is not available. Please Enable Mobile data or wifi.",
            context: navigatorKey.currentState!.context);
      } else {
        AppUtils.showDialogBoxWithOneButton(
            titleText: "Error",
            text: "Something went wrong, Please try again later!",
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



  BulkActivityModel? bulkActivityModel;
  callBulkActivityApi({Function()? dayEndFnc}) async {
    PreferenceHelper.reload().then((value)async {
      if(value != null){
        String? userName = value.getString(PreferenceHelper.USER_NAME);
        String? userId = PreferenceHelper.getString(PreferenceHelper.USER_ID);

        bool? internetBool = value.getBool(PreferenceHelper.INTERNET_BOOL);
        bool? gpsBool = value.getBool(PreferenceHelper.GPS_BOOL);
        String? lastInternetOffTime = value.getString(PreferenceHelper.LAST_INTERNET_OFF_TIME);
        String? lastGpsOffTime = value.getString(PreferenceHelper.LAST_GPS_OFF_TIME);
        double? lastLat = value.getDouble(PreferenceHelper.LAST_LAT);
        double? lastLong = value.getDouble(PreferenceHelper.LAST_LONG);
        Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.medium);
        List<String> offlineData = value.getStringList('offline_data') ?? [];
        List offlineDataMaps = offlineData.map((data) => jsonDecode(data)).toList();
        print("offlineDataMaps$offlineDataMaps");
        Map<String, dynamic> internetOffBody = {
          "userId": userId,
          "sessionId": sessionId,
          "lattitude": lastLat,
          "longitude": lastLong,
          "totTrackingEventId": AppConstant.internetOffEvent,
          "activityDateTime": AppUtils.getDate(
              date: lastInternetOffTime ?? "", format: AppConstant.dateFormat),
          "batteryLevel": await AppUtils.getBatteryLevel(),
          "visitNoteRequestForm" : null,
          "offlineMapData": null,
          "timeZoneDiff": DateTime.now().timeZoneOffset.inMinutes.toString(),
          "loggedInUser": userName ?? ""
        };
        Map<String, dynamic> internetOnBody = {
          "userId": userId,
          "sessionId": sessionId,
          "lattitude": position.latitude,
          "longitude": position.longitude,
          "totTrackingEventId": AppConstant.internetOnEvent,
          "activityDateTime": AppUtils.getDate(
              date: DateTime.now().toString(), format: AppConstant.dateFormat),
          "batteryLevel": await AppUtils.getBatteryLevel(),
          "visitNoteRequestForm" : null,
          "offlineMapData": offlineDataMaps,
          "timeZoneDiff": DateTime.now().timeZoneOffset.inMinutes.toString(),
          "loggedInUser": userName ?? ""
        };

        Map<String, dynamic> gpsOffBody = {
          "userId": userId,
          "sessionId": sessionId,
          "lattitude": lastLat,
          "longitude":  lastLong,
          "totTrackingEventId": AppConstant.gpsOffEvent,
          "activityDateTime": AppUtils.getDate(
              date: lastGpsOffTime ?? "", format: AppConstant.dateFormat),
          "batteryLevel": await AppUtils.getBatteryLevel(),
          "visitNoteRequestForm" : null,
          "offlineMapData": null,
          "timeZoneDiff": DateTime.now().timeZoneOffset.inMinutes.toString(),
          "loggedInUser": userName ?? ""
        };
        Map<String, dynamic> gpsOnBody = {
          "userId": userId,
          "sessionId": sessionId,
          "lattitude": position.latitude,
          "longitude": position.longitude,
          "totTrackingEventId": AppConstant.gpsOnEvent,
          "activityDateTime": AppUtils.getDate(
              date: DateTime.now().toString(), format: AppConstant.dateFormat),
          "batteryLevel": await AppUtils.getBatteryLevel(),
          "visitNoteRequestForm" : null,
          "offlineMapData": null,
          "timeZoneDiff": DateTime.now().timeZoneOffset.inMinutes.toString(),
          "loggedInUser": userName ?? ""
        };

        Map<String, dynamic> body = {};
        print("InternetandGpsBool$internetBool----$gpsBool");
        if (gpsBool == true && internetBool == true) {
          body = {
            "activityList": [internetOffBody, internetOnBody, gpsOffBody, gpsOnBody],
          };
        } else if (internetBool == true) {
          body = {
            "activityList": [internetOffBody, internetOnBody],
          };
        } else if (gpsBool == true) {
          body = {
            "activityList": [gpsOffBody, gpsOnBody],
          };
        }
        print("InternetandGpsBool$internetBool----$gpsBool");

        try {
          String endPoint = ApiConstants.bulkActivity;
          var response = await callPostMethod(endPoint, body);
          bulkActivityModel = BulkActivityModel?.fromJson(json.decode(response));
          if (bulkActivityModel?.isError == false && bulkActivityModel?.isValidationFailed == false) {
            if(internetBool == true){
              PreferenceHelper.remove("offline_data");
              PreferenceHelper.remove(PreferenceHelper.LAST_INTERNET_OFF_TIME);
              PreferenceHelper.remove(PreferenceHelper.LAST_INTERNET_ON_TIME);
              PreferenceHelper.setString(PreferenceHelper.WAITING_START_TIME, DateTime.now().toString());
              PreferenceHelper.setBool(PreferenceHelper.INTERNET_BOOL, false);
            }
            if(gpsBool == true){
              PreferenceHelper.remove(PreferenceHelper.LAST_GPS_OFF_TIME);
              PreferenceHelper.remove(PreferenceHelper.LAST_GPS_ON_TIME);
              PreferenceHelper.setString(PreferenceHelper.WAITING_START_TIME, DateTime.now().toString());
              PreferenceHelper.setBool(PreferenceHelper.GPS_BOOL, false);
            }
            dayEndFnc!();
          }
        } catch (e) {
          print("catch_at_bulkApi_call$e");
        }
      }

    });








  }




  clearController() {
    timeController.clear();
    reasonController.clear();
  }

  setDataAccordingToLastActivity(String? totEventCode) {
    switch (totEventCode) {
      case AppConstant.dayStartEvent:
        PreferenceHelper.setBool(PreferenceHelper.DayStart, true);
        isDayStart.value = PreferenceHelper.getBool(PreferenceHelper.DayStart);
        break;
      case AppConstant.checkInEvent:
        PreferenceHelper.setBool(PreferenceHelper.DayStart, true);
        PreferenceHelper.setBool(PreferenceHelper.checkIn, true);
        isDayStart.value = PreferenceHelper.getBool(PreferenceHelper.DayStart);
        isCheckIn.value = PreferenceHelper.getBool(PreferenceHelper.checkIn);
        break;
      case AppConstant.checkOutEvent:
        PreferenceHelper.setBool(PreferenceHelper.DayStart, true);
        PreferenceHelper.setBool(PreferenceHelper.checkIn, false);
        isDayStart.value = PreferenceHelper.getBool(PreferenceHelper.DayStart);
        isCheckIn.value = PreferenceHelper.getBool(PreferenceHelper.checkIn);
        break;
      case AppConstant.dayEndEvent:
        PreferenceHelper.setBool(PreferenceHelper.DayStart, false);
        PreferenceHelper.setBool(PreferenceHelper.checkIn, false);
        isDayStart.value = PreferenceHelper.getBool(PreferenceHelper.DayStart);
        isCheckIn.value = PreferenceHelper.getBool(PreferenceHelper.checkIn);
        break;
      case AppConstant.trackingWaitingStartEvent:
        PreferenceHelper.setBool(PreferenceHelper.DayStart, true);
        PreferenceHelper.setBool(PreferenceHelper.isWaiting, true);
        PreferenceHelper.setBool(PreferenceHelper.checkIn, false);
        isDayStart.value = PreferenceHelper.getBool(PreferenceHelper.DayStart);
        isCheckIn.value = PreferenceHelper.getBool(PreferenceHelper.checkIn);
        isWaiting.value = PreferenceHelper.getBool(PreferenceHelper.isWaiting);
        break;
      case AppConstant.trackingWaitingStopEvent:
        PreferenceHelper.setBool(PreferenceHelper.DayStart, true);
        PreferenceHelper.setBool(PreferenceHelper.checkIn, false);
        PreferenceHelper.setBool(PreferenceHelper.isWaiting, false);
        isDayStart.value = PreferenceHelper.getBool(PreferenceHelper.DayStart);
        isCheckIn.value = PreferenceHelper.getBool(PreferenceHelper.checkIn);
        isWaiting.value = PreferenceHelper.getBool(PreferenceHelper.isWaiting);
        break;
      case AppConstant.internetOffEvent:
        PreferenceHelper.setBool(PreferenceHelper.DayStart, true);
        PreferenceHelper.setBool(PreferenceHelper.checkIn, false);
        isDayStart.value = PreferenceHelper.getBool(PreferenceHelper.DayStart);
        isCheckIn.value = PreferenceHelper.getBool(PreferenceHelper.checkIn);

        break;
      case AppConstant.internetOnEvent:
        PreferenceHelper.setBool(PreferenceHelper.DayStart, true);
        PreferenceHelper.setBool(PreferenceHelper.checkIn, false);
        isDayStart.value = PreferenceHelper.getBool(PreferenceHelper.DayStart);
        isCheckIn.value = PreferenceHelper.getBool(PreferenceHelper.checkIn);
        break;
      case AppConstant.gpsOffEvent:
        PreferenceHelper.setBool(PreferenceHelper.DayStart, true);
        PreferenceHelper.setBool(PreferenceHelper.checkIn, false);
        isDayStart.value = PreferenceHelper.getBool(PreferenceHelper.DayStart);
        isCheckIn.value = PreferenceHelper.getBool(PreferenceHelper.checkIn);
        break;
      case AppConstant.gpsOnEvent:
        PreferenceHelper.setBool(PreferenceHelper.DayStart, true);
        PreferenceHelper.setBool(PreferenceHelper.checkIn, false);
        isDayStart.value = PreferenceHelper.getBool(PreferenceHelper.DayStart);
        isCheckIn.value = PreferenceHelper.getBool(PreferenceHelper.checkIn);
        break;
      default:
        print('Unknown eventCode$totEventCode');
        PreferenceHelper.setBool(PreferenceHelper.DayStart, false);
        PreferenceHelper.setBool(PreferenceHelper.isWaiting, false);
        PreferenceHelper.setBool(PreferenceHelper.checkIn, false);
        isDayStart.value = PreferenceHelper.getBool(PreferenceHelper.DayStart);
        isCheckIn.value = PreferenceHelper.getBool(PreferenceHelper.checkIn);
        isWaiting.value = PreferenceHelper.getBool(PreferenceHelper.isWaiting);
    }
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
}
