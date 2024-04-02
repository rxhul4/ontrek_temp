import 'dart:async';
import 'dart:convert';

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
    Map<String, dynamic> body = {
      "countryCode": countryCode,
      "phoneNumber": mobileNumberController.text
    };
    try {
      loginModel = LoginModel();
      String endPoint = ApiConstants.login;
      final response = await callPostMethod(endPoint, body);
      loginModel = LoginModel.fromJson(json.decode(response));
      print("response : ${response}");
      if (loginModel?.isError == false &&
          loginModel?.isValidationFailed == false) {
        PreferenceHelper.setString(
            PreferenceHelper.FULL_NAME, loginModel?.data?.userName ?? "");
        navigatePushFnc(OTPVerificationCode(
          appUserId: loginModel?.data?.appUserId,
        ));
      } else {
        AppUtils.dialogWidget(
            loginModel?.message ?? "", navigatorKey.currentState!.context);
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
        // navigatePushReplacementFnc(OTPVerificationCode());
      }
    }
  }

  Future<LoginModel?> apiCallVerifyOtp(/*TextEditingController controller*/) async {
    _isLoading = true;
    notifyListeners();

    Map<String, dynamic> body = {"userId": userUid, "otp": otpController.text};
    try {
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
        AppUtils.dialogWidget(
            loginModel?.message ?? "", navigatorKey.currentState!.context);
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
    _isLoading = false;
    notifyListeners();
    return loginModel;
  }

  Future<bool> saveDataToPref() async {
    PreferenceHelper.setBool(PreferenceHelper.IS_LOGIN, true);
    PreferenceHelper.setString(
        PreferenceHelper.FULL_NAME, loginModel?.data?.userName ?? '');
    PreferenceHelper.setString(
        PreferenceHelper.USER_UID, loginModel?.data?.appUserId ?? '');
    PreferenceHelper.setString(
        PreferenceHelper.ORG_ID, loginModel?.data?.orgId ?? '');
    PreferenceHelper.setString(
        PreferenceHelper.EMAIL, loginModel?.data?.userEmail ?? '');
    PreferenceHelper.setString(
        PreferenceHelper.PHONE_NO, loginModel?.data?.phoneNo ?? '');
    PreferenceHelper.setString(
        PreferenceHelper.ROLE_NAME, loginModel?.data?.roleName ?? '');
    PreferenceHelper.setString(
        PreferenceHelper.AUTH_TOKEN, loginModel?.data?.token ?? '');

    print("data : ${PreferenceHelper.getBool(PreferenceHelper.IS_LOGIN)}");
    return true;
  }

  checkValidationAndCallVerifyOtpApi(/*TextEditingController controller*/) {
    if (otpController.text.isEmpty) {
      AppUtils.showSnackBarWithColor(
          message: "Please Enter One Time Password!", giveColor: Colors.red);
    } else if (otpController.text.length < 4) {
      AppUtils.showSnackBarWithColor(
          message: "Please Enter 4 digit code!", giveColor: Colors.red);
    } else {
      apiCallVerifyOtp();
      // navigatePushReplacementFnc(const DashBoard());
    }
  }
}
