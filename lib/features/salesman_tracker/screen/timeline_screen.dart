import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart';
import 'package:ontrek/core/common_widgets/common_dialog_widget.dart';
import 'package:ontrek/core/utils/App_utils.dart';
import 'package:ontrek/core/utils/app_constant.dart';
import 'package:ontrek/features/salesman_tracker/model/salesmen_tracking_detailes.dart';
import 'package:ontrek/features/salesman_tracker/provider/salesmen_tracking_timeline_provider.dart';
import 'package:provider/provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:timeline_tile/timeline_tile.dart';
import 'dart:math' show cos, ln2, log, min, sqrt;

class TimeLineScreen extends StatefulWidget {
  int? index;
  String? userId;
  String? name;
  String? phoneNumber;
  String? imageUrl;

  TimeLineScreen(
      {super.key,
      this.userId,
      this.name,
      this.index,
      this.phoneNumber,
      this.imageUrl});

  @override
  State<TimeLineScreen> createState() => _TimeLineScreenState();
}

class _TimeLineScreenState extends State<TimeLineScreen> {
  DateTime? selectedDate;
  LatLng currentLocation = LatLng(20.5937, 78.9629);
  PanelController panelController = PanelController();
  Set<Marker> markers = Set();
  Set<Circle> circles = Set();
  Set<Polyline> polylines = Set();
  late SalemenTimeLineProvider saleMenTimeLineProvider;
  final Completer<GoogleMapController> googleMapController =
      Completer<GoogleMapController>();
  int selectedIndex = 0;
  List<LatLng> polylineCoordinates = [];

