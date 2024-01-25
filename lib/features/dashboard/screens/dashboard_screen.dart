import 'package:draggable_bottom_sheet/draggable_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:mapmyindia_gl/mapmyindia_gl.dart';
import 'package:ontrek/core/common_widgets/app_scaffold.dart';
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

  // Location location =  Location();

  List<IconData> iconData = [
    Icons.location_history_sharp,
    Icons.track_changes_outlined,
    Icons.task,
    Icons.person,
  ];
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
      // bottomSheet: DraggableScrollableSheet(
      //   shouldCloseOnMinExtent: true,
      //   snap: true,
      //   expand: false,
      //   initialChildSize: 0.4,
      //   maxChildSize: 0.9,
      //   minChildSize: 0.4,
      //   controller: draggableScrollableController,
      //   builder: (context, scrollController) {
      //     return SingleChildScrollView(
      //       controller: scrollController,
      //       child: Container(
      //         // height: double.infinity,
      //         width: double.infinity,
      //         decoration: WidgetUtils.commonBoxDecoration(
      //             color: AppConstant.whiteColor,
      //             borderRadius: WidgetUtils.borderRadiousonly(
      //                 topright: 30, topleft: 30)),
      //         child: Column(
      //           children: [
      //             WidgetUtils.commonTextWidget(
      //                 text: "text", textColor: Colors.red),
      //             WidgetUtils.commonTextWidget(
      //                 text: "text", textColor: Colors.red),
      //             WidgetUtils.commonTextWidget(
      //                 text: "text", textColor: Colors.red),
      //             WidgetUtils.commonTextWidget(
      //                 text: "text", textColor: Colors.red),
      //             WidgetUtils.commonTextWidget(
      //                 text: "text", textColor: Colors.red),
      //             WidgetUtils.commonTextWidget(
      //                 text: "text", textColor: Colors.red),
      //             WidgetUtils.commonTextWidget(
      //                 text: "text", textColor: Colors.red),
      //             WidgetUtils.commonTextWidget(
      //                 text: "text", textColor: Colors.red),
      //             WidgetUtils.commonTextWidget(
      //                 text: "text", textColor: Colors.red),
      //             WidgetUtils.commonTextWidget(
      //                 text: "text", textColor: Colors.red),
      //             WidgetUtils.commonTextWidget(
      //                 text: "text", textColor: Colors.red),
      //             WidgetUtils.commonTextWidget(
      //                 text: "text", textColor: Colors.red),
      //             WidgetUtils.commonTextWidget(
      //                 text: "text", textColor: Colors.red),
      //             WidgetUtils.commonTextWidget(
      //                 text: "text", textColor: Colors.red),
      //             WidgetUtils.commonTextWidget(
      //                 text: "text", textColor: Colors.red),
      //             WidgetUtils.commonTextWidget(
      //                 text: "text", textColor: Colors.red),
      //             WidgetUtils.commonTextWidget(
      //                 text: "text", textColor: Colors.red),
      //             WidgetUtils.commonTextWidget(
      //                 text: "text", textColor: Colors.red),
      //             WidgetUtils.commonTextWidget(
      //                 text: "text", textColor: Colors.red),
      //             WidgetUtils.commonTextWidget(
      //                 text: "text", textColor: Colors.red),
      //             WidgetUtils.commonTextWidget(
      //                 text: "text", textColor: Colors.red),
      //             WidgetUtils.commonTextWidget(
      //                 text: "text", textColor: Colors.red),
      //             WidgetUtils.commonTextWidget(
      //                 text: "text", textColor: Colors.red),
      //             WidgetUtils.commonTextWidget(
      //                 text: "text", textColor: Colors.red),
      //             WidgetUtils.commonTextWidget(
      //                 text: "text", textColor: Colors.red),
      //             WidgetUtils.commonTextWidget(
      //                 text: "text", textColor: Colors.red),
      //             WidgetUtils.commonTextWidget(
      //                 text: "text", textColor: Colors.red),
      //             WidgetUtils.commonTextWidget(
      //                 text: "text", textColor: Colors.red),
      //             WidgetUtils.commonTextWidget(
      //                 text: "text", textColor: Colors.red),
      //             WidgetUtils.commonTextWidget(
      //                 text: "text", textColor: Colors.red),
      //             WidgetUtils.commonTextWidget(
      //                 text: "text", textColor: Colors.red),
      //             WidgetUtils.commonTextWidget(
      //                 text: "text", textColor: Colors.red),
      //             WidgetUtils.commonTextWidget(
      //                 text: "text", textColor: Colors.red),
      //           ],
      //         ),
      //       ),
      //     );
      //   },
      // ),
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              bottom: MediaQuery.of(context).size.height *0.30,
              child: MapmyIndiaMap(
                  initialCameraPosition:
                      CameraPosition(target: LatLng(20.5937, 78.9629))),
            ),

            screens[_selectedIndex],
            // Positioned.fill(
            //   child: DraggableScrollableSheet(
            //     shouldCloseOnMinExtent: true,
            //     snap: true,
            //     expand: false,
            //     snapAnimationDuration: Duration(milliseconds: 300),
            //     initialChildSize: 0.4,
            //     maxChildSize: 0.9,
            //     minChildSize: 0.4,
            //     controller: draggableScrollableController,
            //     builder: (context, scrollController) {
            //       return SingleChildScrollView(
            //         controller: scrollController,
            //         child: Container(
            //
            //           // height: double.infinity,
            //           width: double.infinity,
            //           decoration: WidgetUtils.commonBoxDecoration(
            //
            //               color: AppConstant.whiteColor,
            //               borderRadius: WidgetUtils.borderRadiousonly(
            //                   topright: 30, topleft: 30)),
            //           child: Column(
            //             children: [
            //               WidgetUtils.commonTextWidget(
            //                   text: "text", textColor: Colors.red),
            //               WidgetUtils.commonTextWidget(
            //                   text: "text", textColor: Colors.red),
            //               WidgetUtils.commonTextWidget(
            //                   text: "text", textColor: Colors.red),
            //               WidgetUtils.commonTextWidget(
            //                   text: "text", textColor: Colors.red),
            //               WidgetUtils.commonTextWidget(
            //                   text: "text", textColor: Colors.red),
            //               WidgetUtils.commonTextWidget(
            //                   text: "text", textColor: Colors.red),
            //               WidgetUtils.commonTextWidget(
            //                   text: "text", textColor: Colors.red),
            //               WidgetUtils.commonTextWidget(
            //                   text: "text", textColor: Colors.red),
            //               WidgetUtils.commonTextWidget(
            //                   text: "text", textColor: Colors.red),
            //               WidgetUtils.commonTextWidget(
            //                   text: "text", textColor: Colors.red),
            //               WidgetUtils.commonTextWidget(
            //                   text: "text", textColor: Colors.red),
            //               WidgetUtils.commonTextWidget(
            //                   text: "text", textColor: Colors.red),
            //               WidgetUtils.commonTextWidget(
            //                   text: "text", textColor: Colors.red),
            //               WidgetUtils.commonTextWidget(
            //                   text: "text", textColor: Colors.red),
            //               WidgetUtils.commonTextWidget(
            //                   text: "text", textColor: Colors.red),
            //               WidgetUtils.commonTextWidget(
            //                   text: "text", textColor: Colors.red),
            //               WidgetUtils.commonTextWidget(
            //                   text: "text", textColor: Colors.red),
            //               WidgetUtils.commonTextWidget(
            //                   text: "text", textColor: Colors.red),
            //               WidgetUtils.commonTextWidget(
            //                   text: "text", textColor: Colors.red),
            //               WidgetUtils.commonTextWidget(
            //                   text: "text", textColor: Colors.red),
            //               WidgetUtils.commonTextWidget(
            //                   text: "text", textColor: Colors.red),
            //               WidgetUtils.commonTextWidget(
            //                   text: "text", textColor: Colors.red),
            //               WidgetUtils.commonTextWidget(
            //                   text: "text", textColor: Colors.red),
            //               WidgetUtils.commonTextWidget(
            //                   text: "text", textColor: Colors.red),
            //               WidgetUtils.commonTextWidget(
            //                   text: "text", textColor: Colors.red),
            //               WidgetUtils.commonTextWidget(
            //                   text: "text", textColor: Colors.red),
            //               WidgetUtils.commonTextWidget(
            //                   text: "text", textColor: Colors.red),
            //               WidgetUtils.commonTextWidget(
            //                   text: "text", textColor: Colors.red),
            //               WidgetUtils.commonTextWidget(
            //                   text: "text", textColor: Colors.red),
            //               WidgetUtils.commonTextWidget(
            //                   text: "text", textColor: Colors.red),
            //               WidgetUtils.commonTextWidget(
            //                   text: "text", textColor: Colors.red),
            //               WidgetUtils.commonTextWidget(
            //                   text: "text", textColor: Colors.red),
            //               WidgetUtils.commonTextWidget(
            //                   text: "text", textColor: Colors.red),
            //             ],
            //           ),
            //         ),
            //       );
            //     },
            //   ),
            // ),

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
