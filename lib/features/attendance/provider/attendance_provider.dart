import 'dart:convert';
import 'package:battery_plus/battery_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:ontrek/core/services/api_constants.dart';
import 'package:ontrek/core/services/network_repository.dart';
import 'package:ontrek/core/utils/App_utils.dart';
import 'package:ontrek/core/utils/app_constant.dart';
import 'package:ontrek/features/attendance/model/add_activity_model.dart';
import 'package:ontrek/main.dart';

class AttendanceProvider extends ChangeNotifier {
  bool _isFetching = false;
  bool _isLoading = false;
  bool _isUploading = false;
  bool _isAdding = false;

  bool get isFetching => _isFetching;

  bool get isLoading => _isLoading;

  bool get isUploading => _isUploading;

  bool get isAdding => _isAdding;

  CreateActivityModel? createActivityModel;
  final Battery battery = Battery();
  int batteryPercentage = 0;

  loaderFnc(bool isLoading) {
    _isLoading = isLoading;
    notifyListeners();
  }

  fetchingFnc(bool isLoading) {
    _isFetching = isLoading;
    notifyListeners();
  }

  void navigatePushReplacementFnc(Widget screen) {
    navigatorKey.currentState!.pushReplacement(CupertinoPageRoute(
      builder: (context) => screen,
    ));
  }

  void navigatePushFnc(Widget screen) {
    navigatorKey.currentState!.push(CupertinoPageRoute(
      builder: (context) => screen,
    ));
  }

  Future<int?> getBatteryLevel() async {
    try {
      final batteryLevel = await battery.batteryLevel;

      batteryPercentage = batteryLevel;
      notifyListeners();
      return batteryPercentage;
    } catch (e) {
      print("Failed to get battery level: $e");
    }
  }

  Future<CreateActivityModel?> apiCallCreateActivity({
    bool? isFromCheckOut = false,
    String? picturePath,
    String? userId,
    double? latitude,
    double? longitude,
    String? totTrackingEventCode,
    String? activityDateTime,
    int? batteryLevel,
    String? customerName,
    String? visitDiscussion,
    String? companyName,
    String? customerPhoneNumber,
    String? visitTypeCode,
  }) async {
    loaderFnc(true);

    Map<String, dynamic> checkOutDataBody = {
      "customerName": customerName,
      "picturePath": "test.jpg",
      "visitDiscussion": visitDiscussion,
      "companyName": companyName,
      "customerPhoneNo": customerPhoneNumber,
      "totVisitTypeId": visitTypeCode,
    };
    Map<String, dynamic> body = {
      "userId": /*userId ??*/ "22235050-456f-4e45-9781-c27d8d2f4c39",
      "longitude": latitude,
      "lattitude": longitude,
      "totTrackingEventId": totTrackingEventCode,
      "activityDateTime": activityDateTime ??
          AppUtils.dateFormat(
              date: DateTime.now(), dateFormat: AppConstant.dateFormat),
      "batteryLevel": batteryLevel,
      "visitNoteRequestForm": isFromCheckOut ?? false ? checkOutDataBody : null
    };
    try {
      String endPoint = ApiConstants.createActivity;
      final response = await callPostMethod(endPoint, body);
      createActivityModel = CreateActivityModel.fromJson(json.decode(response));
      print("response : ${response}");
      // if (createActivityModel?.isError == false &&
      //     createActivityModel?.isValidationFailed == false) {
      //
      // } else {
      //   AppUtils.dialogWidget(
      //       createActivityModel?.message ?? "", navigatorKey.currentState!.context);
      // }
    } catch (e) {
      print("inCatch ${createActivityModel?.message}");
      print("inCatchE $e");
      bool isInternetAvailable = await AppUtils.checkInternetConnectivity();
      if (!isInternetAvailable) {
        createActivityModel = CreateActivityModel(
            message: "Internet is not available, please try again!");
      } else {
        createActivityModel =
            CreateActivityModel(message: "Something went wrong!");
      }
    }
    loaderFnc(false);
    return createActivityModel;
  }
}
