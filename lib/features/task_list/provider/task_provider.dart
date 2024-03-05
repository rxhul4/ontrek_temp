import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:ontrek/core/services/api_constants.dart';
import 'package:ontrek/core/services/network_repository.dart';
import 'package:ontrek/core/storage/preference_helper.dart';
import 'package:ontrek/core/utils/App_utils.dart';
import 'package:ontrek/features/task_list/model/task_model.dart';

class TaskProvider extends ChangeNotifier{
  bool _isFetching = false;
  bool _isLoading = false;
  bool _isUploading = false;
  bool _isAdding = false;

  bool get isFetching => _isFetching;

  bool get isLoading => _isLoading;

  bool get isUploading => _isUploading;

  bool get isAdding => _isAdding;

  GetTaskModel? getTaskModel;


  Future<GetTaskModel?> apiCallGetTaskByIdList(
      {String? date, String? userId,String? orgId}) async {
    var userId = PreferenceHelper.getString(PreferenceHelper.USER_UID);
    var orgId = PreferenceHelper.getString(PreferenceHelper.ORG_ID);
    _isFetching = true;
    notifyListeners();
    Map<String, dynamic> body =
    {
    "orgId": orgId,
    "userId": userId,
    "date": date
    };
    try {
      String endPoint = ApiConstants.getAllTaskByUserId;

      var response = await callPostMethod(endPoint,body);
      getTaskModel = GetTaskModel.fromJson(json.decode(response));
      print('response ${getTaskModel?.toJson()}');
    } catch (e) {
      print('catch at Get Task Provider ${e}');
      bool isInternetAvailable = await AppUtils.checkInternetConnectivity();
      if (!isInternetAvailable) {
        getTaskModel = GetTaskModel(
            message: "Internet is not available, please try again!");
      } else {
        getTaskModel = GetTaskModel(message: "Something went wrong!");
      }
    }
    _isFetching = false;
    notifyListeners();
    return getTaskModel;
  }
}