import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mapmyindia_gl/mapmyindia_gl.dart';
import 'package:ontrek/core/utils/app_constant.dart';
import 'package:ontrek/core/utils/widget_utils.dart';
import 'package:ontrek/features/dashboard/screens/attendance_screen.dart';
import 'package:ontrek/features/dashboard/screens/profile_screen.dart';
import 'package:ontrek/features/dashboard/screens/task_list_screen.dart';
import 'package:ontrek/features/dashboard/screens/track_screen.dart';

class DashBoard extends StatefulWidget {
  const DashBoard({super.key});

  @override
  State<DashBoard> createState() => DashBoardState();
}

class DashBoardState extends State<DashBoard> {
  late MapmyIndiaMapController mapController;
  LatLng? currentLocation;

  // Location location =  Location();

  List<IconData> iconData = [
    Icons.location_history_sharp,
    Icons.track_changes_outlined,
    Icons.task,
    Icons.person,
  ];

  Future getCurrentLocation({bool? endLoader}) async {
    Map<String, dynamic> returnData = {
      "locationFetchingSuccessful": false,
      "currentLocation": currentLocation
    };

    bool isLocationServiceAvailable =
        await WidgetUtils.checkLocationServiceAvailability();
    print("hhhhhh $isLocationServiceAvailable");
    if (isLocationServiceAvailable) {
      try {
        // isLoading.value = true;
        Position position = await Geolocator.getCurrentPosition(
          // forceAndroidLocationManager: true,
          desiredAccuracy: LocationAccuracy.medium,
          // timeLimit: Duration(seconds: 30)
        );
        print("hhhhhhhhh ${position}");
        currentLocation = LatLng(position.latitude, position.longitude);
        mapController.clearSymbols();
        mapController.animateCamera(CameraUpdate.newCameraPosition(
            CameraPosition(
                target: currentLocation ?? LatLng(0, 0),
                zoom: 14,
                tilt: 2,
                bearing: 2)));
        mapController.addSymbol(SymbolOptions(
          geometry: currentLocation,
        ));
        returnData["currentLocation"] = currentLocation;
        returnData["locationFetchingSuccessful"] = true;
      } catch (e) {
        returnData["currentLocation"] = currentLocation;
        returnData["locationFetchingSuccessful"] = false;
        print("in catch at get location lat long : ${e}");
      }
    } else {
      // WidgetUtils.showCustomDialog(
      //     ctx: context,
      //     dialogMessage: "Location is not enable. Please enable it and try again",
      //     showCustomWidget: true,
      //     positiveCustomText: "Open\nSettings",
      //     customWidgetOnPressed: () {
      //       openLocationSettings();
      //     },
      //     showDefaultBtn: false);
      returnData["currentLocation"] = currentLocation;
      returnData["locationFetchingSuccessful"] = false;
    }
    // isLoading.value = endLoader ?? false;
    return returnData;
  }

