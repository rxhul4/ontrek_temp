import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:ontrek/core/services/api_constants.dart';
import 'package:ontrek/core/services/network_repository.dart';
import 'package:ontrek/core/utils/App_utils.dart';
import 'package:ontrek/features/view_task/model/get_task_by_id_model.dart';
import 'package:ontrek/main.dart';

class ViewTaskProvider extends ChangeNotifier{
  bool _isFetching = false;
  bool _isLoading = false;
  bool _isUploading = false;
  bool _isAdding = false;

  bool get isFetching => _isFetching;

  bool get isLoading => _isLoading;

  bool get isUploading => _isUploading;

  bool get isAdding => _isAdding;
  GetTaskById? getTaskById;

  loaderFnc(bool isLoading) {
    _isLoading = isLoading;
    notifyListeners();
  }

  fetchingFnc(bool isLoading) {
    _isFetching = isLoading;
    notifyListeners();
  }



  Future<GetTaskById?> apiCallGetSalesManList({
    String? taskFormId,
}) async {

    fetchingFnc(true);
    Map<String, dynamic> body = {
      "taskFormId": taskFormId
    };
    try {
      String endPoint = ApiConstants.getTaskById;
      var response = await callPostMethod(endPoint, body);
      getTaskById = GetTaskById.fromJson(json.decode(response));
      print('response ${getTaskById?.toJson()}');
      if (getTaskById?.isError == false && getTaskById?.isValidationFailed == false) {
      } else {
        AppUtils.showDialogBoxWithOneButton(text: getTaskById?.message ?? "",context: navigatorKey.currentState!.context);
      }
    } catch (e) {
      print('catch at GetEmployee_Provider $e');
      bool isInternetAvailable = await AppUtils.checkInternetConnectivity();
      if (!isInternetAvailable) {
        getTaskById = GetTaskById(
            message: "Internet is not available, please try again!");
      } else {
        getTaskById =
            GetTaskById(message: "Something went wrong!");
      }
    }
    fetchingFnc(false);
    return getTaskById;
  }
}