

class AppOffTime {
  String? pkId;
  String startTime;
  String stopTime;


  AppOffTime({
     this.pkId,
    required this.startTime,
    required this.stopTime,

  });

  // Convert a AppOffTime object into a Map object
  Map<String, dynamic> toMap() {
    return {
      'pkId': pkId,
      'startTime': startTime,
      'stopTime': stopTime,
    };
  }

  // Extract a AppOffTime object from a Map object
  factory AppOffTime.fromMap(Map<String, dynamic> map) {
    return AppOffTime(
      pkId: map['pkId'],
      startTime: map['startTime'],
      stopTime: map['stopTime'],
    );
  }
}
