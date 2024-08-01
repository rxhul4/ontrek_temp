import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:ontrek/core/services/api_constants.dart';
import 'package:ontrek/core/services/network_repository.dart';
import 'package:ontrek/core/storage/preference_helper.dart';
import 'package:ontrek/core/utils/App_utils.dart';
import 'package:ontrek/features/home/expanse/model/common_expense_model.dart';
import 'package:ontrek/features/home/expanse/model/expense_category_model.dart';
import 'package:ontrek/features/home/expanse/model/expense_list_model.dart';
import 'package:ontrek/features/home/expanse/model/expense_sub_category_model.dart';
import 'package:ontrek/features/home/leave/model/add_leave_model.dart';
import 'package:ontrek/main.dart';

class ExpenseProvider extends ChangeNotifier {
  bool _isFetching = false;
  bool _isLoading = false;
  bool _isUploading = false;
  bool _isAdding = false;

  bool get isFetching => _isFetching;

  bool get isLoading => _isLoading;

  bool get isUploading => _isUploading;

  bool get isAdding => _isAdding;
  ExpenseListModel? expenseListModel;
  CommonExpenseModel? commonExpenseModel;
  ExpenseCategoryModel? expenseCategoryModel;
  ExpenseSubCategoryModel? expenseSubCategoryModel;
  bool? ApprovalStatus;

  fetchingFnc(bool isLoading) {
    _isFetching = isLoading;
    notifyListeners();
  }
  manageApprovalStatus(bool? approvalStatus){
    ApprovalStatus = approvalStatus;
    notifyListeners();
  }

