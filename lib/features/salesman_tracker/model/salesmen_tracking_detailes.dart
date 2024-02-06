class GetTimeLineModel {
  List<Data>? data;
  bool? isSuccessful;
  int? code;
  String? message;

  GetTimeLineModel({this.data, this.isSuccessful, this.code, this.message});

  GetTimeLineModel.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(new Data.fromJson(v));
      });
    }
    isSuccessful = json['isSuccessful'];
    code = json['code'];
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    data['isSuccessful'] = this.isSuccessful;
    data['code'] = this.code;
    data['message'] = this.message;
    return data;
  }
}

class Data {
  String? userUid;
  int? trackingId;
  String? trackingStatus;
  double? lattitude;
  double? longitude;
  String? totTrackingEventCode;
  String? eventDate;
  String? sessionUid;
  String? eventTime;
  String? parentTrackingId;
  String? durationMin;
  int? batteryLevel;
  String? deviceId;
  String? deviceName;
  int? locAccuracy;
  String? trackingAddress;
  int? formVisitId;
  String? customerName;
  String? picturePath;
  String? visitDiscussion;
  String? companyName;
  String? customerPhoneNo;
  String? totVisitTypeCode;

  Data(
      {this.userUid,
        this.trackingId,
        this.trackingStatus,
        this.lattitude,
        this.longitude,
        this.totTrackingEventCode,
        this.eventDate,
        this.sessionUid,
        this.eventTime,
        this.parentTrackingId,
        this.durationMin,
        this.batteryLevel,
        this.deviceId,
        this.deviceName,
        this.locAccuracy,
        this.trackingAddress,
        this.formVisitId,
        this.customerName,
        this.picturePath,
        this.visitDiscussion,
        this.companyName,
        this.customerPhoneNo,
        this.totVisitTypeCode});

  Data.fromJson(Map<String, dynamic> json) {
    userUid = json['user_uid'];
    trackingId = json['tracking_id'];
    trackingStatus = json['trackingStatus'];
    lattitude = json['lattitude'];
    longitude = json['longitude'];
    totTrackingEventCode = json['tot_tracking_event_code'];
    eventDate = json['event_date'];
    sessionUid = json['session_uid'];
    eventTime = json['event_time'];
    parentTrackingId = json['parent_tracking_id'];
    durationMin = json['duration_min'];
    batteryLevel = json['battery_level'];
    deviceId = json['device_id'];
    deviceName = json['device_name'];
    locAccuracy = json['loc_accuracy'];
    trackingAddress = json['tracking_address'];
    formVisitId = json['form_visit_id'];
    customerName = json['customer_name'];
    picturePath = json['picture_path'];
    visitDiscussion = json['visit_discussion'];
    companyName = json['company_name'];
    customerPhoneNo = json['customer_phone_no'];
    totVisitTypeCode = json['tot_visit_type_code'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['user_uid'] = this.userUid;
    data['tracking_id'] = this.trackingId;
    data['trackingStatus'] = this.trackingStatus;
    data['lattitude'] = this.lattitude;
    data['longitude'] = this.longitude;
    data['tot_tracking_event_code'] = this.totTrackingEventCode;
    data['event_date'] = this.eventDate;
    data['session_uid'] = this.sessionUid;
    data['event_time'] = this.eventTime;
    data['parent_tracking_id'] = this.parentTrackingId;
    data['duration_min'] = this.durationMin;
    data['battery_level'] = this.batteryLevel;
    data['device_id'] = this.deviceId;
    data['device_name'] = this.deviceName;
    data['loc_accuracy'] = this.locAccuracy;
    data['tracking_address'] = this.trackingAddress;
    data['form_visit_id'] = this.formVisitId;
    data['customer_name'] = this.customerName;
    data['picture_path'] = this.picturePath;
    data['visit_discussion'] = this.visitDiscussion;
    data['company_name'] = this.companyName;
    data['customer_phone_no'] = this.customerPhoneNo;
    data['tot_visit_type_code'] = this.totVisitTypeCode;
    return data;
  }
}
