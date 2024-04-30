import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:ontrek/core/services/api_constants.dart';
import 'package:ontrek/core/services/network_repository.dart';
import 'package:ontrek/core/utils/App_utils.dart';
import 'package:ontrek/core/utils/app_constant.dart';
import 'package:ontrek/features/check_out/model/check_out_form_model.dart';
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


  TaskByIdModel? taskByIdModel;
  GetTotByGroupTypeModel? getTotByGroupTypeModel;


  loaderFnc(bool isLoading) {
    _isLoading = isLoading;
    notifyListeners();
  }

  fetchingFnc(bool isLoading) {
    _isFetching = isLoading;
    notifyListeners();
  }


  Future<TaskByIdModel?> apiCallGetTaskByID({
    String? taskFormId,
}) async {
    fetchingFnc(true);
    Map<String, dynamic> body = {
      "taskFormId": taskFormId
    };
    try {
      String endPoint = ApiConstants.getTaskById;
      var response = await callPostMethod(endPoint, body);
      taskByIdModel = TaskByIdModel.fromJson(json.decode(response));
      print('response ${taskByIdModel?.toJson()}');
      if (taskByIdModel?.isError == false && taskByIdModel?.isValidationFailed == false) {


      } else {
        AppUtils.showDialogBoxWithOneButton(text: taskByIdModel?.message ?? "",context: navigatorKey.currentState!.context);
      }
    } catch (e) {
      print('catch at GetEmployee_Provider $e');
      bool isInternetAvailable = await AppUtils.checkInternetConnectivity();
      if (!isInternetAvailable) {
        taskByIdModel = TaskByIdModel(
            message: "Internet is not available, please try again!");
      } else {
        taskByIdModel =
            TaskByIdModel(message: "Something went wrong!");
      }
    }
    fetchingFnc(false);
    return taskByIdModel;
  }


  Future<GetTotByGroupTypeModel?> apiCallGetTotByType({
    String? groupType
  }) async {
    // loaderFnc(true);
    fetchingFnc(true);
    Map<String,dynamic>  body ={
      "groupType": groupType,
    };
    try {
      String endPoint = ApiConstants.getTotByGroupType;
      var response = await callPostMethod(endPoint,body);
      getTotByGroupTypeModel = GetTotByGroupTypeModel.fromJson(json.decode(response));
      print("reponse : $response");
    } catch (e) {
      print('catch at getTotByGroupType $e');
      bool isInternetAvailable = await AppUtils.checkInternetConnectivity();
      if (!isInternetAvailable) {
        getTotByGroupTypeModel = GetTotByGroupTypeModel(
            message: "Internet is not available, please try again!");
      } else {
        getTotByGroupTypeModel =
            GetTotByGroupTypeModel(message: "Something went wrong!");
      }
    }
    // lo(false);
    fetchingFnc(false);
    return getTotByGroupTypeModel;
  }

  Future<TaskByIdModel?> apiCallUpdateStatus({
   String? taskFormId,
    String? assignedBy,
    String? assignedTo,
    String? totTaskStatusId,
    String? taskTitle,
    String? taskDescription,
    String? startDate,
    String? endDate,
  }) async {
    loaderFnc(true);
    Map<String,dynamic>  body ={
      "taskFormId": taskFormId,
      "assignedBy": assignedBy,
      "assignedTo": assignedTo,
      "totTaskStatusId": totTaskStatusId,
      "taskTitle": taskTitle,
      "taskDescription": taskDescription,
      "startDate": AppUtils.getDate(date: startDate.toString(), format: "yyyy-MM-dd"),
      "endDate": AppUtils.getDate(date: endDate.toString(), format: "yyyy-MM-dd")
    };
    try {
      String endPoint = ApiConstants.updateTaskStatus;
      var response = await callPostMethod(endPoint,body);
      taskByIdModel = TaskByIdModel.fromJson(json.decode(response));
      print("reponse : $response");

    } catch (e) {
      print('catch at updateTaskStatus $e');
      bool isInternetAvailable = await AppUtils.checkInternetConnectivity();
      if (!isInternetAvailable) {
        taskByIdModel = TaskByIdModel(
            message: "Internet is not available, please try again!");
      } else {
        taskByIdModel =
            TaskByIdModel(message: "Something went wrong!");
      }
    }
    loaderFnc(false);
    return taskByIdModel;
  }
}