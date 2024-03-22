class GetTimeLineModel {
  bool? isError;
  bool? isValidationFailed;
  String? errorCode;
  String? message;
  Data? data;

  GetTimeLineModel(
      {this.isError,
        this.isValidationFailed,
        this.errorCode,
        this.message,
        this.data});

  GetTimeLineModel.fromJson(Map<String, dynamic> json) {
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
  String? fieldUserName;
  String? userPhoneNo;
  String? timeLineDate;
  num? totalKmTravel;
  int? totalCheckIn;
  String? totalDuration;
  FieldUserLastActivity? fieldUserLastActivity;
  FieldUserDeviceInfo? fieldUserDeviceInfo;
  List<SessionTimeLine>? sessionTimeLine;

  Data(
      {this.fieldUserId,
        this.fieldUserName,
        this.userPhoneNo,
        this.timeLineDate,
        this.totalKmTravel,
        this.totalCheckIn,
        this.totalDuration,
        this.fieldUserLastActivity,
        this.fieldUserDeviceInfo,
        this.sessionTimeLine});

  Data.fromJson(Map<String, dynamic> json) {
    fieldUserId = json['fieldUserId'];
    fieldUserName = json['fieldUserName'];
    userPhoneNo = json['userPhoneNo'];
    timeLineDate = json['timeLineDate'];
    totalKmTravel = json['totalKmTravel'];
    totalCheckIn = json['totalCheckIn'];
    totalDuration = json['totalDuration'];
    fieldUserLastActivity = json['fieldUserLastActivity'] != null
        ? new FieldUserLastActivity.fromJson(json['fieldUserLastActivity'])
        : null;
    fieldUserDeviceInfo = json['fieldUserDeviceInfo'] != null
        ? new FieldUserDeviceInfo.fromJson(json['fieldUserDeviceInfo'])
        : null;
    if (json['sessionTimeLine'] != null) {
      sessionTimeLine = <SessionTimeLine>[];
      json['sessionTimeLine'].forEach((v) {
        sessionTimeLine!.add(new SessionTimeLine.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['fieldUserId'] = this.fieldUserId;
    data['fieldUserName'] = this.fieldUserName;
    data['userPhoneNo'] = this.userPhoneNo;
    data['timeLineDate'] = this.timeLineDate;
    data['totalKmTravel'] = this.totalKmTravel;
    data['totalCheckIn'] = this.totalCheckIn;
    data['totalDuration'] = this.totalDuration;
    if (this.fieldUserLastActivity != null) {
      data['fieldUserLastActivity'] = this.fieldUserLastActivity!.toJson();
    }
    if (this.fieldUserDeviceInfo != null) {
      data['fieldUserDeviceInfo'] = this.fieldUserDeviceInfo!.toJson();
    }
    if (this.sessionTimeLine != null) {
      data['sessionTimeLine'] =
          this.sessionTimeLine!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class FieldUserLastActivity {
  String? fieldUserId;
  String? trackingEventId;
  String? activityName;
  String? activityCode;
  String? lastTrackingActivityTime;
  double? lastActivityLat;
  double? lastActivityLong;
  String? lastActivityPlace;
  int? lastBatteryPercentage;

  FieldUserLastActivity(
      {this.fieldUserId,
        this.trackingEventId,
        this.activityName,
        this.activityCode,
        this.lastTrackingActivityTime,
        this.lastActivityLat,
        this.lastActivityLong,
        this.lastActivityPlace,
        this.lastBatteryPercentage});

  FieldUserLastActivity.fromJson(Map<String, dynamic> json) {
    fieldUserId = json['fieldUserId'];
    trackingEventId = json['trackingEventId'];
    activityName = json['activityName'];
    activityCode = json['activityCode'];
    lastTrackingActivityTime = json['lastTrackingActivityTime'];
    lastActivityLat = json['lastActivityLat'];
    lastActivityLong = json['lastActivityLong'];
    lastActivityPlace = json['lastActivityPlace'];
    lastBatteryPercentage = json['lastBatteryPercentage'];
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
    return data;
  }
}

class FieldUserDeviceInfo {
  String? deviceId;
  String? deviceModel;
  String? deviceOs;
  String? osVersion;

  FieldUserDeviceInfo(
      {this.deviceId, this.deviceModel, this.deviceOs, this.osVersion});

  FieldUserDeviceInfo.fromJson(Map<String, dynamic> json) {
    deviceId = json['deviceId'];
    deviceModel = json['deviceModel'];
    deviceOs = json['deviceOs'];
    osVersion = json['osVersion'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['deviceId'] = this.deviceId;
    data['deviceModel'] = this.deviceModel;
    data['deviceOs'] = this.deviceOs;
    data['osVersion'] = this.osVersion;
    return data;
  }
}

class SessionTimeLine {
  String? sessionId;
  int? sessionNo;
  String? sessionStartDateTime;
  String? sessionEndDateTime;
  num? totalKmTravel;
  int? totalCheckIn;
  String? totalDuration;
  List<SessionEvents>? sessionEvents;
  SessionRouteHistory? sessionRouteHistory;

  SessionTimeLine(
      {this.sessionId,
        this.sessionNo,
        this.sessionStartDateTime,
        this.sessionEndDateTime,
        this.totalKmTravel,
        this.totalCheckIn,
        this.totalDuration,
        this.sessionEvents,
        this.sessionRouteHistory});

  SessionTimeLine.fromJson(Map<String, dynamic> json) {
    sessionId = json['sessionId'];
    sessionNo = json['sessionNo'];
    sessionStartDateTime = json['sessionStartDateTime'];
    sessionEndDateTime = json['sessionEndDateTime'];
    totalKmTravel = json['totalKmTravel'];
    totalCheckIn = json['totalCheckIn'];
    totalDuration = json['totalDuration'];
    if (json['sessionEvents'] != null) {
      sessionEvents = <SessionEvents>[];
      json['sessionEvents'].forEach((v) {
        sessionEvents!.add(new SessionEvents.fromJson(v));
      });
    }
    sessionRouteHistory = json['sessionRouteHistory'] != null
        ? new SessionRouteHistory.fromJson(json['sessionRouteHistory'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['sessionId'] = this.sessionId;
    data['sessionNo'] = this.sessionNo;
    data['sessionStartDateTime'] = this.sessionStartDateTime;
    data['sessionEndDateTime'] = this.sessionEndDateTime;
    data['totalKmTravel'] = this.totalKmTravel;
    data['totalCheckIn'] = this.totalCheckIn;
    data['totalDuration'] = this.totalDuration;
    if (this.sessionEvents != null) {
      data['sessionEvents'] =
          this.sessionEvents!.map((v) => v.toJson()).toList();
    }
    if (this.sessionRouteHistory != null) {
      data['sessionRouteHistory'] = this.sessionRouteHistory!.toJson();
    }
    return data;
  }
}

class SessionEvents {
  String? sessionId;
  int? sessionNo;
  String? eventId;
  String? eventName;
  String? eventCode;
  double? eventLat;
  double? eventLong;
  String? eventActivityPlace;
  String? eventStartDate;
  String? eventEndDate;
  String? eventDuration;
  int? batteryPercentage;
  String? visitFormId;

  SessionEvents(
      {this.sessionId,
        this.sessionNo,
        this.eventId,
        this.eventName,
        this.eventCode,
        this.eventLat,
        this.eventLong,
        this.eventActivityPlace,
        this.eventStartDate,
        this.eventEndDate,
        this.eventDuration,
        this.batteryPercentage,
        this.visitFormId});

  SessionEvents.fromJson(Map<String, dynamic> json) {
    sessionId = json['sessionId'];
    sessionNo = json['sessionNo'];
    eventId = json['eventId'];
    eventName = json['eventName'];
    eventCode = json['eventCode'];
    eventLat = json['eventLat'];
    eventLong = json['eventLong'];
    eventActivityPlace = json['eventActivityPlace'];
    eventStartDate = json['eventStartDate'];
    eventEndDate = json['eventEndDate'];
    eventDuration = json['eventDuration'];
    batteryPercentage = json['batteryPercentage'];
    visitFormId = json['visitFormId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['sessionId'] = this.sessionId;
    data['sessionNo'] = this.sessionNo;
    data['eventId'] = this.eventId;
    data['eventName'] = this.eventName;
    data['eventCode'] = this.eventCode;
    data['eventLat'] = this.eventLat;
    data['eventLong'] = this.eventLong;
    data['eventActivityPlace'] = this.eventActivityPlace;
    data['eventStartDate'] = this.eventStartDate;
    data['eventEndDate'] = this.eventEndDate;
    data['eventDuration'] = this.eventDuration;
    data['batteryPercentage'] = this.batteryPercentage;
    data['visitFormId'] = this.visitFormId;
    return data;
  }
}

class SessionRouteHistory {
  String? sessionId;
  int? sessionNo;
  List<LatlongArray>? latlongArray;

  SessionRouteHistory({this.sessionId, this.sessionNo, this.latlongArray});

  SessionRouteHistory.fromJson(Map<String, dynamic> json) {
    sessionId = json['sessionId'];
    sessionNo = json['sessionNo'];
    if (json['latlongArray'] != null) {
      latlongArray = <LatlongArray>[];
      json['latlongArray'].forEach((v) {
        latlongArray!.add(new LatlongArray.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['sessionId'] = this.sessionId;
    data['sessionNo'] = this.sessionNo;
    if (this.latlongArray != null) {
      data['latlongArray'] = this.latlongArray!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class LatlongArray {
  double? x;
  double? y;

  LatlongArray({this.x, this.y});

  LatlongArray.fromJson(Map<String, dynamic> json) {
    x = json['x'];
    y = json['y'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['x'] = this.x;
    data['y'] = this.y;
    return data;
  }
}
