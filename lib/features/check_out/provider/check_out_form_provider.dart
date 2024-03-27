import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:ontrek/core/services/api_constants.dart';
import 'package:ontrek/core/services/network_repository.dart';
import 'package:ontrek/core/utils/App_utils.dart';
import 'package:ontrek/features/check_out/model/check_out_form_model.dart';

class CheckOutProvider extends ChangeNotifier {
  bool _isFetching = false;
  bool _isLoading = false;
  bool _isUploading = false;
  bool _isAdding = false;

  bool get isFetching => _isFetching;

  bool get isLoading => _isLoading;

  bool get isUploading => _isUploading;

  bool get isAdding => _isAdding;

  loaderFnc(bool isLoading) {
    _isLoading = isLoading;
    notifyListeners();
  }

  fetchingFnc(bool isLoading) {
    _isFetching = isLoading;
    notifyListeners();
  }


  GetTotByGroupTypeModel? getTotByGroupTypeModel;

  Future<GetTotByGroupTypeModel?> apiCallGetTotByType() async {
    fetchingFnc(true);

    Map<String,dynamic>  body ={
      // "trackingEventId": AppConstant.checkOutEvent
      "groupType": "visit_type"
    };
    try {
      String endPoint = ApiConstants.getTotByGroupType;
      var response = await callPostMethod(endPoint,body);
      getTotByGroupTypeModel = GetTotByGroupTypeModel.fromJson(json.decode(response));
      print("reponse : $response");
    } catch (e) {
      print('catch at getAllOrders ${e}');
      bool isInternetAvailable = await AppUtils.checkInternetConnectivity();
      if (!isInternetAvailable) {
        getTotByGroupTypeModel = GetTotByGroupTypeModel(
            message: "Internet is not available, please try again!");
      } else {
        getTotByGroupTypeModel =
            GetTotByGroupTypeModel(message: "Something went wrong!");
      }
    }
    fetchingFnc(false);
    return getTotByGroupTypeModel;
  }
}
