import 'package:permission_handler/permission_handler.dart';

class UserPermission {
  Future<void> checkAndRequestPermissions() async {
    await checkPermissionOfLocation();
    await checkPermissionOfActivity();
    await checkPermissionOfLocationAlways();
  }

  Future<bool> isAllPermissionsGranted() async {


    var locationStatus = Permission.locationWhenInUse.status;
    var locationAlways = Permission.locationAlways.status;
    var activityStatus = Permission.activityRecognition;

    if(locationStatus ==  PermissionStatus.granted && locationAlways == PermissionStatus.granted && activityStatus == PermissionStatus.granted){
      return true;
    }else{
      return false;
    }

  }

  Future<void> checkPermissionOfLocation() async {
    PermissionStatus locationStatus = await Permission.location.status;

    if (!locationStatus.isGranted) {
      PermissionStatus result = await Permission.location.request();

      if (result.isGranted) {
        print("Location permission granted.");
        await checkPermissionOfLocationAlways();
      } else if (result.isDenied) {
        print("Location permission denied.");
      } else if (result.isPermanentlyDenied) {
        openAppSettings(); // Open app settings for the user to enable permissions
      }
    }
  }

  Future<void> checkPermissionOfActivity() async {
    PermissionStatus activityStatus = await Permission.activityRecognition.status;

    if (!activityStatus.isGranted) {
      PermissionStatus result = await Permission.activityRecognition.request();

      if (result.isGranted) {
        print("Activity permission granted.");
      } else if (result.isDenied) {
        print("Activity permission denied.");
      } else if (result.isPermanentlyDenied) {
        openAppSettings(); // Open app settings for the user to enable permissions
      }
    }
  }

  Future<void> checkPermissionOfLocationAlways() async {
    PermissionStatus locationAlwaysStatus = await Permission.locationAlways.status;

    if (!locationAlwaysStatus.isGranted) {
      PermissionStatus result = await Permission.locationAlways.request();

      if (result.isGranted) {
        print("Location Always permission granted.");
      } else if (result.isDenied) {
        print("Location Always permission denied.");
      } else if (result.isPermanentlyDenied) {
        openAppSettings(); // Open app settings for the user to enable permissions
      }
    }
  }
}
