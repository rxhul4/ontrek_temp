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

  DayEndRequestListModel? dayEndRequestListModel;
  ApproveRequestModel? approveRequestModel;



  Future<DayEndRequestListModel?> apiCallGetDayEndRequestList(
      {String? requestedDate,
        String? empName,
        String? organizationId,
        bool? isApproved}) async {
    var userId = PreferenceHelper.getString(PreferenceHelper.USER_ID);
    var organizationId = PreferenceHelper.getString(PreferenceHelper.ORG_ID);
    _isFetching = true;
    notifyListeners();
    Map<String, dynamic> body = {
      "empName": "",
      "orgId": organizationId,
      // "requestedDate": AppUtils.dateFormat(date: DateTime.now(),dateFormat: AppConstant.dateFormat),
      "isApproved": isApproved ?? true,
      // "pageSize" : 10,
      // "pageNo" : 1
    };
    try {
      String endPoint = ApiConstants.getDayEndRequestList;
      var response = await callPostMethod(endPoint, body);
      dayEndRequestListModel = DayEndRequestListModel.fromJson(json.decode(response));
      print('response ${dayEndRequestListModel?.toJson()}');
      if (dayEndRequestListModel?.isError == false &&
          dayEndRequestListModel?.isValidationFailed == false) {

      } else {
        if (dayEndRequestListModel?.isValidationFailed == true) {
          AppUtils.showDialogBoxWithOneButton(
              titleText: "Information",
              context: navigatorKey.currentState!.context,
              text: dayEndRequestListModel?.message ?? "");
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
    _isFetching = false;
    notifyListeners();
    return dayEndRequestListModel;
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
      if (approveRequestModel?.isError == false &&
          approveRequestModel?.isValidationFailed == false) {

        await apiCallGetDayEndRequestList(isApproved: false,);

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