  Future<void> getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low,
      );
      setState(() {
        currentLocation = LatLng(position.latitude, position.longitude);
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
    final GoogleMapController controller = await googleMapController.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(
        target: location,
        zoom: 12,
      ),
    ));
  }

  void addTimeLineMarker(
      {String? eventId,
      required LatLng location,
      String? eventCode,
      String? eventName}) {
    markers.clear();
    markers.add(Marker(
        markerId: MarkerId("$eventId"),
        position: location,
        icon: getMarkerColor("$eventCode"),
        infoWindow: InfoWindow(title: "${eventName}")
        // Adjust icon as needed
        ));
  }

  void addCurrentLocationMarker(LatLng location) async {
    markers.clear();
    markers.add(
      Marker(
        markerId: MarkerId("currentLocation"),
        position: location,
        infoWindow: InfoWindow(title: "Current Location"),
      ),
    );
  }

  void addRouteMarker(
      {LatLng? startLocation, LatLng? endLocation, int? sessionNumber}) async {
    markers.add(
      Marker(
        markerId: MarkerId("currentLocation"),
        position: startLocation ?? LatLng(0, 0),
        infoWindow: InfoWindow(title: "Current Location"),
        // icon: BitmapDescriptor.fromBytes(markerIcon),
      ),
    );
    markers.add(
      Marker(
        markerId: MarkerId("currentLocation"),
        position: endLocation ?? LatLng(0, 0),
        infoWindow: InfoWindow(title: "Current Location"),
        // icon: BitmapDescriptor.fromBytes(markerIcon),
      ),
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    selectedDate = DateTime.now();
    // getCurrentLocation();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      panelController.animatePanelToSnapPoint();
      final saleMenTimeLineProvider =
          Provider.of<SalemenTimeLineProvider>(context, listen: false);
      if (!mounted) {}
      saleMenTimeLineProvider.sessionEvents.clear();
      saleMenTimeLineProvider.allSessionLatLong.clear();
      await saleMenTimeLineProvider
          .apiCallGetTimeLine(
              userid: widget.userId, date: selectedDate.toString())
          .then((value) async {
        if (value?.isValidationFailed == false && value?.isError == false) {
          await drawPolyLines();
        }
      });
    });
  }

  Future<void> drawPolyLines() async {
    if (selectedIndex != 0) {
      polylineCoordinates.clear();
      var sessionTimeline =
          saleMenTimeLineProvider.getTimeLineModel?.data?.sessionTimeLine;
      if (sessionTimeline != null) {
        var session = sessionTimeline
            .firstWhere((element) => element.sessionNo == selectedIndex);
        if (session != null && session.sessionRouteHistory != null) {
          session.sessionRouteHistory?.latlongArray?.forEach((latLng) {
            polylineCoordinates.add(LatLng(
              latLng.x ?? 0,
              latLng.y ?? 0,
            ));
          });
        }
      }

      polylines.add(Polyline(
        polylineId: PolylineId("PolyLine$selectedIndex"),
        visible: true,
        width: 4,
        points: polylineCoordinates,
        color: AppConstant.appPrimaryColor,
      ));
    } else {
      var sessionTimeLine =
          saleMenTimeLineProvider.getTimeLineModel?.data?.sessionTimeLine;
      if (sessionTimeLine != null) {
        for (var session in sessionTimeLine) {
          var latlongArray = session.sessionRouteHistory?.latlongArray;
          List<LatLng> polylineCoordinates = [];
          if (latlongArray != null) {
            latlongArray.forEach((latLng) {
              polylineCoordinates.add(LatLng(
                latLng.x ?? 0,
                latLng.y ?? 0,
              ));
            });
          }
          polylines.add(Polyline(
            polylineId: PolylineId("PolyLine${session.sessionNo}"),
            visible: true,
            width: 4,
            points: polylineCoordinates,
            color: AppConstant.greyColor,
          ));

          if (polylineCoordinates.isNotEmpty) {
            var startLatLng = polylineCoordinates.first;
            // Print startLatLng for debugging
            markers.add(Marker(
              markerId: MarkerId("StartMarker${session.sessionNo}"),
              position: startLatLng,
              icon: BitmapDescriptor.defaultMarker, // Adjust icon as needed
            ));
          }

          if (polylineCoordinates.isNotEmpty) {
            var endLatLng = polylineCoordinates.last;
            markers.add(Marker(
              markerId: MarkerId("EndMarker${session.sessionNo}"),
              position: endLatLng,
              icon: BitmapDescriptor.defaultMarker, // Adjust icon as needed
            ));
          }
        }
      }
    }
    if (selectedIndex != 0) {
      if (polylineCoordinates.isNotEmpty) {
        var startLatLng = polylineCoordinates.first;
        markers.clear();
        markers.add(Marker(
          markerId: MarkerId("StartMarker"),
          position: startLatLng,
          icon: BitmapDescriptor.defaultMarker, // Adjust icon as needed
        ));
      }
      if (polylineCoordinates.isNotEmpty) {
        var endLatLng = polylineCoordinates.last;
        markers.add(Marker(
          markerId: MarkerId("EndMarker"),
          position: endLatLng,
          icon: BitmapDescriptor.defaultMarker, // Adjust icon as needed
        ));
      }
    }

    saleMenTimeLineProvider.sessionEvents.forEach((element) async {
      if (element.sessionNo == selectedIndex) {
        markers.add(Marker(
            markerId: MarkerId("${element.eventId}"),
            position: LatLng(element.eventLat ?? 0, element.eventLong ?? 0),
            icon: getMarkerColor("${element.eventCode}"),
            infoWindow: InfoWindow(title: "${element.eventName}")
            // Adjust icon as needed
            ));
      } else {
        if (selectedIndex == 0) {
          markers.add(Marker(
              markerId: MarkerId("${element.eventId}"),
              position: LatLng(element.eventLat ?? 0, element.eventLong ?? 0),
              icon: getMarkerColor("${element.eventCode}"),
              infoWindow: InfoWindow(title: "${element.eventName}")
              // Adjust icon as needed
              ));
        }
      }
    });

    if (polylines.isNotEmpty) {
      if (selectedIndex == 0) {
        List<LatLng> policoordinates = [];

        saleMenTimeLineProvider.getTimeLineModel?.data?.sessionTimeLine
            ?.forEach((session) {
          session.sessionRouteHistory?.latlongArray?.forEach((latLng) {
            policoordinates.add(LatLng(latLng.x ?? 0, latLng.y ?? 0));
          });
        });
        await boundsFromLatLngList(policoordinates);
      } else {
        await boundsFromLatLngList(polylineCoordinates);
      }
    }
  }

  final BitmapDescriptor dayStartColor =
      BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);
  final BitmapDescriptor dayEndEventColor =
      BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
  final BitmapDescriptor checkInCheckOut =
      BitmapDescriptor.defaultMarkerWithHue(212.0);
  final BitmapDescriptor waitingColor =
      BitmapDescriptor.defaultMarkerWithHue(30.0);
  final BitmapDescriptor internetEventColor =
      BitmapDescriptor.defaultMarkerWithHue(204.0);
  final BitmapDescriptor gpsEventColor =
      BitmapDescriptor.defaultMarkerWithHue(38.0);

  BitmapDescriptor getMarkerColor(String eventCode) {
    if (eventCode != null) {
      switch (eventCode) {
        case 'tracking_event_day_start':
          return dayStartColor;
        case 'tracking_event_check_in':
        case 'tracking_event_check_out':
          return checkInCheckOut; // #1B4E89
        case 'tracking_event_waiting_start':
        case 'tracking_event_waiting_end':
          return waitingColor; // #d18950
        case 'tracking_event_internet_on':
        case 'tracking_event_internet_off':
          return internetEventColor; // #268dc6
        case 'tracking_event_gps_off':
        case 'tracking_event_gps_on':
          return gpsEventColor; // #f29900
        default:
          return dayEndEventColor;
      }
    } else {
      return dayEndEventColor;
    }
  }

  Widget datePickerWidget(bool? isFromSheet) {
    return Align(
      alignment: Alignment.topCenter,
      child: dateSelectionWidget(
        isFromSheet: isFromSheet,
      ),
    );
  }

  Future<void> boundsFromLatLngList(List<LatLng> list) async {
    final GoogleMapController mapController = await googleMapController.future;
    double? x0, x1, y0, y1;
    for (LatLng latLng in list) {
      if (x0 == null) {
        x0 = x1 = latLng.latitude;
        y0 = y1 = latLng.longitude;
      } else {
        if (latLng.latitude > x1!) x1 = latLng.latitude;
        if (latLng.latitude < x0) x0 = latLng.latitude;
        if (latLng.longitude > y1!) y1 = latLng.longitude;
        if (latLng.longitude < y0!) y0 = latLng.longitude;
      }
    }
    LatLngBounds bounds =
        LatLngBounds(northeast: LatLng(x1!, y1!), southwest: LatLng(x0!, y0!));
    CameraUpdate cameraUpdate = CameraUpdate.newLatLngBounds(bounds, 70);

    return checkCameraLocation(cameraUpdate, mapController);
  }

  Future<void> checkCameraLocation(
      CameraUpdate cameraUpdate, GoogleMapController mapController) async {
    mapController.animateCamera(cameraUpdate);
    LatLngBounds l1 = await mapController.getVisibleRegion();
    LatLngBounds l2 = await mapController.getVisibleRegion();

    if (l1.southwest.latitude == -90 || l2.southwest.latitude == -90) {
      return checkCameraLocation(cameraUpdate, mapController);
    }
  }

  @override
  Widget build(BuildContext context) {
    saleMenTimeLineProvider = Provider.of<SalemenTimeLineProvider>(context);
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      body: AppUtils.commonSlidePanel(
        body: Stack(
          children: [
            Positioned.fill(
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
                circles: circles,
                polylines: Set<Polyline>.of(polylines),
                initialCameraPosition: CameraPosition(
                  target: currentLocation,
                  zoom: 14,
                ),
              ),
            ),
            trackAppBarWidget(
              onTapGetCurrentPosition: getCurrentLocation,
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
                    isFromTimeLine: true,
                    width: width,
                    height: height,
                    backgroundColor: AppConstant.whiteColor,
                    title: widget.name,
                    leadingImage: widget.imageUrl,
                    actionWidget: [
                      GestureDetector(
                          onTap: () {
                            AppUtils.showDialogBoxWithTwoButton(
                              context: context,
                              titleText: "Call",
                              text:
                                  "Are you sure to call ${widget.name ?? ""}?",
                              onSuccessString: "Call",
                              onCancelString: "Cancel",
                              onSuccess: () {
                                AppUtils.launchToBrowser(
                                    Uri.parse("tel:${widget.phoneNumber}"));
                              },
                              onCancel: () {},
                            );
                          },
                          child: Icon(
                            Icons.call,
                            color: AppConstant.appPrimaryColor,
                          ))
                    ],
                    subTitle: saleMenTimeLineProvider.getTimeLineModel?.data
                        ?.fieldUserLastActivity?.lastActivityPlace,
                  ),
                  saleMenTimeLineProvider.isFetching ||
                          saleMenTimeLineProvider
                                  .getTimeLineModel?.data?.sessionTimeLine ==
                              null ||
                          (saleMenTimeLineProvider.getTimeLineModel?.data
                                      ?.sessionTimeLine?.length ??
                                  0) <=
                              0
                      ? informationBar(
                          totalCheckIn: 0,
                          totalDuration: "00:00:00",
                          totalKMTravel: "0.0")
                      : selectedIndex == 0
                          ? informationBar(
                              totalCheckIn: saleMenTimeLineProvider
                                  .getTimeLineModel?.data?.totalCheckIn,
                              totalDuration: saleMenTimeLineProvider
                                      .getTimeLineModel?.data?.totalDuration ??
                                  "",
                              totalKMTravel: saleMenTimeLineProvider
                                  .getTimeLineModel?.data?.totalKmTravel
                                  ?.toStringAsFixed(2))
                          : informationBar(
                              totalCheckIn: saleMenTimeLineProvider
                                  .getTimeLineModel?.data?.sessionTimeLine
                                  ?.firstWhere((element) =>
                                      element.sessionNo == selectedIndex)
                                  .totalCheckIn,
                              totalDuration: saleMenTimeLineProvider
                                      .getTimeLineModel?.data?.sessionTimeLine
                                      ?.firstWhere((element) =>
                                          element.sessionNo == selectedIndex)
                                      .totalDuration ??
                                  "",
                              totalKMTravel: saleMenTimeLineProvider
                                  .getTimeLineModel?.data?.sessionTimeLine
                                  ?.firstWhere((element) =>
                                      element.sessionNo == selectedIndex)
                                  .totalKmTravel
                                  ?.toStringAsFixed(2),
                            ),
                  saleMenTimeLineProvider.isFetching
                      ? LinearProgressIndicator(
                          color: AppConstant.appPrimaryColor,
                        )
                      : SizedBox(),
                  datePickerWidget(true),
                  saleMenTimeLineProvider.isFetching ||
                          saleMenTimeLineProvider
                                  .getTimeLineModel?.data?.sessionTimeLine ==
                              null ||
                          (saleMenTimeLineProvider.getTimeLineModel?.data
                                      ?.sessionTimeLine?.length ??
                                  0) <
                              0
                      ? const SizedBox()
                      : AppUtils.commonContainer(
                          height: 50,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      selectedIndex = 0;
                                      panelController.animatePanelToSnapPoint(
                                          duration:
                                              Duration(milliseconds: 300));
                                    });
                                    polylines.clear();
                                    drawPolyLines();
                                  },
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 300),
                                    padding: const EdgeInsets.only(
                                        left: 15, right: 15),
                                    margin: const EdgeInsets.only(
                                        left: 10, right: 10, bottom: 5),
                                    decoration: AppUtils.commonBoxDecoration(
                                      border: Border.all(
                                          color: AppConstant.appPrimaryColor),
                                      color: selectedIndex == 0
                                          ? AppConstant.appPrimaryColor
                                          : AppConstant.transparentColor,
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(6)),
                                    ),
                                    child: Center(
                                      child: AppUtils.commonTextWidget(
                                        text: "All Sessions",
                                        textColor: selectedIndex == 0
                                            ? AppConstant.whiteColor
                                            : AppConstant.appPrimaryColor,
                                      ),
                                    ),
                                  ),
                                ),
                                if ((saleMenTimeLineProvider.getTimeLineModel
                                            ?.data?.sessionTimeLine?.length ??
                                        0) >
                                    1) ...[
                                  ListView.builder(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemCount: saleMenTimeLineProvider
                                            .getTimeLineModel
                                            ?.data
                                            ?.sessionTimeLine
                                            ?.length ??
                                        0,
                                    scrollDirection: Axis.horizontal,
                                    itemBuilder: (context, index) {
                                      return GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            selectedIndex =
                                                saleMenTimeLineProvider
                                                        .getTimeLineModel
                                                        ?.data
                                                        ?.sessionTimeLine?[
                                                            index]
                                                        .sessionNo ??
                                                    0;

                                            panelController
                                                .animatePanelToSnapPoint(
                                                    duration: Duration(
                                                        milliseconds: 300));
                                          });
                                          polylines.clear();
                                          drawPolyLines();
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
                                                color: AppConstant
                                                    .appPrimaryColor),
                                            color: saleMenTimeLineProvider
                                                        .getTimeLineModel
                                                        ?.data
                                                        ?.sessionTimeLine?[
                                                            index]
                                                        .sessionNo ==
                                                    selectedIndex
                                                ? AppConstant.appPrimaryColor
                                                : AppConstant.transparentColor,
                                            borderRadius:
                                                const BorderRadius.all(
                                                    Radius.circular(6)),
                                          ),
                                          child: Center(
                                            child: AppUtils.commonTextWidget(
                                              text:
                                                  "Session ${saleMenTimeLineProvider.getTimeLineModel?.data?.sessionTimeLine?[index].sessionNo}",
                                              textColor: saleMenTimeLineProvider
                                                          .getTimeLineModel
                                                          ?.data
                                                          ?.sessionTimeLine?[
                                                              index]
                                                          .sessionNo ==
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
                              ],
                            ),
                          ),
                        ),
                  sessionTimeLineWidget(
                      scrollController: p0,
                      sessionList: selectedIndex == 0
                          ? saleMenTimeLineProvider.sessionEvents
                          : saleMenTimeLineProvider
                              .getTimeLineModel?.data?.sessionTimeLine
                              ?.firstWhere((element) =>
                                  element.sessionNo == selectedIndex)
                              .sessionEvents),
                ],
              ),
            ],
          );
        },
        // snapPoint: 0.01,
      ),
    );
  }

  Widget sessionTimeLineWidget({
    ScrollController? scrollController,
    List<SessionEvents>? sessionList,
  }) {
    return Expanded(
      child: saleMenTimeLineProvider.isFetching
          ? SizedBox()
          : saleMenTimeLineProvider.getTimeLineModel?.data?.sessionTimeLine ==
                      null ||
                  (saleMenTimeLineProvider.getTimeLineModel?.data
                              ?.sessionTimeLine?.length ??
                          0) <
                      0
              ? AppUtils.commonNoDataFound(
                  text: saleMenTimeLineProvider.getTimeLineModel?.message,
                  onPressed: () {
                    saleMenTimeLineProvider.apiCallGetTimeLine(
                        date: selectedDate.toString(), userid: widget.userId);
                  },
                )
              : ListView.builder(
                  itemCount: sessionList?.length,
                  physics: const BouncingScrollPhysics(),
                  controller: scrollController,
                  shrinkWrap: true,
                  padding: const EdgeInsets.only(bottom: 30),
                  itemBuilder: (context, index) {
                    return TimelineTile(
                      hasIndicator: true,
                      axis: TimelineAxis.vertical,
                      lineXY: 0.35,
                      isLast: index == (sessionList?.length ?? 0) - 1,
                      isFirst: index == sessionList?.length,
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
                                sessionList?[index].eventCode),
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
                                    date: sessionList?[index].eventStartDate ??
                                        "",
                                    format: "d MMM y"),
                                textColor: AppConstant.greyColor,
                                fontWeight: FontWeight.w400,
                                fontSize: 12),
                            AppUtils.commonTextWidget(
                                text: AppUtils.timeLineDate(
                                  date:
                                      sessionList?[index].eventStartDate ?? "",
                                ),
                                textColor: AppConstant.blackColor,
                                fontWeight: FontWeight.w400,
                                fontSize: 10),
                          ],
                        ),
                      ),
                      endChild: AppUtils.commonInkWell(
                        onTap: () {
                          panelController.animatePanelToSnapPoint(
                              duration: Duration(milliseconds: 300));
                          LatLng activityLatLong = LatLng(
                              sessionList?[index].eventLat ?? 0,
                              sessionList?[index].eventLong ?? 0);
                          updateCameraPosition(activityLatLong);
                          addTimeLineMarker(
                              eventId: sessionList?[index].eventId,
                              eventCode: sessionList?[index].eventCode,
                              eventName: sessionList?[index].eventName,
                              location: activityLatLong);
                        },
                        child: AppUtils.commonContainer(
                          padding: AppUtils.edgeInsetsOnly(top: 5),
                          margin: AppUtils.edgeInsetsOnly(
                              right: 10, bottom: 20, left: 30),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AppUtils.commonTextWidget(
                                  text: sessionList?[index].eventName ?? "",
                                  textColor: AppUtils.getStatusColor(
                                    sessionList?[index].eventCode ?? "",
                                  ),
                                  fontWeight: FontWeight.w400,
                                  fontSize: 12),
                              AppUtils.commonTextWidget(
                                  text:
                                      sessionList?[index].eventActivityPlace ??
                                          "",
                                  textColor: AppConstant.blackColor,
                                  fontWeight: FontWeight.w400,
                                  fontSize: 10),
                              AppUtils.commonSizedBox(height: 10),
                              sessionList?[index].eventName == "Check Out"
                                  ? AppUtils.commonElevatedBtn(
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (context) {
                                            return CustomNoteDialog(
                                                eventId: sessionList?[index]
                                                        .eventId ??
                                                    "");
                                          },
                                        );
                                      },
                                      bottomMargin: 0,
                                      topMargin: 0,
                                      text: "Notes",
                                      height: 40,
                                      textColor: AppConstant.whiteColor,
                                      bgColor: AppConstant.appPrimaryColor,
                                      fontSize: 12,
                                    )
                                  : AppUtils.commonSizedBox(),

                              // checkOutNoteWidget(sessionList),
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

  Widget checkOutNoteWidget(List<SessionEvents>? sessionList) {
    final checkOutSession =
        sessionList?.firstWhere((element) => element.eventName == "Check Out");

    if (checkOutSession != null) {
      return AppUtils.commonElevatedBtn(
        bottomMargin: 0,
        topMargin: 0,
        text: "Notes",
        height: 40,
        textColor: AppConstant.whiteColor,
        bgColor: AppConstant.appPrimaryColor,
        fontSize: 12,
      );
    } else {
      return AppUtils.commonSizedBox();
    }
  }

  Widget informationBar(
      {required String totalDuration,
      String? totalKMTravel,
      int? totalCheckIn}) {
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
              textData: AppUtils.removeMilliseconds(totalDuration),
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
      required String textData,
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
            text: textData,
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
                  selectedIndex = 0;
                });
                saleMenTimeLineProvider
                    .apiCallGetTimeLine(
                        date: selectedDate.toString(), userid: widget.userId)
                    .then((value) {
                  if (value?.isError == false &&
                      value?.isValidationFailed == false) {
                    polylines.clear();
                    drawPolyLines();
                    panelController.animatePanelToSnapPoint(
                        duration: Duration(milliseconds: 300));
                  } else {
                    markers.clear();
                    polylines.clear();
                  }
                });
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
                selectedIndex = 0;
              });
              saleMenTimeLineProvider
                  .apiCallGetTimeLine(
                      date: selectedDate.toString(), userid: widget.userId)
                  .then((value) {
                if (value?.isError == false &&
                    value?.isValidationFailed == false) {
                  polylines.clear();
                  drawPolyLines();
                  panelController.animatePanelToSnapPoint(
                      duration: Duration(milliseconds: 300));
                } else {
                  markers.clear();
                  polylines.clear();
                }
              });
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
      });
      saleMenTimeLineProvider
          .apiCallGetTimeLine(
              date: selectedDate.toString(), userid: widget.userId)
          .then((value) {
        if (value?.isError == false && value?.isValidationFailed == false) {
          polylines.clear();
          drawPolyLines();
          panelController.animatePanelToSnapPoint(
              duration: Duration(milliseconds: 300));
        } else {
          markers.clear();
          polylines.clear();
        }
      });
    }
  }
}
