import 'dart:io';
import 'package:permission_handler/permission_handler.dart';

class UserPermission {
  Future<void> checkAndRequestPermissions() async {
    await checkPermissionOfLocation();
    await checkPermissionOfActivity();
  }

  Future<bool> isAllPermissionsGranted() async {
    var locationStatus = await Permission.locationWhenInUse.status;
    var locationAlwaysStatus = await Permission.locationAlways.status;
    var activityStatus = Platform.isAndroid
        ? await Permission.activityRecognition.status
        : await Permission.sensors.status;

    return locationStatus.isGranted &&
        locationAlwaysStatus.isGranted &&
        activityStatus.isGranted;
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
    } else {
      await checkPermissionOfLocationAlways();
    }
  }

  Future<void> checkPermissionOfActivity() async {
    PermissionStatus activityStatus = Platform.isAndroid
        ? await Permission.activityRecognition.status
        : await Permission.sensors.status;

    if (!activityStatus.isGranted) {
      PermissionStatus result = Platform.isAndroid
          ? await Permission.activityRecognition.request()
          : await Permission.sensors.request();

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
