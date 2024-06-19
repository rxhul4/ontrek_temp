import 'dart:async';
import 'dart:ui';
import 'package:disable_battery_optimization/disable_battery_optimization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:ontrek/core/common_widgets/custom_upgrader_message.dart';
import 'package:ontrek/core/storage/preference_helper.dart';
import 'package:ontrek/core/utils/app_constant.dart';
import 'package:ontrek/core/utils/image_path.dart';
import 'package:ontrek/core/utils/App_utils.dart';
import 'package:ontrek/features/attendance/model/get_last_activity_model.dart';
import 'package:ontrek/features/attendance/provider/attendance_provider.dart';
import 'package:ontrek/features/attendance/screen/attendance_screen.dart';
import 'package:ontrek/features/attendance/screen/pending_dayend_screen.dart';
import 'package:ontrek/features/authentication/screens/login_with_phone_number.dart';
import 'package:ontrek/features/dashboard/provider/dashboard_provider.dart';
import 'package:ontrek/features/leads/screen/lead_screen.dart';
import 'package:ontrek/features/profile/screen/profile_screen.dart';
import 'package:ontrek/features/task_list/screen/task_list_screen.dart';
import 'package:ontrek/features/track_function/screen/track_screen.dart';
import 'package:ontrek/main.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:upgrader/upgrader.dart';

class DashBoard extends StatefulWidget {
  const DashBoard({super.key});

  @override
  State<DashBoard> createState() => DashBoardState();
}

class DashBoardState extends State<DashBoard> {
  List<Map<String, dynamic>> showUserInMap = [];
  bool? isMapLoaded = false;

  List<String> lableString = [
    "Attendance",
    "Track",
    "Tasks",
    "Leads",
    "More",
  ];
  List<String> iconString = [
    attendanceIconPath,
    trackingIconPath,
    taskIconPath,
    leadIconPath,
    profileIconPath,
  ];
  late DashBoardProvider dashBoardProvider;
  final GlobalKey globalKey = GlobalKey();

  GoogleMapController? googleMapController;

  @override
  void initState() {
    super.initState();


    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      final dashBoardProvider =
          Provider.of<DashBoardProvider>(context, listen: false);
      final attendanceProvider =
          Provider.of<AttendanceProvider>(context, listen: false);
      attendanceProvider.getAllConfiguration();
      bool isInternetAvailable = await AppUtils.checkInternetConnectivity();
      if (isInternetAvailable) {
        await attendanceProvider.callGetLastActivity();
      } else {
        AppUtils.showDialogBoxWithOneButton(
            titleText: "Internet Off Alert",
            text:
            "Internet is not available. Please Enable Mobile data or wifi.",
            context: context);
        var lastActivity = PreferenceHelper.getObject(PreferenceHelper.LastActivity);
        LastActivityData lastActivityData = LastActivityData.fromJson(lastActivity);
        attendanceProvider.EventUpdateProcess(lastActivityData);
      }
      if (!mounted) {}
      dashBoardProvider.initialIndex();
      dashBoardProvider.checkPermission(context);
      await checkPermissionOfBatteryOptimization();
      setState(() {});
    });
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

  void _onMapCreated(GoogleMapController controller) {
    setState(() {
      googleMapController = controller;
      isMapLoaded = true;
    });
    final dashBoardProvider =
        Provider.of<DashBoardProvider>(context, listen: false);
    dashBoardProvider.googleMapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    dashBoardProvider = Provider.of<DashBoardProvider>(context);
    return Scaffold(
      body: UpgradeAlert(
        showReleaseNotes: false,
        upgrader: Upgrader(messages: CustomUpgraderMessage()),
        child: Stack(
          children: [
            Positioned.fill(
              child: GoogleMap(
                  zoomControlsEnabled: false,
                  padding: AppUtils.edgeInsetsOnly(
                      bottom: MediaQuery.of(context).size.height * 0.3),
                  mapType: MapType.normal,
                  onMapCreated: _onMapCreated,
                  markers: dashBoardProvider.markers,
                  initialCameraPosition: CameraPosition(
                    target: LatLng(20.5937, 78.9629),
                    zoom: 0,
                  )),
            ),
            if (isMapLoaded == true)
              getScreenForIndex(dashBoardProvider.selectedIndex),
          ],
        ),
      ),
      bottomNavigationBar: AppUtils.commonContainer(
        height: 60,
        decoration: AppUtils.commonBoxDecoration(
          color: AppConstant.whiteColor,
          border: Border.all(
            color: AppConstant.greyColor.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: AppUtils.commonContainer(
          padding: EdgeInsets.only(left: 10, right: 10, bottom: 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: List.generate(lableString.length, (index) {
              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.vibrate();
                    if (!mounted) {}
                    dashBoardProvider.selectIndex(index);
                    if (dashBoardProvider.selectedIndex == 0) {
                      dashBoardProvider.getCurrentLocation();
                    }
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    alignment: Alignment.center,
                    height: 60,
                    color: Colors.white,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          width: 22,
                          height: 22,
                          iconString[index],
                          color: dashBoardProvider.selectedIndex == index
                              ? AppConstant.appPrimaryColor
                              : AppConstant.greyColor,
                        ),
                        AppUtils.commonTextWidget(
                          letterSpacing: 0,
                          text: lableString[index],
                          textColor: dashBoardProvider.selectedIndex == index
                              ? AppConstant.appPrimaryColor
                              : AppConstant.greyColor,
                          fontSize: 10,
                          fontWeight: dashBoardProvider.selectedIndex == index
                              ? FontWeight.w500
                              : FontWeight.w400,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  Widget getScreenForIndex(int index) {
    switch (index) {
      case 0:
        return AttendanceScreen(onLocationFetch: (value) {
          if (mounted) {
            dashBoardProvider.getLocationFromSheet(getCurrentLocation: value);
          }
        });
      case 1:
        return TrackScreen(onUserFetch: (value) async {
          if (value != null) {
            dashBoardProvider.showUserInMap = value;
            await dashBoardProvider.addUsersMarker();
            dashBoardProvider.markers.clear();
            await Future.delayed(const Duration(milliseconds: 100));
            await dashBoardProvider.addUsersMarker();
          }
        });
      case 2:
        return TaskListScreen();
      case 3:
        return LeadScreen();
      case 4:
        return ProfileScreen();
      default:
        return Container();
    }
  }
}
