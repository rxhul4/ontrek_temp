import 'dart:async';
import 'dart:ui' as ui;
import 'dart:typed_data';



import 'package:app_settings/app_settings.dart';
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
import 'package:ontrek/core/utils/App_utils.dart';
import 'package:ontrek/core/utils/image_path.dart';

import 'package:ontrek/features/attendance/model/get_last_activity_model.dart';
import 'package:ontrek/main.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'package:widget_to_marker/widget_to_marker.dart';


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
  GoogleMapController? googleMapController;
  Set<Marker> markers = Set();
  int selectedIndex = 0;
  ValueNotifier<bool> isDayStart = ValueNotifier(false);
  ValueNotifier<bool> isCheckIn = ValueNotifier(false);
  ValueNotifier<bool> isDayEnd = ValueNotifier(false);
  ValueNotifier<bool> isWaiting = ValueNotifier(false);
  GetLastActivityModel? getLastActivityModel;
  FlutterBackgroundService service = FlutterBackgroundService();


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

  initialIndex(){
    selectedIndex = 0;
    notifyListeners();
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
          await updateCameraPosition(currentLocation ?? LatLng(0, 0));
          await addCurrentLocationMarker(currentLocation ?? LatLng(0, 0));
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
    try{
    googleMapController?.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(
          target: location,
          zoom: 14,
        ),
      ));
    notifyListeners();
    }catch(e){
      print("Error_in_updateCamara$e");
    }

  }

  Future<BitmapDescriptor> _getCustomMarkerIcon() async {
    final Uint8List markerIcon = await getBytesFromNetwork('https://images.pexels.com/photos/774909/pexels-photo-774909.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1');
    return BitmapDescriptor.fromBytes(markerIcon);
  }
  Future<Uint8List> getBytesFromNetwork(String url) async {
    final response = await http.get(Uri.parse(url));
    final bytes = response.bodyBytes;
    return bytes;
  }






  Future addCurrentLocationMarker(LatLng location) async{
    try{
      final Uint8List markerIcon = await AppUtils.getBytesFromAsset(locationMarker, 130);
      markers.clear(); // Clear previous markers
      await  markers.add(
        Marker(
          markerId: MarkerId("currentLocation"),
          position: location,

          infoWindow: InfoWindow(title: "Current Location"),
          icon: await CustomMarkerWidget().toBitmapDescriptor(logicalSize: Size(150, 150),imageSize: Size(300, 300)),
        ),
      );
      notifyListeners();
    }catch(e){
      print("Error_in_marker$e");
    }

  }



  getLocationFromSheet({required Position position}){
    currentLocation = LatLng(position.latitude, position.longitude);
    notifyListeners();
  }


}