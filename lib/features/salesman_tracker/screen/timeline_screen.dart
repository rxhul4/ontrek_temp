import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ontrek/core/utils/App_utils.dart';
import 'package:ontrek/core/utils/app_constant.dart';
import 'package:ontrek/core/utils/image_path.dart';
import 'package:ontrek/features/salesman_tracker/provider/salesmen_tracking_timeline_provider.dart';
import 'package:provider/provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:timeline_tile/timeline_tile.dart';

class TimeLineScreen extends StatefulWidget {
  int? index;
  String? userId;
  String? name;
  TimeLineScreen({super.key,this.userId,this.name,this.index});

  @override
  State<TimeLineScreen> createState() => _TimeLineScreenState();
}

class _TimeLineScreenState extends State<TimeLineScreen> {
  DateTime? selectedDate;
  LatLng currentLocation = LatLng(20.5937, 78.9629);
  PanelController panelController = PanelController();
  Set<Marker> markers = Set();
  late final Completer<GoogleMapController> googleMapController = Completer();


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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final saleMenTimeLineProvider =
      Provider.of<SalemenTimeLineProvider>(context, listen: false);
      if(!mounted){

      }
      saleMenTimeLineProvider.apiCallGetTimeLine(userid: widget.userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      body: SafeArea(
        child: AppUtils.commonSlidePanel(
          body: Stack(
            children: [

              Center(
                child: Text("This is the Widget behind the sliding panel"),
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
          minHeight: height * 0.23,
          controller: panelController,
          isDraggable: true,
          panelBuilder: (p0) {
            return AppUtils.commonContainer(
              decoration: AppUtils.commonBoxDecoration(
                color: AppConstant.whiteColor,
                borderRadius:
                    AppUtils.borderRadiousonly(topleft: 15, topright: 15),
                boxShadow: [
                  BoxShadow(
                    color: AppConstant.greyColor.withOpacity(0.5),
                    offset: const Offset(0, -2),
                    blurRadius: 15,
                    spreadRadius: 6,
                  ),
                ],
              ),
              child: Column(
                children: [
                  Column(
                    children: [
                      AppUtils.commonContainer(
                        decoration: AppUtils.commonBoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              width: 1,
                              color: AppConstant.greyColor.withOpacity(0.3),
                            ),
                          ),
                          borderRadius: AppUtils.borderRadiousonly(
                              topleft: 18, topright: 18),
                          color: Colors.white,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          child: Column(
                            children: [
                              AppUtils.commonContainer(
                                width: 30,
                                height: 5,
                                decoration: AppUtils.commonBoxDecoration(
                                    color: AppConstant.greyColor
                                        .withOpacity(0.3),
                                    borderRadius: AppUtils.borderRadiusAll(
                                        raduis: 12)),
                              ),
                              Row(
                                children: [
                                  AppUtils.commonContainer(
                                      height: 45,
                                      width: 45,
                                      decoration:
                                          AppUtils.commonBoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                            color: Colors.grey, width: 1.2),
                                      ),
                                      child: const Icon(Icons.person,
                                          color: Colors.cyan)),
                                  AppUtils.commonSizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        AppUtils.commonTextWidget(
                                          text: widget.name ?? "",
                                          fontWeight: FontWeight.w600,
                                          textColor: AppConstant.blackColor,
                                          letterSpacing: 0.2,
                                          fontSize: 15,
                                        ),
                                        AppUtils.commonTextWidget(
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
                                    color: AppConstant.appPrimaryColor,
                                    onTap: () {},
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      AppUtils.commonContainer(
                        padding:
                            AppUtils.edgeInsetsOnly(top: 20, bottom: 20),
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
                                textData: "2",
                                typeOfText: "CHECKINS",
                                iconColor: AppConstant.appPrimaryColor),
                          ],
                        ),
                      ),
                      Align(
                        alignment: Alignment.topCenter,
                        child: dateSelectionWidget(
                          isFromSheet: true, /*getMdl: getMdl*/
                        ),
                      ),
                    ],
                  ),
                  // getMdl.isFetching
                  //     ? AppUtils.loaderWidget()
                  //     : getMdl.getTimeLineModel?.data == null ||
                  //             (getMdl.getTimeLineModel?.data?.length ??
                  //                     0) <=
                  //                 0
                  //         ? AppUtils.commonNoDataFound(
                  //             onPressed: () {
                  //               // callGetTimeline(getMdl);
                  //             },
                  //           )
                  //         :
                  Expanded(
                    child: ListView.builder(
                      itemCount: 10,
                      physics: const BouncingScrollPhysics(),
                      controller: p0,
                      shrinkWrap: true,
                      padding: EdgeInsets.only(bottom: 30),
                      itemBuilder: (context, index) {
                        return TimelineTile(
                          hasIndicator: true,

                          axis: TimelineAxis.vertical,
                          lineXY: 0.5,
                          isLast: index == 10 - 1,
                          // ==
                          //     (getMdl.getTimeLineModel?.data
                          //                 ?.length ??
                          //             0) -
                          //         1,
                          isFirst: index == 10,
                          // getMdl
                          //     .getTimeLineModel?.data?.length,
                          indicatorStyle: IndicatorStyle(
                            indicatorXY: 0,
                            drawGap: true,
                            height: 40,
                            width: 40,
                            indicator: AppUtils.commonContainer(
                              decoration: AppUtils.commonBoxDecoration(
                                // color: Colors.lightGreen,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                  child: Image.asset(
                                loginIcon,
                                // AppUtils.getImagePathFromApi(getTimeLineModel?.data?[index].trackingStatus),
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
                                    text: "12 jan 2024",
                                    // text: AppUtils.getDate(
                                    //     date: getMdl
                                    //             .getTimeLineModel
                                    //             ?.data?[index]
                                    //             .eventTime ??
                                    //         "",
                                    //     format: "d MMM y"),
                                    textColor: AppConstant.greyColor,
                                    fontWeight: FontWeight.w400,
                                    fontSize: 16),
                                AppUtils.commonTextWidget(
                                    text: "12:12 PM",
                                    // AppUtils.getDate(
                                    //     date: getMdl
                                    //             .getTimeLineModel
                                    //             ?.data?[index]
                                    //             .eventTime ??
                                    //         "",
                                    //     format: "HH:mm aa"),
                                    textColor: AppConstant.blackColor,
                                    fontWeight: FontWeight.w400,
                                    fontSize: 14),
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
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  AppUtils.commonTextWidget(
                                      text:
                                          "LogIn" /*getMdl
                                                        .getTimeLineModel
                                                        ?.data?[index]
                                                        .trackingStatus ??
                                                    ""*/
                                      ,
                                      textColor:
                                          AppConstant.appPrimaryColor,
                                      // AppUtils.getStatusColor(
                                      //     getTimeLineModel
                                      //         ?.data?[index]
                                      //         .trackingStatus),
                                      fontWeight: FontWeight.w400,
                                      fontSize: 16),
                                  AppUtils.commonTextWidget(
                                      text: /*getMdl
                                                        .getTimeLineModel
                                                        ?.data?[index]
                                                        .trackingAddress ??*/
                                          "12,Jashoda Nagar Ahmedabad",
                                      textColor: AppConstant.blackColor,
                                      fontWeight: FontWeight.w400,
                                      fontSize: 14),
                                ],
                              ),
                            ),
                          ),
                          alignment: TimelineAlign.manual,
                        );
                      },
                    ),
                  )
                ],
              ),
            );
          },
          // snapPoint: 0.01,
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
                // callGetTimeline(getMdl);
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
              // callGetTimeline(getMdl);
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
