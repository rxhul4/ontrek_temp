class Activity {
  int pkId;
  String sessionId;
  String eventCode;
  double latitude;
  double longitude;
  String activityDate;
  int? parentId;
  bool isSync;
  bool isEventCompleted;
  bool? waitingStart;

  Activity({
    required this.pkId,
    required this.sessionId,
    required this.eventCode,
    required this.latitude,
    required this.longitude,
    required this.activityDate,
    this.parentId,
    this.waitingStart,
    required this.isSync,
    required this.isEventCompleted,
  });

  // Factory constructor to create an Activity object from a JSON map
  factory Activity.fromJson(Map<String, dynamic> json) {
    return Activity(
      pkId: json['PkId'],
      sessionId: json['SessionId'],
      eventCode: json['EventCode'],
      latitude: json['Latitude'],
      longitude: json['Longitude'],
      activityDate: json["ActivityDate"],
      parentId: json['ParentId'],
      isSync: json['IsSync'],
      isEventCompleted: json['isEventCompleted'],
      waitingStart: json['waitingStart'],
    );
  }

  // Method to convert an Activity object to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'PkId': pkId,
      'SessionId': sessionId,
      'EventCode': eventCode,
      'Latitude': latitude,
      'Longitude': longitude,
      'ActivityDate': activityDate,
      'ParentId': parentId,
      'IsSync': isSync,
      'isEventCompleted': isEventCompleted,
      'waitingStart': waitingStart,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Activity && other.pkId == pkId;
  }

  @override
  int get hashCode => pkId.hashCode;

}