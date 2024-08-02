class LeaveListModel {
  bool? isError;
  bool? isValidationFailed;
  String? errorCode;
  String? message;
  Data? data;

  LeaveListModel(
      {this.isError,
        this.isValidationFailed,
        this.errorCode,
        this.message,
        this.data});

  LeaveListModel.fromJson(Map<String, dynamic> json) {
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
  String? pkId;
  String? orgId;
  String? userId;
  String? userName;
  String? leaveCategoryTotId;
  String? leaveCategoryTotName;
  String? leaveReason;
  bool? isFullDay;
  String? submissionDate;
  String? leaveStartDate;
  String? leaveEndDate;
  num? leaveDays;
  String? approvedRejectedBy;
  String? approvedRejectedOn;
  bool? isApproved;
  String? approverNote;

  ListItem(
      {this.pkId,
        this.orgId,
        this.userId,
        this.userName,
        this.leaveCategoryTotId,
        this.leaveCategoryTotName,
        this.leaveReason,
        this.isFullDay,
        this.submissionDate,
        this.leaveStartDate,
        this.leaveEndDate,
        this.leaveDays,
        this.approvedRejectedBy,
        this.approvedRejectedOn,
        this.isApproved,
        this.approverNote});

  ListItem.fromJson(Map<String, dynamic> json) {
    pkId = json['pkId'];
    orgId = json['orgId'];
    userId = json['userId'];
    userName = json['userName'];
    leaveCategoryTotId = json['leaveCategoryTotId'];
    leaveCategoryTotName = json['leaveCategoryTotName'];
    leaveReason = json['leaveReason'];
    isFullDay = json['isFullDay'];
    submissionDate = json['submissionDate'];
    leaveStartDate = json['leaveStartDate'];
    leaveEndDate = json['leaveEndDate'];
    leaveDays = json['leaveDays'];
    approvedRejectedBy = json['approvedRejectedBy'];
    approvedRejectedOn = json['approvedRejectedOn'];
    isApproved = json['isApproved'];
    approverNote = json['approverNote'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['pkId'] = this.pkId;
    data['orgId'] = this.orgId;
    data['userId'] = this.userId;
    data['userName'] = this.userName;
    data['leaveCategoryTotId'] = this.leaveCategoryTotId;
    data['leaveCategoryTotName'] = this.leaveCategoryTotName;
    data['leaveReason'] = this.leaveReason;
    data['isFullDay'] = this.isFullDay;
    data['submissionDate'] = this.submissionDate;
    data['leaveStartDate'] = this.leaveStartDate;
    data['leaveEndDate'] = this.leaveEndDate;
    data['leaveDays'] = this.leaveDays;
    data['approvedRejectedBy'] = this.approvedRejectedBy;
    data['approvedRejectedOn'] = this.approvedRejectedOn;
    data['isApproved'] = this.isApproved;
    data['approverNote'] = this.approverNote;
    return data;
  }
}
