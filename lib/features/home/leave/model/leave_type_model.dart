class GetLeaveTypeModel {
  bool? isError;
  bool? isValidationFailed;
  String? errorCode;
  String? message;
  List<Data>? data;

  GetLeaveTypeModel(
      {this.isError,
        this.isValidationFailed,
        this.errorCode,
        this.message,
        this.data});

  GetLeaveTypeModel.fromJson(Map<String, dynamic> json) {
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
  String? totId;
  String? totGroup;
  int? totKey;
  String? totValue;
  int? totSequence;
  String? totCode;

  Data(
      {this.totId,
        this.totGroup,
        this.totKey,
        this.totValue,
        this.totSequence,
        this.totCode});

  Data.fromJson(Map<String, dynamic> json) {
    totId = json['totId'];
    totGroup = json['totGroup'];
    totKey = json['totKey'];
    totValue = json['totValue'];
    totSequence = json['totSequence'];
    totCode = json['totCode'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['totId'] = this.totId;
    data['totGroup'] = this.totGroup;
    data['totKey'] = this.totKey;
    data['totValue'] = this.totValue;
    data['totSequence'] = this.totSequence;
    data['totCode'] = this.totCode;
    return data;
  }
}
