class ExpenseListModel {
  bool? isError;
  bool? isValidationFailed;
  String? errorCode;
  String? message;
  Data? data;

  ExpenseListModel(
      {this.isError,
        this.isValidationFailed,
        this.errorCode,
        this.message,
        this.data});

  ExpenseListModel.fromJson(Map<String, dynamic> json) {
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
  String? expenseDate;
  String? submissionDate;
  String? expenseCategoryId;
  String? expenseCategoryName;
  String? expenseSubCategoryId;
  String? expenseSubCategoryName;
  String? expenseDescription;
  int? submittedAmount;
  String? approvedRejectedBy;
  String? approveRejectDate;
  int? approvedAmount;
  String? approverNotes;
  String? invoiceImage;
  bool? isApproved;

  ListItem(
      {this.pkId,
        this.orgId,
        this.userId,
        this.userName,
        this.expenseDate,
        this.submissionDate,
        this.expenseCategoryId,
        this.expenseCategoryName,
        this.expenseSubCategoryId,
        this.expenseSubCategoryName,
        this.expenseDescription,
        this.submittedAmount,
        this.approvedRejectedBy,
        this.approveRejectDate,
        this.approvedAmount,
        this.approverNotes,
        this.invoiceImage,
        this.isApproved});

  ListItem.fromJson(Map<String, dynamic> json) {
    pkId = json['pkId'];
    orgId = json['orgId'];
    userId = json['userId'];
    userName = json['userName'];
    expenseDate = json['expenseDate'];
    submissionDate = json['submissionDate'];
    expenseCategoryId = json['expenseCategoryId'];
    expenseCategoryName = json['expenseCategoryName'];
    expenseSubCategoryId = json['expenseSubCategoryId'];
    expenseSubCategoryName = json['expenseSubCategoryName'];
    expenseDescription = json['expenseDescription'];
    submittedAmount = json['submittedAmount'];
    approvedRejectedBy = json['approvedRejectedBy'];
    approveRejectDate = json['approveRejectDate'];
    approvedAmount = json['approvedAmount'];
    approverNotes = json['approverNotes'];
    invoiceImage = json['invoiceImage'];
    isApproved = json['isApproved'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['pkId'] = this.pkId;
    data['orgId'] = this.orgId;
    data['userId'] = this.userId;
    data['userName'] = this.userName;
    data['expenseDate'] = this.expenseDate;
    data['submissionDate'] = this.submissionDate;
    data['expenseCategoryId'] = this.expenseCategoryId;
    data['expenseCategoryName'] = this.expenseCategoryName;
    data['expenseSubCategoryId'] = this.expenseSubCategoryId;
    data['expenseSubCategoryName'] = this.expenseSubCategoryName;
    data['expenseDescription'] = this.expenseDescription;
    data['submittedAmount'] = this.submittedAmount;
    data['approvedRejectedBy'] = this.approvedRejectedBy;
    data['approveRejectDate'] = this.approveRejectDate;
    data['approvedAmount'] = this.approvedAmount;
    data['approverNotes'] = this.approverNotes;
    data['invoiceImage'] = this.invoiceImage;
    data['isApproved'] = this.isApproved;
    return data;
  }
}
