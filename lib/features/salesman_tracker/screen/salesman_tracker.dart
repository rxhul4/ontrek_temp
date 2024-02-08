import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:ontrek/core/utils/app_constant.dart';
import 'package:ontrek/core/utils/App_utils.dart';
import 'package:ontrek/core/utils/app_constant.dart';
import 'package:ontrek/core/utils/image_path.dart';

import 'package:ontrek/features/salesman_tracker/model/salesmen_tracking_detailes.dart';
import 'package:ontrek/features/salesman_tracker/provider/salesmen_tracking_timeline_provider.dart';
import 'package:provider/provider.dart';
import 'package:timeline_tile/timeline_tile.dart';

import '../local_model.dart';

class SaleManTracker extends StatefulWidget {
  int? index;
  String? name;
  String? userUid;
  String? phoneNumber;

  SaleManTracker(
      {super.key, this.index, this.name, this.userUid, this.phoneNumber});

  @override
  State<SaleManTracker> createState() => _SaleManTrackerState();
}

class _SaleManTrackerState extends State<SaleManTracker> {
  late final Completer<GoogleMapController> googleMapController = Completer();
  Set<Marker> markers = Set();
  LatLng currentLocation = LatLng(20.5937, 78.9629);
  DraggableScrollableController draggableScrollableController =
      DraggableScrollableController();
  GetTimeLineModel? getTimeLineModel;
  int? countOfCheckins;
  String imagePath = '';
  Color? statusColor;
  int? checkInCount;

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

  void addUpdatedLocationMarker(LatLng location) {
    setState(() {
      markers.clear(); // Clear previous markers
      markers.add(
        Marker(
          markerId: MarkerId("updateLocation"),
          position: location,
          infoWindow: InfoWindow(title: "Update Location"),
        ),
      );
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print("index_____${widget.index}");
    print("userUid----${widget.userUid}");
    getCurrentLocation();
    selectedDate = DateTime.now();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final getMdl = Provider.of<SaleMenTackingTimeLineProvider>(context, listen: false);
      callGetTimeline(getMdl);
      // setIconFunction();
    });
  }

  countCheckins() {
    List<String?>? trackingStatus =
        getTimeLineModel?.data?.map((e) => e.trackingStatus).toList();
    setState(() {
      checkInCount =
          trackingStatus?.where((element) => element == "Check In")?.length;
    });

    print("cehckiinnn${checkInCount}");
    return checkInCount;
  }

  callGetTimeline(SaleMenTackingTimeLineProvider getMdl) {
    getMdl
        .apiCallGetTimeLine(
            eventDate: AppUtils.dateFormat(
                date: selectedDate, dateFormat: "yyyy-MM-dd"),
            userUid: widget.userUid)
        .then((value) {
      getTimeLineModel = value;
      if (getTimeLineModel?.code != 200) {
        openCustomDialog(getTimeLineModel?.message ?? "");
      } else {
        // getTimeLineModel = GetTimeLineModel();
        countCheckins();
        // setIconFunction();
      }
    });
  }

  Future onClickLocateOnMap(LatLng location) async {
    await updateCameraPosition(location);
    addUpdatedLocationMarker(location);
  }

