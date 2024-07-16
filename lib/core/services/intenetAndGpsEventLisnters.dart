import 'dart:async';
// import 'package:flutter_activity_recognition/flutter_activity_recognition.dart';
import 'package:geolocator/geolocator.dart' as geoLocater;

import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:permission_handler/permission_handler.dart' as permission;

class InternetAndGpsListener {


  StreamSubscription<InternetConnectionStatus>? _connectivitySubscription;
  StreamSubscription<geoLocater.ServiceStatus>? _locationServiceSubscription;
  // StreamSubscription<Activity>? _activityRecognizationSubscription;

  // StreamSubscription<Activity>? _activityStreamSubscription;

  final Function(bool isConnected) onInternetStatusChange;
  final Function(bool isConnected) onLocationServiceChange;
  // final Function(Activity  activity) onActivityChange;

  InternetAndGpsListener({
    required this.onInternetStatusChange,
    required this.onLocationServiceChange,
    // required this.onActivityChange,
  });


   startListening() async{
     // final activityRecognition = FlutterActivityRecognition.instance;

     // Listen for connectivity changes
      bool isInternetAvilable  = await InternetConnectionChecker().hasConnection;
      await onInternetStatusChange(isInternetAvilable);

    _connectivitySubscription = await InternetConnectionChecker().onStatusChange.listen((InternetConnectionStatus status) async{
      if(status == InternetConnectionStatus.connected){
        await onInternetStatusChange(true);
      }else{
        await onInternetStatusChange(false);
      }
    });

      // _activityStreamSubscription = activityRecognition.activityStream.listen(onActivityChange);


      // _activityRecognizationSubscription  = await activityRecognition.activityStream.listen((Activity activity)async{
      //   await onActivityChange(activity);
      // });

    try
    {
       bool isGpsAvailable = await geoLocater.Geolocator.isLocationServiceEnabled();
       await  onLocationServiceChange(isGpsAvailable);

      _locationServiceSubscription = await geoLocater.Geolocator.getServiceStatusStream().listen((geoLocater.ServiceStatus status)async  {
        if (status == geoLocater.ServiceStatus.enabled) {
         await  onLocationServiceChange(true);
        } else {
         await onLocationServiceChange(false);
        }
      });
    }catch(e)
    {
      print("Gps Status Error ${e}");
    }


    // Listen for position changes
     // Geolocator.requestPermission().then((permission) {
     //   if (permission == LocationPermission.always || permission == LocationPermission.whileInUse) {
     //     _positionSubscription = Geolocator.getPositionStream().listen((Position position) {
     //       onPositionChanged(position);
     //     });
     //   }
     // });

  }

  void stopListening() {
    _connectivitySubscription?.cancel();
    _locationServiceSubscription?.cancel();
    // _activityRecognizationSubscription?.cancel();
  }
}
