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
import 'package:ontrek/features/leads/screen/lead_screen.dart';
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

GoogleMapController? googleMapController;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      dashBoardProvider = Provider.of<DashBoardProvider>(context,listen: false);
      dashBoardProvider.initialIndex();
      setState(() {});
      dashBoardProvider.checkPermission();
      dashBoardProvider.getCurrentLocation();
    });

  }



  @override
  Widget build(BuildContext context) {
    final dashBoardProvider = Provider.of<DashBoardProvider>(context);
    final height = MediaQuery.of(context).size.height;
    print("height====${height}");
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: GoogleMap(
                zoomControlsEnabled: false,
                padding: AppUtils.edgeInsetsOnly(
                    bottom: MediaQuery.of(context).size.height * 0.3),
                mapType: MapType.normal,
                onMapCreated: (GoogleMapController  controller) {
                  dashBoardProvider.googleMapController = controller;
                },
                markers: dashBoardProvider.markers,
                initialCameraPosition:
                    CameraPosition(target: LatLng(0, 0), zoom: 14)),
          ),
          [
            AttendanceScreen(onLocationFetch: (value) {
              if (!mounted) {}
              dashBoardProvider.getLocationFromSheet(position:  value);
            }),
            TrackScreen(),
            TaskListScreen(),
            LeadScreen(),
            ProfileScreen(),
          ][dashBoardProvider.selectedIndex],
        ],
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
            children: List.generate(
                lableString.length, (index) {
              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.vibrate();

                    if(!mounted){}
                    dashBoardProvider.selectIndex(index);
                    dashBoardProvider.getCurrentLocation();
                    print("selected----${dashBoardProvider.selectedIndex}&& $index");
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

}
