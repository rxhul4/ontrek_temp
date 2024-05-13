class GetLastActivityModel {
  bool? isError;
  bool? isValidationFailed;
  String? errorCode;
  String? message;
  Data? data;

  GetLastActivityModel(
      {this.isError,
        this.isValidationFailed,
        this.errorCode,
        this.message,
        this.data});

  GetLastActivityModel.fromJson(Map<String, dynamic> json) {
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
  String? fieldUserId;
  String? trackingEventId;
  String? activityName;
  String? activityCode;
  String? lastTrackingActivityTime;
  double? lastActivityLat;
  double? lastActivityLong;
  String? lastActivityPlace;
  int? lastBatteryPercentage;
  bool? isLastSessionEnded;
  String? pendingSessionDate;
  String? pendingSessionId;
  String? tlDate;
  String? tlTime;
  String? tlDateTime;
  String? markerTitle;

  Data(
      {this.fieldUserId,
        this.trackingEventId,
        this.activityName,
        this.activityCode,
        this.lastTrackingActivityTime,
        this.lastActivityLat,
        this.lastActivityLong,
        this.lastActivityPlace,
        this.lastBatteryPercentage,
        this.isLastSessionEnded,
        this.pendingSessionDate,
        this.pendingSessionId,
        this.tlDate,
        this.tlTime,
        this.tlDateTime,
        this.markerTitle});

  Data.fromJson(Map<String, dynamic> json) {
    fieldUserId = json['fieldUserId'];
    trackingEventId = json['trackingEventId'];
    activityName = json['activityName'];
    activityCode = json['activityCode'];
    lastTrackingActivityTime = json['lastTrackingActivityTime'];
    lastActivityLat = json['lastActivityLat'];
    lastActivityLong = json['lastActivityLong'];
    lastActivityPlace = json['lastActivityPlace'];
    lastBatteryPercentage = json['lastBatteryPercentage'];
    isLastSessionEnded = json['isLastSessionEnded'];
    pendingSessionDate = json['pendingSessionDate'];
    pendingSessionId = json['pendingSessionId'];
    tlDate = json['tlDate'];
    tlTime = json['tlTime'];
    tlDateTime = json['tlDateTime'];
    markerTitle = json['markerTitle'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['fieldUserId'] = this.fieldUserId;
    data['trackingEventId'] = this.trackingEventId;
    data['activityName'] = this.activityName;
    data['activityCode'] = this.activityCode;
    data['lastTrackingActivityTime'] = this.lastTrackingActivityTime;
    data['lastActivityLat'] = this.lastActivityLat;
    data['lastActivityLong'] = this.lastActivityLong;
    data['lastActivityPlace'] = this.lastActivityPlace;
    data['lastBatteryPercentage'] = this.lastBatteryPercentage;
    data['isLastSessionEnded'] = this.isLastSessionEnded;
    data['pendingSessionDate'] = this.pendingSessionDate;
    data['pendingSessionId'] = this.pendingSessionId;
    data['tlDate'] = this.tlDate;
    data['tlTime'] = this.tlTime;
    data['tlDateTime'] = this.tlDateTime;
    data['markerTitle'] = this.markerTitle;
    return data;
  }
}
