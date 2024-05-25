class BulkActivityRequestModel {
  List<CreateActivityList>? createActivityList;

  BulkActivityRequestModel({this.createActivityList});

  BulkActivityRequestModel.fromJson(Map<String, dynamic> json) {
    if (json['createActivityList'] != null) {
      createActivityList = <CreateActivityList>[];
      json['createActivityList'].forEach((v) {
        createActivityList!.add(new CreateActivityList.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.createActivityList != null) {
      data['createActivityList'] =
          this.createActivityList!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class CreateActivityList {
  int? timeZoneDiff;
  String? loggedInUser;
  int? pkId;
  int? parentId;
  String? userId;
  double? longitude;
  double? lattitude;
  String? totTrackingEventId;
  String? activityDateTime;
  int? batteryLevel;
  String? sessionId;
  VisitNoteRequestForm? visitNoteRequestForm;
  List<OfflineMapData>? offlineMapData;

  CreateActivityList(
      {this.timeZoneDiff,
        this.loggedInUser,
        this.pkId,
        this.parentId,
        this.userId,
        this.longitude,
        this.lattitude,
        this.totTrackingEventId,
        this.activityDateTime,
        this.batteryLevel,
        this.sessionId,
        this.visitNoteRequestForm,
        this.offlineMapData});

  CreateActivityList.fromJson(Map<String, dynamic> json) {
    timeZoneDiff = json['timeZoneDiff'];
    loggedInUser = json['loggedInUser'];
    pkId = json['pkId'];
    parentId = json['parentId'];
    userId = json['userId'];
    longitude = json['longitude'];
    lattitude = json['lattitude'];
    totTrackingEventId = json['totTrackingEventId'];
    activityDateTime = json['activityDateTime'];
    batteryLevel = json['batteryLevel'];
    sessionId = json['sessionId'];
    visitNoteRequestForm = json['visitNoteRequestForm'] != null
        ? new VisitNoteRequestForm.fromJson(json['visitNoteRequestForm'])
        : null;
    if (json['offlineMapData'] != null) {
      offlineMapData = <OfflineMapData>[];
      json['offlineMapData'].forEach((v) {
        offlineMapData!.add(new OfflineMapData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['timeZoneDiff'] = this.timeZoneDiff;
    data['loggedInUser'] = this.loggedInUser;
    data['pkId'] = this.pkId;
    data['parentId'] = this.parentId;
    data['userId'] = this.userId;
    data['longitude'] = this.longitude;
    data['lattitude'] = this.lattitude;
    data['totTrackingEventId'] = this.totTrackingEventId;
    data['activityDateTime'] = this.activityDateTime;
    data['batteryLevel'] = this.batteryLevel;
    data['sessionId'] = this.sessionId;
    if (this.visitNoteRequestForm != null) {
      data['visitNoteRequestForm'] = this.visitNoteRequestForm!.toJson();
    }
    if (this.offlineMapData != null) {
      data['offlineMapData'] =
          this.offlineMapData!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class VisitNoteRequestForm {
  String? customerName;
  String? picturePath;
  String? visitDiscussion;
  String? companyName;
  String? customerPhoneNo;
  String? totVisitTypeId;

  VisitNoteRequestForm(
      {this.customerName,
        this.picturePath,
        this.visitDiscussion,
        this.companyName,
        this.customerPhoneNo,
        this.totVisitTypeId});

  VisitNoteRequestForm.fromJson(Map<String, dynamic> json) {
    customerName = json['customerName'];
    picturePath = json['picturePath'];
    visitDiscussion = json['visitDiscussion'];
    companyName = json['companyName'];
    customerPhoneNo = json['customerPhoneNo'];
    totVisitTypeId = json['totVisitTypeId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['customerName'] = this.customerName;
    data['picturePath'] = this.picturePath;
    data['visitDiscussion'] = this.visitDiscussion;
    data['companyName'] = this.companyName;
    data['customerPhoneNo'] = this.customerPhoneNo;
    data['totVisitTypeId'] = this.totVisitTypeId;
    return data;
  }
}

class OfflineMapData {
  double? longitude;
  double? lattitude;
  String? offlineTime;

  OfflineMapData({this.longitude, this.lattitude, this.offlineTime});

  OfflineMapData.fromJson(Map<String, dynamic> json) {
    longitude = json['longitude'];
    lattitude = json['lattitude'];
    offlineTime = json['offlineTime'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['longitude'] = this.longitude;
    data['lattitude'] = this.lattitude;
    data['offlineTime'] = this.offlineTime;
    return data;
  }
}
