import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:ontrek/core/services/api_constants.dart';
import 'package:ontrek/core/services/network_repository.dart';
import 'package:ontrek/core/utils/App_utils.dart';
import 'package:ontrek/features/salesman_tracker/model/salesmen_tracking_detailes.dart';

class SaleMenTackingTimeLineProvider extends ChangeNotifier{

  bool _isFetching = false;
  bool _isLoading = false;
  bool _isUploading = false;
  bool _isAdding = false;

  bool get isFetching => _isFetching;

  bool get isLoading => _isLoading;

  bool get isUploading => _isUploading;

  bool get isAdding => _isAdding;

  GetTimeLineModel? getTimeLineModel;

  Future<GetTimeLineModel?> apiCallGetTimeLine({String? userid,String? eventDate}) async {
    _isFetching = true;
    notifyListeners();

    Map<String,dynamic> body ={
      "userId": userid,
      "eventDate": eventDate
    };
    try {
      String endPoint = ApiConstants.getSalesMenTimeLine;
      var response = await callPostMethod(endPoint,body);
      getTimeLineModel = GetTimeLineModel.fromJson(json.decode(response));
      print('response ${getTimeLineModel?.toJson()}');
    } catch (e) {
      print('catch at GetEmployee_Provider2 ${e}');
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