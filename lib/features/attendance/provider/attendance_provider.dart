import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:ontrek/core/services/api_constants.dart';
import 'package:ontrek/core/storage/preference_helper.dart';
import 'package:ontrek/core/utils/App_utils.dart';
import 'package:ontrek/features/attendance/model/add_activity_model.dart';

class AttendanceProvider extends ChangeNotifier {
  bool _isFetching = false;
  bool _isLoading = false;
  bool _isUploading = false;
  bool _isAdding = false;

  bool get isFetching => _isFetching;

  bool get isLoading => _isLoading;

  bool get isUploading => _isUploading;

  bool get isAdding => _isAdding;

  AddActivityModel? addActivityModel;



  Future<AddActivityModel?> apiCallAddActivity({
    File? imageFile,
    String? userUid,
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
    try {
      _isLoading = true;
      notifyListeners();
      String? userUid = PreferenceHelper.getString(PreferenceHelper.USER_UID);

      var request =
          http.MultipartRequest('POST', Uri.parse(ApiConstants.addActivity));
      if (imageFile != null) {
        request.files.add(await http.MultipartFile.fromPath(
            "picture_path", imageFile.path ?? ''));
      }
      if(userUid != null){
        request.fields['user_uid'] = userUid;
      }

      request.fields['lattitude'] = latitude.toString();
      request.fields['longitude'] = longitude.toString();
      request.fields['tot_tracking_event_code'] = totTrackingEventCode.toString();
      request.fields['event_date'] = eventDate.toString();
      request.fields['event_time'] = eventTime.toString();
      request.fields['battery_level'] = batteryLevel.toString();
      request.fields['device_id'] = deviceId.toString();
      request.fields['device_name'] = deviceName.toString();
      request.fields['loc_accuracy'] = locAccuracy.toString();
      request.fields['tracking_address'] = trackingAddress.toString();
      request.fields['customer_name'] = customerName.toString();
      request.fields['visit_discussion'] = visitDiscussion.toString();
      request.fields['company_name'] = companyName.toString();
      request.fields['customer_phone_no'] = customerPhoneNumber.toString();
      request.fields['visit_type_code'] = visitTypeCode.toString();
      request.fields['ActivityStatus'] = activityStatus.toString();

      print("request is ${request.fields}");
      print("request is ${request.url}");
      var response = await request.send();
      print('---------response$response');
      var responsed = await http.Response.fromStream(response);
      print("SUCCESS  ${responsed.body}");
      print("SUCCESS  ${json.decode(responsed.body)}");
      addActivityModel =
          AddActivityModel.fromJson(json.decode(responsed.body));
      print(addActivityModel?.data);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print("inCatch ${addActivityModel?.message}");
      print("inCatchE ${e}");
      bool isInternetAvailable = await AppUtils.checkInternetConnectivity();
      if (!isInternetAvailable) {
        addActivityModel = AddActivityModel(
            message: "Internet is not available, please try again!");
      } else {
        addActivityModel =
            AddActivityModel(message: "Something went wrong!");
      }

    }
    return addActivityModel;
  }

}
