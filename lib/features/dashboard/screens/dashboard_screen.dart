import 'dart:async';
import 'dart:typed_data';
import 'dart:ui';

import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:ontrek/core/utils/app_constant.dart';
import 'package:ontrek/core/utils/image_path.dart';
import 'package:ontrek/core/utils/App_utils.dart';
import 'package:ontrek/features/attendance/screen/attendance_screen.dart';
import 'package:ontrek/features/dashboard/provider/dashboard_provider.dart';
import 'package:ontrek/features/profile/screen/profile_screen.dart';
import 'package:ontrek/features/task_list/screen/task_list_screen.dart';
import 'package:ontrek/features/track_function/screen/track_screen.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

class DashBoard extends StatefulWidget {
  const DashBoard({super.key});

  @override
  State<DashBoard> createState() => DashBoardState();
}

class DashBoardState extends State<DashBoard> {



  List<String> iconString = [
    attendanceIconPath,
    trackingIconPath,
    taskIconPath,
    profileIconPath
  ];

  List<IconData> iconData = [
    Icons.location_history_sharp,
    Icons.track_changes_outlined,
    Icons.task,
    Icons.person,
  ];

  // Future<void> getCurrentLocation() async {
  //   print("innnnnnnnnnnnn");
  //   try {
  //     Position position = await Geolocator.getCurrentPosition(
  //       desiredAccuracy: LocationAccuracy.low,
  //     );
  //
  //     if (!mounted) {}
  //     setState(() {
  //       currentLocation = LatLng(position.latitude, position.longitude);
  //       print("${currentLocation}");
  //       if (currentLocation != null) {
  //         updateCameraPosition(currentLocation ?? LatLng(0, 0));
  //         addCurrentLocationMarker(currentLocation ?? LatLng(0, 0));
  //       }
  //     });
  //   } catch (e) {
  //     print("Error fetching location: $e");
  //   }
  // }

  // Future<void> getFetchedLocation(currentLocation,DashBoardProvider dashBoardProvider) async {
  //   try {
  //     if (currentLocation != null) {
  //       if (dashBoardProvider.googleMapController != null) {
  //         updateCameraPosition(currentLocation ?? LatLng(0, 0));
  //         addCurrentLocationMarker(currentLocation ?? LatLng(0, 0));
  //       }
  //     }
  //   } catch (e) {
  //     print("catach at getFecthedLocation${e}");
  //   }
  // }

  // Future updateCameraPosition(LatLng location) async {
  //   print("location-------${location}");
  //   final GoogleMapController controller = await googleMapController.future;
  //   controller.animateCamera(CameraUpdate.newCameraPosition(
  //     CameraPosition(
  //       target: location,
  //       zoom: 14,
  //     ),
  //   ));
  // }

  // void addCurrentLocationMarker(LatLng location) {
  //   markers.clear(); // Clear previous markers
  //   markers.add(
  //     Marker(
  //       markerId: MarkerId("currentLocation"),
  //       position: location,
  //       infoWindow: InfoWindow(title: "Current Location"),
  //     ),
  //   );
  // }

  List<String> lableString = [
    "Attendance",
    "Track",
    "Tasks",
    "Profile",
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      final dashBoardProvider = Provider.of<DashBoardProvider>(context,listen: false);
      dashBoardProvider.checkPermission();
    });

    // calculateSize();
  }


  // void calculateSize() =>
  //     WidgetsBinding.instance?.addPersistentFrameCallback((_) {
  //       _size = _key.currentContext?.size;
  //     });

  // Future checkPermission(DashBoardProvider dashBoardProvider) async {
  //   final status = await Permission.location.status;
  //   if (status.isDenied) {
  //     await Permission.location.request();
  //   } else if (status.isPermanentlyDenied) {
  //     AppSettings.openAppSettings(type: AppSettingsType.location);
  //   } else {
  //     await dashBoardProvider.getCurrentLocation();
  //   }
  // }



  @override
  Widget build(BuildContext context) {
    final dashBoardProvider = Provider.of<DashBoardProvider>(context);
    final height = MediaQuery.of(context).size.height;
    print("height====${height}");
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // Positioned.fill(
            //   // bottom: MediaQuery.of(context).size.height ,
            //   child: GoogleMap(
            //       zoomControlsEnabled: false,
            //       padding: AppUtils.edgeInsetsOnly(
            //           bottom: MediaQuery.of(context).size.height * 0.3),
            //       mapType: MapType.normal,
            //       onMapCreated: (controller) {
            //         dashBoardProvider.googleMapController.complete(controller);
            //       },
            //       markers: dashBoardProvider.markers,
            //       initialCameraPosition:
            //           CameraPosition(target: LatLng(0, 0), zoom: 14)),
            // ),
            [
              AttendanceScreen(onLocationFetch: (value) {
                if (!mounted) {}
                dashBoardProvider.getLocationFromSheet(position:  value);
                  // dashBoardProvider.currentLocation = LatLng(value.latitude, value.longitude);

                // dashBoardProvider.getFetchedLocation(dashBoardProvider.currentLocation);
              }),
              TrackScreen(),
              TaskListScreen(),
              ProfileScreen(),
            ][dashBoardProvider.selectedIndex],
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
          padding: EdgeInsets.only(left: 10, right: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: List.generate(iconData.length, (index) {
              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.vibrate();
                    // dashBoardProvider.getCurrentLocation();
                    if(!mounted){}
                    dashBoardProvider.selectIndex(index);
                    print("selected----${dashBoardProvider.selectedIndex}&& ${index}");
                  },
                  child: AnimatedContainer(
                  
                    // padding: AppUtils.edgeInsetsOnly(left: 15, right: 15),
                    duration: const Duration(milliseconds: 300),
                    alignment: Alignment.center,
                    height: 60,
                    // width: 100,
                    color: Colors.white,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          width:  22 ,
                          height:  22 ,
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

  final List<IconData> icons = const [
    Icons.message,
    Icons.call,
    Icons.mail,
    Icons.notifications,
    Icons.settings,
  ];
}
