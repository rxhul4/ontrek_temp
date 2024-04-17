import 'package:ontrek/features/salesman_tracker/model/salesmen_tracking_detailes.dart';

class TimeLineLocalModel{
  String? eventName;
  String? eventStartDate;
  String? eventCode;
  String? eventActivityPlace;
  String? duration;
  num? kiloMeter;
  int? totalCheckIn;
  List<SessionEvents>? sessionEventName;
  List<List<LatlongArray>>? allSessionLatLong;

  TimeLineLocalModel({
    this.sessionEventName,
    this.eventName,
    this.eventStartDate,
    this.eventCode,
    this.eventActivityPlace,
    this.duration,
    this.kiloMeter,
    this.totalCheckIn,
    this.allSessionLatLong
  });
}
