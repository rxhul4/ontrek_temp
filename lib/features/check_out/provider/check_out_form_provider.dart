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

  CheckOutFormModel? checkOutFormModel;

  Future<CheckOutFormModel?> apiCallGetTotByType() async {
    _isFetching = true;
    notifyListeners();
    try {
      String endPoint = "${ApiConstants.getTableOfTableByType}?tot_type=visit_type";
      var response = await callGetMethod(endPoint);
      checkOutFormModel = CheckOutFormModel.fromJson(json.decode(response));
      print("reponse : $response");
    } catch (e) {
      print('catch at getAllOrders ${e}');
      bool isInternetAvailable = await AppUtils.checkInternetConnectivity();
      if (!isInternetAvailable) {
        checkOutFormModel = CheckOutFormModel(
            message: "Internet is not available, please try again!");
      } else {
        checkOutFormModel =
            CheckOutFormModel(message: "Something went wrong!");
      }
    }
    _isFetching = false;
    notifyListeners();
    return checkOutFormModel;
  }
}
