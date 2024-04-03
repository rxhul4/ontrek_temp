import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ontrek/core/utils/App_utils.dart';
import 'package:ontrek/core/utils/app_constant.dart';
import 'package:ontrek/core/utils/image_path.dart';
import 'package:ontrek/features/salesman_tracker/local_model.dart';
import 'package:ontrek/features/salesman_tracker/model/salesmen_tracking_detailes.dart';
import 'package:ontrek/features/salesman_tracker/provider/salesmen_tracking_timeline_provider.dart';
import 'package:provider/provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:timeline_tile/timeline_tile.dart';

class TimeLineScreen extends StatefulWidget {
  int? index;
  String? userId;
  String? name;

  TimeLineScreen({super.key, this.userId, this.name, this.index});

  @override
  State<TimeLineScreen> createState() => _TimeLineScreenState();
}

class _TimeLineScreenState extends State<TimeLineScreen> {
  DateTime? selectedDate;
  LatLng currentLocation = LatLng(20.5937, 78.9629);
  PanelController panelController = PanelController();
  Set<Marker> markers = Set();
  List<List<SessionEvents>?>? sessionEvent = [];
  late SalemenTimeLineProvider saleMenTimeLineProvider;
  final Completer<GoogleMapController> googleMapController =
      Completer<GoogleMapController>();
  Set<Polyline> polylines = {};
  int selectedIndex = -1;
  List<LatLng> polylineCoordinates = [];
  PolylinePoints polylinePoints = PolylinePoints();

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
          updateCameraPosition(currentLocation);
          addCurrentLocationMarker(currentLocation);
        }
      });
    } catch (e) {
      print("Error fetching location: $e");
    }
  }

  Future updateCameraPosition(LatLng location) async {
    print("location-------${location}");
    final GoogleMapController controller = await googleMapController.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(
        target: location,
        zoom: 16,
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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    selectedDate = DateTime.now();
    getCurrentLocation();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      panelController.animatePanelToSnapPoint();
      final saleMenTimeLineProvider = Provider.of<SalemenTimeLineProvider>(context, listen: false);
      if (!mounted) {}
      saleMenTimeLineProvider.allSession?.clear();
      saleMenTimeLineProvider.coordinates.clear();
      saleMenTimeLineProvider.apiCallGetTimeLine(
          userid: widget.userId, date: selectedDate.toString());
      drawPolyline();
    });
  }

  void drawPolyline() {
    polylines.add(Polyline(
      polylineId: PolylineId('poly'),
      color: Colors.blue,
      points: saleMenTimeLineProvider.coordinates,
      width: 5,
    ));
  }

  @override
  Widget build(BuildContext context) {
    saleMenTimeLineProvider = Provider.of<SalemenTimeLineProvider>(context);
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      body: SafeArea(
        child: AppUtils.commonSlidePanel(
          body: Stack(
            children: [
              Positioned.fill(
                // bottom: MediaQuery.of(context).size.height ,
                child: GoogleMap(
                  zoomControlsEnabled: false,
                  padding: AppUtils.edgeInsetsOnly(
                    bottom: MediaQuery.of(context).size.height * 0.25,
                  ),
                  mapType: MapType.normal,
                  onMapCreated: (controller) {
                    googleMapController.complete(controller);
                  },
                  markers: markers,
                  polylines: polylines,
                  initialCameraPosition: CameraPosition(
                    target: (saleMenTimeLineProvider.coordinates != null && saleMenTimeLineProvider.coordinates.length > 0) ? saleMenTimeLineProvider.coordinates[0] : currentLocation,
                    zoom: 14,
                  ),
                ),

              ),
              trackAppBarWidget(
                onTapGetCurrentPosition: getCurrentLocation,
                // getMdl: getMdl,
                onTapBackButton: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
          maxHeight: height,
          minHeight: height * 0.21,
          controller: panelController,
          isDraggable: true,
          snapPoint: 0.0001,
          panelBuilder: (p0) {
            return Stack(
              children: [
                Column(
                  children: [
                    AppUtils.buildHeader(
                      width: width,
                      height: height,
                      title: widget.name,
                      subTitle: "Dwarkesh Business Hub Visat...",
                    ),
                    informationBar(
                      totalCheckIn: selectedIndex == -1
                          ? saleMenTimeLineProvider
                              .getTimeLineModel?.data?.totalCheckIn
                          : saleMenTimeLineProvider.getTimeLineModel?.data
                              ?.sessionTimeLine?[selectedIndex].totalCheckIn,
                      totalDuration: selectedIndex == -1
                          ? saleMenTimeLineProvider
                              .getTimeLineModel?.data?.totalDuration
                          : saleMenTimeLineProvider.getTimeLineModel?.data
                              ?.sessionTimeLine?[selectedIndex].totalDuration,
                      totalKMTravel: selectedIndex == -1
                          ? saleMenTimeLineProvider
                              .getTimeLineModel?.data?.totalKmTravel
                          : saleMenTimeLineProvider.getTimeLineModel?.data
                              ?.sessionTimeLine?[selectedIndex].totalKmTravel,
                    ),
                    datePickerWidget(true),
                    AppUtils.commonContainer(
                      height: 50,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            // "All Sessions" item
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedIndex = -1; // Set selectedIndex to -1 for "All Sessions"
                                });
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                padding:
                                    const EdgeInsets.only(left: 15, right: 15),
                                margin: const EdgeInsets.only(
                                    left: 10, right: 10, bottom: 5),
                                decoration: AppUtils.commonBoxDecoration(
                                  border: Border.all(
                                      color: AppConstant.appPrimaryColor),
                                  color: selectedIndex == -1 // Check if selectedIndex is -1
                                      ? AppConstant.appPrimaryColor
                                      : AppConstant.transparentColor,
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(6)),
                                ),
                                child: Center(
                                  child: AppUtils.commonTextWidget(
                                    text: "All Sessions",
                                    textColor: selectedIndex == -1
                                        ? AppConstant.whiteColor
                                        : AppConstant.appPrimaryColor,
                                  ),
                                ),
                              ),
                            ),
                            // List of sessions
                            Row(
                              children: [
                                ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: saleMenTimeLineProvider
                                          .getTimeLineModel
                                          ?.data
                                          ?.sessionTimeLine
                                          ?.length ??
                                      0,
                                  scrollDirection: Axis.horizontal,
                                  itemBuilder: (context, index) {
                                    final sessionIndex = index;
                                    return GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          selectedIndex = sessionIndex;
                                        });
                                      },
                                      child: AnimatedContainer(
                                        duration:
                                            const Duration(milliseconds: 300),
                                        padding: const EdgeInsets.only(
                                            left: 15, right: 15),
                                        margin: const EdgeInsets.only(
                                            left: 10, right: 10, bottom: 5),
                                        decoration:
                                            AppUtils.commonBoxDecoration(
                                          border: Border.all(
                                              color:
                                                  AppConstant.appPrimaryColor),
                                          color: sessionIndex == selectedIndex
                                              ? AppConstant.appPrimaryColor
                                              : AppConstant.transparentColor,
                                          borderRadius: const BorderRadius.all(
                                              Radius.circular(6)),
                                        ),
                                        child: Center(
                                          child: AppUtils.commonTextWidget(
                                            text: "Session ${sessionIndex + 1}",
                                            textColor: sessionIndex ==
                                                    selectedIndex
                                                ? AppConstant.whiteColor
                                                : AppConstant.appPrimaryColor,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    selectedIndex == -1
                        ? allSessionTimeLineWidget(
                            sessionList: saleMenTimeLineProvider.allSession,
                            scrollController: p0)
                        : sessionTimeLineWidget(
                            scrollController: p0,
                            sessionList: saleMenTimeLineProvider
                                .getTimeLineModel
                                ?.data
                                ?.sessionTimeLine?[selectedIndex]
                                .sessionEvents),
                  ],
                ),
              ],
            );
          },
          // snapPoint: 0.01,
        ),
      ),
    );
  }

  Widget datePickerWidget(bool? isFromSheet) {
    return Align(
      alignment: Alignment.topCenter,
      child: dateSelectionWidget(
        isFromSheet: isFromSheet, /*getMdl: getMdl*/
      ),
    );
  }

  Widget allSessionTimeLineWidget({
    ScrollController? scrollController,
    List<TimeLineLocalModel>? sessionList,
  }) {
    return Expanded(
      child: saleMenTimeLineProvider.isFetching
          ? AppUtils.loaderWidget()
          : sessionList == null || (sessionList.length ?? 0) < 0
              ? AppUtils.commonNoDataFound(
                  text: saleMenTimeLineProvider.getTimeLineModel?.message,
                  onPressed: () {
                    saleMenTimeLineProvider.apiCallGetTimeLine(
                        date: selectedDate.toString(), userid: widget.userId);
                  },
                )
              : ListView.builder(
                  itemCount: sessionList.length,
                  physics: const BouncingScrollPhysics(),
                  controller: scrollController,
                  shrinkWrap: true,
                  padding: EdgeInsets.only(bottom: 30),
                  itemBuilder: (context, index) {
                    return TimelineTile(
                      hasIndicator: true,
                      axis: TimelineAxis.vertical,
                      lineXY: 0.5,
                      isLast: index == (sessionList.length) - 1,
                      isFirst: index == sessionList.length,
                      indicatorStyle: IndicatorStyle(
                        indicatorXY: 0,
                        drawGap: true,
                        height: 40,
                        width: 40,
                        indicator: AppUtils.commonContainer(
                          decoration: AppUtils.commonBoxDecoration(
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                              child: Image.asset(
                                height: 30,
                            width: 30,
                            AppUtils.getImagePathFromApi(
                                sessionList[index].eventCode),
                          )),
                        ),
                      ),
                      beforeLineStyle: LineStyle(
                        color: AppConstant.primaryColor,
                        thickness: 1,
                      ),
                      afterLineStyle: LineStyle(
                        color: AppConstant.primaryColor,
                        thickness: 1,
                      ),
                      startChild: AppUtils.commonContainer(
                        padding: AppUtils.edgeInsetsOnly(top: 10),
                        margin: AppUtils.edgeInsetsOnly(left: 30),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppUtils.commonTextWidget(
                                // text: "12 jan 2024",
                                text: AppUtils.getDate(
                                    date:
                                        sessionList[index].eventStartDate ?? "",
                                    format: "d MMM y"),
                                textColor: AppConstant.greyColor,
                                fontWeight: FontWeight.w400,
                                fontSize: 14),
                            AppUtils.commonTextWidget(
                                text: AppUtils.getDate(
                                    date:
                                        sessionList[index].eventStartDate ?? "",
                                    format: "HH:mm"),
                                textColor: AppConstant.blackColor,
                                fontWeight: FontWeight.w400,
                                fontSize: 12),
                          ],
                        ),
                      ),
                      endChild: AppUtils.commonInkWell(
                        onTap: () {
                          // draggableScrollableController
                          //     .animateTo(0.23,
                          //         duration: Duration(
                          //             milliseconds: 1000),
                          //         curve: Curves.decelerate);
                          // onClickLocateOnMap(LatLng(
                          //         getTimeLineModel
                          //                 ?.data?[index]
                          //                 .lattitude ??
                          //             0,
                          //         getTimeLineModel
                          //                 ?.data?[index]
                          //                 .longitude ??
                          //             0))
                          //     .then((value) {
                          //   draggableScrollableController
                          //       .reset();
                          // });
                        },
                        child: AppUtils.commonContainer(
                          padding: AppUtils.edgeInsetsOnly(top: 5),
                          margin: AppUtils.edgeInsetsOnly(
                              right: 10, bottom: 20, left: 30),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AppUtils.commonTextWidget(
                                  text: sessionList[index].eventName ?? "",
                                  textColor: AppUtils.getStatusColor(
                                      sessionList[index].eventCode),
                                  fontWeight: FontWeight.w400,
                                  fontSize: 14),
                              AppUtils.commonTextWidget(
                                  text: sessionList[index].eventActivityPlace ??
                                      "",
                                  textColor: AppConstant.blackColor,
                                  fontWeight: FontWeight.w400,
                                  fontSize: 10),
                            ],
                          ),
                        ),
                      ),
                      alignment: TimelineAlign.manual,
                    );
                  },
                ),
    );
  }

  Widget sessionTimeLineWidget({
    ScrollController? scrollController,
    List<SessionEvents>? sessionList,
  }) {
    return Expanded(
      child: saleMenTimeLineProvider.isFetching
          ? AppUtils.loaderWidget()
          : sessionList == null || sessionList.isEmpty
              ? AppUtils.commonNoDataFound(
                  text: saleMenTimeLineProvider.getTimeLineModel?.message,
                  onPressed: () {
                    saleMenTimeLineProvider.apiCallGetTimeLine(
                        date: selectedDate.toString(), userid: widget.userId);
                  },
                )
              : ListView.builder(
                  itemCount: sessionList.length,
                  physics: const BouncingScrollPhysics(),
                  controller: scrollController,
                  shrinkWrap: true,
                  padding: const EdgeInsets.only(bottom: 30),
                  itemBuilder: (context, index) {
                    return TimelineTile(
                      hasIndicator: true,
                      axis: TimelineAxis.vertical,
                      lineXY: 0.5,
                      isLast: index == (sessionList.length) - 1,
                      isFirst: index == sessionList.length,
                      indicatorStyle: IndicatorStyle(
                        indicatorXY: 0,
                        drawGap: true,
                        height: 40,
                        width: 40,
                        indicator: AppUtils.commonContainer(
                          decoration: AppUtils.commonBoxDecoration(
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                              child: Image.asset(
                            AppUtils.getImagePathFromApi(
                                sessionList[index].eventCode),
                          )),
                        ),
                      ),
                      beforeLineStyle: LineStyle(
                        color: AppConstant.primaryColor,
                        thickness: 1,
                      ),
                      afterLineStyle: LineStyle(
                        color: AppConstant.primaryColor,
                        thickness: 1,
                      ),
                      startChild: AppUtils.commonContainer(
                        padding: AppUtils.edgeInsetsOnly(top: 10),
                        margin: AppUtils.edgeInsetsOnly(left: 30),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppUtils.commonTextWidget(
                                // text: "12 jan 2024",
                                text: AppUtils.getDate(
                                    date:
                                        sessionList[index].eventStartDate ?? "",
                                    format: "d MMM y"),
                                textColor: AppConstant.greyColor,
                                fontWeight: FontWeight.w400,
                                fontSize: 12),
                            AppUtils.commonTextWidget(
                                text: AppUtils.getDate(
                                    date:
                                        sessionList[index].eventStartDate ?? "",
                                    format: "HH:mm"),
                                textColor: AppConstant.blackColor,
                                fontWeight: FontWeight.w400,
                                fontSize: 10),
                          ],
                        ),
                      ),
                      endChild: AppUtils.commonInkWell(
                        onTap: () {
                          // draggableScrollableController
                          //     .animateTo(0.23,
                          //         duration: Duration(
                          //             milliseconds: 1000),
                          //         curve: Curves.decelerate);
                          // onClickLocateOnMap(LatLng(
                          //         getTimeLineModel
                          //                 ?.data?[index]
                          //                 .lattitude ??
                          //             0,
                          //         getTimeLineModel
                          //                 ?.data?[index]
                          //                 .longitude ??
                          //             0))
                          //     .then((value) {
                          //   draggableScrollableController
                          //       .reset();
                          // });
                        },
                        child: AppUtils.commonContainer(
                          padding: AppUtils.edgeInsetsOnly(top: 5),
                          margin: AppUtils.edgeInsetsOnly(
                              right: 10, bottom: 20, left: 30),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AppUtils.commonTextWidget(
                                  text: sessionList[index].eventName ?? "",
                                  textColor: AppUtils.getStatusColor(
                                    sessionList[index].eventCode ?? "",
                                  ),
                                  fontWeight: FontWeight.w400,
                                  fontSize: 12),
                              AppUtils.commonTextWidget(
                                  text: sessionList[index].eventActivityPlace ??
                                      "",
                                  textColor: AppConstant.blackColor,
                                  fontWeight: FontWeight.w400,
                                  fontSize: 10),
                            ],
                          ),
                        ),
                      ),
                      alignment: TimelineAlign.manual,
                    );
                  },
                ),
    );
  }

  Widget informationBar(
      {String? totalDuration, num? totalKMTravel, int? totalCheckIn}) {
    return AppUtils.commonContainer(
      padding: AppUtils.edgeInsetsOnly(top: 10, bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: AppConstant.greyColor.withOpacity(0.2),
            offset: Offset(0, 2),
            blurRadius: 4,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          travelInfoRowWidget(
              iconData: Icons.timelapse,
              textData: totalDuration,
              typeOfText: "DURATION",
              iconColor: Colors.red),
          travelInfoRowWidget(
              iconData: Icons.speed_sharp,
              textData: totalKMTravel.toString(),
              typeOfText: "DISTANCE",
              iconColor: Colors.green),
          travelInfoRowWidget(
              iconData: Icons.location_on_outlined,
              textData: totalCheckIn.toString(),
              typeOfText: "CHECKINS",
              iconColor: AppConstant.appPrimaryColor),
        ],
      ),
    );
  }

  Widget travelInfoRowWidget(
      {IconData? iconData,
      String? textData,
      String? typeOfText,
      Color? iconColor}) {
    return Column(
      children: [
        Icon(
          iconData,
          color: iconColor,
          size: 36,
        ),
        AppUtils.commonSizedBox(height: 5),
        AppUtils.commonTextWidget(
            fontWeight: FontWeight.w500,
            text: textData ?? "",
            textColor: AppConstant.blackColor,
            fontSize: 12,
            letterSpacing: 1),
        AppUtils.commonSizedBox(height: 5),
        AppUtils.commonTextWidget(
            fontWeight: FontWeight.w500,
            text: typeOfText ?? "",
            textColor: AppConstant.greyColor.withOpacity(0.8),
            fontSize: 12,
            letterSpacing: 1),
      ],
    );
  }

  Widget commonIconWidget(
      {Function()? onTap, IconData? iconData, Color? color}) {
    return InkWell(
      onTap: onTap,
      child: Icon(
        iconData,
        size: 26,
        color: color ?? AppConstant.blackColor.withOpacity(0.6),
      ),
    );
  }

  Widget trackAppBarWidget(
      {Function()? onTapBackButton,
      Function()? onTapGetCurrentPosition,
      getMdl}) {
    return Positioned(
      child: AppUtils.commonContainer(
        margin: const EdgeInsets.only(left: 10, right: 10, top: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            AppUtils.commonInkWell(
              onTap: onTapBackButton ?? () {},
              child: AppUtils.commonContainer(
                  height: 40,
                  width: 40,
                  decoration: AppUtils.commonBoxDecoration(
                      color: AppConstant.whiteColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppConstant.greyColor.withOpacity(0.5),
                          offset: Offset(2, 2),
                          blurRadius: 3,
                          spreadRadius: 2,
                        )
                      ]),
                  child: AppUtils.commonContainer(
                    child: Icon(
                      Icons.arrow_back_ios_new,
                      size: 18,
                      color: AppConstant.blackColor,
                    ),
                  )),
            ),
            dateSelectionWidget(isFromSheet: false, getMdl: getMdl),
            AppUtils.commonInkWell(
              onTap: onTapGetCurrentPosition ?? () {},
              child: AppUtils.commonContainer(
                  height: 40,
                  width: 40,
                  decoration: AppUtils.commonBoxDecoration(
                      color: AppConstant.whiteColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppConstant.greyColor.withOpacity(0.5),
                          offset: Offset(2, 2),
                          blurRadius: 3,
                          spreadRadius: 2,
                        )
                      ]),
                  child: Icon(
                    Icons.location_searching_outlined,
                    size: 18,
                    color: AppConstant.blackColor,
                  )),
            ),
          ],
        ),
      ),
    );
  }

  Widget dateSelectionWidget({bool? isFromSheet, getMdl}) {
    return AppUtils.commonContainer(
      width: 210,
      margin: AppUtils.edgeInsetsOnly(
          top: isFromSheet == true ? 0 : 10, bottom: 10, right: 20, left: 20),
      padding: AppUtils.edgeInsetsAll(allPadding: 8),
      decoration: AppUtils.commonBoxDecoration(
        borderRadius: isFromSheet == true
            ? AppUtils.borderRadiousonly(bottomleft: 15, bottomright: 15)
            : AppUtils.borderRadiusAll(raduis: 60),
        color: AppConstant.whiteColor,
        boxShadow: isFromSheet == true
            ? [
                BoxShadow(
                  color: AppConstant.greyColor.withOpacity(0.2),
                  offset:
                      Offset(0, 5), // Adjusting the offset for the bottom side
                  blurRadius: 4,
                  spreadRadius: 1,
                ),
              ]
            : [
                BoxShadow(
                  color: AppConstant.greyColor.withOpacity(0.5),
                  offset:
                      Offset(2, 2), // Default shadow if isFromSheet is false
                  blurRadius: 3,
                  spreadRadius: 2,
                ),
              ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          AppUtils.commonInkWell(
              onTap: () {
                setState(() {
                  selectedDate = selectedDate?.subtract(Duration(days: 1));
                });
                saleMenTimeLineProvider.apiCallGetTimeLine(
                    userid: widget.userId, date: selectedDate.toString());
              },
              child: AppUtils.commonContainer(
                width: 40,
                height: 30,
                decoration: AppUtils.commonBoxDecoration(
                    borderRadius: AppUtils.borderRadiousonly(
                        bottomleft: 15, topleft: 15)),
                child: Icon(
                  Icons.keyboard_arrow_left,
                  color: AppConstant.appPrimaryColor,
                  size: 30,
                ),
              )),
          AppUtils.commonInkWell(
            onTap: openDatePicker,
            child: AppUtils.commonTextWidget(
                textColor: AppConstant.blackColor,
                text: AppUtils.dateFormat(
                    date: selectedDate, dateFormat: "dd-MM-yyyy"),
                fontSize: 14),
          ),
          AppUtils.commonInkWell(
            onTap: () {
              setState(() {
                selectedDate = selectedDate?.add(Duration(days: 1));
              });
              saleMenTimeLineProvider.apiCallGetTimeLine(
                  userid: widget.userId, date: selectedDate.toString());
            },
            child: AppUtils.commonContainer(
              width: 40,
              height: 30,
              decoration: AppUtils.commonBoxDecoration(
                  borderRadius: AppUtils.borderRadiousonly(
                      topright: 15, bottomright: 15)),
              child: Icon(
                Icons.keyboard_arrow_right,
                color: AppConstant.appPrimaryColor,
                size: 30,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> openDatePicker() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      initialEntryMode: DatePickerEntryMode.calendarOnly,
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            backgroundColor: AppConstant.whiteColor,
            dialogBackgroundColor: AppConstant.whiteColor,
            scaffoldBackgroundColor: AppConstant.whiteColor,
            textSelectionTheme: TextSelectionThemeData(
              selectionColor:
                  AppConstant.appPrimaryColor, // Selected date color
            ),
            colorScheme: ColorScheme.light(
              background: Colors.white,
              onBackground: AppConstant.greyColor.withOpacity(0.5),
              primary: AppConstant.appPrimaryColor, // Button color
              onPrimary: AppConstant.whiteColor, // Text color on button
            ).copyWith(background: AppConstant.whiteColor),
            // Other theme modifications as needed...
          ),
          child: child ?? Container(),
        );
      },
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        // historyDateController.text =
        //     dateFormat.format(picked); // Format date as dd-MM-yyyy
      });
      // callGetTimeline(getMdl);
    }
  }
}
