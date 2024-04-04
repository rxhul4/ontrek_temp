import 'dart:convert';
import 'package:battery_plus/battery_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:geolocator/geolocator.dart';
import 'package:local_auth/local_auth.dart';
import 'package:ontrek/core/services/api_constants.dart';
import 'package:ontrek/core/services/network_repository.dart';
import 'package:ontrek/core/storage/preference_helper.dart';

import 'package:ontrek/core/storage/sql_db_service.dart';
import 'package:ontrek/core/utils/App_utils.dart';
import 'package:ontrek/core/utils/app_constant.dart';
import 'package:ontrek/features/attendance/model/add_activity_model.dart';
import 'package:ontrek/features/attendance/model/get_last_activity_model.dart';
import 'package:ontrek/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  int? battery;
  DatabaseService? databaseService;
  PanelController panelController = PanelController();
  ValueNotifier<bool> isDayStart = ValueNotifier(false);
  ValueNotifier<bool> isCheckIn = ValueNotifier(false);
  ValueNotifier<bool> isDayEnd = ValueNotifier(false);
  ValueNotifier<bool> isWaiting = ValueNotifier(false);
  LocalAuthentication localAuthentication = LocalAuthentication();
  bool isBiometricAvailable = false;
  AnimationController? controller;


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
        AppUtils.dialogWidget("Authentication Fail! Please Try Again",
            navigatorKey.currentContext);
      }
    } else {
      AppUtils.dialogWidget("Biometric Auth is not available on this device",
          navigatorKey.currentContext);
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
        AppUtils.dialogWidget("Please Enable Your Location Service",
            navigatorKey!.currentState?.context);
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

  Future<GetLastActivityModel?> callGetLastActivity() async {
    loaderFnc(true);
    String? userId = PreferenceHelper.getString(PreferenceHelper.USER_UID);
    Map<String, dynamic> body = {
      "userId": userId,
      "currentDate": AppUtils.dateFormat(date: DateTime.now(),dateFormat: AppConstant.dateFormat)
    };
    try {
      String endPoint = ApiConstants.getLastActivity;
      final response = await callPostMethod(endPoint, body);
      getLastActivityModel = GetLastActivityModel.fromJson(json.decode(response));
      print("response_of_lastActivity: $response");
      if(getLastActivityModel?.isError == false && getLastActivityModel?.isValidationFailed == false){
        print("totEvent${getLastActivityModel?.data?.trackingEventId}");
        String? totEventCode = getLastActivityModel?.data?.trackingEventId;

        switch (totEventCode) {
          case AppConstant.dayStartEvent :
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
            PreferenceHelper.setBool(PreferenceHelper.checkIn, false);
            isDayStart.value = PreferenceHelper.getBool(PreferenceHelper.DayStart);
            isCheckIn.value = PreferenceHelper.getBool(PreferenceHelper.checkIn);
            break;
          case AppConstant.trackingWaitingStopEvent:
            PreferenceHelper.setBool(PreferenceHelper.DayStart, true);
            PreferenceHelper.setBool(PreferenceHelper.checkIn, false);
            isDayStart.value = PreferenceHelper.getBool(PreferenceHelper.DayStart);
            isCheckIn.value = PreferenceHelper.getBool(PreferenceHelper.checkIn);
            break;
          default:
            print('Unknown eventCode');

        }

      }
    } catch (e) {
      print("inCatch ${createActivityModel?.message}");
      print("inCatchE $e");
      bool isInternetAvailable = await AppUtils.checkInternetConnectivity();
      if (!isInternetAvailable) {
        getLastActivityModel = GetLastActivityModel(
            message: "Internet is not available, please try again!");
      } else {
        getLastActivityModel =
            GetLastActivityModel(message: "Something went wrong!");
      }
    }
    loaderFnc(false);
    return getLastActivityModel;
  }





}
