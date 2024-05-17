import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:ontrek/core/services/api_constants.dart';
import 'package:ontrek/core/services/network_repository.dart';
import 'package:ontrek/core/storage/preference_helper.dart';
import 'package:ontrek/core/utils/App_utils.dart';
import 'package:ontrek/core/utils/app_constant.dart';
import 'package:ontrek/features/task_list/model/task_model.dart';
import 'package:ontrek/main.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class TaskProvider extends ChangeNotifier{
  bool _isFetching = false;
  bool _isLoading = false;
  bool _isUploading = false;
  bool _isAdding = false;

  bool get isFetching => _isFetching;

  bool get isLoading => _isLoading;

  bool get isUploading => _isUploading;

  bool get isAdding => _isAdding;

  GetAllTaskModel? getAllTaskModel;
  PanelController panelController = PanelController();
  DateTime selectedDate = DateTime.now();
  bool? isInternetAvailable;


  Future<GetAllTaskModel?> apiCallGetTaskByIdList(
      {String? date, String? userId,String? orgId,String? filter}) async {
    var userId = PreferenceHelper.getString(PreferenceHelper.USER_ID);
    var orgId = PreferenceHelper.getString(PreferenceHelper.ORG_ID);
    _isFetching = true;
    notifyListeners();
    Map<String, dynamic> body =

    {
      "userId": userId,
      "taskDate": AppUtils.getDate(date: date ?? "", format: AppConstant.dateFormat),
      "fillter": "",
      "orgId": orgId
    };

    try {
      String endPoint = ApiConstants.getAllTaskByUserId;
      var response = await callPostMethod(endPoint,body);
      getAllTaskModel = GetAllTaskModel.fromJson(json.decode(response));
      print('response ${getAllTaskModel?.toJson()}');
      if(getAllTaskModel?.isError == false && getAllTaskModel?.isValidationFailed == false){

      }else{
        if( getAllTaskModel?.isValidationFailed == true){
          AppUtils.showDialogBoxWithOneButton(
            titleText: "Information",
              context: navigatorKey.currentState!.context,
              text: getAllTaskModel?.message ?? "");
        }
      }
    } catch (e) {
      print('catch at Get Task Provider $e');
      // AppUtils.showDialogBoxWithOneButton(context: navigatorKey.currentContext,text: getAllTaskModel?.message ?? "");
      isInternetAvailable = await AppUtils.checkInternetConnectivity();
      if (isInternetAvailable == false) {
        AppUtils.showDialogBoxWithOneButton(
            titleText: "Internet Off Alert",
            text: "Internet is not available. Please Enable Mobile data or wifi.",
            context: navigatorKey.currentState!.context);
      } else {
        AppUtils.showDialogBoxWithOneButton(
            titleText: "Error",
            text: "Something went wrong!",
            context: navigatorKey.currentState!.context);
      }
    }
    _isFetching = false;
    notifyListeners();
    return getAllTaskModel;
  }
}