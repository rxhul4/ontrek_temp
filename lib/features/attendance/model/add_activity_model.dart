import 'package:ontrek/features/attendance/model/get_last_activity_model.dart';

class CreateActivityModel {
  bool? isError;
  bool? isValidationFailed;
  String? errorCode;
  String? message;
  Data? data;

  CreateActivityModel(
      {this.isError,
        this.isValidationFailed,
        this.errorCode,
        this.message,
        this.data});

  CreateActivityModel.fromJson(Map<String, dynamic> json) {
    isError = json['isError'];
    isValidationFailed = json['isValidationFailed'];
    errorCode = json['errorCode'];
    message = json['message'];
    data = json['data'] != null ? new Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['isError'] = this.isError;
    data['isValidationFailed'] = this.isValidationFailed;
    data['errorCode'] = this.errorCode;
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class Data {
  String? sessionId;
  String? eventCode;
  String? eventDate;
  LastActivityData? lastActivityDto;
  int? localPkId;
  bool? isSuccess;
  String? errorCode;
  String? message;

  Data(
      {this.sessionId,
        this.eventCode,
        this.eventDate,
        this.lastActivityDto,
        this.localPkId,
        this.isSuccess,
        this.errorCode,
        this.message});

  Data.fromJson(Map<String, dynamic> json) {
    sessionId = json['sessionId'];
    eventCode = json['eventCode'];
    eventDate = json['eventDate'];
    lastActivityDto = json['lastActivityDto'] != null
        ? new LastActivityData.fromJson(json['lastActivityDto'])
        : null;
    localPkId = json['localPkId'];
    isSuccess = json['isSuccess'];
    errorCode = json['errorCode'];
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['sessionId'] = this.sessionId;
    data['eventCode'] = this.eventCode;
    data['eventDate'] = this.eventDate;
    if (this.lastActivityDto != null) {
      data['lastActivityDto'] = this.lastActivityDto!.toJson();
    }
    data['localPkId'] = this.localPkId;
    data['isSuccess'] = this.isSuccess;
    data['errorCode'] = this.errorCode;
    data['message'] = this.message;
    return data;
  }
}

// class LastActivityDto {
//   String? fieldUserId;
//   String? trackingEventId;
//   String? activityName;
//   String? activityCode;
//   String? lastTrackingActivityTime;
//   double? lastActivityLat;
//   double? lastActivityLong;
//   String? lastActivityPlace;
//   int? lastBatteryPercentage;
//   String? sessionId;
//   String? sessionStartDateTime;
//   bool? isSessionActive;
//   bool? alreadyRequested;
//   double? lastLocationLat;
//   double? lastLocationLong;
//   String? lastLocationTime;
//   String? tlDate;
//   String? tlTime;
//   String? tlDateTime;
//   String? markerTitle;
//
//   LastActivityDto(
//       {this.fieldUserId,
//         this.trackingEventId,
//         this.activityName,
//         this.activityCode,
//         this.lastTrackingActivityTime,
//         this.lastActivityLat,
//         this.lastActivityLong,
//         this.lastActivityPlace,
//         this.lastBatteryPercentage,
//         this.sessionId,
//         this.sessionStartDateTime,
//         this.isSessionActive,
//         this.alreadyRequested,
//         this.lastLocationLat,
//         this.lastLocationLong,
//         this.lastLocationTime,
//         this.tlDate,
//         this.tlTime,
//         this.tlDateTime,
//         this.markerTitle});
//
//   LastActivityDto.fromJson(Map<String, dynamic> json) {
//     fieldUserId = json['fieldUserId'];
//     trackingEventId = json['trackingEventId'];
//     activityName = json['activityName'];
//     activityCode = json['activityCode'];
//     lastTrackingActivityTime = json['lastTrackingActivityTime'];
//     lastActivityLat = json['lastActivityLat'];
//     lastActivityLong = json['lastActivityLong'];
//     lastActivityPlace = json['lastActivityPlace'];
//     lastBatteryPercentage = json['lastBatteryPercentage'];
//     sessionId = json['sessionId'];
//     sessionStartDateTime = json['sessionStartDateTime'];
//     isSessionActive = json['isSessionActive'];
//     alreadyRequested = json['alreadyRequested'];
//     lastLocationLat = json['lastLocationLat'];
//     lastLocationLong = json['lastLocationLong'];
//     lastLocationTime = json['lastLocationTime'];
//     tlDate = json['tlDate'];
//     tlTime = json['tlTime'];
//     tlDateTime = json['tlDateTime'];
//     markerTitle = json['markerTitle'];
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['fieldUserId'] = this.fieldUserId;
//     data['trackingEventId'] = this.trackingEventId;
//     data['activityName'] = this.activityName;
//     data['activityCode'] = this.activityCode;
//     data['lastTrackingActivityTime'] = this.lastTrackingActivityTime;
//     data['lastActivityLat'] = this.lastActivityLat;
//     data['lastActivityLong'] = this.lastActivityLong;
//     data['lastActivityPlace'] = this.lastActivityPlace;
//     data['lastBatteryPercentage'] = this.lastBatteryPercentage;
//     data['sessionId'] = this.sessionId;
//     data['sessionStartDateTime'] = this.sessionStartDateTime;
//     data['isSessionActive'] = this.isSessionActive;
//     data['alreadyRequested'] = this.alreadyRequested;
//     data['lastLocationLat'] = this.lastLocationLat;
//     data['lastLocationLong'] = this.lastLocationLong;
//     data['lastLocationTime'] = this.lastLocationTime;
//     data['tlDate'] = this.tlDate;
//     data['tlTime'] = this.tlTime;
//     data['tlDateTime'] = this.tlDateTime;
//     data['markerTitle'] = this.markerTitle;
//     return data;
//   }
// }
