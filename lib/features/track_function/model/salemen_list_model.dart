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
  String? phoneNo;
  int? countryCode;
  String? userEmail;
  String? managerId;
  bool? webAccess;
  String? orgId;
  String? orgName;
  String? profilePic;
  int? userType;
  String? eventTime;
  int? batteryLevel;
  String? createdOn;
  String? roleId;
  String? roleName;
  bool? isPresent;

  Data(
      {this.userId,
        this.userName,
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
        this.batteryLevel,
        this.createdOn,
        this.roleId,
        this.roleName,
        this.isPresent});

  Data.fromJson(Map<String, dynamic> json) {
    userId = json['userId'];
    userName = json['userName'];
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
    batteryLevel = json['batteryLevel'];
    createdOn = json['createdOn'];
    roleId = json['roleId'];
    roleName = json['roleName'];
    isPresent = json['isPresent'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['userId'] = this.userId;
    data['userName'] = this.userName;
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
    data['batteryLevel'] = this.batteryLevel;
    data['createdOn'] = this.createdOn;
    data['roleId'] = this.roleId;
    data['roleName'] = this.roleName;
    data['isPresent'] = this.isPresent;
    return data;
  }
}
