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

  Map<String,dynamic> sessionEventList = {};
  List<Map<String, dynamic>> eventDataList = [];
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


  Future<GetTimeLineModel?> apiCallGetTimeLine({String? userid, String? date}) async {

    _isFetching = true;
    eventDataList.clear();
    notifyListeners();
    Map<String,dynamic> body ={
      "userId": userid,
      "eventDate": AppUtils.getDate(date: date ?? "",format:  AppConstant.dateFormat)
      // "userId": "082e75ff-5ed5-4c92-9181-02a52a1a5087",
      // "eventDate": "2024-03-15T00:00:00"
    };
    try {
      String endPoint = ApiConstants.getSalesMenTimeLine;
      var response = await callPostMethod(endPoint,body);
      getTimeLineModel = GetTimeLineModel.fromJson(json.decode(response));
      print('response ${getTimeLineModel?.toJson()}');
      if(getTimeLineModel?.isError == false && getTimeLineModel?.isValidationFailed == false){

        getTimeLineModel?.data?.sessionTimeLine?.forEach((session) {
          session.sessionEvents?.forEach((event) {

            String eventName = event.eventName ?? "";
            String eventDateTime = event.eventStartDate ?? "";
            String eventCode = event.eventCode ?? "";
            String eventActivityPlace = event.eventActivityPlace ?? "";
            Map<String,dynamic> body = {
              "eventName": eventName,
              "eventDate": eventDateTime,
              "eventCode": eventCode,
              "eventActivityPlace" : eventActivityPlace
            };
            if (eventName.isNotEmpty && eventDateTime.isNotEmpty) {
              eventDataList.add(body);
            }
          });
        });

        print("Event Map: $eventDataList");

      }else{

      }
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