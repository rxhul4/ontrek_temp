import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:ontrek/core/services/api_constants.dart';
import 'package:ontrek/core/services/network_repository.dart';
import 'package:ontrek/core/storage/preference_helper.dart';
import 'package:ontrek/core/utils/App_utils.dart';
import 'package:ontrek/core/utils/app_constant.dart';
import 'package:ontrek/features/home/day_end_request_approval/model/day_end_approval_model.dart';
import 'package:ontrek/features/home/reports/model/approve_request_model.dart';

import '../../../../main.dart';

class DayEndRequestProvider extends ChangeNotifier{
  bool _isFetching = false;
  bool _isLoading = false;
  bool _isUploading = false;
  bool _isAdding = false;

  bool get isFetching => _isFetching;

  bool get isLoading => _isLoading;

  bool get isUploading => _isUploading;

  bool get isAdding => _isAdding;

  DayEndRequestModel? dayEndRequestModel;
  ApproveRequestModel? approveRequestModel;

  DateTime myDayEndSelectedDate = DateTime.now();
  DateTime employeeDayEndSelectedDate = DateTime.now();
  bool? isMyRequestApproved;
  bool? isEmployeeRequestApproved;


  filterDayEndRequest({bool? isApproved,int? index}){

    index == 0 ? isMyRequestApproved = isApproved : isEmployeeRequestApproved = isApproved;
    notifyListeners();
  }




  Future<DayEndRequestModel?> apiCallGetDayEndRequestList(
      {String? requestedDate,
        String? empName,
        String? organizationId,
       }) async {
    var userId = PreferenceHelper.getString(PreferenceHelper.USER_ID);
    var organizationId = PreferenceHelper.getString(PreferenceHelper.ORG_ID);
    _isFetching = true;
    notifyListeners();
    Map<String, dynamic> body = {
      "empName": "",
      "userId": userId,
      "orgId": organizationId,
      "requestedDate": AppUtils.dateFormat(date: myDayEndSelectedDate,dateFormat: AppConstant.dateFormat),
      "isApproved": isMyRequestApproved,
      "pageNo": 1,
      "pageSize": 10
    };
    try {
      String endPoint = ApiConstants.dayEndMyRequestList;
      var response = await callPostMethod(endPoint, body);
      dayEndRequestModel = DayEndRequestModel.fromJson(json.decode(response));
      print('response ${dayEndRequestModel?.toJson()}');
      if (dayEndRequestModel?.isError == false &&
          dayEndRequestModel?.isValidationFailed == false) {

      } else {
        if (dayEndRequestModel?.isValidationFailed == true) {
          AppUtils.showDialogBoxWithOneButton(
              titleText: "Information",
              context: navigatorKey.currentState!.context,
              text: dayEndRequestModel?.message ?? "");
        }
      }
    } catch (e) {
      print('catch at Get DayEnd Provider $e');
      bool isInternetAvailable = await AppUtils.checkInternetConnectivity();
      if (isInternetAvailable == false) {
        AppUtils.showDialogBoxWithOneButton(
            titleText: "Internet Off Alert",
            text:
            "Internet is not available. Please Enable Mobile data or wifi.",
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
    return dayEndRequestModel;
  }

  Future<DayEndRequestModel?> apiCallEmployeeRequests(
      {String? requestedDate,
        String? empName,
        String? organizationId,
      }) async {
    var userId = PreferenceHelper.getString(PreferenceHelper.USER_ID);
    var organizationId = PreferenceHelper.getString(PreferenceHelper.ORG_ID);
    _isFetching = true;
    notifyListeners();
    Map<String, dynamic> body = {
      "empName": "",
      "userId": userId,
      "orgId": organizationId,
      "requestedDate":  AppUtils.dateFormat(date: employeeDayEndSelectedDate,dateFormat: AppConstant.dateFormat),
      "isApproved": isEmployeeRequestApproved,
      "pageNo": 1,
      "pageSize": 10
    };
    try {
      String endPoint = ApiConstants.dayEndMyEmployeeRequest;
      var response = await callPostMethod(endPoint, body);
      dayEndRequestModel = DayEndRequestModel.fromJson(json.decode(response));
      print('response ${dayEndRequestModel?.toJson()}');
      if (dayEndRequestModel?.isError == false &&
          dayEndRequestModel?.isValidationFailed == false) {

      } else {
        if (dayEndRequestModel?.isValidationFailed == true) {
          AppUtils.showDialogBoxWithOneButton(
              titleText: "Information",
              context: navigatorKey.currentState!.context,
              text: dayEndRequestModel?.message ?? "");
        }
      }
    } catch (e) {
      print('catch at Get DayEnd Provider $e');
      bool isInternetAvailable = await AppUtils.checkInternetConnectivity();
      if (isInternetAvailable == false) {
        AppUtils.showDialogBoxWithOneButton(
            titleText: "Internet Off Alert",
            text:
            "Internet is not available. Please Enable Mobile data or wifi.",
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
    return dayEndRequestModel;
  }


  Future<ApproveRequestModel?> apiCallApproveRequest(
      {String? userId, String? orgId,String? sessionId,String? sessionEndDateTime}) async {
    var organizationId = PreferenceHelper.getString(PreferenceHelper.ORG_ID);
    _isAdding = true;

    notifyListeners();
    Map<String, dynamic> body = {
      "userId": userId,
      "orgId": organizationId,
      "sessionId": sessionId,
      "sessionEndDateTime": sessionEndDateTime
    };
    try {
      String endPoint = ApiConstants.approveRequest;
      var response = await callPostMethod(endPoint, body);
      approveRequestModel = ApproveRequestModel.fromJson(json.decode(response));
      print('response ${approveRequestModel?.toJson()}');
      if (approveRequestModel?.isError == false && approveRequestModel?.isValidationFailed == false) {
        await apiCallGetDayEndRequestList();
      } else {
        if (approveRequestModel?.isValidationFailed == true) {
          AppUtils.showDialogBoxWithOneButton(
              titleText: "Information",
              context: navigatorKey.currentState!.context,
              text: approveRequestModel?.message ?? "");
        }
      }
    } catch (e) {
      print('catch at Get Task Provider $e');
      // AppUtils.showDialogBoxWithOneButton(context: navigatorKey.currentContext,text: getAllTaskModel?.message ?? "");
      bool isInternetAvailable = await AppUtils.checkInternetConnectivity();
      if (isInternetAvailable == false) {
        AppUtils.showDialogBoxWithOneButton(
            titleText: "Internet Off Alert",
            text:
            "Internet is not available. Please Enable Mobile data or wifi.",
            context: navigatorKey.currentState!.context);
      } else {
        AppUtils.showDialogBoxWithOneButton(
            titleText: "Error",
            text: "Something went wrong!",
            context: navigatorKey.currentState!.context);
      }
    }
    _isAdding = false;
    notifyListeners();
    return approveRequestModel;
  }


}