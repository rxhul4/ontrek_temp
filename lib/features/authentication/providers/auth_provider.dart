import 'dart:convert';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:ontrek/core/services/api_constants.dart';
import 'package:ontrek/core/services/network_repository.dart';
import 'package:ontrek/core/utils/App_utils.dart';
import 'package:ontrek/core/utils/app_constant.dart';
import 'package:ontrek/features/authentication/models/login_model.dart';

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


  Future<LoginModel?> apiCallLogin(
      {
        int? countryCode,
        String? phoneNumber,

      }) async {
    _isLoading = true;
    notifyListeners();
    // var loginDate = AppUtils.dateFormat(
    //     dateFormat: AppConstant.dateFormat, date: DateTime.now());

    Map<String, dynamic> body = {
      "countryCode" :countryCode,
      "phoneNumber": phoneNumber
    };
    try {
      loginModel = LoginModel();
      String endPoint = ApiConstants.login;
      final response = await callPostMethod(endPoint, body);
      loginModel = LoginModel.fromJson(json.decode(response));
      print("response : ${response}");
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
}
