class DayEndRequestModel {
  bool? isError;
  bool? isValidationFailed;
  String? errorCode;
  String? message;
  Data? data;

  DayEndRequestModel(
      {this.isError,
        this.isValidationFailed,
        this.errorCode,
        this.message,
        this.data});

  DayEndRequestModel.fromJson(Map<String, dynamic> json) {
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
  int? pageSize;
  int? pageNo;
  int? recordCount;
  List<ListItem>? listItem;

  Data({this.pageSize, this.pageNo, this.recordCount, this.listItem});

  Data.fromJson(Map<String, dynamic> json) {
    pageSize = json['pageSize'];
    pageNo = json['pageNo'];
    recordCount = json['recordCount'];
    if (json['listItem'] != null) {
      listItem = <ListItem>[];
      json['listItem'].forEach((v) {
        listItem!.add(new ListItem.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['pageSize'] = this.pageSize;
    data['pageNo'] = this.pageNo;
    data['recordCount'] = this.recordCount;
    if (this.listItem != null) {
      data['listItem'] = this.listItem!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class ListItem {
  String? userId;
  String? sessionId;
  String? requestedDate;
  String? attendanceDate;
  String? requestedBy;
  String? approvedBy;
  String? approvedOn;
  String? comment;
  String? approverComment;
  bool? isApproved;

  ListItem(
      {this.userId,
        this.sessionId,
        this.requestedDate,
        this.attendanceDate,
        this.requestedBy,
        this.approvedBy,
        this.approvedOn,
        this.comment,
        this.approverComment,
        this.isApproved});

  ListItem.fromJson(Map<String, dynamic> json) {
    userId = json['userId'];
    sessionId = json['sessionId'];
    requestedDate = json['requestedDate'];
    attendanceDate = json['attendanceDate'];
    requestedBy = json['requestedBy'];
    approvedBy = json['approvedBy'];
    approvedOn = json['approvedOn'];
    comment = json['comment'];
    approverComment = json['approverComment'];
    isApproved = json['isApproved'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['userId'] = this.userId;
    data['sessionId'] = this.sessionId;
    data['requestedDate'] = this.requestedDate;
    data['attendanceDate'] = this.attendanceDate;
    data['requestedBy'] = this.requestedBy;
    data['approvedBy'] = this.approvedBy;
    data['approvedOn'] = this.approvedOn;
    data['comment'] = this.comment;
    data['approverComment'] = this.approverComment;
    data['isApproved'] = this.isApproved;
    return data;
  }
}
