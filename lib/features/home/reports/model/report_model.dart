class ReportsModel {
  bool? isError;
  bool? isValidationFailed;
  String? errorCode;
  String? message;
  ReportData? data;

  ReportsModel(
      {this.isError,
        this.isValidationFailed,
        this.errorCode,
        this.message,
        this.data});

  ReportsModel.fromJson(Map<String, dynamic> json) {
    isError = json['isError'];
    isValidationFailed = json['isValidationFailed'];
    errorCode = json['errorCode'];
    message = json['message'];
    data = json['data'] != null ? new ReportData.fromJson(json['data']) : null;
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

class ReportData {
  List<UserAttendenceReport>? userAttendenceReport;

  ReportData({this.userAttendenceReport});

  ReportData.fromJson(Map<String, dynamic> json) {
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
  double? sumTotalKm;
  double? sumProductiveKm;
  int? sumGpsOffMinutes;
  int? sumInternetOffMinutes;
  int? sumWaitingMinutes;
  int? sumProductiveHours;
  int? sumTotalHours;
  int? sumAppOffTime;
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
        this.sumProductiveHours,
        this.sumTotalHours,
        this.sumAppOffTime,
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
    sumProductiveHours = json['sumProductiveHours'];
    sumTotalHours = json['sumTotalHours'];
    sumAppOffTime = json['sumAppOffTime'];
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
    data['sumProductiveHours'] = this.sumProductiveHours;
    data['sumTotalHours'] = this.sumTotalHours;
    data['sumAppOffTime'] = this.sumAppOffTime;
    data['absentDays'] = this.absentDays;
    data['totalDays'] = this.totalDays;
    return data;
  }
}

class UserAttendenceDetail {
  String? userId;
  String? reportDate;
  int? appOffTime;
  double? totalKm;
  double? productiveKm;
  int? gpsOffMinutes;
  int? internetOffMinutes;
  int? waitingMinutes;
  int? productiveHours;
  int? totalHours;
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
    data['attendenceType'] = this.attendenceType;
    return data;
  }
}