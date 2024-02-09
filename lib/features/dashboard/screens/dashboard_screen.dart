import 'dart:async';
import 'dart:typed_data';
import 'dart:ui';

import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

// import 'package:mapmyindia_gl/mapmyindia_gl.dart';
import 'package:ontrek/core/storage/preference_helper.dart';
import 'package:ontrek/core/utils/app_constant.dart';
import 'package:ontrek/core/utils/image_path.dart';
import 'package:ontrek/core/utils/App_utils.dart';
import 'package:ontrek/features/attendance/screen/attendance_screen.dart';
import 'package:ontrek/features/profile/screen/profile_screen.dart';
import 'package:ontrek/features/task_list/screen/task_list_screen.dart';
import 'package:ontrek/features/track_function/screen/track_screen.dart';
import 'package:permission_handler/permission_handler.dart';

class DashBoard extends StatefulWidget {
  const DashBoard({super.key});

  @override
  State<DashBoard> createState() => DashBoardState();
}

class DashBoardState extends State<DashBoard> {
  late final Completer<GoogleMapController> googleMapController = Completer();
  LatLng? currentLocation;
  late ValueNotifier<bool> isLoading;
  Set<Marker> markers = Set();
  int _selectedIndex = 0;

  ValueNotifier<bool> isDayStarted = ValueNotifier(false);
  ValueNotifier<bool> isCheckedIn = ValueNotifier(false);

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

  Future<void> getCurrentLocation() async {
    print("innnnnnnnnnnnn");
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low,
      );

