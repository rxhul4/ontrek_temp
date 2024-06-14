import 'package:app_settings/app_settings.dart';
import 'package:disable_battery_optimization/disable_battery_optimization.dart';
import 'package:flutter_jailbreak_detection/flutter_jailbreak_detection.dart';
import 'package:ontrek/core/utils/App_utils.dart';
import 'package:ontrek/main.dart';
import 'package:permission_handler/permission_handler.dart';

class UserPermission {
  Future<void> checkAndRequestPermissions() async {
    await checkPermissionOfLocation();
    await checkPermissionOfActivity();
    // await checkPermissionOfLocationAlways();
    await checkPermissionOfBatteryOptimization();
    // await isAllPermisionAreGranted();

    // await _checkDeveloperModeStatus();
  }

  Future<bool> isAllPermissionsGranted() async {
    // List of permissions to check
    List<Permission> permissions = [
      Permission.location,
      Permission.locationAlways,
      Permission.ignoreBatteryOptimizations,
      Permission.activityRecognition
    ];

    // Request and get the status of each permission
    Map<Permission, PermissionStatus> statuses = await permissions.request();

    // Check if all permissions are granted
    bool allGranted = statuses.values.every((status) => status == PermissionStatus.granted);

    return allGranted;
  }

  checkPermissionOfLocation() async {
    PermissionStatus locationStatus = await Permission.location.status;

    if (!locationStatus.isGranted) {
      PermissionStatus result = await Permission.location.request();

      if (result.isGranted) {
        print("Location permission granted.");
        await checkPermissionOfLocationAlways();
      } else if (result.isDenied) {
        await checkPermissionOfLocation();
        print("Location permission denied.");
      } else if (result.isPermanentlyDenied) {
        AppSettings.openAppSettings();
      }
    }
  }


  checkPermissionOfActivity() async {
    PermissionStatus locationStatus = await Permission.activityRecognition.status;

    if (!locationStatus.isGranted) {
      PermissionStatus result = await Permission.activityRecognition.request();

      if (result.isGranted) {
        print("Location permission granted.");
        await checkPermissionOfActivity();
      } else if (result.isDenied) {
        await checkPermissionOfActivity();
        print("Location permission denied.");
      } else if (result.isPermanentlyDenied) {
        AppSettings.openAppSettings();
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
        await checkPermissionOfLocationAlways();
        print("Location Always permission denied.");
      } else if (result.isPermanentlyDenied) {
        print("Location Always permission permanently denied. Please enable it from settings.");
        // AppSettings.openAppSettings();
        AppSettings.openAppSettings();

      }
    }
  }


  Future<void> checkPermissionOfBatteryOptimization() async {
    // Check if battery optimization is disabled
    bool? isBatteryOptimizationDisabled = await DisableBatteryOptimization.isBatteryOptimizationDisabled;

    // If battery optimization is enabled, request to ignore battery optimizations
    if (isBatteryOptimizationDisabled == false) {
      PermissionStatus status = await Permission.ignoreBatteryOptimizations.request();

      if (status.isGranted) {
        print("Battery optimization is ignored.");
      } else if (status.isDenied) {
        await checkPermissionOfBatteryOptimization();
        print("Battery optimization permission denied.");
      } else if (status.isPermanentlyDenied) {
        print("Battery optimization permission permanently denied. Please enable it from settings.");
        // You can navigate to the app settings to let the user manually enable the permission
        openAppSettings();
      }
    }
  }

  // Future<bool> _checkDeveloperModeStatus() async {
  //   bool isDeveloperModeActive = await FlutterJailbreakDetection.developerMode;
  //   if (isDeveloperModeActive) {
  //     // Handle the developer mode active status
  //   }
  // }
}
