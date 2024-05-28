import 'dart:async';

import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

import 'package:flutter/widgets.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ontrek/core/common_widgets/marker_widget.dart';
import 'package:ontrek/core/storage/preference_helper.dart';
import 'package:ontrek/core/utils/App_utils.dart';
import 'package:ontrek/features/attendance/model/get_last_activity_model.dart';
import 'package:ontrek/main.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:widget_to_marker/widget_to_marker.dart';

class DashBoardProvider extends ChangeNotifier {
  bool _isFetching = false;
  bool _isLoading = false;
  bool _isUploading = false;
  bool _isAdding = false;

  bool get isFetching => _isFetching;

  bool get isLoading => _isLoading;

  bool get isUploading => _isUploading;

  bool get isAdding => _isAdding;

  LatLng? currentLocation;
  GoogleMapController? googleMapController;
  Set<Marker> markers = Set();
  int selectedIndex = 0;
  ValueNotifier<bool> isDayStart = ValueNotifier(false);
  ValueNotifier<bool> isCheckIn = ValueNotifier(false);
  ValueNotifier<bool> isDayEnd = ValueNotifier(false);
  ValueNotifier<bool> isWaiting = ValueNotifier(false);
  GetLastActivityModel? getLastActivityModel;
  FlutterBackgroundService service = FlutterBackgroundService();
  List<Map<String, dynamic>> showUserInMap = [];
  bool isMapLoaded = false;

  loaderFnc(bool isLoading) {
    _isLoading = isLoading;
    notifyListeners();
  }

  fetchingFnc(bool isLoading) {
    _isFetching = isLoading;
    notifyListeners();
  }

  void navigatePushReplacementFnc(Widget screen) {
    navigatorKey.currentState!.pushReplacement(CupertinoPageRoute(
      builder: (context) => screen,
    ));
  }

  void navigatePushFnc(Widget screen) {
    navigatorKey.currentState!.push(CupertinoPageRoute(
      builder: (context) => screen,
    ));
  }

  initialIndex() {
    selectedIndex = 0;
    notifyListeners();
  }

  selectIndex(int index) {
    selectedIndex = index;
    markers.clear();
    notifyListeners();
  }

  Future checkPermission(BuildContext context) async {
    final status = await Permission.location.status;
    final status2 = await Permission.locationAlways.status;
    if (status.isDenied) {
      await Permission.location.request();
    } else if (status.isPermanentlyDenied) {
      AppUtils.showDialogBoxWithOneButton(
          titleText: "Location",
          text: "Please enable your location service.",
          context: context);
    } else {
      // Location permission is granted
      if (status2.isDenied) {
        await Permission.locationAlways.request();
      } else if (status2.isPermanentlyDenied) {
        AppUtils.showDialogBoxWithOneButton(
            titleText: "Location",
            text: "Please enable your always on location service.",
            context: context);
      } else {
        await getCurrentLocation();
      }
    }
  }


  Future<void> getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low,
      );
      currentLocation = LatLng(position.latitude, position.longitude);
      print("LatLong${currentLocation}");
      if (currentLocation != null) {
        await updateCameraPosition(currentLocation ?? LatLng(0, 0));
        await addCurrentLocationMarker(currentLocation ?? LatLng(0, 0));
        markers.clear();
        Future.delayed(
          Duration(milliseconds: 100),
          () async {
            await addCurrentLocationMarker(currentLocation ?? LatLng(0, 0));
          },
        );
      }
      notifyListeners();
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
    try {
      googleMapController?.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(
          target: location,
          zoom: 14,
        ),
      ));
      notifyListeners();
    } catch (e) {
      print("Error_in_updateCamara$e");
    }
  }

  Future addCurrentLocationMarker(LatLng location) async {
    try {
      String? imgUrl = PreferenceHelper.getString(PreferenceHelper.PROFILE_PIC);
      await markers.add(
        Marker(
          markerId: MarkerId("currentLocation"),
          position: location,
          infoWindow: InfoWindow(title: "Current Location"),
          icon: await CustomMarkerWidget(
            imageUrl: imgUrl,
          ).toBitmapDescriptor(
            logicalSize: Size(150, 150),
            imageSize: Size(300, 300),
          ),
        ),
      );
      Future.delayed(
        Duration(milliseconds: 100),
        () async {
          markers.clear();
          await markers.add(
            Marker(
              markerId: MarkerId("currentLocation"),
              position: location,
              infoWindow: InfoWindow(title: "Current Location"),
              icon: await CustomMarkerWidget(
                imageUrl: imgUrl,
              ).toBitmapDescriptor(
                logicalSize: Size(150, 150),
                imageSize: Size(300, 300),
              ),
            ),
          );
          notifyListeners();
          print("ceckkkkkkkkkk");
        },
      );
    } catch (e) {
      print("Error_in_marker$e");
    }
    notifyListeners();
  }

  String? userId;
  String? userName;
  double? userLat;
  double? userLong;
  String? userProfilePic;
  List<LatLng> userLatLng = [];

  Future addUsersMarker() async {
    print("showDashBoardUser$showUserInMap");

    for (var element in showUserInMap) {
      userId = element["userId"];
      userName = element["userName"];
      userProfilePic = element["userProfilePic"];
      userLat = element["userLastLat"];
      userLong = element["userLastLong"];
      userLatLng.add(LatLng(userLat ?? 0, userLong ?? 0));
      try {
        await markers.add(
          Marker(
            markerId: MarkerId("$userId"),
            position: LatLng(userLat ?? 0, userLong ?? 0),
            infoWindow: InfoWindow(
              title: userName ?? "",
            ),
            icon: (userProfilePic != null)
                ? await CustomMarkerWidget(
                    imageUrl: userProfilePic,
                  ).toBitmapDescriptor(
                    logicalSize: Size(150, 150),
                    imageSize: Size(300, 300),
                  )
                : BitmapDescriptor.defaultMarker,
          ),
        );
        print("marker$markers");
      } catch (e) {
        print("Error_in_marker$e");
      }
    }

    boundsFromLatLngList(userLatLng);
    notifyListeners();
  }

  Future<void> boundsFromLatLngList(List<LatLng> list) {
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
    CameraUpdate cameraUpdate = CameraUpdate.newLatLngBounds(bounds, 100);

    return checkCameraLocation(cameraUpdate, googleMapController!);
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

  getLocationFromSheet({LatLng? getCurrentLocation}) {
    currentLocation = getCurrentLocation ?? LatLng(0, 0);
    print("currentLocation$currentLocation");
    if (currentLocation != null) {
      addCurrentLocationMarker(currentLocation ?? LatLng(0, 0));
      updateCameraPosition(currentLocation ?? LatLng(0, 0));
    }
    notifyListeners();
  }
}
