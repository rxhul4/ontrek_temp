import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ontrek/core/services/api_constants.dart';
import 'package:ontrek/core/services/network_repository.dart';
import 'package:ontrek/core/storage/preference_helper.dart';
import 'package:ontrek/core/utils/App_utils.dart';

import 'package:ontrek/features/authentication/models/login_model.dart';
import 'package:ontrek/features/authentication/screens/otp_verification%20screen.dart';
import 'package:ontrek/features/dashboard/screens/dashboard_screen.dart';
import 'package:ontrek/main.dart';

class AuthenticationProvider extends ChangeNotifier {
  bool _isFetching = false;
  bool _isLoading = false;
  bool _isUploading = false;
  bool _isAdding = false;

  bool get isFetching => _isFetching;

  bool get isLoading => _isLoading;

  bool get isUploading => _isUploading;

  bool get isAdding => _isAdding;

  LoginModel? loginModel;

  int? countryCode;
  bool? isValid;
  bool isUsernameEmpty = true;
  int secondRemaining = 30;
  bool enableResend = false;
  Timer? timer;
  String? userUid;
  TextEditingController mobileNumberController = TextEditingController();
  TextEditingController otpController = TextEditingController();
  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();




  loaderFnc(bool isLoading) {
    _isLoading = isLoading;
    notifyListeners();
  }

  fetchingFnc(bool isLoading) {
    _isFetching = isLoading;
    notifyListeners();
  }

  saveCountryCode({String? countryCodeFromView}) {
    countryCode = int.parse(countryCodeFromView ?? "");
    notifyListeners();
  }

