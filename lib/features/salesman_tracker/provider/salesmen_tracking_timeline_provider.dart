import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:ontrek/core/services/api_constants.dart';
import 'package:ontrek/core/services/network_repository.dart';
import 'package:ontrek/core/utils/App_utils.dart';
import 'package:ontrek/core/utils/app_constant.dart';
import 'package:ontrek/features/salesman_tracker/model/salesmen_tracking_detailes.dart';
import 'package:ontrek/main.dart';



class SalemenTimeLineProvider extends ChangeNotifier{

  bool _isFetching = false;
  bool _isLoading = false;
  bool _isUploading = false;
  bool _isAdding = false;

  bool get isFetching => _isFetching;

  bool get isLoading => _isLoading;

  bool get isUploading => _isUploading;

  bool get isAdding => _isAdding;

  GetTimeLineModel? getTimeLineModel;
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


  Future<GetTimeLineModel?> apiCallGetTimeLine({String? userid}) async {


    Map<String,dynamic> body ={
      "userId": userid,
      "eventDate": AppUtils.getDate(date: DateTime.now().toString(),format:  AppConstant.dateFormat)
    };
    try {
      String endPoint = ApiConstants.getSalesMenTimeLine;
      var response = await callPostMethod(endPoint,body);
      getTimeLineModel = GetTimeLineModel.fromJson(json.decode(response));
      print('response ${getTimeLineModel?.toJson()}');
    } catch (e) {
      print('catch at GetTimeLineProvider ${e}');
      bool isInternetAvailable = await AppUtils.checkInternetConnectivity();
      if (!isInternetAvailable) {
        getTimeLineModel = GetTimeLineModel(
            message: "Internet is not available, please try again!");
      } else {
        getTimeLineModel = GetTimeLineModel(message: "Something went wrong!");
      }
    }
    _isFetching = false;
    notifyListeners();
    return getTimeLineModel;
  }

}