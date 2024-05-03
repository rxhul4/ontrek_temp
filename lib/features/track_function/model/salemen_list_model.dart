class GetSalesMenListModel {
  bool? isError;
  bool? isValidationFailed;
  String? errorCode;
  String? message;
  List<Data>? data;

  GetSalesMenListModel(
      {this.isError,
        this.isValidationFailed,
        this.errorCode,
        this.message,
        this.data});

  GetSalesMenListModel.fromJson(Map<String, dynamic> json) {
    isError = json['isError'];
    isValidationFailed = json['isValidationFailed'];
    errorCode = json['errorCode'];
    message = json['message'];
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(new Data.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['isError'] = this.isError;
    data['isValidationFailed'] = this.isValidationFailed;
    data['errorCode'] = this.errorCode;
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Data {
  String? userId;
  String? userName;
  String? managerName;
  String? phoneNo;
  int? countryCode;
  String? userEmail;
  String? managerId;
  Null? webAccess;
  String? orgId;
  String? orgName;
  String? profilePic;
  int? userType;
  String? eventTime;
  String? createdOn;
  String? lastSeenTime;
  String? lastSeenLocation;
  String? roleId;
  String? roleName;
  LastActivityDto? lastActivityDto;
  bool? isPresent;

  Data(
      {this.userId,
        this.userName,
        this.managerName,
        this.phoneNo,
        this.countryCode,
        this.userEmail,
        this.managerId,
        this.webAccess,
        this.orgId,
        this.orgName,
        this.profilePic,
        this.userType,
        this.eventTime,
        this.createdOn,
        this.lastSeenTime,
        this.lastSeenLocation,
        this.roleId,
        this.roleName,
        this.lastActivityDto,
        this.isPresent});

  Data.fromJson(Map<String, dynamic> json) {
    userId = json['userId'];
    userName = json['userName'];
    managerName = json['managerName'];
    phoneNo = json['phoneNo'];
    countryCode = json['countryCode'];
    userEmail = json['userEmail'];
    managerId = json['managerId'];
    webAccess = json['webAccess'];
    orgId = json['orgId'];
    orgName = json['orgName'];
    profilePic = json['profilePic'];
    userType = json['userType'];
    eventTime = json['eventTime'];
    createdOn = json['createdOn'];
    lastSeenTime = json['lastSeenTime'];
    lastSeenLocation = json['lastSeenLocation'];
    roleId = json['roleId'];
    roleName = json['roleName'];
    lastActivityDto = json['lastActivityDto'] != null
        ? new LastActivityDto.fromJson(json['lastActivityDto'])
        : null;
    isPresent = json['isPresent'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['userId'] = this.userId;
    data['userName'] = this.userName;
    data['managerName'] = this.managerName;
    data['phoneNo'] = this.phoneNo;
    data['countryCode'] = this.countryCode;
    data['userEmail'] = this.userEmail;
    data['managerId'] = this.managerId;
    data['webAccess'] = this.webAccess;
    data['orgId'] = this.orgId;
    data['orgName'] = this.orgName;
    data['profilePic'] = this.profilePic;
    data['userType'] = this.userType;
    data['eventTime'] = this.eventTime;
    data['createdOn'] = this.createdOn;
    data['lastSeenTime'] = this.lastSeenTime;
    data['lastSeenLocation'] = this.lastSeenLocation;
    data['roleId'] = this.roleId;
    data['roleName'] = this.roleName;
    if (this.lastActivityDto != null) {
      data['lastActivityDto'] = this.lastActivityDto!.toJson();
    }
    data['isPresent'] = this.isPresent;
    return data;
  }
}

class LastActivityDto {
  String? fieldUserId;
  String? trackingEventId;
  String? activityName;
  String? activityCode;
  String? lastTrackingActivityTime;
  double? lastActivityLat;
  double? lastActivityLong;
  String? lastActivityPlace;
  int? lastBatteryPercentage;
  String? tlDate;
  String? tlTime;
  String? tlDateTime;
  String? markerTitle;

  LastActivityDto(
      {this.fieldUserId,
        this.trackingEventId,
        this.activityName,
        this.activityCode,
        this.lastTrackingActivityTime,
        this.lastActivityLat,
        this.lastActivityLong,
        this.lastActivityPlace,
        this.lastBatteryPercentage,
        this.tlDate,
        this.tlTime,
        this.tlDateTime,
        this.markerTitle});

  LastActivityDto.fromJson(Map<String, dynamic> json) {
    fieldUserId = json['fieldUserId'];
    trackingEventId = json['trackingEventId'];
    activityName = json['activityName'];
    activityCode = json['activityCode'];
    lastTrackingActivityTime = json['lastTrackingActivityTime'];
    lastActivityLat = json['lastActivityLat'];
    lastActivityLong = json['lastActivityLong'];
    lastActivityPlace = json['lastActivityPlace'];
    lastBatteryPercentage = json['lastBatteryPercentage'];
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
    data['tlDate'] = this.tlDate;
    data['tlTime'] = this.tlTime;
    data['tlDateTime'] = this.tlDateTime;
    data['markerTitle'] = this.markerTitle;
    return data;
  }
}
