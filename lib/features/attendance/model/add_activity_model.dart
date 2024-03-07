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
  String? trackingId;
  String? userId;
  String? sessionId;
  String? parentTrackingId;
  String? totTrackingEventId;
  String? totTrackingValue;
  int? batteryLevel;
  String? deviceId;
  String? deviceName;
  int? locationAccuracy;
  bool? isFakeLocation;
  String? trackingAddress;
  String? eventDate;
  String? durationMin;
  bool? isActive;
  bool? isDeleted;
  String? createdBy;
  String? createdOn;
  String? modifiedBy;
  String? modifiedOn;

  Data(
      {this.trackingId,
        this.userId,
        this.sessionId,
        this.parentTrackingId,
        this.totTrackingEventId,
        this.totTrackingValue,
        this.batteryLevel,
        this.deviceId,
        this.deviceName,
        this.locationAccuracy,
        this.isFakeLocation,
        this.trackingAddress,
        this.eventDate,
        this.durationMin,
        this.isActive,
        this.isDeleted,
        this.createdBy,
        this.createdOn,
        this.modifiedBy,
        this.modifiedOn});

  Data.fromJson(Map<String, dynamic> json) {
    trackingId = json['trackingId'];
    userId = json['userId'];
    sessionId = json['sessionId'];
    parentTrackingId = json['parentTrackingId'];
    totTrackingEventId = json['totTrackingEventId'];
    totTrackingValue = json['totTrackingValue'];
    batteryLevel = json['batteryLevel'];
    deviceId = json['deviceId'];
    deviceName = json['deviceName'];
    locationAccuracy = json['locationAccuracy'];
    isFakeLocation = json['isFakeLocation'];
    trackingAddress = json['trackingAddress'];
    eventDate = json['eventDate'];
    durationMin = json['durationMin'];
    isActive = json['isActive'];
    isDeleted = json['isDeleted'];
    createdBy = json['createdBy'];
    createdOn = json['createdOn'];
    modifiedBy = json['modifiedBy'];
    modifiedOn = json['modifiedOn'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['trackingId'] = this.trackingId;
    data['userId'] = this.userId;
    data['sessionId'] = this.sessionId;
    data['parentTrackingId'] = this.parentTrackingId;
    data['totTrackingEventId'] = this.totTrackingEventId;
    data['totTrackingValue'] = this.totTrackingValue;
    data['batteryLevel'] = this.batteryLevel;
    data['deviceId'] = this.deviceId;
    data['deviceName'] = this.deviceName;
    data['locationAccuracy'] = this.locationAccuracy;
    data['isFakeLocation'] = this.isFakeLocation;
    data['trackingAddress'] = this.trackingAddress;
    data['eventDate'] = this.eventDate;
    data['durationMin'] = this.durationMin;
    data['isActive'] = this.isActive;
    data['isDeleted'] = this.isDeleted;
    data['createdBy'] = this.createdBy;
    data['createdOn'] = this.createdOn;
    data['modifiedBy'] = this.modifiedBy;
    data['modifiedOn'] = this.modifiedOn;
    return data;
  }
}
