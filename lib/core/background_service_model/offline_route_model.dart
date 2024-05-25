

class OfflineRouteModel {
  final double latitude;
  final double longitude;
  final String offlineTime;

  OfflineRouteModel({
    required this.latitude,
    required this.longitude,
    required this.offlineTime,
  });

  factory OfflineRouteModel.fromJson(Map<String, dynamic> json) {
    return OfflineRouteModel(
      latitude: json['latitude'],
      longitude: json['longitude'],
      offlineTime: json['offlineTime'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'offlineTime': offlineTime,
    };
  }


  @override
  String toString() {
    return 'LocationDataPoint(latitude: $latitude, longitude: $longitude, offlineTime: $offlineTime)';
  }
}