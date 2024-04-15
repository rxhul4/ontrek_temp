class GetLeadByIdModel {
  bool? isError;
  bool? isValidationFailed;
  String? errorCode;
  String? message;
  Data? data;

  GetLeadByIdModel(
      {this.isError,
        this.isValidationFailed,
        this.errorCode,
        this.message,
        this.data});

  GetLeadByIdModel.fromJson(Map<String, dynamic> json) {
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
  String? leadId;
  String? userId;
  String? totLeadSourceId;
  String? countryId;
  String? stateId;
  String? cityId;
  String? companyName;
  String? customerName;
  String? customerPhone;
  String? customerEmail;
  String? customerAddress;
  String? zipCode;
  String? createdOn;
  String? modifiedOn;
  bool? isActive;
  bool? isDeleted;
  String? createdBy;
  String? modifiedBy;
  AppUserDtos? appUserDtos;
  TotDtos? totDtos;

  Data(
      {this.leadId,
        this.userId,
        this.totLeadSourceId,
        this.countryId,
        this.stateId,
        this.cityId,
        this.companyName,
        this.customerName,
        this.customerPhone,
        this.customerEmail,
        this.customerAddress,
        this.zipCode,
        this.createdOn,
        this.modifiedOn,
        this.isActive,
        this.isDeleted,
        this.createdBy,
        this.modifiedBy,
        this.appUserDtos,
        this.totDtos});

  Data.fromJson(Map<String, dynamic> json) {
    leadId = json['leadId'];
    userId = json['userId'];
    totLeadSourceId = json['totLeadSourceId'];
    countryId = json['countryId'];
    stateId = json['stateId'];
    cityId = json['cityId'];
    companyName = json['companyName'];
    customerName = json['customerName'];
    customerPhone = json['customerPhone'];
    customerEmail = json['customerEmail'];
    customerAddress = json['customerAddress'];
    zipCode = json['zipCode'];
    createdOn = json['createdOn'];
    modifiedOn = json['modifiedOn'];
    isActive = json['isActive'];
    isDeleted = json['isDeleted'];
    createdBy = json['createdBy'];
    modifiedBy = json['modifiedBy'];
    appUserDtos = json['appUserDtos'] != null
        ? new AppUserDtos.fromJson(json['appUserDtos'])
        : null;
    totDtos =
    json['totDtos'] != null ? new TotDtos.fromJson(json['totDtos']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['leadId'] = this.leadId;
    data['userId'] = this.userId;
    data['totLeadSourceId'] = this.totLeadSourceId;
    data['countryId'] = this.countryId;
    data['stateId'] = this.stateId;
    data['cityId'] = this.cityId;
    data['companyName'] = this.companyName;
    data['customerName'] = this.customerName;
    data['customerPhone'] = this.customerPhone;
    data['customerEmail'] = this.customerEmail;
    data['customerAddress'] = this.customerAddress;
    data['zipCode'] = this.zipCode;
    data['createdOn'] = this.createdOn;
    data['modifiedOn'] = this.modifiedOn;
    data['isActive'] = this.isActive;
    data['isDeleted'] = this.isDeleted;
    data['createdBy'] = this.createdBy;
    data['modifiedBy'] = this.modifiedBy;
    if (this.appUserDtos != null) {
      data['appUserDtos'] = this.appUserDtos!.toJson();
    }
    if (this.totDtos != null) {
      data['totDtos'] = this.totDtos!.toJson();
    }
    return data;
  }
}

class AppUserDtos {
  String? pkId;
  String? userName;
  String? userEmail;

  AppUserDtos({this.pkId, this.userName, this.userEmail});

  AppUserDtos.fromJson(Map<String, dynamic> json) {
    pkId = json['pkId'];
    userName = json['userName'];
    userEmail = json['userEmail'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['pkId'] = this.pkId;
    data['userName'] = this.userName;
    data['userEmail'] = this.userEmail;
    return data;
  }
}

class TotDtos {
  String? totId;
  String? totValue;

  TotDtos({this.totId, this.totValue});

  TotDtos.fromJson(Map<String, dynamic> json) {
    totId = json['totId'];
    totValue = json['totValue'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['totId'] = this.totId;
    data['totValue'] = this.totValue;
    return data;
  }
}
