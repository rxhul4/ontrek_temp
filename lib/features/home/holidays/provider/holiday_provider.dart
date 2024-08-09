import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:ontrek/core/services/api_constants.dart';
import 'package:ontrek/core/services/network_repository.dart';
import 'package:ontrek/core/storage/preference_helper.dart';
import 'package:ontrek/core/utils/App_utils.dart';
import 'package:ontrek/features/home/holidays/model/holiday_list_model.dart';
import 'package:ontrek/main.dart';

class HolidayProvider extends ChangeNotifier {
  bool _isFetching = false;
  bool _isLoading = false;
  bool _isUploading = false;
  bool _isAdding = false;

  bool get isFetching => _isFetching;

  bool get isLoading => _isLoading;

  bool get isUploading => _isUploading;

  bool get isAdding => _isAdding;

  GetHolidayListModel? getHolidayListModel;

  Future<GetHolidayListModel?> apiCallGetDayEndRequestList() async {
    var organizationId = PreferenceHelper.getString(PreferenceHelper.ORG_ID);
    _isFetching = true;
    notifyListeners();
    Map<String, dynamic> body = {"orgId": organizationId};
    try {
      String endPoint = ApiConstants.getHolidayList;
      var response = await callPostMethod(endPoint, body);
      getHolidayListModel = GetHolidayListModel.fromJson(json.decode(response));
      print('response ${getHolidayListModel?.toJson()}');
      if (getHolidayListModel?.isError == false &&
          getHolidayListModel?.isValidationFailed == false) {

      } else {
        if (getHolidayListModel?.isValidationFailed == true) {
          AppUtils.showDialogBoxWithOneButton(
              titleText: "Information",
              context: navigatorKey.currentState!.context,
              text: getHolidayListModel?.message ?? "");
        }
      }
    } catch (e) {
      print('catch at Holiday Provider $e');
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
    return getHolidayListModel;
  }

  String formatDateString(String serverDate) {
    try {
      // Parse the date string
      DateTime parsedDate = DateTime.parse(serverDate);

      // Format the date
      String formattedDate = DateFormat('dd-MM-yyyy').format(parsedDate);

      return formattedDate;
    } catch (e) {
      // Handle any parsing or formatting errors
      print("Error formatting date: $e");
      return "";
    }
  }
}
