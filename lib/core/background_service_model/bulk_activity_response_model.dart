class BulkActivityResponseModel {
  bool? isError;
  bool? isValidationFailed;
  String? errorCode;
  String? message;
  List<Data>? data;

  BulkActivityResponseModel(
      {this.isError,
        this.isValidationFailed,
        this.errorCode,
        this.message,
        this.data});

  BulkActivityResponseModel.fromJson(Map<String, dynamic> json) {
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
  String? sessionId;
  int? localPkId;
  String? eventCode;
  String? eventDate;
  bool? isSuccess;
  String? errorCode;
  String? message;

  Data(
      {this.sessionId,
        this.localPkId,
        this.eventCode,
        this.eventDate,
        this.isSuccess,
        this.errorCode,
        this.message});

  Data.fromJson(Map<String, dynamic> json) {
    sessionId = json['sessionId'];
    localPkId = json['localPkId'];
    eventCode = json['eventCode'];
    eventDate = json['eventDate'];
    isSuccess = json['isSuccess'];
    errorCode = json['errorCode'];
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['sessionId'] = this.sessionId;
    data['localPkId'] = this.localPkId;
    data['eventCode'] = this.eventCode;
    data['eventDate'] = this.eventDate;
    data['isSuccess'] = this.isSuccess;
    data['errorCode'] = this.errorCode;
    data['message'] = this.message;
    return data;
  }
}
