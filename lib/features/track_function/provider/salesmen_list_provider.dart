import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:ontrek/core/services/api_constants.dart';
import 'package:ontrek/core/services/network_repository.dart';
import 'package:ontrek/core/storage/preference_helper.dart';
import 'package:ontrek/core/utils/App_utils.dart';
import 'package:ontrek/core/utils/app_constant.dart';
import 'package:ontrek/features/track_function/model/salemen_list_model.dart';

class SalesMenListProvider extends ChangeNotifier{
  bool _isFetching = false;
  bool _isLoading = false;
  bool _isUploading = false;
  bool _isAdding = false;

  bool get isFetching => _isFetching;

  bool get isLoading => _isLoading;

  bool get isUploading => _isUploading;

  bool get isAdding => _isAdding;

  GetSalesMenListModel? getSalesMenListModel;

  Future<GetSalesMenListModel?> apiCallGetSalesManList(
      {String? eventDate, String? managerId,String? filter,String? orgId}) async {
    // var managerId = PreferenceHelper.getInt(PreferenceHelper.USER_UID);
    _isFetching = true;
    notifyListeners();

    Map<String, dynamic> body =
      {
        "managerId": /*"919e3ede-00e1-4502-87f2-6b2459554c9c"*/managerId,
        "eventDate": /*AppUtils.dateFormat(date: DateTime.now(),dateFormat: AppConstant.dateFormat)*/eventDate,
        "fillter": filter,
        "orgId":/*"10bce922-213c-46dd-aa94-0c47883b76d3"*/orgId
      };
    try {
      String endPoint = ApiConstants.getSalesMenList;

      var response = await callPostMethod(endPoint,body);
      getSalesMenListModel = GetSalesMenListModel.fromJson(json.decode(response));
      print('response ${getSalesMenListModel?.toJson()}');
    } catch (e) {
      print('catch at GetEmployee_Provider ${e}');
      bool isInternetAvailable = await AppUtils.checkInternetConnectivity();
      if (!isInternetAvailable) {
        getSalesMenListModel = GetSalesMenListModel(
            message: "Internet is not available, please try again!");
      } else {
        getSalesMenListModel = GetSalesMenListModel(message: "Something went wrong!");
      }
    }
    _isFetching = false;
    notifyListeners();
    return getSalesMenListModel;
  }
}