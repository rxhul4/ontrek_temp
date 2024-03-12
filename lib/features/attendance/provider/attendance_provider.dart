import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:ontrek/core/services/api_constants.dart';
import 'package:ontrek/core/services/network_repository.dart';
import 'package:ontrek/core/storage/preference_helper.dart';
import 'package:ontrek/core/utils/App_utils.dart';
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



  Future<CreateActivityModel?> apiCallCreateActivity({
    String? picturePath,
    String? userId,
    double? latitude,
    double? longitude,
    String? totTrackingEventCode,
    String? eventDate,
    String? eventTime,
    int? batteryLevel,
    String? deviceId,
    String? deviceName,
    double? locAccuracy,
    String? trackingAddress,
    String? customerName,
    String? visitDiscussion,
    String? companyName,
    String? customerPhoneNumber,
    String? visitTypeCode,
    String? activityStatus,

}) async {
    loaderFnc(true);
    Map<String, dynamic> body = {
      "userId": userId,
      "lattitude": latitude,
      "longitude": longitude,
      "totTrackingEventId": totTrackingEventCode,
      "eventDate": eventDate,
      "eventTime": eventTime,
      "batteryLevel": 50,
      "trackingAddress": "Dwarkesh Business Hub",
      "customerName": customerName,
      "picturePath": picturePath,
      "visitDiscussion": visitDiscussion,
      "companyName": companyName,
      "customerPhoneNo": customerPhoneNumber,
      "totVisitTypeId": visitTypeCode,
      "activityStatus": activityStatus
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
        createActivityModel =
            CreateActivityModel(message: "Internet is not available, please try again!");
      } else {
        createActivityModel = CreateActivityModel(message: "Something went wrong!");
      }
    }
    loaderFnc(false);
    return createActivityModel;
  }





}
