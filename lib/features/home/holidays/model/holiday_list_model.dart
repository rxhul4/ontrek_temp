class GetHolidayListModel {
  bool? isError;
  bool? isValidationFailed;
  String? errorCode;
  String? message;
  List<Data>? data;

  GetHolidayListModel(
      {this.isError,
        this.isValidationFailed,
        this.errorCode,
        this.message,
        this.data});

  GetHolidayListModel.fromJson(Map<String, dynamic> json) {
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
  String? pkId;
  String? countryId;
  String? countryName;
  String? stateId;
  String? stateName;
  String? orgId;
  String? holidayTitle;
  String? holidayDescription;
  String? holidayDate;
  String? createdOn;
  String? modifiedBy;
  String? modifiedOn;

  Data(
      {this.pkId,
        this.countryId,
        this.countryName,
        this.stateId,
        this.stateName,
        this.orgId,
        this.holidayTitle,
        this.holidayDescription,
        this.holidayDate,
        this.createdOn,
        this.modifiedBy,
        this.modifiedOn});

  Data.fromJson(Map<String, dynamic> json) {
    pkId = json['pkId'];
    countryId = json['countryId'];
    countryName = json['countryName'];
    stateId = json['stateId'];
    stateName = json['stateName'];
    orgId = json['orgId'];
    holidayTitle = json['holidayTitle'];
    holidayDescription = json['holidayDescription'];
    holidayDate = json['holidayDate'];
    createdOn = json['createdOn'];
    modifiedBy = json['modifiedBy'];
    modifiedOn = json['modifiedOn'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['pkId'] = this.pkId;
    data['countryId'] = this.countryId;
    data['countryName'] = this.countryName;
    data['stateId'] = this.stateId;
    data['stateName'] = this.stateName;
    data['orgId'] = this.orgId;
    data['holidayTitle'] = this.holidayTitle;
    data['holidayDescription'] = this.holidayDescription;
    data['holidayDate'] = this.holidayDate;
    data['createdOn'] = this.createdOn;
    data['modifiedBy'] = this.modifiedBy;
    data['modifiedOn'] = this.modifiedOn;
    return data;
  }
}
