import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:local_auth/local_auth.dart';
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
      "picturePath": picturePath,
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
      if (isInternetAvailable == false) {
        AppUtils.showDialogBoxWithOneButton(
            titleText: "Internet Off Alert",
            text: "Internet is not available. Please Enable Mobile data or wifi.",
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
        print("totEvent${getLastActivityModel?.data?.trackingEventId}");
        String? totEventCode = getLastActivityModel?.data?.trackingEventId;
        switch (totEventCode) {
          case AppConstant.dayStartEvent:
            PreferenceHelper.setBool(PreferenceHelper.DayStart, true);
            isDayStart.value =
                PreferenceHelper.getBool(PreferenceHelper.DayStart);
            break;
          case AppConstant.checkInEvent:
            PreferenceHelper.setBool(PreferenceHelper.DayStart, true);
            PreferenceHelper.setBool(PreferenceHelper.checkIn, true);
            isDayStart.value =
                PreferenceHelper.getBool(PreferenceHelper.DayStart);
            isCheckIn.value =
                PreferenceHelper.getBool(PreferenceHelper.checkIn);
            break;
          case AppConstant.checkOutEvent:
            PreferenceHelper.setBool(PreferenceHelper.DayStart, true);
            PreferenceHelper.setBool(PreferenceHelper.checkIn, false);
            isDayStart.value =
                PreferenceHelper.getBool(PreferenceHelper.DayStart);
            isCheckIn.value =
                PreferenceHelper.getBool(PreferenceHelper.checkIn);
            break;
          case AppConstant.dayEndEvent:
            PreferenceHelper.setBool(PreferenceHelper.DayStart, false);
            PreferenceHelper.setBool(PreferenceHelper.checkIn, false);
            isDayStart.value =
                PreferenceHelper.getBool(PreferenceHelper.DayStart);
            isCheckIn.value =
                PreferenceHelper.getBool(PreferenceHelper.checkIn);
            break;
          case AppConstant.trackingWaitingStartEvent:
            PreferenceHelper.setBool(PreferenceHelper.DayStart, true);
            PreferenceHelper.setBool(PreferenceHelper.isWaiting, true);
            PreferenceHelper.setBool(PreferenceHelper.checkIn, false);
            isDayStart.value =
                PreferenceHelper.getBool(PreferenceHelper.DayStart);
            isCheckIn.value =
                PreferenceHelper.getBool(PreferenceHelper.checkIn);
            isWaiting.value =
                PreferenceHelper.getBool(PreferenceHelper.isWaiting);
            break;
          case AppConstant.trackingWaitingStopEvent:
            PreferenceHelper.setBool(PreferenceHelper.DayStart, true);
            PreferenceHelper.setBool(PreferenceHelper.checkIn, false);
            PreferenceHelper.setBool(PreferenceHelper.isWaiting, false);
            isDayStart.value =
                PreferenceHelper.getBool(PreferenceHelper.DayStart);
            isCheckIn.value =
                PreferenceHelper.getBool(PreferenceHelper.checkIn);
            isWaiting.value =
                PreferenceHelper.getBool(PreferenceHelper.isWaiting);
            break;
          case AppConstant.internetOffEvent:
            PreferenceHelper.setBool(PreferenceHelper.DayStart, true);
            PreferenceHelper.setBool(PreferenceHelper.checkIn, false);
            isDayStart.value =
                PreferenceHelper.getBool(PreferenceHelper.DayStart);
            isCheckIn.value =
                PreferenceHelper.getBool(PreferenceHelper.checkIn);

            break;
          case AppConstant.internetOnEvent:
            PreferenceHelper.setBool(PreferenceHelper.DayStart, true);
            PreferenceHelper.setBool(PreferenceHelper.checkIn, false);
            isDayStart.value =
                PreferenceHelper.getBool(PreferenceHelper.DayStart);
            isCheckIn.value =
                PreferenceHelper.getBool(PreferenceHelper.checkIn);
            break;
          case AppConstant.gpsOffEvent:
            PreferenceHelper.setBool(PreferenceHelper.DayStart, true);
            PreferenceHelper.setBool(PreferenceHelper.checkIn, false);
            isDayStart.value =
                PreferenceHelper.getBool(PreferenceHelper.DayStart);
            isCheckIn.value =
                PreferenceHelper.getBool(PreferenceHelper.checkIn);
            break;
          case AppConstant.gpsOnEvent:
            PreferenceHelper.setBool(PreferenceHelper.DayStart, true);
            PreferenceHelper.setBool(PreferenceHelper.checkIn, false);
            isDayStart.value =
                PreferenceHelper.getBool(PreferenceHelper.DayStart);
            isCheckIn.value =
                PreferenceHelper.getBool(PreferenceHelper.checkIn);
            break;
          default:
            print('Unknown eventCode');
            PreferenceHelper.setBool(PreferenceHelper.DayStart, false);
            PreferenceHelper.setBool(PreferenceHelper.isWaiting, false);
            PreferenceHelper.setBool(PreferenceHelper.checkIn, false);
            isDayStart.value =
                PreferenceHelper.getBool(PreferenceHelper.DayStart);
            isCheckIn.value =
                PreferenceHelper.getBool(PreferenceHelper.checkIn);
            isWaiting.value =
                PreferenceHelper.getBool(PreferenceHelper.isWaiting);
        }
        if (isDayStart.value == true) {
          bool? liveLocationTracking =
              PreferenceHelper.getBool(PreferenceHelper.LIVE_LOCATION_TRACKING);
          if (liveLocationTracking == true) {
            await service.startService();
          }
        }
      } else {
        if (getLastActivityModel?.isError == true) {
          AppUtils.showDialogBoxWithOneButton(
              context: navigatorKey.currentState!.context,
              text: "Something went wrong, Please try again later!");
        }
        if (getLastActivityModel?.isValidationFailed == true) {
          AppUtils.showDialogBoxWithOneButton(
              context: navigatorKey.currentState!.context,
              text: createActivityModel?.message ?? "");
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
            text: "Internet is not available. Please Enable Mobile data or wifi.",
            context: navigatorKey.currentState!.context);
      } else {
        AppUtils.showDialogBoxWithOneButton(
            titleText: "Error",
            text: "Something went wrong!",
            context: navigatorKey.currentState!.context);
      }
    }
    loaderFnc(false);
    return getLastActivityModel;
  }

  Future<GetLastPendingDayEnd?> apiCallCheckPendingEndDate() async {
    String? userId = PreferenceHelper.getString(PreferenceHelper.USER_ID);

    loaderFnc(true);
    Map<String, dynamic> body = {
      "userId": userId,
    };
    try {
      String endPoint = ApiConstants.checkPendingEndDate;
      final response = await callPostMethod(endPoint, body);
      getLastPendingDayEnd =
          GetLastPendingDayEnd.fromJson(json.decode(response));
      print("response : ${response}");
    } catch (e) {
      print("inCatch ${getLastPendingDayEnd?.message}");
      print("inCatchE $e");
      isInternetAvailable = await AppUtils.checkInternetConnectivity();
      if (isInternetAvailable == false) {
        AppUtils.showDialogBoxWithOneButton(
            titleText: "Internet Off Alert",
            text: "Internet is not available. Please Enable Mobile data or wifi.",
            context: navigatorKey.currentState!.context);
      } else {
        AppUtils.showDialogBoxWithOneButton(
            titleText: "Error",
            text: "Something went wrong!",
            context: navigatorKey.currentState!.context);
      }
    }
    loaderFnc(false);
    return getLastPendingDayEnd;
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
        Navigator.pop(navigatorKey.currentState!.context);
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
            text: "Internet is not available. Please Enable Mobile data or wifi.",
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
}