  validation({bool? isValidFromView}) {
    isValid = isValidFromView;
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

  void startTimer() {
    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (secondRemaining != 0) {
        secondRemaining--;
        notifyListeners();
      } else {
        enableResend = true;
        timer.cancel();
        notifyListeners();
      }
    });
  }

  void resendCode() {
    secondRemaining = 30;
    enableResend = false;
    startTimer();
    notifyListeners();
  }

  Future<LoginModel?> apiCallVerifyNumber() async {
    loaderFnc(true);
    Map<String, dynamic> body;

    if(Platform.isIOS){
      var iosInfo = await deviceInfo.iosInfo;
       body = {
        "countryCode": countryCode,
        "phoneNumber": mobileNumberController.text,
        "deviceInfo": {
          "deviceId" : iosInfo.identifierForVendor,
          "deviceModel" :iosInfo.model,
          "deviceOs " : iosInfo.systemName,
          "osVersion " : iosInfo.systemVersion,
        }
      };

    }else{
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      body = {
        "countryCode": countryCode,
        "phoneNumber": mobileNumberController.text,
        "deviceInfo": {
          "deviceId" : androidInfo.id,
          "deviceModel" :androidInfo.model,
          "deviceOs " : androidInfo.version.release,
          "osVersion " : Platform.operatingSystemVersion,
        }
      };
    }

    try {
      loginModel = LoginModel();
      String endPoint = ApiConstants.login;
      final response = await callPostMethod(endPoint, body);
      loginModel = LoginModel.fromJson(json.decode(response));
      print("response : ${response}");
      if (loginModel?.isError == false &&
          loginModel?.isValidationFailed == false) {
        PreferenceHelper.setString(
            PreferenceHelper.USER_NAME, loginModel?.data?.userName ?? "");
        navigatePushFnc(OTPVerificationCode(
          appUserId: loginModel?.data?.appUserId,
        ));
      } else {
        AppUtils.showDialogBoxWithOneButton(
          titleText: "Error",
            context: navigatorKey.currentState!.context,
            text: loginModel?.message ?? "");
        // AppUtils.dialogWidget(
        //     loginModel?.message ?? "", navigatorKey.currentState!.context);
      }
    } catch (e) {
      print("inCatch ${loginModel?.message}");
      print("inCatchE ${e}");
      bool isInternetAvailable = await AppUtils.checkInternetConnectivity();
      if (!isInternetAvailable) {
        loginModel =
            LoginModel(message: "Internet is not available, please try again!");
      } else {
        loginModel = LoginModel(message: "Something went wrong!");
      }
    }
    loaderFnc(false);
    return loginModel;
  }

  checkValidationAndCallLoginApi() {
    if (mobileNumberController.text.isEmpty) {
      AppUtils.showSnackBarWithColor(
          message: "Please Enter Phone Number", giveColor: Colors.red);
    } else {
      if (isValid ?? false) {
        apiCallVerifyNumber();
      }
    }
  }

  Future<LoginModel?> apiCallVerifyOtp({String? otpText}) async {
    loaderFnc(true);
    try {


    Map<String, dynamic> body;
    if(Platform.isIOS){
      var iosInfo = await deviceInfo.iosInfo;
      body = {
        "userId": userUid,
        "otp": otpText,
        "deviceInfo": {
          "deviceId" :  iosInfo.identifierForVendor,
          "deviceModel" :  iosInfo.model,
          "deviceOs " :  iosInfo.systemName,
          "osVersion " : Platform.operatingSystemVersion,
        }
      };
    }else{
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      body = {
        "userId": userUid,
        "otp": otpText,
        "deviceInfo": {
          "deviceId" :  androidInfo.id,
          "deviceModel" :  androidInfo.model,
          "deviceOs " :  androidInfo.version.release,
          "osVersion " : Platform.operatingSystemVersion,

        }
      };
    }


      loginModel = LoginModel();
      String endPoint = ApiConstants.verifyOtp;
      final response = await callPostMethod(endPoint, body);
      loginModel = LoginModel.fromJson(json.decode(response));
      print("response : ${response}");
      if (loginModel?.isError == false &&
          loginModel?.isValidationFailed == false) {
        saveDataToPref().then((value) {
          navigatePushReplacementFnc(DashBoard());
        });
      } else {
        AppUtils.showDialogBoxWithOneButton(
            context: navigatorKey.currentState!.context,
            text: loginModel?.message ?? "");
      }
    } catch (e) {
      print("inCatch ${loginModel?.message}");
      print("inCatchE ${e}");
      AppUtils.showDialogBoxWithOneButton(
          context: navigatorKey.currentState!.context,
          text: loginModel?.message ?? "");
      bool isInternetAvailable = await AppUtils.checkInternetConnectivity();
      if (!isInternetAvailable) {
        loginModel =
            LoginModel(message: "Internet is not available, please try again!");
      } else {
        loginModel = LoginModel(message: "Something went wrong!");
      }
    }
    loaderFnc(false);
    return loginModel;
  }

  Future<bool> saveDataToPref() async {
    PreferenceHelper.setBool(PreferenceHelper.IS_LOGIN, true);
    PreferenceHelper.setString(
        PreferenceHelper.USER_ID, loginModel?.data?.appUserId ?? '');
    PreferenceHelper.setString(
        PreferenceHelper.USER_NAME, loginModel?.data?.userName ?? '');
    PreferenceHelper.setInt(
        PreferenceHelper.COUNTRY_CODE, loginModel?.data?.countryCode ?? 0);
    PreferenceHelper.setString(
        PreferenceHelper.PHONE_NO, loginModel?.data?.phoneNo ?? '');
    PreferenceHelper.setString(
        PreferenceHelper.EMAIL, loginModel?.data?.userEmail ?? '');
    PreferenceHelper.setString(
        PreferenceHelper.ORG_ID, loginModel?.data?.orgId ?? '');
    PreferenceHelper.setString(
        PreferenceHelper.ORG_NAME, loginModel?.data?.orgName ?? '');
    PreferenceHelper.setString(
        PreferenceHelper.ROLE_NAME, loginModel?.data?.roleName ?? '');
    PreferenceHelper.setString(
        PreferenceHelper.ROLE_ID, loginModel?.data?.roleId ?? '');
    PreferenceHelper.setString(
        PreferenceHelper.REPORTING_MANAGER, loginModel?.data?.createdBy ?? '');
    /*PreferenceHelper.setString(
        PreferenceHelper.PROFILE_PIC, loginModel?.data?. ?? '');*/
    PreferenceHelper.setBool(PreferenceHelper.ALLOW_FG_AUTH,loginModel?.data?.appUserConfigAttendanceRequest?.allowFgAuth ?? false);
    PreferenceHelper.setBool(
        PreferenceHelper.AllowCheckInCheckOut,
        loginModel?.data?.appUserConfigAttendanceRequest
                ?.allowCheckinOut ??
            false);
    PreferenceHelper.setBool(
        PreferenceHelper.LOCATION_RESTRICTION,
        loginModel?.data?.appUserConfigAttendanceRequest
            ?.allowLocationRestriction ??
            false);
    PreferenceHelper.setDouble(
        PreferenceHelper.LOCATION_RESTRICTION_LAT,
        loginModel?.data?.appUserConfigAttendanceRequest
                ?.locationRestrictionLat ??
            0.0);
    PreferenceHelper.setDouble(
        PreferenceHelper.LOCATION_RESTRICTION_LONG,
        loginModel?.data?.appUserConfigAttendanceRequest
                ?.locationRestrictionLong ??
            0.0);
    PreferenceHelper.setInt(
        PreferenceHelper.RESTRICTED_LOCATION_METER,
        loginModel?.data?.appUserConfigAttendanceRequest?.locRestrictionMtrs ??
            0);

    PreferenceHelper.setBool(
        PreferenceHelper.LIVE_LOCATION_TRACKING,
        loginModel?.data?.appUserConfigTrackingRequest?.allowLiveTracking ??
            false);
    PreferenceHelper.setInt(
        PreferenceHelper.LIVE_LOCATION_INTERVAL,
        loginModel?.data?.appUserConfigTrackingRequest?.liveTrackingInterval ??
            0);


    print("data : ${PreferenceHelper.getBool(PreferenceHelper.IS_LOGIN)}");
    return true;
  }

  checkValidationAndCallVerifyOtpApi(
      {required TextEditingController controller}) {
    if (controller.text.isEmpty) {
      AppUtils.showSnackBarWithColor(
          message: "Please Enter One Time Password!", giveColor: Colors.red);
    } else if (controller.text.length < 4) {
      AppUtils.showSnackBarWithColor(
          message: "Please Enter 4 digit code!", giveColor: Colors.red);
    } else {
      apiCallVerifyOtp(otpText: controller.text);
    }
  }
}