      setState(() {
        currentLocation = LatLng(position.latitude, position.longitude);
        print("${currentLocation}");
        if (currentLocation != null) {
          updateCameraPosition(currentLocation ?? LatLng(0, 0));
          addCurrentLocationMarker(currentLocation ?? LatLng(0, 0));
        }
      });
    } catch (e) {
      print("Error fetching location: $e");
    }
  }

  Future<void> getFetchedLocation(currentLocation) async {
    try {
      if (currentLocation != null) {
        if (googleMapController != null) {
          updateCameraPosition(currentLocation ?? LatLng(0, 0));
          addCurrentLocationMarker(currentLocation ?? LatLng(0, 0));
        }
      }
    } catch (e) {
      print("catach at getFecthedLocation${e}");
    }
  }

  Future updateCameraPosition(LatLng location) async {
    print("location-------${location}");
    final GoogleMapController controller = await googleMapController.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(
        target: location,
        zoom: 14,
      ),
    ));
  }

  void addCurrentLocationMarker(LatLng location) {
    markers.clear(); // Clear previous markers
    markers.add(
      Marker(
        markerId: MarkerId("currentLocation"),
        position: location,
        infoWindow: InfoWindow(title: "Current Location"),
      ),
    );
  }

  List<String> lableString = [
    "Attandance",
    "Track",
    "Tasks",
    "Pofile",
  ];

  @override
  void initState() {
    super.initState();
    draggableScrollableController = DraggableScrollableController();
    // draggableScrollableController.addListener(() {
    //   if(_selectedIndex == 0){
    //     draggableScrollableController.isAttached
    //   }
    // });
    checkPermission();

  }

  Future checkPermission() async {
    final status = await Permission.location.status;
    if (status.isDenied) {
      await Permission.location.request();
    } else if (status.isPermanentlyDenied) {
      AppSettings.openAppSettings(type: AppSettingsType.location);
    } else {
      // Location permission is granted
      await getCurrentLocation();
    }
  }
  DraggableScrollableController draggableScrollableController =
  DraggableScrollableController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              // bottom: MediaQuery.of(context).size.height ,
              child: GoogleMap(
                  zoomControlsEnabled: false,
                  padding: AppUtils.edgeInsetsOnly(
                      bottom: MediaQuery.of(context).size.height * 0.3),
                  mapType: MapType.normal,
                  onMapCreated: (controller) {
                    googleMapController.complete(controller);
                  },
                  markers: markers,
                  initialCameraPosition:
                  CameraPosition(target: LatLng(0, 0), zoom: 14)),
            ),

            // screens[_selectedIndex],
            Positioned.fill(
              child: DraggableScrollableSheet(
                shouldCloseOnMinExtent: true,
                snap: true,
                expand: false,
                snapAnimationDuration: const Duration(milliseconds: 200),
                initialChildSize:  0.4,
                maxChildSize: 1,
                minChildSize: 0.09,
                controller: draggableScrollableController,
                snapSizes: [
                  0.4
                ] ,
                builder: (context, scrollController) {
                  return [
                    AttendanceScreen(
                        scrollController: scrollController,
                        onLocationFetch: (value) {
                          setState(() {
                            currentLocation = LatLng(value.latitude, value.longitude);
                          });
                          getFetchedLocation(currentLocation);
                        }),
                    TrackScreen(scrollController: scrollController,),
                    TaskListScreen(scrollController: scrollController),
                    ProfileScreen(scrollController: scrollController),
                  ][_selectedIndex];
                },
              ),
            ),
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
          padding: EdgeInsets.only(left: 10,right: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: List.generate(iconData.length, (index) {
              return GestureDetector(
                onTap: () {
                  HapticFeedback.vibrate();
                  getCurrentLocation();
                  setState(() {
                    if (index == 3) {
                      draggableScrollableController.jumpTo(1);
                    } else {
                      draggableScrollableController.jumpTo(0.4);
                    }
                    _selectedIndex = index;
                    print("selected----${_selectedIndex}&& ${index}");
                    print("size_of_sheet${draggableScrollableController.size}&& ${index}");

                    // Future.delayed(duration)
                  });
                },
                child: AnimatedContainer(

                  padding:  index == 0 ? AppUtils.edgeInsetsOnly(left: 0,right: 0) : AppUtils.edgeInsetsOnly(left: 15,right: 15),
                  duration: const Duration(milliseconds: 300),
                  alignment: Alignment.center,
                  height: 60,
                  // width: 100,
                  color: Colors.white,
                  child:  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        width: index == 0 || index == 1 ? 25 : 20,
                        height: index == 0 || index == 1 ? 25 : 20,
                        iconString[index],
                        color: _selectedIndex == index
                            ? AppConstant.appPrimaryColor
                            : AppConstant.greyColor,
                      ),
                      AppUtils.commonTextWidget(
                        text: lableString[index],
                        textColor: _selectedIndex == index
                            ? AppConstant.appPrimaryColor
                            : AppConstant.greyColor,
                        fontSize: 12,
                        fontWeight: _selectedIndex == index
                            ? FontWeight.w600
                            : FontWeight.w400,
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  // Widget _backgroundWidget() {
  //   return Scaffold(
  //     backgroundColor: Colors.white,
  //     body: MapmyIndiaMap(
  //         initialCameraPosition:
  //         CameraPosition(target: LatLng(20.5937, 78.9629))),
  //   );
  // }

  // Widget _previewWidget() {
  //   return Container(
  //     padding: const EdgeInsets.all(16),
  //     decoration:  BoxDecoration(
  //       color: AppConstant.whiteColor,
  //       borderRadius: BorderRadius.only(
  //         topLeft: Radius.circular(20),
  //         topRight: Radius.circular(20),
  //       ),
  //     ),
  //     child: Column(
  //       children: <Widget>[
  //         Container(
  //           width: 40,
  //           height: 6,
  //           decoration: BoxDecoration(
  //             color: AppConstant.whiteColor,
  //             borderRadius: BorderRadius.circular(10),
  //           ),
  //         ),
  //         const SizedBox(height: 8),
  //          Text(
  //           'Drag Me',
  //           style: TextStyle(
  //             color: AppConstant.whiteColor,
  //             fontSize: 16,
  //             fontWeight: FontWeight.bold,
  //           ),
  //         ),
  //         const SizedBox(height: 16),
  //         Row(
  //             mainAxisAlignment: MainAxisAlignment.center,
  //             children: icons.map((icon) {
  //               return Container(
  //                 width: 50,
  //                 height: 50,
  //                 margin: const EdgeInsets.only(right: 16),
  //                 decoration: BoxDecoration(
  //                   color: Colors.white,
  //                   borderRadius: BorderRadius.circular(10),
  //                 ),
  //                 child: Icon(icon, color: Colors.pink, size: 40),
  //               );
  //             }).toList())
  //       ],
  //     ),
  //   );
  // }

  // Widget _expandedWidget() {
  //   return Container(
  //     padding: const EdgeInsets.all(16),
  //     decoration:  BoxDecoration(
  //       color: AppConstant.whiteColor,
  //       borderRadius: BorderRadius.only(
  //         topLeft: Radius.circular(20),
  //         topRight: Radius.circular(20),
  //       ),
  //     ),
  //     child: Column(
  //       children: <Widget>[
  //         const Icon(Icons.keyboard_arrow_down, size: 30, color: Colors.white),
  //         const SizedBox(height: 8),
  //         Text(
  //           'Hey...I\'m expanding!!!',
  //           style: TextStyle(
  //             color: Colors.white,
  //             fontSize: 16,
  //             fontWeight: FontWeight.bold,
  //           ),
  //         ),
  //         const SizedBox(height: 16),
  //         Expanded(
  //           child: GridView.builder(
  //             itemCount: icons.length,
  //             gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
  //               crossAxisCount: 2,
  //               crossAxisSpacing: 10,
  //               mainAxisSpacing: 10,
  //             ),
  //             itemBuilder: (context, index) => Container(
  //               decoration: BoxDecoration(
  //                 color: Colors.white,
  //                 borderRadius: BorderRadius.circular(10),
  //               ),
  //               child: Icon(icons[index], color: Colors.pink, size: 40),
  //             ),
  //           ),
  //         )
  //       ],
  //     ),
  //   );
  // }
  final List<IconData> icons = const [
    Icons.message,
    Icons.call,
    Icons.mail,
    Icons.notifications,
    Icons.settings,
  ];
}