  @override
  Widget build(BuildContext context) {
    final getMdl = Provider.of<SaleMenTackingTimeLineProvider>(context);

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            GoogleMap(
                zoomControlsEnabled: false,
                padding: AppUtils.edgeInsetsOnly(
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
              getMdl: getMdl,
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
                          child: SingleChildScrollView(
                            controller: scrollController,
                            child: Column(
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
                                              borderRadius:
                                                  AppUtils.borderRadiusAll(raduis: 12)),
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
                                              color: AppConstant.blueColor,
                                              onTap: openDialogFnc,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                AppUtils.commonContainer(
                                  padding: AppUtils.edgeInsetsOnly(top: 20, bottom: 20),
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
                                          textData: checkInCount.toString(),
                                          typeOfText: "CHECKINS",
                                          iconColor: AppConstant.blueColor),
                                    ],
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.topCenter,
                                  child: dateSelectionWidget(isFromSheet: true,getMdl: getMdl),
                                ),
                                AppUtils.commonSizedBox(height: 20),
                                getMdl.isFetching
                                    ? AppUtils.loaderWidget()
                                    : getMdl.getTimeLineModel?.data == null ||
                                            (getMdl.getTimeLineModel?.data?.length ??
                                                    0) <=
                                                0
                                        ? AppUtils.commonNoDataFound(
                                            onPressed: () {
                                              callGetTimeline(getMdl);
                                            },
                                          )
                                        : ListView.builder(
                                            itemCount:
                                                getMdl.getTimeLineModel?.data?.length ??
                                                    0,
                                            physics:
                                                const NeverScrollableScrollPhysics(),
                                            shrinkWrap: true,
                                            itemBuilder: (context, index) {
                                              // DateTime dateTime = DateTime.now();
                                              var formatTime = AppUtils.getDate(
                                                  date: getMdl.getTimeLineModel
                                                          ?.data?[index].eventTime ??
                                                      "",
                                                  format: "HH:mm aa");
                                              var formattedDate = AppUtils.getDate(
                                                  date: getMdl.getTimeLineModel
                                                          ?.data?[index].eventTime ??
                                                      "",
                                                  format: "d MMM y");


                                                final trackingStatus = getTimeLineModel?.data?[index].trackingStatus;

                                                if (trackingStatus != null) {
                                                  print("Tracking Status: $trackingStatus");

                                                  switch (trackingStatus) {
                                                    case 'Day Start':
                                                      imagePath = loginIcon;
                                                      statusColor = Colors.lightGreen;
                                                      break;
                                                    case 'Check In':
                                                      imagePath = checkInIcon;
                                                      statusColor = AppConstant.blueColor;
                                                      break;
                                                    case 'Check Out':
                                                      imagePath = checkOutIcon;
                                                      statusColor = AppConstant.blueColor;
                                                      break;
                                                    case 'Waiting Start':
                                                    case 'Waiting End':
                                                      imagePath = waitingIcon;
                                                      statusColor = Colors.orangeAccent;
                                                      break;
                                                    default:
                                                      imagePath = logoutIcon;
                                                      statusColor = Colors.red;
            }
                                                } else {
                                                  // Handling null case
                                                  print("Tracking status is null");
                                                  imagePath = logoutIcon; // or provide a default image path
                                                }

                                              return TimelineTile(
                                                hasIndicator: true,
                                                axis: TimelineAxis.vertical,
                                                lineXY: 0.5,
                                                isLast: index ==
                                                    (getMdl.getTimeLineModel?.data
                                                                ?.length ??
                                                            0) -
                                                        1,
                                                isFirst: index ==
                                                    getMdl
                                                        .getTimeLineModel?.data?.length,
                                                indicatorStyle: IndicatorStyle(
                                                  indicatorXY: 0,
                                                  drawGap: true,
                                                  height: 40,
                                                  width: 40,
                                                  indicator: AppUtils.commonContainer(
                                                    decoration:
                                                        AppUtils.commonBoxDecoration(
                                                      // color: Colors.lightGreen,
                                                      shape: BoxShape.circle,
                                                    ),
                                                    child: Center(
                                                        child: Image.asset(
                                                          imagePath,
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
                                                  padding:
                                                      AppUtils.edgeInsetsOnly(top: 10),
                                                  margin:
                                                      AppUtils.edgeInsetsOnly(left: 30),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment.start,
                                                    children: [
                                                      AppUtils.commonTextWidget(

                                                          text: formattedDate /* getTimeLineModel?.data?[index].eventDate ?? ""*/,
                                                          textColor:
                                                              AppConstant.greyColor,
                                                          fontWeight: FontWeight.w400,
                                                          fontSize: 16),
                                                      AppUtils.commonTextWidget(
                                                          text:
                                                              formatTime /*getTimeLineModel?.data?[index].eventTime ?? ""*/,
                                                          textColor:
                                                              AppConstant.blackColor,
                                                          fontWeight: FontWeight.w400,
                                                          fontSize: 14),
                                                    ],
                                                  ),
                                                ),
                                                endChild: AppUtils.commonInkWell(

                                                  onTap: () {

                                                    draggableScrollableController.animateTo(0.23,duration: Duration(milliseconds: 1000),curve: Curves.decelerate);
                                                    onClickLocateOnMap(LatLng(getTimeLineModel?.data?[index].lattitude ?? 0, getTimeLineModel?.data?[index].longitude ?? 0)).then((value) {
                                                      draggableScrollableController.reset();
                                                    });

                                                  },
                                                  child: AppUtils.commonContainer(
                                                    padding:
                                                        AppUtils.edgeInsetsOnly(top: 5),
                                                    margin: AppUtils.edgeInsetsOnly(
                                                        right: 10, bottom: 20, left: 30),
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment.start,
                                                      children: [
                                                        AppUtils.commonTextWidget(
                                                            text: getMdl
                                                                    .getTimeLineModel
                                                                    ?.data?[index]
                                                                    .trackingStatus ??
                                                                "",
                                                            textColor: statusColor,
                                                            fontWeight: FontWeight.w400,
                                                            fontSize: 16),
                                                        AppUtils.commonTextWidget(
                                                            text: getMdl
                                                                    .getTimeLineModel
                                                                    ?.data?[index]
                                                                    .trackingAddress ??
                                                                "",
                                                            textColor:
                                                                AppConstant.blackColor,
                                                            fontWeight: FontWeight.w400,
                                                            fontSize: 14),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                alignment: TimelineAlign.manual,
                                              );
                                            },
                                          )
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
      {required Function() onTapBackButton,
      required Function() onTapGetCurrentPosition,
      getMdl}) {
    return Positioned(
      child: AppUtils.commonContainer(
        margin: const EdgeInsets.only(left: 10, right: 10, top: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            AppUtils.commonInkWell(
              onTap: onTapBackButton,
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
              onTap: onTapGetCurrentPosition,
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
      padding: AppUtils.edgeInsetsAll(allPadding: 10),
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
                callGetTimeline(getMdl);
              },
              child: AppUtils.commonContainer(
                width: 40,
                height: 30,
                decoration: AppUtils.commonBoxDecoration(
                    borderRadius: AppUtils.borderRadiousonly(
                        bottomleft: 15, topleft: 15)),
                child: Icon(
                  Icons.keyboard_arrow_left,
                  color: AppConstant.blueColor,
                  size: 30,
                ),
              )),
          AppUtils.commonInkWell(
            onTap: openDatePicker,
            child: AppUtils.commonTextWidget(
                textColor: AppConstant.blackColor,
                text: AppUtils.dateFormat(
                    date: selectedDate, dateFormat: "dd-MM-yyyy"),
                fontSize: 15),
          ),
          AppUtils.commonInkWell(
            onTap: () {
              setState(() {
                selectedDate = selectedDate?.add(Duration(days: 1));
              });
              callGetTimeline(getMdl);
            },
            child: AppUtils.commonContainer(
              width: 40,
              height: 30,
              decoration: AppUtils.commonBoxDecoration(
                  borderRadius: AppUtils.borderRadiousonly(
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

  openDialogFnc() {
    showDialog(
      context: context,
      builder: (context) => showDialogBox(context),
    );
  }

  AlertDialog showDialogBox(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppConstant.blueColor,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10))),
      contentPadding:
          AppUtils.edgeInsetsOnly(right: 15, left: 15, top: 10, bottom: 20),
      insetPadding: AppUtils.edgeInsetsAll(allPadding: 0),
      titlePadding: AppUtils.edgeInsetsAll(allPadding: 0),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            AppUtils.commonSizedBox(
              height: 40,
              width: 40,
            ),
            AppUtils.commonTextWidget(
                // textColor: App,
                text: "Contact Info",
                fontSize: 16),
            AppUtils.commonContainer(
                height: 40,
                width: 40,
                child: IconButton(
                    color: AppConstant.whiteColor,
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: Icon(Icons.close)))
          ],
        ),
        AppUtils.commonSizedBox(height: 10),
        Visibility(
          visible: false,
          child: AppUtils.commonTextWidget(
            margin: AppUtils.edgeInsetsOnly(top: 30, bottom: 30),
            text: "No contact info found",
            fontSize: 14,
          ),
        ),
        GestureDetector(
          onTap: () {
            AppUtils.launchToBrowser(Uri.parse("tel:${widget.phoneNumber}"));
          },
          child: AppUtils.commonContainer(
            padding: AppUtils.edgeInsetsAll(allPadding: 15),
            width: double.infinity,
            decoration: AppUtils.commonBoxDecoration(
                border: Border.all(
                  color: AppConstant.greyColor.withOpacity(0.5),
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(5),
                color: AppConstant.whiteColor),
            child: Row(
              children: [
                Icon(Icons.call, color: AppConstant.blueColor),
                AppUtils.commonSizedBox(width: 5),
                AppUtils.commonTextWidget(
                    letterSpacing: 2,
                    text: widget.phoneNumber ?? "",
                    // text: getSalesMenListModelData?[
                    // index]
                    //     .primaryPhoneNo ??
                    //     '',
                    fontSize: 14,
                    textColor: AppConstant.blueColor),
              ],
            ),
          ),
        ),
      ]),
    );
  }

  openCustomDialog(String text) {
    showDialog(
      context: context,
      builder: (context) => showCustomDialog(text, context),
    );
  }

  AlertDialog showCustomDialog(String text, BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10))),
      // Remove border radius
      insetPadding: const EdgeInsets.all(0),
      titlePadding: const EdgeInsets.all(0),
      contentPadding:
          const EdgeInsets.only(top: 30, bottom: 10, left: 20, right: 20),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Text(text, textAlign: TextAlign.center,),
          AppUtils.commonTextWidget(
              text: text,
              textAlign: TextAlign.center,
              textColor: AppConstant.blackColor,
              fontWeight: FontWeight.w400),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                style: TextButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10))),
                onPressed: () {
                  Navigator.pop(context);
                },
                child: AppUtils.commonTextWidget(
                    text: "OK",
                    textColor: AppConstant.blueColor,
                    letterSpacing: 1,
                    fontWeight: FontWeight.w600),
              ),
            ],
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
