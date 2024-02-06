class GetSalesMenListModel {
  List<Data>? data;
  bool? isSuccessful;
  int? code;
  String? message;

  GetSalesMenListModel({this.data, this.isSuccessful, this.code, this.message});

  GetSalesMenListModel.fromJson(Map<String, dynamic> json) {
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
  int? userId;
  String? userUid;
  String? fullName;
  String? phoneNo;
  int? roleId;
  String? roleName;
  int? managerId;
  bool? allowWebAccess;
  int? workLocationId;
  String? companyUid;
  String? profilePic;
  String? countryPhoneCode;
  String? totUserTypeCode;
  String? totEmploymentTypeCode;
  String? totTrackingEventCode;
  String? eventDate;
  String? eventTime;
  int? batteryLevel;
  String? createdOn;
  bool? isPresent;

  Data(
      {this.userId,
        this.userUid,
        this.fullName,
        this.phoneNo,
        this.roleId,
        this.roleName,
        this.managerId,
        this.allowWebAccess,
        this.workLocationId,
        this.companyUid,
        this.profilePic,
        this.countryPhoneCode,
        this.totUserTypeCode,
        this.totEmploymentTypeCode,
        this.totTrackingEventCode,
        this.eventDate,
        this.eventTime,
        this.batteryLevel,
        this.createdOn,
        this.isPresent});

  Data.fromJson(Map<String, dynamic> json) {
    userId = json['user_id'];
    userUid = json['user_uid'];
    fullName = json['full_name'];
    phoneNo = json['phone_no'];
    roleId = json['role_id'];
    roleName = json['role_name'];
    managerId = json['manager_id'];
    allowWebAccess = json['allow_web_access'];
    workLocationId = json['work_location_id'];
    companyUid = json['company_uid'];
    profilePic = json['profile_pic'];
    countryPhoneCode = json['country_phone_code'];
    totUserTypeCode = json['tot_user_type_code'];
    totEmploymentTypeCode = json['tot_employment_type_code'];
    totTrackingEventCode = json['tot_tracking_event_code'];
    eventDate = json['event_date'];
    eventTime = json['event_time'];
    batteryLevel = json['battery_level'];
    createdOn = json['created_on'];
    isPresent = json['isPresent'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['user_id'] = this.userId;
    data['user_uid'] = this.userUid;
    data['full_name'] = this.fullName;
    data['phone_no'] = this.phoneNo;
    data['role_id'] = this.roleId;
    data['role_name'] = this.roleName;
    data['manager_id'] = this.managerId;
    data['allow_web_access'] = this.allowWebAccess;
    data['work_location_id'] = this.workLocationId;
    data['company_uid'] = this.companyUid;
    data['profile_pic'] = this.profilePic;
    data['country_phone_code'] = this.countryPhoneCode;
    data['tot_user_type_code'] = this.totUserTypeCode;
    data['tot_employment_type_code'] = this.totEmploymentTypeCode;
    data['tot_tracking_event_code'] = this.totTrackingEventCode;
    data['event_date'] = this.eventDate;
    data['event_time'] = this.eventTime;
    data['battery_level'] = this.batteryLevel;
    data['created_on'] = this.createdOn;
    data['isPresent'] = this.isPresent;
    return data;
  }
}
