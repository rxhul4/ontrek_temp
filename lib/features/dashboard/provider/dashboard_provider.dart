import 'dart:async';

import 'package:app_settings/app_settings.dart';
import 'package:flutter/cupertino.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ontrek/main.dart';
import 'package:permission_handler/permission_handler.dart';

class DashBoardProvider extends ChangeNotifier{
  bool _isFetching = false;
  bool _isLoading = false;
  bool _isUploading = false;
  bool _isAdding = false;

  bool get isFetching => _isFetching;

  bool get isLoading => _isLoading;

  bool get isUploading => _isUploading;

  bool get isAdding => _isAdding;

  LatLng? currentLocation;
  late final Completer<GoogleMapController> googleMapController = Completer();
  Set<Marker> markers = Set();
  int selectedIndex = 0;


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


  selectIndex(int index){
    selectedIndex = index;
    notifyListeners();
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


  Future<void> getCurrentLocation() async {

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low,
      );


        currentLocation = LatLng(position.latitude, position.longitude);
        print("${currentLocation}");
        if (currentLocation != null) {
          updateCameraPosition(currentLocation ?? LatLng(0, 0));
          addCurrentLocationMarker(currentLocation ?? LatLng(0, 0));
        }

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

  getLocationFromSheet({required Position position}){
    currentLocation = LatLng(position.latitude, position.longitude);
    notifyListeners();
  }



}