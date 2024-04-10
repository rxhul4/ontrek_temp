class TaskByIdModel {
  bool? isError;
  bool? isValidationFailed;
  String? errorCode;
  String? message;
  Data? data;

  TaskByIdModel(
      {this.isError,
        this.isValidationFailed,
        this.errorCode,
        this.message,
        this.data});

  TaskByIdModel.fromJson(Map<String, dynamic> json) {
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
  String? taskFormId;
  String? assignedBy;
  String? managerName;
  String? assignedTo;
  String? userName;
  String? totTaskStatusId;
  String? taskStatus;
  String? taskTitle;
  String? taskDescription;
  String? startDate;
  String? endDate;
  String? createdOn;
  String? modifiedOn;
  String? createdBy;
  String? modifiedBy;
  bool? isActive;
  bool? isDeleted;

  Data(
      {this.taskFormId,
        this.assignedBy,
        this.managerName,
        this.assignedTo,
        this.userName,
        this.totTaskStatusId,
        this.taskStatus,
        this.taskTitle,
        this.taskDescription,
        this.startDate,
        this.endDate,
        this.createdOn,
        this.modifiedOn,
        this.createdBy,
        this.modifiedBy,
        this.isActive,
        this.isDeleted});

  Data.fromJson(Map<String, dynamic> json) {
    taskFormId = json['taskFormId'];
    assignedBy = json['assignedBy'];
    managerName = json['managerName'];
    assignedTo = json['assignedTo'];
    userName = json['userName'];
    totTaskStatusId = json['totTaskStatusId'];
    taskStatus = json['taskStatus'];
    taskTitle = json['taskTitle'];
    taskDescription = json['taskDescription'];
    startDate = json['startDate'];
    endDate = json['endDate'];
    createdOn = json['createdOn'];
    modifiedOn = json['modifiedOn'];
    createdBy = json['createdBy'];
    modifiedBy = json['modifiedBy'];
    isActive = json['isActive'];
    isDeleted = json['isDeleted'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['taskFormId'] = this.taskFormId;
    data['assignedBy'] = this.assignedBy;
    data['managerName'] = this.managerName;
    data['assignedTo'] = this.assignedTo;
    data['userName'] = this.userName;
    data['totTaskStatusId'] = this.totTaskStatusId;
    data['taskStatus'] = this.taskStatus;
    data['taskTitle'] = this.taskTitle;
    data['taskDescription'] = this.taskDescription;
    data['startDate'] = this.startDate;
    data['endDate'] = this.endDate;
    data['createdOn'] = this.createdOn;
    data['modifiedOn'] = this.modifiedOn;
    data['createdBy'] = this.createdBy;
    data['modifiedBy'] = this.modifiedBy;
    data['isActive'] = this.isActive;
    data['isDeleted'] = this.isDeleted;
    return data;
  }
}
