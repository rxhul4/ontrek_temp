import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:ontrek/core/services/api_constants.dart';
import 'package:ontrek/core/services/network_repository.dart';
import 'package:ontrek/core/storage/preference_helper.dart';
import 'package:ontrek/core/utils/App_utils.dart';
import 'package:ontrek/core/utils/app_constant.dart';
import 'package:ontrek/features/home/reports/model/get_all_report_model.dart';
import 'package:ontrek/main.dart';

class ReportProvider extends ChangeNotifier {
  bool _isFetching = false;
  bool _isLoading = false;
  bool _isUploading = false;
  bool _isAdding = false;

  bool get isFetching => _isFetching;

  bool get isLoading => _isLoading;

  bool get isUploading => _isUploading;

  bool get isAdding => _isAdding;

  GetAllReportModel? getAllReportModel;

  List<bool> isExpandedList = [];

  expand(index){
    isExpandedList[index] = !isExpandedList[index];
    notifyListeners();
  }

  Future<GetAllReportModel?> apiCallGetAllReport(
      {String? reportDate,
      String? userId,
      String? organizationId,
      int? reportType}) async {
    var userId = PreferenceHelper.getString(PreferenceHelper.USER_ID);
    var organizationId = PreferenceHelper.getString(PreferenceHelper.ORG_ID);
    _isFetching = true;
    notifyListeners();
    Map<String, dynamic> body = {
      "organizationId": organizationId,
      "reportType": reportType ?? 2,
      "reportDate": reportDate ??
          AppUtils.getDate(
              date: DateTime.now().toString(), format: "yyyy-MM-01"),
      "userId": userId
    };
    try {
      String endPoint = ApiConstants.getAttendanceReport;
      var response = await callPostMethod(endPoint, body);
      getAllReportModel = GetAllReportModel.fromJson(json.decode(response));
      print('response ${getAllReportModel?.toJson()}');
      if (getAllReportModel?.isError == false &&
          getAllReportModel?.isValidationFailed == false) {
        String? userId = PreferenceHelper.getString(PreferenceHelper.USER_ID);
        isExpandedList = List.generate(
            getAllReportModel?.data?.userAttendenceReport
                    ?.firstWhere(
                      (element) => element.userId == userId,
                    )
                    .userAttendenceDetail
                    ?.length ??
                0,
            (index) => false);
      } else {
        if (getAllReportModel?.isValidationFailed == true) {
          AppUtils.showDialogBoxWithOneButton(
              titleText: "Information",
              context: navigatorKey.currentState!.context,
              text: getAllReportModel?.message ?? "");
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
    return getAllReportModel;
  }
}
