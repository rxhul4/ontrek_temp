import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ontrek/core/utils/app_constant.dart';
import 'package:ontrek/core/utils/widget_utils.dart';

class SaleManTracker extends StatefulWidget {
  int? index;

  SaleManTracker({super.key, this.index});

  @override
  State<SaleManTracker> createState() => _SaleManTrackerState();
}

class _SaleManTrackerState extends State<SaleManTracker> {
  late final Completer<GoogleMapController> googleMapController = Completer();
  Set<Marker> markers = Set();
  LatLng currentLocation = LatLng(20.5937, 78.9629);

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

  Future updateCameraPosition(LatLng location) async {
    print("location-------${location}");
    final GoogleMapController controller = await googleMapController.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(
        target: location,
        zoom: 24,
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
    print("index_____${widget.index}");
    getCurrentLocation();
  }

  DraggableScrollableController draggableScrollableController =
      DraggableScrollableController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            GoogleMap(
                zoomControlsEnabled: false,
                padding: WidgetUtils.edgeInsetsOnly(
                    bottom: MediaQuery.of(context).size.height * 0.25),
                mapType: MapType.normal,
                onMapCreated: (controller) {
                  googleMapController.complete(controller);
                },
                markers: markers,
                initialCameraPosition:
                    CameraPosition(target: currentLocation, zoom: 80)),
            // dateSelectionWidget(),
            trackAppBarWidget(
              onTapGetCurrentPosition: getCurrentLocation,
              onTapBackButton: () {
                Navigator.pop(context);
              },
            ),
            DraggableScrollableSheet(
              shouldCloseOnMinExtent: true,
              snap: true,
              expand: true,
              snapAnimationDuration: Duration(milliseconds: 500),
              initialChildSize: 0.23,
              maxChildSize: 1,
              minChildSize: 0.23,
              controller: draggableScrollableController,
              builder: (context, scrollController) {
                return WidgetUtils.commonContainer(
                  decoration: WidgetUtils.commonBoxDecoration(
                    color: AppConstant.whiteColor,
                    borderRadius: WidgetUtils.borderRadiousonly(
                        topleft: 15, topright: 15),
                    boxShadow: [
                      BoxShadow(
                        color: AppConstant.greyColor.withOpacity(0.5),
                        offset: const Offset(0, -2),
                        blurRadius: 15,
                        spreadRadius: 6,
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    controller: scrollController,
                    child: Column(
                      children: [
                        WidgetUtils.commonContainer(
                          decoration: WidgetUtils.commonBoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                width: 1,
                                color: AppConstant.greyColor.withOpacity(0.3),
                              ),
                            ),
                            borderRadius: WidgetUtils.borderRadiousonly(
                                topleft: 18, topright: 18),
                            color: Colors.white,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                            child: Column(
                              children: [
                                WidgetUtils.commonContainer(
                                  width: 30,
                                  height: 5,
                                  decoration: WidgetUtils.commonBoxDecoration(
                                      color: AppConstant.greyColor
                                          .withOpacity(0.3),
                                      borderRadius: WidgetUtils.borderRadiusAll(
                                          raduis: 12)),
                                ),
                                Row(
                                  children: [
                                    WidgetUtils.commonContainer(
                                        height: 45,
                                        width: 45,
                                        decoration:
                                            WidgetUtils.commonBoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                              color: Colors.grey, width: 1.2),
                                        ),
                                        child: Icon(Icons.person,
                                            color: Colors.cyan)),
                                    WidgetUtils.commonSizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          WidgetUtils.commonTextWidget(
                                            text: "You",
                                            fontWeight: FontWeight.w600,
                                            textColor: AppConstant.blackColor,
                                            letterSpacing: 0.2,
                                            fontSize: 15,
                                          ),
                                          WidgetUtils.commonTextWidget(
                                            text:
                                                "Dwarkesh Business Hub Visat...",
                                            fontWeight: FontWeight.w400,
                                            textColor: AppConstant.blackColor
                                                .withOpacity(0.3),
                                            letterSpacing: 0,
                                            fontSize: 13,
                                          ),
                                        ],
                                      ),
                                    ),
                                    commonIconWidget(
                                      iconData: Icons.call,
                                      color: AppConstant.blueColor,
                                      onTap: () {},
                                    ),
                                    WidgetUtils.commonSizedBox(width: 10),
                                    commonIconWidget(
                                      iconData: Icons.more_vert,
                                      onTap: () {},
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        WidgetUtils.commonContainer(
                          padding:
                              WidgetUtils.edgeInsetsOnly(top: 20, bottom: 20),
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
                            children: [
                              travelInfoRowWidget(
                                  iconData: Icons.timelapse,
                                  textData: "15:30",
                                  typeOfText: "DURATION",
                                  iconColor: Colors.red),
                              travelInfoRowWidget(
                                  iconData: Icons.speed_sharp,
                                  textData: "0 Km",
                                  typeOfText: "DISTANCE",
                                  iconColor: Colors.green),
                              travelInfoRowWidget(
                                  iconData: Icons.location_on_outlined,
                                  textData: "3",
                                  typeOfText: "CHECKINS",
                                  iconColor: AppConstant.blueColor),
                            ],
                          ),
                        ),
                        Align(
                            alignment: Alignment.topCenter,
                            child: dateSelectionWidget(isFromSheet: true)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
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
        WidgetUtils.commonSizedBox(height: 5),
        WidgetUtils.commonTextWidget(
            text: textData ?? "",
            textColor: AppConstant.blackColor,
            fontSize: 12,
            letterSpacing: 2),
        WidgetUtils.commonSizedBox(height: 5),
        WidgetUtils.commonTextWidget(
            text: typeOfText ?? "",
            textColor: AppConstant.greyColor.withOpacity(0.8),
            fontSize: 12,
            letterSpacing: 2),
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
      {required Function() onTapBackButton,
      required Function() onTapGetCurrentPosition}) {
    return Positioned(
      child: WidgetUtils.commonContainer(
        margin: const EdgeInsets.only(left: 10, right: 10, top: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            WidgetUtils.commonInkWell(
              onTap: onTapBackButton,
              child: WidgetUtils.commonContainer(
                  height: 40,
                  width: 40,
                  decoration: WidgetUtils.commonBoxDecoration(
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
                  child: WidgetUtils.commonContainer(
                    child: Icon(
                      Icons.arrow_back_ios_new,
                      size: 18,
                      color: AppConstant.blackColor,
                    ),
                  )),
            ),
            dateSelectionWidget(isFromSheet: false),
            WidgetUtils.commonInkWell(
              onTap: onTapGetCurrentPosition,
              child: WidgetUtils.commonContainer(
                  height: 40,
                  width: 40,
                  decoration: WidgetUtils.commonBoxDecoration(
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

  Widget dateSelectionWidget({bool? isFromSheet}) {
    return WidgetUtils.commonContainer(
      width: 210,
      margin: WidgetUtils.edgeInsetsOnly(
          top: isFromSheet == true ? 0 : 10, bottom: 10, right: 20, left: 20),
      padding: WidgetUtils.edgeInsetsAll(allPadding: 10),
      decoration: WidgetUtils.commonBoxDecoration(
        borderRadius: isFromSheet == true
            ? WidgetUtils.borderRadiousonly(bottomleft: 15, bottomright: 15)
            : WidgetUtils.borderRadiusAll(raduis: 60),
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
          WidgetUtils.commonInkWell(
              onTap: () {
                setState(() {
                  selectedDate = selectedDate?.subtract(Duration(days: 1));
                });
                // callGetRouteHistoryApi(getMdl);
              },
              child: WidgetUtils.commonContainer(
                width: 40,
                height: 30,
                decoration: WidgetUtils.commonBoxDecoration(
                    borderRadius: WidgetUtils.borderRadiousonly(
                        bottomleft: 15, topleft: 15)),
                child: Icon(
                  Icons.keyboard_arrow_left,
                  color: AppConstant.blueColor,
                  size: 30,
                ),
              )),
          WidgetUtils.commonInkWell(
            onTap: openDatePicker,
            child: WidgetUtils.commonTextWidget(
                textColor: AppConstant.blackColor,
                text: WidgetUtils.dateFormat(
                    date: selectedDate, dateFormat: "dd-MM-yyyy"),
                fontSize: 15),
          ),
          WidgetUtils.commonInkWell(
            onTap: () {
              setState(() {
                selectedDate = selectedDate?.add(Duration(days: 1));
              });
              // callGetRouteHistoryApi(getMdl);
            },
            child: WidgetUtils.commonContainer(
              width: 40,
              height: 30,
              decoration: WidgetUtils.commonBoxDecoration(
                  borderRadius: WidgetUtils.borderRadiousonly(
                      topright: 15, bottomright: 15)),
              child: Icon(
                Icons.keyboard_arrow_right,
                color: AppConstant.blueColor,
                size: 30,
              ),
            ),
          ),
        ],
      ),
    );
  }

  DateTime? selectedDate;

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
              selectionColor: AppConstant.blueColor, // Selected date color
            ),
            colorScheme: ColorScheme.light(
              background: Colors.white,
              onBackground: AppConstant.greyColor.withOpacity(0.5),
              primary: AppConstant.blueColor, // Button color
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
