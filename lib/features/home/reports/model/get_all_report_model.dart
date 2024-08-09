class GetAllReportModel {
  bool? isError;
  bool? isValidationFailed;
  String? errorCode;
  String? message;
  Data? data;

  GetAllReportModel(
      {this.isError,
        this.isValidationFailed,
        this.errorCode,
        this.message,
        this.data});

  GetAllReportModel.fromJson(Map<String, dynamic> json) {
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
  List<UserAttendenceReport>? userAttendenceReport;

  Data({this.userAttendenceReport});

  Data.fromJson(Map<String, dynamic> json) {
    if (json['userAttendenceReport'] != null) {
      userAttendenceReport = <UserAttendenceReport>[];
      json['userAttendenceReport'].forEach((v) {
        userAttendenceReport!.add(new UserAttendenceReport.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.userAttendenceReport != null) {
      data['userAttendenceReport'] =
          this.userAttendenceReport!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class UserAttendenceReport {
  String? userId;
  String? userName;
  String? datePeriod;
  List<UserAttendenceDetail>? userAttendenceDetail;
  num? sumTotalKm;
  num? sumProductiveKm;
  int? sumGpsOffMinutes;
  int? sumInternetOffMinutes;
  int? sumWaitingMinutes;
  int? sumAppOffTime;
  int? sumTotalHours;
  int? sumProductiveHours;
  int? meetingCount;
  int? sumMeetingMinutes;
  int? sumTravellingMinutes;
  int? absentDays;
  int? totalDays;

  UserAttendenceReport(
      {this.userId,
        this.userName,
        this.datePeriod,
        this.userAttendenceDetail,
        this.sumTotalKm,
        this.sumProductiveKm,
        this.sumGpsOffMinutes,
        this.sumInternetOffMinutes,
        this.sumWaitingMinutes,
        this.sumAppOffTime,
        this.sumTotalHours,
        this.sumProductiveHours,
        this.meetingCount,
        this.sumMeetingMinutes,
        this.sumTravellingMinutes,
        this.absentDays,
        this.totalDays});

  UserAttendenceReport.fromJson(Map<String, dynamic> json) {
    userId = json['userId'];
    userName = json['userName'];
    datePeriod = json['datePeriod'];
    if (json['userAttendenceDetail'] != null) {
      userAttendenceDetail = <UserAttendenceDetail>[];
      json['userAttendenceDetail'].forEach((v) {
        userAttendenceDetail!.add(new UserAttendenceDetail.fromJson(v));
      });
    }
    sumTotalKm = json['sumTotalKm'];
    sumProductiveKm = json['sumProductiveKm'];
    sumGpsOffMinutes = json['sumGpsOffMinutes'];
    sumInternetOffMinutes = json['sumInternetOffMinutes'];
    sumWaitingMinutes = json['sumWaitingMinutes'];
    sumAppOffTime = json['sumAppOffTime'];
    sumTotalHours = json['sumTotalHours'];
    sumProductiveHours = json['sumProductiveHours'];
    meetingCount = json['meetingCount'];
    sumMeetingMinutes = json['sumMeetingMinutes'];
    sumTravellingMinutes = json['sumTravellingMinutes'];
    absentDays = json['absentDays'];
    totalDays = json['totalDays'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['userId'] = this.userId;
    data['userName'] = this.userName;
    data['datePeriod'] = this.datePeriod;
    if (this.userAttendenceDetail != null) {
      data['userAttendenceDetail'] =
          this.userAttendenceDetail!.map((v) => v.toJson()).toList();
    }
    data['sumTotalKm'] = this.sumTotalKm;
    data['sumProductiveKm'] = this.sumProductiveKm;
    data['sumGpsOffMinutes'] = this.sumGpsOffMinutes;
    data['sumInternetOffMinutes'] = this.sumInternetOffMinutes;
    data['sumWaitingMinutes'] = this.sumWaitingMinutes;
    data['sumAppOffTime'] = this.sumAppOffTime;
    data['sumTotalHours'] = this.sumTotalHours;
    data['sumProductiveHours'] = this.sumProductiveHours;
    data['meetingCount'] = this.meetingCount;
    data['sumMeetingMinutes'] = this.sumMeetingMinutes;
    data['sumTravellingMinutes'] = this.sumTravellingMinutes;
    data['absentDays'] = this.absentDays;
    data['totalDays'] = this.totalDays;
    return data;
  }
}

class UserAttendenceDetail {
  String? userId;
  String? reportDate;
  int? appOffTime;
  num? totalKm;
  num? productiveKm;
  int? gpsOffMinutes;
  int? internetOffMinutes;
  int? waitingMinutes;
  int? productiveHours;
  int? totalHours;
  int? meetingCount;
  int? meetingMinutes;
  int? travellingMinutes;
  String? attendenceType;

  UserAttendenceDetail(
      {this.userId,
        this.reportDate,
        this.appOffTime,
        this.totalKm,
        this.productiveKm,
        this.gpsOffMinutes,
        this.internetOffMinutes,
        this.waitingMinutes,
        this.productiveHours,
        this.totalHours,
        this.meetingCount,
        this.meetingMinutes,
        this.travellingMinutes,
        this.attendenceType});

  UserAttendenceDetail.fromJson(Map<String, dynamic> json) {
    userId = json['userId'];
    reportDate = json['reportDate'];
    appOffTime = json['appOffTime'];
    totalKm = json['totalKm'];
    productiveKm = json['productiveKm'];
    gpsOffMinutes = json['gpsOffMinutes'];
    internetOffMinutes = json['internetOffMinutes'];
    waitingMinutes = json['waitingMinutes'];
    productiveHours = json['productiveHours'];
    totalHours = json['totalHours'];
    meetingCount = json['meetingCount'];
    meetingMinutes = json['meetingMinutes'];
    travellingMinutes = json['travellingMinutes'];
    attendenceType = json['attendenceType'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['userId'] = this.userId;
    data['reportDate'] = this.reportDate;
    data['appOffTime'] = this.appOffTime;
    data['totalKm'] = this.totalKm;
    data['productiveKm'] = this.productiveKm;
    data['gpsOffMinutes'] = this.gpsOffMinutes;
    data['internetOffMinutes'] = this.internetOffMinutes;
    data['waitingMinutes'] = this.waitingMinutes;
    data['productiveHours'] = this.productiveHours;
    data['totalHours'] = this.totalHours;
    data['meetingCount'] = this.meetingCount;
    data['meetingMinutes'] = this.meetingMinutes;
    data['travellingMinutes'] = this.travellingMinutes;
    data['attendenceType'] = this.attendenceType;
    return data;
  }
}
