class AddActivityModel {
  Data? data;
  bool? isSuccessful;
  int? code;
  String? message;

  AddActivityModel({this.data, this.isSuccessful, this.code, this.message});

  AddActivityModel.fromJson(Map<String, dynamic> json) {
    data = json['data'] != null ? new Data.fromJson(json['data']) : null;
    isSuccessful = json['isSuccessful'];
    code = json['code'];
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    data['isSuccessful'] = this.isSuccessful;
    data['code'] = this.code;
    data['message'] = this.message;
    return data;
  }
}

class Data {
  String? userUid;
  double? lattitude;
  double? longitude;
  String? totTrackingEventCode;
  String? eventDate;
  String? eventTime;
  int? batteryLevel;
  String? deviceId;
  String? deviceName;
  double? locAccuracy;
  String? trackingAddress;
  String? customerName;
  String? picturePath;
  String? visitDiscussion;
  String? companyName;
  String? customerPhoneNo;
  String? visitTypeCode;
  String? activityStatus;

  Data(
      {this.userUid,
        this.lattitude,
        this.longitude,
        this.totTrackingEventCode,
        this.eventDate,
        this.eventTime,
        this.batteryLevel,
        this.deviceId,
        this.deviceName,
        this.locAccuracy,
        this.trackingAddress,
        this.customerName,
        this.picturePath,
        this.visitDiscussion,
        this.companyName,
        this.customerPhoneNo,
        this.visitTypeCode,
        this.activityStatus});

  Data.fromJson(Map<String, dynamic> json) {
    userUid = json['user_uid'];
    lattitude = json['lattitude'];
    longitude = json['longitude'];
    totTrackingEventCode = json['tot_tracking_event_code'];
    eventDate = json['event_date'];
    eventTime = json['event_time'];
    batteryLevel = json['battery_level'];
    deviceId = json['device_id'];
    deviceName = json['device_name'];
    locAccuracy = json['loc_accuracy'];
    trackingAddress = json['tracking_address'];
    customerName = json['customer_name'];
    picturePath = json['picture_path'];
    visitDiscussion = json['visit_discussion'];
    companyName = json['company_name'];
    customerPhoneNo = json['customer_phone_no'];
    visitTypeCode = json['visit_type_code'];
    activityStatus = json['activityStatus'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['user_uid'] = this.userUid;
    data['lattitude'] = this.lattitude;
    data['longitude'] = this.longitude;
    data['tot_tracking_event_code'] = this.totTrackingEventCode;
    data['event_date'] = this.eventDate;
    data['event_time'] = this.eventTime;
    data['battery_level'] = this.batteryLevel;
    data['device_id'] = this.deviceId;
    data['device_name'] = this.deviceName;
    data['loc_accuracy'] = this.locAccuracy;
    data['tracking_address'] = this.trackingAddress;
    data['customer_name'] = this.customerName;
    data['picture_path'] = this.picturePath;
    data['visit_discussion'] = this.visitDiscussion;
    data['company_name'] = this.companyName;
    data['customer_phone_no'] = this.customerPhoneNo;
    data['visit_type_code'] = this.visitTypeCode;
    data['activityStatus'] = this.activityStatus;
    return data;
  }
}
