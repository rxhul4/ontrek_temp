class LoginModel {
  bool? isError;
  bool? isValidationFailed;
  String? errorCode;
  String? message;
  Data? data;

  LoginModel(
      {this.isError,
        this.isValidationFailed,
        this.errorCode,
        this.message,
        this.data});

  LoginModel.fromJson(Map<String, dynamic> json) {
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
  String? appUserId;
  String? userName;
  int? countryCode;
  String? phoneNo;
  String? userEmail;
  String? profilePic;
  Null? token;
  String? deviceModel;
  bool? isAdmin;
  String? orgId;
  String? orgName;
  int? timeZoneDiff;
  bool? isActive;
  String? createdBy;
  String? createdOn;
  String? modifiedBy;
  String? modifiedOn;
  String? userType;
  String? roleId;
  String? roleName;
  AppUserConfigAttendanceRequest? appUserConfigAttendanceRequest;
  AppUserConfigTrackingRequest? appUserConfigTrackingRequest;

  Data(
      {this.appUserId,
        this.userName,
        this.countryCode,
        this.phoneNo,
        this.userEmail,
        this.profilePic,
        this.token,
        this.deviceModel,
        this.isAdmin,
        this.orgId,
        this.orgName,
        this.timeZoneDiff,
        this.isActive,
        this.createdBy,
        this.createdOn,
        this.modifiedBy,
        this.modifiedOn,
        this.userType,
        this.roleId,
        this.roleName,
        this.appUserConfigAttendanceRequest,
        this.appUserConfigTrackingRequest});

  Data.fromJson(Map<String, dynamic> json) {
    appUserId = json['appUserId'];
    userName = json['userName'];
    countryCode = json['countryCode'];
    phoneNo = json['phoneNo'];
    userEmail = json['userEmail'];
    profilePic = json['profilePic'];
    token = json['token'];
    deviceModel = json['deviceModel'];
    isAdmin = json['isAdmin'];
    orgId = json['orgId'];
    orgName = json['orgName'];
    timeZoneDiff = json['timeZoneDiff'];
    isActive = json['isActive'];
    createdBy = json['createdBy'];
    createdOn = json['createdOn'];
    modifiedBy = json['modifiedBy'];
    modifiedOn = json['modifiedOn'];
    userType = json['userType'];
    roleId = json['roleId'];
    roleName = json['roleName'];
    appUserConfigAttendanceRequest =
    json['appUserConfigAttendanceRequest'] != null
        ? new AppUserConfigAttendanceRequest.fromJson(
        json['appUserConfigAttendanceRequest'])
        : null;
    appUserConfigTrackingRequest = json['appUserConfigTrackingRequest'] != null
        ? new AppUserConfigTrackingRequest.fromJson(
        json['appUserConfigTrackingRequest'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['appUserId'] = this.appUserId;
    data['userName'] = this.userName;
    data['countryCode'] = this.countryCode;
    data['phoneNo'] = this.phoneNo;
    data['userEmail'] = this.userEmail;
    data['profilePic'] = this.profilePic;
    data['token'] = this.token;
    data['deviceModel'] = this.deviceModel;
    data['isAdmin'] = this.isAdmin;
    data['orgId'] = this.orgId;
    data['orgName'] = this.orgName;
    data['timeZoneDiff'] = this.timeZoneDiff;
    data['isActive'] = this.isActive;
    data['createdBy'] = this.createdBy;
    data['createdOn'] = this.createdOn;
    data['modifiedBy'] = this.modifiedBy;
    data['modifiedOn'] = this.modifiedOn;
    data['userType'] = this.userType;
    data['roleId'] = this.roleId;
    data['roleName'] = this.roleName;
    if (this.appUserConfigAttendanceRequest != null) {
      data['appUserConfigAttendanceRequest'] =
          this.appUserConfigAttendanceRequest!.toJson();
    }
    if (this.appUserConfigTrackingRequest != null) {
      data['appUserConfigTrackingRequest'] =
          this.appUserConfigTrackingRequest!.toJson();
    }
    return data;
  }
}

class AppUserConfigAttendanceRequest {
  bool? allowWebAccess;
  bool? allowFgAuth;
  bool? allowCheckinOut;
  bool? allowLocationRestriction;
  double? locationRestrictionLat;
  double? locationRestrictionLong;
  int? locRestrictionMtrs;
  bool? allowAutoLogout;
  Null? defaultAutoLogoutTime;

  AppUserConfigAttendanceRequest(
      {this.allowWebAccess,
        this.allowFgAuth,
        this.allowCheckinOut,
        this.allowLocationRestriction,
        this.locationRestrictionLat,
        this.locationRestrictionLong,
        this.locRestrictionMtrs,
        this.allowAutoLogout,
        this.defaultAutoLogoutTime});

  AppUserConfigAttendanceRequest.fromJson(Map<String, dynamic> json) {
    allowWebAccess = json['allowWebAccess'];
    allowFgAuth = json['allowFgAuth'];
    allowCheckinOut = json['allowCheckinOut'];
    allowLocationRestriction = json['allowLocationRestriction'];
    locationRestrictionLat = json['locationRestrictionLat'];
    locationRestrictionLong = json['locationRestrictionLong'];
    locRestrictionMtrs = json['locRestrictionMtrs'];
    allowAutoLogout = json['allowAutoLogout'];
    defaultAutoLogoutTime = json['defaultAutoLogoutTime'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['allowWebAccess'] = this.allowWebAccess;
    data['allowFgAuth'] = this.allowFgAuth;
    data['allowCheckinOut'] = this.allowCheckinOut;
    data['allowLocationRestriction'] = this.allowLocationRestriction;
    data['locationRestrictionLat'] = this.locationRestrictionLat;
    data['locationRestrictionLong'] = this.locationRestrictionLong;
    data['locRestrictionMtrs'] = this.locRestrictionMtrs;
    data['allowAutoLogout'] = this.allowAutoLogout;
    data['defaultAutoLogoutTime'] = this.defaultAutoLogoutTime;
    return data;
  }
}

class AppUserConfigTrackingRequest {
  bool? allowLiveTracking;
  int? liveTrackingInterval;
  bool? allowCheckoutReminder;
  Null? chekoutReminderDistance;
  bool? allowIdleMarker;
  int? idleMarkerTime;
  bool? allowNotification;

  AppUserConfigTrackingRequest(
      {this.allowLiveTracking,
        this.liveTrackingInterval,
        this.allowCheckoutReminder,
        this.chekoutReminderDistance,
        this.allowIdleMarker,
        this.idleMarkerTime,
        this.allowNotification});

  AppUserConfigTrackingRequest.fromJson(Map<String, dynamic> json) {
    allowLiveTracking = json['allowLiveTracking'];
    liveTrackingInterval = json['liveTrackingInterval'];
    allowCheckoutReminder = json['allowCheckoutReminder'];
    chekoutReminderDistance = json['chekoutReminderDistance'];
    allowIdleMarker = json['allowIdleMarker'];
    idleMarkerTime = json['idleMarkerTime'];
    allowNotification = json['allowNotification'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['allowLiveTracking'] = this.allowLiveTracking;
    data['liveTrackingInterval'] = this.liveTrackingInterval;
    data['allowCheckoutReminder'] = this.allowCheckoutReminder;
    data['chekoutReminderDistance'] = this.chekoutReminderDistance;
    data['allowIdleMarker'] = this.allowIdleMarker;
    data['idleMarkerTime'] = this.idleMarkerTime;
    data['allowNotification'] = this.allowNotification;
    return data;
  }
}
