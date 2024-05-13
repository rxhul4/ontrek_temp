class GetLastPendingDayEnd {
  bool? isError;
  bool? isValidationFailed;
  String? errorCode;
  String? message;
  Data? data;

  GetLastPendingDayEnd(
      {this.isError,
        this.isValidationFailed,
        this.errorCode,
        this.message,
        this.data});

  GetLastPendingDayEnd.fromJson(Map<String, dynamic> json) {
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
  String? sessionId;
  String? userId;
  int? sessionNo;
  String? sessionStartDatetime;
  String? sessionEndDatetime;
  bool? isActiveSession;
  String? sessionDateOnly;

  Data(
      {this.sessionId,
        this.userId,
        this.sessionNo,
        this.sessionStartDatetime,
        this.sessionEndDatetime,
        this.isActiveSession,
        this.sessionDateOnly});

  Data.fromJson(Map<String, dynamic> json) {
    sessionId = json['sessionId'];
    userId = json['userId'];
    sessionNo = json['sessionNo'];
    sessionStartDatetime = json['sessionStartDatetime'];
    sessionEndDatetime = json['sessionEndDatetime'];
    isActiveSession = json['isActiveSession'];
    sessionDateOnly = json['sessionDateOnly'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['sessionId'] = this.sessionId;
    data['userId'] = this.userId;
    data['sessionNo'] = this.sessionNo;
    data['sessionStartDatetime'] = this.sessionStartDatetime;
    data['sessionEndDatetime'] = this.sessionEndDatetime;
    data['isActiveSession'] = this.isActiveSession;
    data['sessionDateOnly'] = this.sessionDateOnly;
    return data;
  }
}
