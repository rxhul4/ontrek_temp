import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ontrek/core/services/api_constants.dart';
import 'package:ontrek/core/services/network_repository.dart';
import 'package:ontrek/core/utils/App_utils.dart';
import 'package:ontrek/core/utils/app_constant.dart';
import 'package:ontrek/features/salesman_tracker/local_model.dart';
import 'package:ontrek/features/salesman_tracker/model/salesmen_tracking_detailes.dart';
import 'package:ontrek/features/salesman_tracker/screen/timeline_screen.dart';
import 'package:ontrek/main.dart';

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

  List<TimeLineLocalModel>? allSession = [];
  List<LatLng> coordinates = [];

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
      {String? userid, String? date}) async {
    _isFetching = true;
    allSession?.clear();
    coordinates.clear();
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
        getTimeLineModel?.data?.sessionTimeLine?.forEach((element) {
          element.sessionRouteHistory?.latlongArray?.forEach((element) {
            coordinates.add(LatLng(element.x ?? 0, element.y ?? 0));
          });
        });
        getTimeLineModel?.data?.sessionTimeLine?.forEach((session) {
          int? totalCheckIn = session.totalCheckIn;
          String? totalDuration = session.totalDuration;
          num? totalKmTravel = session.totalKmTravel;
          session.sessionEvents?.forEach((event) {
            String? eventName = event.eventName ?? "";
            String? eventStartDate = event.eventStartDate ?? "";
            String? eventCode = event.eventCode ?? "";
            String? eventActivityPlace = event.eventActivityPlace ?? "";
            if (event != null || session != null) {
              allSession?.add(TimeLineLocalModel(
                  eventName: eventName,
                  eventStartDate: eventStartDate,
                  eventCode: eventCode,
                  eventActivityPlace: eventActivityPlace,
                duration: totalDuration,
                kiloMeter: totalKmTravel,
                totalCheckIn: totalCheckIn,

              ));
            }
          });
        });

        print("Event list: $allSession");
      } else {}
    } catch (e) {
      print('catch at GetTimeLineProvider ${e}');
      bool isInternetAvailable = await AppUtils.checkInternetConnectivity();
      if (!isInternetAvailable) {
        getTimeLineModel = GetTimeLineModel(
            message: "Internet is not available, please try again!");
      } else {
        getTimeLineModel = GetTimeLineModel(message: "Something went wrong!");
      }
    }
    _isFetching = false;
    notifyListeners();
    return getTimeLineModel;
  }
}