  List<String> lableString = [
    "Attandance",
    "Track",
    "Tasks",
    "Pofile",
  ];
  int _selectedIndex = 0;
  double bannerHeight = 300;
  List screens = [
    AttendanceScreen(),
    TrackScreen(),
    TaskListScreen(),
    ProfileScreen(),
  ];
  bool isBottomSheetVisible =
      true; // Set to true to make the bottom sheet always visible

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // modalBottomSheetShow(context);
    });
    MapmyIndiaAccountManager.setMapSDKKey(AppConstant.apiKeyofMap);
    MapmyIndiaAccountManager.setRestAPIKey(AppConstant.apiKeyofMap);
    MapmyIndiaAccountManager.setAtlasClientId(AppConstant.atlasClientId);
    MapmyIndiaAccountManager.setAtlasClientSecret(
        AppConstant.atlasClientSecretId);
  }

  // Future modalBottomSheetShow(BuildContext context) {
  //   return showModalBottomSheet(
  //     backgroundColor: Colors.transparent,
  //     context: context,
  //     builder: (context) => buildSheet(),
  //     isDismissible: false,
  //     elevation: 0,
  //   ).whenComplete(() => modalBottomSheetShow(context));
  // }
  // Widget buildSheet() {
  //   return DraggableScrollableSheet(
  //     initialChildSize: 0.6,
  //     maxChildSize: 0.9,
  //     minChildSize: 0.6,
  //     builder: (BuildContext context, ScrollController scrollController) {
  //       return Container(
  //         decoration: BoxDecoration(color: Colors.white, boxShadow: [
  //           BoxShadow(
  //             color: Color(0x6C000000),
  //             spreadRadius: 5,
  //             blurRadius: 20,
  //             offset: Offset(0, 0),
  //           )
  //         ]),
  //         padding: EdgeInsets.all(16),
  //       );
  //     },
  //   );
  // }
  DraggableScrollableController draggableScrollableController =
      DraggableScrollableController();
  double minHeight = 0.4;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              bottom: MediaQuery.of(context).size.height * 0.3,
              child: MapmyIndiaMap(
                  onMapCreated: (controller) {
                    mapController = controller;
                  },
                  onStyleLoadedCallback: () async {
                    getCurrentLocation();
                  },
                  initialCameraPosition:
                      CameraPosition(target: LatLng(20.5937, 78.9629))),
            ),

            // screens[_selectedIndex],
            Positioned.fill(
              child: DraggableScrollableSheet(
                shouldCloseOnMinExtent: true,
                snap: true,
                expand: false,
                snapAnimationDuration: Duration(milliseconds: 200),
                initialChildSize: 0.4,
                maxChildSize: 1,
                minChildSize: 0.4,
                controller: draggableScrollableController,
                builder: (context, scrollController) {
                  return [
                    AttendanceScreen(scrollController: scrollController),
                    TrackScreen(scrollController: scrollController),
                    TaskListScreen(scrollController: scrollController),
                    ProfileScreen(scrollController: scrollController),
                  ][_selectedIndex];
                },
              ),
            ),

            // WidgetUtils.commonAnimatedContainer(
            //   height: bannerHeight,
            //   duration: Duration(milliseconds: 50),
            //   child: Column(children: [
            //     GestureDetector(
            //         onVerticalDragUpdate: (DragUpdateDetails details) {
            //           setState(() {
            //             double positionY = details.globalPosition.dy;
            //             double maxHeight =
            //                 MediaQuery.of(context).size.height - 300;
            //             print("yo ${positionY}");
            //
            //             if (positionY < 200) bannerHeight = 300;
            //
            //             /// Limits at 200 height minimum
            //             if (positionY <= maxHeight)
            //               bannerHeight =
            //                   MediaQuery.of(context).size.height - positionY;
            //           });
            //         },
            //         child: WidgetUtils.commonAnimatedContainer(
            //             duration: Duration(milliseconds: 50),
            //             color: Colors.green,
            //             height: 45)),
            //     screens[_selectedIndex],
            //   ]),
            // ),
          ],
        ),
      ),
      bottomNavigationBar: WidgetUtils.commonContainer(
        height: 60,
        decoration: WidgetUtils.commonBoxDecoration(
          border: Border.all(
            color: AppConstant.greyColor,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: List.generate(iconData.length, (index) {
            return Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    // minHeight = 0.2;
                    if(index == 2){

                      draggableScrollableController.jumpTo(1);

                    }else{
                      draggableScrollableController.jumpTo(0.4);

                    }
                    _selectedIndex = index;
                    // Future.delayed(duration)
                  });
                },
                child: WidgetUtils.commonContainer(
                  alignment: Alignment.center,
                  height: 50,
                  width: 90,
                  color: AppConstant.whiteColor,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        iconData[index],
                        color: _selectedIndex == index
                            ? Colors.blueAccent
                            : AppConstant.greyColor,
                        size: _selectedIndex == index ? 22 : 20,
                      ),
                      WidgetUtils.commonTextWidget(
                        text: lableString[index],
                        textColor: _selectedIndex == index
                            ? Colors.blueAccent
                            : AppConstant.greyColor,
                        fontSize: 12,
                        fontWeight: _selectedIndex == index
                            ? FontWeight.w600
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
