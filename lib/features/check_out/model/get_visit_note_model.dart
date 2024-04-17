class GetVisitNoteModel {
  bool? isError;
  bool? isValidationFailed;
  String? errorCode;
  String? message;
  List<Data>? data;

  GetVisitNoteModel(
      {this.isError,
        this.isValidationFailed,
        this.errorCode,
        this.message,
        this.data});

  GetVisitNoteModel.fromJson(Map<String, dynamic> json) {
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
  String? visitFormId;
  String? userId;
  String? totTrackingEventId;
  String? customerName;
  String? picturePath;
  String? visitDiscussion;
  String? companyName;
  String? customerPhoneNo;
  String? totVisitTypeId;
  String? visitTypeValue;
  String? createdOn;

  Data(
      {this.visitFormId,
        this.userId,
        this.totTrackingEventId,
        this.customerName,
        this.picturePath,
        this.visitDiscussion,
        this.companyName,
        this.customerPhoneNo,
        this.totVisitTypeId,
        this.visitTypeValue,
        this.createdOn});

  Data.fromJson(Map<String, dynamic> json) {
    visitFormId = json['visitFormId'];
    userId = json['userId'];
    totTrackingEventId = json['totTrackingEventId'];
    customerName = json['customerName'];
    picturePath = json['picturePath'];
    visitDiscussion = json['visitDiscussion'];
    companyName = json['companyName'];
    customerPhoneNo = json['customerPhoneNo'];
    totVisitTypeId = json['totVisitTypeId'];
    visitTypeValue = json['visitTypeValue'];
    createdOn = json['createdOn'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['visitFormId'] = this.visitFormId;
    data['userId'] = this.userId;
    data['totTrackingEventId'] = this.totTrackingEventId;
    data['customerName'] = this.customerName;
    data['picturePath'] = this.picturePath;
    data['visitDiscussion'] = this.visitDiscussion;
    data['companyName'] = this.companyName;
    data['customerPhoneNo'] = this.customerPhoneNo;
    data['totVisitTypeId'] = this.totVisitTypeId;
    data['visitTypeValue'] = this.visitTypeValue;
    data['createdOn'] = this.createdOn;
    return data;
  }
}
