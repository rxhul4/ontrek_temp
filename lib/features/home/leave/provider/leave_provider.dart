import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:ontrek/core/services/api_constants.dart';
import 'package:ontrek/core/services/network_repository.dart';
import 'package:ontrek/core/storage/preference_helper.dart';
import 'package:ontrek/core/utils/App_utils.dart';
import 'package:ontrek/features/check_out/model/check_out_form_model.dart';
import 'package:ontrek/features/home/leave/model/add_leave_model.dart';
import 'package:ontrek/features/home/leave/model/my_leave_list_mode.dart';
import 'package:ontrek/main.dart';

class LeaveProvider extends ChangeNotifier {
  bool _isFetching = false;
  bool _isLoading = false;
  bool _isUploading = false;
  bool _isAdding = false;

  bool get isFetching => _isFetching;

  bool get isLoading => _isLoading;

  bool get isUploading => _isUploading;

  bool get isAdding => _isAdding;

  LeaveListModel? myLeaveListModel;
  GetTotByGroupTypeModel? getTotByGroupTypeModel;
  AddLeaveModel? addLeaveModel;
  bool? ApprovalStatus = null;

  manageApprovalStatus(bool? approvalStatus){
    ApprovalStatus = approvalStatus;
    notifyListeners();
  }


  Future<LeaveListModel?> apiCallGetMyLeaveList(
      {String? submissionDate, bool? approvalStatus,int? pageNo,int? pageSize}) async {
    var userId = PreferenceHelper.getString(PreferenceHelper.USER_ID);
    var organizationId = PreferenceHelper.getString(PreferenceHelper.ORG_ID);
    // _isFetching = true;
    // notifyListeners();
    Map<String, dynamic> body = {
      "pageNo": pageNo,
      "pageSize": 10,
      "orgId": organizationId,
      "userId": userId,
      "approvalStatus": ApprovalStatus,
      "submissionDate": null
    };
    try {
      String endPoint = ApiConstants.getMyLeaveList;
      var response = await callPostMethod(endPoint, body);
      myLeaveListModel = LeaveListModel.fromJson(json.decode(response));
      print('response ${myLeaveListModel?.toJson()}');
      if (myLeaveListModel?.isError == false &&
          myLeaveListModel?.isValidationFailed == false) {

      } else {
        if (myLeaveListModel?.isValidationFailed == true) {
          AppUtils.showDialogBoxWithOneButton(
              titleText: "Information",
              context: navigatorKey.currentState!.context,
              text: myLeaveListModel?.message ?? "");
        }
      }
    } catch (e) {
      print('catch at Leave Provier $e');
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
    // _isFetching = false;
    // notifyListeners();
    return myLeaveListModel;
  }

  Future<LeaveListModel?> apiCallGetEmployeeLeaveList(
      {String? submissionDate, bool? approvalStatus,int? pageNo}) async {
    var userId = PreferenceHelper.getString(PreferenceHelper.USER_ID);
    var organizationId = PreferenceHelper.getString(PreferenceHelper.ORG_ID);
    // _isFetching = true;
    // notifyListeners();
    Map<String, dynamic> body = {
      "pageNo": pageNo,
      "pageSize": 10,
      "orgId": organizationId,
      "userId": userId,
      "approvalStatus": ApprovalStatus,
      "submissionDate": null
    };
    try {
      String endPoint = ApiConstants.getMyEmployeeLeaveList;
      var response = await callPostMethod(endPoint, body);
      myLeaveListModel = LeaveListModel.fromJson(json.decode(response));
      print('response ${myLeaveListModel?.toJson()}');
      if (myLeaveListModel?.isError == false &&
          myLeaveListModel?.isValidationFailed == false) {
      } else {
        if (myLeaveListModel?.isValidationFailed == true) {
          AppUtils.showDialogBoxWithOneButton(
              titleText: "Information",
              context: navigatorKey.currentState!.context,
              text: myLeaveListModel?.message ?? "");
        }
      }
    } catch (e) {
      print('catch at Leave Provier $e');
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
    // _isFetching = false;
    // notifyListeners();
    return myLeaveListModel;
  }

  Future<GetTotByGroupTypeModel?> apiCallGetTotByType() async {
    _isFetching = true;
    notifyListeners();
    Map<String, dynamic> body = {
      "groupType": "leave_category",
    };
    try {
      String endPoint = ApiConstants.getTotByGroupType;
      var response = await callPostMethod(endPoint, body);
      getTotByGroupTypeModel =
          GetTotByGroupTypeModel.fromJson(json.decode(response));
      print("reponse : $response");
    } catch (e) {
      print('catch at apiCallGetTotByType ${e}');
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
    return getTotByGroupTypeModel;
  }

  Future<AddLeaveModel?> apiCallApplyLeave({
    String? userId,
    String? leaveCategoryTotId,
    String? leaveReason,
    bool? isFullDay,
    String? submissionDate,
    String? leaveStartDate,
    String? leaveEndDate,
    num? leaveDays,
    required Function() onSuccess,
  }) async {
    var organizationId = PreferenceHelper.getString(PreferenceHelper.ORG_ID);
    _isAdding = true;
    notifyListeners();
    Map<String, dynamic> body = {
      "pkId": null,
      "orgId": organizationId,
      "userId": userId,
      "leaveCategoryTotId": leaveCategoryTotId,
      "leaveReason": leaveReason,
      "isFullDay": isFullDay,
      "submissionDate": submissionDate,
      "leaveStartDate": leaveStartDate,
      "leaveEndDate": leaveEndDate,
      "leaveDays": leaveDays
    };
    try {
      String endPoint = ApiConstants.applyAndUpdateLeave;
      var response = await callPostMethod(endPoint, body);
      addLeaveModel = AddLeaveModel.fromJson(json.decode(response));
      print('response ${addLeaveModel?.toJson()}');
      if (addLeaveModel?.isError == false &&
          addLeaveModel?.isValidationFailed == false) {
        onSuccess();

      } else {
        if (addLeaveModel?.isValidationFailed == true) {
          AppUtils.showDialogBoxWithOneButton(
              titleText: "Information",
              context: navigatorKey.currentState!.context,
              text: myLeaveListModel?.message ?? "");
        }
      }
    } catch (e) {
      print('catch at Leave Provier $e');
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
    return addLeaveModel;
  }
TextEditingController approvalNotesController = TextEditingController();
TextEditingController rejectionNotesController = TextEditingController();
  Future<AddLeaveModel?> apiCallApplyRejectLeave(
      {String? pkId,
      String? orgId,
      String? userId,
      String? approvedRejectedOn,
      String? approverNote,
      bool? isApproved,
        required Function() onSuccess
      }) async {
    var organizationId = PreferenceHelper.getString(PreferenceHelper.ORG_ID);
    var approvedRejectedBy = PreferenceHelper.getString(PreferenceHelper.USER_NAME);
    _isLoading = true;
    notifyListeners();
    Map<String, dynamic> body = {
      "pkId": pkId,
      "orgId": organizationId,
      "userId": userId,
      "approvedRejectedBy": approvedRejectedBy,
      "approvedRejectedOn": AppUtils.formatDateString(approvedRejectedOn ?? "", "yyyy-MM-dd"),
      "isApproved": isApproved,
      "approverNote" : isApproved == false ? rejectionNotesController.text :  approvalNotesController.text

    };
    try {
      String endPoint = ApiConstants.approveRejectLeave;
      var response = await callPostMethod(endPoint, body);
      addLeaveModel = AddLeaveModel.fromJson(json.decode(response));
      print('response ${addLeaveModel?.toJson()}');
      if (addLeaveModel?.isError == false &&
          addLeaveModel?.isValidationFailed == false) {
        onSuccess();
      } else {
        if (addLeaveModel?.isValidationFailed == true) {
          AppUtils.showDialogBoxWithOneButton(
              titleText: "Information",
              context: navigatorKey.currentState!.context,
              text: addLeaveModel?.message ?? "");
        }
      }
    } catch (e) {
      print('catch at Leave Provier $e');
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
    _isLoading = false;
    notifyListeners();
    return addLeaveModel;
  }
}
