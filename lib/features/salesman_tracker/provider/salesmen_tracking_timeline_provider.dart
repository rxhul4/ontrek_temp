import 'dart:convert';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ontrek/core/common_widgets/marker_widget.dart';
import 'package:ontrek/core/services/api_constants.dart';
import 'package:ontrek/core/services/network_repository.dart';
import 'package:ontrek/core/storage/preference_helper.dart';
import 'package:ontrek/core/utils/App_utils.dart';
import 'package:ontrek/core/utils/app_constant.dart';
import 'package:ontrek/features/salesman_tracker/model/salesmen_tracking_detailes.dart';
import 'package:ontrek/main.dart';
import 'package:widget_to_marker/widget_to_marker.dart';

class SalemenTimeLineProvider extends ChangeNotifier {
  bool _isFetching = false;
  bool _isLoading = false;
  bool _isUploading = false;
  bool _isAdding = false;

  bool get isFetching => _isFetching;

  bool get isLoading => _isLoading;

  bool get isUploading => _isUploading;

  bool get isAdding => _isAdding;

  GetTimeLineModel? getTimeLineModel;

  List<SessionEvents> sessionEvents = [];
  List<LatlongArray>? latLongArray;
  List<LatLng> coordinates = [];
  int totalCheckIn = 0;
  String totalDuration = "";
  num totalKmTravel = 0;
  Set<Marker> markers = Set();
  GoogleMapController? googleMapController;

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

  Future<GetTimeLineModel?> apiCallGetTimeLine(
      {String? userid, String? date, String? imgUrl}) async {
    _isFetching = true;
    sessionEvents.clear();
    notifyListeners();
    Map<String, dynamic> body = {
      "userId": userid,
      "eventDate":
          AppUtils.getDate(date: date ?? "", format: AppConstant.dateFormat)
    };
    try {
      String endPoint = ApiConstants.getSalesMenTimeLine;
      var response = await callPostMethod(endPoint, body);
      getTimeLineModel = GetTimeLineModel.fromJson(json.decode(response));
      print('response ${getTimeLineModel?.toJson()}');
      if (getTimeLineModel?.isError == false &&
          getTimeLineModel?.isValidationFailed == false) {
        getTimeLineModel?.data?.sessionTimeLine?.forEach((session) {
          session.sessionEvents?.forEach((event) {
            if (event != null || session != null) {
              sessionEvents.add(SessionEvents(
                sessionId: event.sessionId,
                sessionNo: event.sessionNo,
                eventCode: event.eventCode,
                eventStartDate: event.eventStartDate,
                eventEndDate: event.eventEndDate,
                eventActivityPlace: event.eventActivityPlace,
                eventName: event.eventName,
                batteryPercentage: event.batteryPercentage,
                eventDuration: event.eventDuration,
                eventId: event.eventId,
                eventLat: event.eventLat,
                eventLong: event.eventLong,
                visitFormId: event.visitFormId,
              ));
            }
          });
        });

        print(
            "testttttttttttttt${getTimeLineModel?.data?.sessionTimeLine?.map((e) => e.sessionRouteHistory?.latlongArray).toList()}");
        print("Event list: ${sessionEvents.length}");
      } else {
        if (getTimeLineModel?.isError == true) {
          AppUtils.showDialogBoxWithOneButton(
              titleText: "Error",
              context: navigatorKey.currentState!.context,
              text: "Something went wrong!");
        }
      }
    } catch (e) {
      print('catch at GetTimeLineProvider ${e}');
      bool isInternetAvailable = await AppUtils.checkInternetConnectivity();
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
    return getTimeLineModel;
  }

}
