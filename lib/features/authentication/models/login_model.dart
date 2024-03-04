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
  String? token;
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
  String? roleId;
  String? roleName;

  Data(
      {this.appUserId,
        this.userName,
        this.countryCode,
        this.phoneNo,
        this.userEmail,
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
        this.roleId,
        this.roleName});

  Data.fromJson(Map<String, dynamic> json) {
    appUserId = json['appUserId'];
    userName = json['userName'];
    countryCode = json['countryCode'];
    phoneNo = json['phoneNo'];
    userEmail = json['userEmail'];
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
    roleId = json['roleId'];
    roleName = json['roleName'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['appUserId'] = this.appUserId;
    data['userName'] = this.userName;
    data['countryCode'] = this.countryCode;
    data['phoneNo'] = this.phoneNo;
    data['userEmail'] = this.userEmail;
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
    data['roleId'] = this.roleId;
    data['roleName'] = this.roleName;
    return data;
  }
}