  Future<ExpenseListModel?> apiCallGetMyExpenseList(
      {String? submissionDate, bool? approvalStatus, int? pageNo}) async {
    var userId = PreferenceHelper.getString(PreferenceHelper.USER_ID);
    var organizationId = PreferenceHelper.getString(PreferenceHelper.ORG_ID);
    // _isFetching = true;
    // notifyListeners();
    Map<String, dynamic> body = {
      "orgId": organizationId,
      "userId": userId,
      "approvalStatus": ApprovalStatus,
      "submissionDate": null,
      "pageNo": pageNo,
      "pageSize": 10
    };
    try {
      String endPoint = ApiConstants.getMyExpenseList;
      var response = await callPostMethod(endPoint, body);
      expenseListModel = ExpenseListModel.fromJson(json.decode(response));
      print('response ${expenseListModel?.toJson()}');
      if (expenseListModel?.isError == false &&
          expenseListModel?.isValidationFailed == false) {

      } else {
        if (expenseListModel?.isValidationFailed == true) {
          AppUtils.showDialogBoxWithOneButton(
              titleText: "Information",
              context: navigatorKey.currentState!.context,
              text: expenseListModel?.message ?? "");
        }
      }
    } catch (e) {
      print('catch at Expense Provider $e');
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
    return expenseListModel;
  }

  Future<ExpenseListModel?> apiCallGetEmployeeExpenseList(
      {String? submissionDate, bool? approvalStatus, int? pageNo}) async {
    var userId = PreferenceHelper.getString(PreferenceHelper.USER_ID);
    var organizationId = PreferenceHelper.getString(PreferenceHelper.ORG_ID);
    // _isFetching = true;
    // notifyListeners();
    Map<String, dynamic> body = {
      "orgId": organizationId,
      "userId": userId,
      "approvalStatus": ApprovalStatus,
      "submissionDate": null,
      "pageNo": pageNo,
      "pageSize": 10
    };
    try {
      String endPoint = ApiConstants.getMyEmployeeExpenseList;
      var response = await callPostMethod(endPoint, body);
      expenseListModel = ExpenseListModel.fromJson(json.decode(response));
      print('response ${expenseListModel?.toJson()}');
      if (expenseListModel?.isError == false &&
          expenseListModel?.isValidationFailed == false) {
      } else {
        if (expenseListModel?.isValidationFailed == true) {
          AppUtils.showDialogBoxWithOneButton(
              titleText: "Information",
              context: navigatorKey.currentState!.context,
              text: expenseListModel?.message ?? "");
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
    return expenseListModel;
  }

  Future<CommonExpenseModel?> apiCallAddExpense({
    String? pkId,
    String? expenseDate,
    String? expenseCategoryId,
    String? expenseSubCategoryId,
    String? expenseDescription,
    int? submittedAmount,
    String? invoiceImage,
    required Function() onSuccess,
  }) async {
    String? userId = PreferenceHelper.getString(PreferenceHelper.USER_ID);
    String? orgId = PreferenceHelper.getString(PreferenceHelper.ORG_ID);
    _isAdding = true;
    notifyListeners();
    Map<String, dynamic> body = {
      "pkId": null,
      "orgId": orgId,
      "userId": userId,
      "expenseDate": AppUtils.getDate(
          date: DateTime.now().toString(), format: "yyyy-MM-dd"),
      "submissionDate": AppUtils.getDate(
          date: DateTime.now().toString(), format: "yyyy-MM-dd"),
      "expenseCategoryId": expenseCategoryId,
      "expenseSubCategoryId": expenseSubCategoryId,
      "expenseDescription": expenseDescription,
      "submittedAmount": submittedAmount,
      "invoiceImage": invoiceImage
    };
    try {
      String endPoint = ApiConstants.applyAndUpdateExpense;
      var response = await callPostMethod(endPoint, body);
      commonExpenseModel = CommonExpenseModel.fromJson(json.decode(response));
      print('response ${commonExpenseModel?.toJson()}');
      if (commonExpenseModel?.isError == false &&
          commonExpenseModel?.isValidationFailed == false) {
        onSuccess();
      } else {
        if (commonExpenseModel?.isValidationFailed == true) {
          AppUtils.showDialogBoxWithOneButton(
              titleText: "Information",
              context: navigatorKey.currentState!.context,
              text: commonExpenseModel?.message ?? "");
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
    return commonExpenseModel;
  }

  Future<CommonExpenseModel?> apiCallApplyRejectExpense(
      {String? pkId,
      String? orgId,
      String? userId,
      String? approvedRejectedBy,
      String? approvedRejectedOn,
      bool? isApproved,
      int? approvedAmount,
      String? approvedNotes,
      required Function() onSuccess}) async {
    var organizationId = PreferenceHelper.getString(PreferenceHelper.ORG_ID);
    var userName = PreferenceHelper.getString(PreferenceHelper.USER_NAME);
    _isLoading = true;
    notifyListeners();
    Map<String, dynamic> body = {
      "pkId": pkId,
      "orgId": organizationId,
      "userId": userId,
      "approvedRejectedBy": userName,
      "approveRejectDate":
          AppUtils.formatDateString(approvedRejectedOn ?? "", "yyyy-MM-dd"),
      "isApproved": isApproved,
      "approvedAmount": approvedAmount,
      "approverNotes":  approvedNotes
    };
    try {
      String endPoint = ApiConstants.approveRejectExpense;
      var response = await callPostMethod(endPoint, body);
      commonExpenseModel = CommonExpenseModel.fromJson(json.decode(response));
      print('response ${commonExpenseModel?.toJson()}');
      if (commonExpenseModel?.isError == false &&
          commonExpenseModel?.isValidationFailed == false) {
        onSuccess();
      } else {
        if (commonExpenseModel?.isValidationFailed == true) {
          AppUtils.showDialogBoxWithOneButton(
              titleText: "Information",
              context: navigatorKey.currentState!.context,
              text: commonExpenseModel?.message ?? "");
        }
      }
    } catch (e) {
      print('catch at Expense Provier $e');
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
    return commonExpenseModel;
  }

  Future<ExpenseCategoryModel?> apiCallExpenseCategory() async {
    var organizationId = PreferenceHelper.getString(PreferenceHelper.ORG_ID);
    _isFetching = true;
    notifyListeners();
    Map<String, dynamic> body = {
      "orgId": organizationId,
    };
    try {
      String endPoint = ApiConstants.getExpenseCategory;
      var response = await callPostMethod(endPoint, body);
      expenseCategoryModel =
          ExpenseCategoryModel.fromJson(json.decode(response));
      print('response ${expenseCategoryModel?.toJson()}');
      if (expenseCategoryModel?.isError == false &&
          expenseCategoryModel?.isValidationFailed == false) {
      } else {
        if (expenseCategoryModel?.isValidationFailed == true) {
          AppUtils.showDialogBoxWithOneButton(
              titleText: "Information",
              context: navigatorKey.currentState!.context,
              text: expenseCategoryModel?.message ?? "");
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
    _isFetching = false;
    notifyListeners();
    return expenseCategoryModel;
  }

  Future<ExpenseSubCategoryModel?> apiCallExpenseSubCategory(
      {String? categoryId}) async {
    var organizationId = PreferenceHelper.getString(PreferenceHelper.ORG_ID);

    _isFetching = true;
    notifyListeners();
    Map<String, dynamic> body = {
      "orgId": organizationId,
      "catgegoryId": categoryId
    };
    try {
      String endPoint = ApiConstants.getExpenseSubCategory;
      var response = await callPostMethod(endPoint, body);
      expenseSubCategoryModel =
          ExpenseSubCategoryModel.fromJson(json.decode(response));
      print('response ${expenseSubCategoryModel?.toJson()}');
      if (expenseSubCategoryModel?.isError == false &&
          expenseSubCategoryModel?.isValidationFailed == false) {
      } else {
        if (expenseSubCategoryModel?.isValidationFailed == true) {
          AppUtils.showDialogBoxWithOneButton(
              titleText: "Information",
              context: navigatorKey.currentState!.context,
              text: expenseSubCategoryModel?.message ?? "");
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
    _isFetching = false;
    notifyListeners();
    return expenseSubCategoryModel;
  }
}
