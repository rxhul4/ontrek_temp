class CreateRouteHistoryModel {
  bool? isError;
  bool? isValidationFailed;
  String? errorCode;
  String? message;
  Data? data;

  CreateRouteHistoryModel(
      {this.isError,
        this.isValidationFailed,
        this.errorCode,
        this.message,
        this.data});

  CreateRouteHistoryModel.fromJson(Map<String, dynamic> json) {
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
  String? routeHistoryId;
  String? userId;
  String? sessionId;
  String? modifiedOn;
  List<LatLongArray>? latLongArray;

  Data(
      {this.routeHistoryId,
        this.userId,
        this.sessionId,
        this.modifiedOn,
        this.latLongArray});

  Data.fromJson(Map<String, dynamic> json) {
    routeHistoryId = json['routeHistoryId'];
    userId = json['userId'];
    sessionId = json['sessionId'];
    modifiedOn = json['modifiedOn'];
    if (json['latLongArray'] != null) {
      latLongArray = <LatLongArray>[];
      json['latLongArray'].forEach((v) {
        latLongArray!.add(new LatLongArray.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['routeHistoryId'] = this.routeHistoryId;
    data['userId'] = this.userId;
    data['sessionId'] = this.sessionId;
    data['modifiedOn'] = this.modifiedOn;
    if (this.latLongArray != null) {
      data['latLongArray'] = this.latLongArray!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class LatLongArray {
  double? x;
  double? y;

  LatLongArray({this.x, this.y});

  LatLongArray.fromJson(Map<String, dynamic> json) {
    x = json['x'];
    y = json['y'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['x'] = this.x;
    data['y'] = this.y;
    return data;
  }
}
