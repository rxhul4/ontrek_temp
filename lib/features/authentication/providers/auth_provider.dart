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
import 'package:ontrek/core/utils/app_constant.dart';

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
  String? userid;
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

  // void navigatePushReplacementFnc(Widget screen) {
  //   navigatorKey.currentState!.pushReplacement(CupertinoPageRoute(
  //     builder: (context) => screen,
  //   ));
  // }
  //
  // // void navigatePushFnc(Widget screen) {
  // //   navigatorKey.currentState!.push(CupertinoPageRoute(
  // //     builder: (context) => screen,
  // //   ));
  // // }





  Future<LoginModel?> apiCallVerifyNumber({bool? isFromOtpScreen,String? phoneNumber,int? countryCodeFromOtp,required Function() navigatorFnc}) async {
     loaderFnc(true);
    Map<String, dynamic> body;

    if (Platform.isIOS) {
      var iosInfo = await deviceInfo.iosInfo;
      body = {
        "countryCode": isFromOtpScreen == true ? countryCodeFromOtp : countryCode,
        "phoneNumber": isFromOtpScreen == true ? phoneNumber :mobileNumberController.text,
        "deviceInfo": {
          "deviceId": iosInfo.identifierForVendor,
          "deviceModel": iosInfo.model,
          "deviceOs ": iosInfo.systemName,
          "osVersion ": iosInfo.systemVersion,
        }
      };
    } else {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      body = {
        "countryCode": isFromOtpScreen == true ? countryCodeFromOtp : countryCode,
        "phoneNumber": isFromOtpScreen == true ? phoneNumber :mobileNumberController.text,
        "deviceInfo": {
          "deviceId": androidInfo.id,
          "deviceModel": androidInfo.model,
          "deviceOs ": androidInfo.version.release,
          "osVersion ": Platform.operatingSystemVersion,
          "appVersion": AppConstant.appVersionAndroid
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
        userid = loginModel?.data?.appUserId;

        if(isFromOtpScreen == true){

        }else{
          navigatorFnc();
        }

      } else {
        if (loginModel?.isValidationFailed == true) {
          AppUtils.showDialogBoxWithOneButton(
              titleText: "Information",
              context: navigatorKey.currentState!.context,
              text: loginModel?.message ?? "");
        }
        if (loginModel?.isError == true) {
          AppUtils.showDialogBoxWithOneButton(
              titleText: "Error",
              context: navigatorKey.currentState!.context,
              text: "Something went wrong!");
        }
      }
    } catch (e) {
      print("inCatch ${loginModel?.message}");
      print("inCatchE ${e}");
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
    return loginModel;
  }

  checkValidationAndCallLoginApi({required Function() navigatorFnc}) {
    if (mobileNumberController.text.isEmpty) {
      AppUtils.showSnackBarWithColor(
          message: "Please Enter Phone Number", giveColor: Colors.red);
    } else {
      if (isValid ?? false) {
        apiCallVerifyNumber(navigatorFnc: navigatorFnc);
      }
    }
  }

  Future<LoginModel?> apiCallVerifyOtp({String? otpText,required Function() navigatorFnc}) async {
    fetchingFnc(true);
    try {
      Map<String, dynamic> body;
      if (Platform.isIOS) {
        var iosInfo = await deviceInfo.iosInfo;
        body = {
          "userId": userid,
          "otp": otpText,
          "deviceInfo": {
            "deviceId": iosInfo.identifierForVendor,
            "deviceModel": iosInfo.model,
            "deviceOs ": iosInfo.systemName,
            "osVersion ": Platform.operatingSystemVersion,
          }
        };
      } else {
        AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        body = {
          "userId": userid,
          "otp": otpText,
          "deviceInfo": {
            "deviceId": androidInfo.id,
            "deviceModel": androidInfo.model,
            "deviceOs ": androidInfo.version.release,
            "osVersion ": Platform.operatingSystemVersion,
            "appVersion": AppConstant.appVersionAndroid
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
          navigatorFnc();
        });
      } else {
        if (loginModel?.isValidationFailed == true) {
          AppUtils.showDialogBoxWithOneButton(
              titleText: "Information",
              context: navigatorKey.currentState!.context,
              text: loginModel?.message ?? "");
        }
        if (loginModel?.isError == true) {
          AppUtils.showDialogBoxWithOneButton(
              titleText: "Error",
              context: navigatorKey.currentState!.context,
              text: "Something went wrong!");
        }
      }
    } catch (e) {
      print("inCatch ${loginModel?.message}");
      print("inCatchE ${e}");
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
    fetchingFnc(false);
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
        PreferenceHelper.REPORTING_MANAGER, loginModel?.data?.managerName ?? '');
    PreferenceHelper.setString(
        PreferenceHelper.PROFILE_PIC, loginModel?.data?.profilePic ?? '');
    PreferenceHelper.setBool(PreferenceHelper.ALLOW_FG_AUTH,
        loginModel?.data?.appUserConfigAttendanceRequest?.allowFgAuth ?? false);
    PreferenceHelper.setBool(
        PreferenceHelper.AllowCheckInCheckOut,
        loginModel?.data?.appUserConfigAttendanceRequest?.allowCheckinOut ??
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
    PreferenceHelper.setBool(PreferenceHelper.CHECKOUT_REMINDER, loginModel?.data?.appUserConfigTrackingRequest?.allowCheckoutReminder ?? false);
    PreferenceHelper.setInt(PreferenceHelper.CHECKOUT_REMINDER_METER, loginModel?.data?.appUserConfigTrackingRequest?.chekoutReminderDistance ?? 0);

    PreferenceHelper.setBool(
        PreferenceHelper.LIVE_LOCATION_TRACKING,
        loginModel?.data?.appUserConfigTrackingRequest?.allowLiveTracking ??
            false);
    PreferenceHelper.setBool(
        PreferenceHelper.ALLOW_WAITING,
        loginModel?.data?.appUserConfigTrackingRequest?.allowIdleMarker ??
            false);
    PreferenceHelper.setInt(
        PreferenceHelper.LIVE_LOCATION_INTERVAL,
        loginModel?.data?.appUserConfigTrackingRequest?.liveTrackingInterval ??
            0);
    PreferenceHelper.setInt(PreferenceHelper.WAITING_TIME_INTERVAL,
        loginModel?.data?.appUserConfigTrackingRequest?.idleMarkerTime ?? 0);
    PreferenceHelper.setString(
        PreferenceHelper.REPORTING_MANAGER_PHONE_NO, loginModel?.data?.managerPhoneNo?? '');

    return true;
  }

  checkValidationAndCallVerifyOtpApi(
      {required TextEditingController controller,required Function() navigatorFnc}) {
    if (controller.text.isEmpty) {
      AppUtils.showSnackBarWithColor(
          message: "Please Enter One Time Password!", giveColor: Colors.red);
    } else if (controller.text.length < 4) {
      AppUtils.showSnackBarWithColor(
          message: "Please Enter 4 digit code!", giveColor: Colors.red);
    } else {
      apiCallVerifyOtp(otpText: controller.text,navigatorFnc: navigatorFnc);
    }
  }
}
