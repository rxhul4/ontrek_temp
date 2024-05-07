import 'dart:async';
import 'dart:math';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'dart:ui';

import 'package:app_settings/app_settings.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

import 'package:flutter/widgets.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ontrek/core/common_widgets/marker_widget.dart';
import 'package:ontrek/features/attendance/model/get_last_activity_model.dart';
import 'package:ontrek/main.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
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
      print("LatLong${currentLocation}");
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

  // Future<Uint8List> loadNetworkImage(path) async {
  //   final completed = Completer<ImageInfo>();
  //   var image = NetworkImage(path);
  //   image.resolve(const ImageConfiguration()).addListener(
  //       ImageStreamListener((info, _) => completed.complete(info)));
  //   final imageInfo = await completed.future;
  //   final byteData =
  //       await imageInfo.image.toByteData(format: ui.ImageByteFormat.png);
  //   if (byteData?.buffer.asUint8List() != null) {
  //     return byteData!.buffer.asUint8List();
  //   }
  //   return byteData!.buffer.asUint8List();
  // }

  // Future<Uint8List> loadNetworkImage(String path, {double size = 130}) async {
  //   final completed = Completer<ImageInfo>();
  //   var image = NetworkImage(path);
  //   image.resolve(const ImageConfiguration()).addListener(
  //     ImageStreamListener((info, _) => completed.complete(info)),
  //   );
  //   final imageInfo = await completed.future;
  //   final byteData = await imageInfo.image.toByteData(format: ui.ImageByteFormat.png);
  //   if (byteData?.buffer.asUint8List() != null) {
  //     final resizedImage = await _resizeAndRoundImage(byteData!.buffer.asUint8List(), size);
  //     return resizedImage;
  //   }
  //   throw Exception("Failed to load image");
  // }
  //
  // Future<Uint8List> _resizeAndRoundImage(Uint8List imageData, double size) async {
  //   final Completer<Uint8List> completer = Completer();
  //   final Codec imageCodec = await instantiateImageCodec(imageData);
  //   final FrameInfo frameInfo = await imageCodec.getNextFrame();
  //   final ui.Image image = frameInfo.image;
  //
  //   final resizedImage = await _resizeImage(image, size);
  //   final roundedImage = await _roundImage(resizedImage,Colors.grey,1);
  //
  //   final ByteData? byteData = await roundedImage.toByteData(format: ui.ImageByteFormat.png);
  //   completer.complete(byteData!.buffer.asUint8List());
  //   return completer.future;
  // }
  //
  // Future<ui.Image> _resizeImage(ui.Image image, double size) {
  //   final Completer<ui.Image> completer = Completer();
  //   final Size newSize = Size(size, size);
  //   final Size imageSize = Size(image.width.toDouble(), image.height.toDouble());
  //   final FittedSizes fittedSizes = applyBoxFit(BoxFit.cover, imageSize, newSize);
  //   final Rect viewportRect = Alignment.center.inscribe(fittedSizes.destination, Offset.zero & newSize);
  //
  //   final PictureRecorder recorder = PictureRecorder();
  //   final Canvas canvas = Canvas(recorder, viewportRect);
  //   canvas.drawImageRect(image, Offset.zero & imageSize, viewportRect, Paint());
  //   final Picture picture = recorder.endRecording();
  //   picture.toImage(newSize.width.toInt(), newSize.height.toInt()).then((ui.Image image) {
  //     completer.complete(image);
  //   });
  //   return completer.future;
  // }
  // Future<ui.Image> _roundImage(ui.Image image, Color borderColor, double borderWidth) {
  //   final Completer<ui.Image> completer = Completer();
  //   final Size size = Size(image.width.toDouble(), image.height.toDouble());
  //
  //   final PictureRecorder recorder = PictureRecorder();
  //   final Canvas canvas = Canvas(recorder);
  //
  //   // Draw border
  //   final Paint borderPaint = Paint()
  //     ..isAntiAlias = true
  //     ..color = borderColor
  //     ..strokeWidth = borderWidth
  //     ..style = PaintingStyle.stroke;
  //   final Rect borderRect = Rect.fromLTWH(0, 0, size.width, size.height);
  //   canvas.drawOval(borderRect, borderPaint);
  //
  //   final Paint paint = Paint()
  //     ..isAntiAlias = true
  //     ..color = Colors.transparent;
  //   canvas.drawCircle(size.center(Offset.zero), size.shortestSide / 2.0, paint);
  //
  //   final Path clipPath = Path()
  //     ..addOval(Rect.fromCircle(center: size.center(Offset.zero), radius: size.shortestSide / 2.0));
  //   canvas.clipPath(clipPath);
  //
  //   canvas.drawImage(image, Offset.zero, Paint());
  //   final Picture picture = recorder.endRecording();
  //
  //   picture.toImage(size.width.toInt(), size.height.toInt()).then((ui.Image image) {
  //     completer.complete(image);
  //   });
  //   return completer.future;
  // }

  Future addCurrentLocationMarker(LatLng location) async {
    try {
      // Uint8List markerWithImage = await loadNetworkImage(
      //     "https://images.unsplash.com/photo-1494790108377-be9c29b29330?q=80&w=1974&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D");
      markers.clear(); // Clear previous markers

      await markers.add(
        Marker(
          markerId: MarkerId("currentLocation"),
          position: location,
          infoWindow: InfoWindow(title: "Current Location"),
          icon: await CustomMarkerWidget(
            imageUrl: "https://images.unsplash.com/photo-1494790108377-be9c29b29330?q=80&w=1974&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
          ).toBitmapDescriptor(
              logicalSize: Size(150, 150),
              imageSize: Size(300, 300),
              waitToRender: Duration(milliseconds: 500)),
        ),
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

  double? sourceLat;
  double? sourceLong;
  double? destinationLat;
  double? destinationLong;

  Future addUsersMarker() async {
    markers.clear();
    print("showDashBoardUser$showUserInMap");

    for (var element in showUserInMap) {
      userId = element["userId"];
      userName = element["userName"];
      userProfilePic = element["userProfilePic"];
      userLat = element["userLastLat"];
      userLong = element["userLastLong"];
      print("userId=======$userId");

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
                    waitToRender: Duration(milliseconds: 300),
                  )
                : BitmapDescriptor.defaultMarker,
          ),
        );
        print("marker$markers");
      } catch (e) {
        print("Error_in_marker$e");
      }
    }

    sourceLat = showUserInMap.first["userLastLat"];
    sourceLong = showUserInMap.first["userLastLong"];
    destinationLat = showUserInMap.last["userLastLat"];
    destinationLong = showUserInMap.last["userLastLong"];
    print("source${LatLng(sourceLat ?? 0, sourceLong ?? 0)}");
    print("destination${LatLng(destinationLat ?? 0, destinationLong ?? 0)}");
    updateCameraLocation(LatLng(sourceLat ?? 0, sourceLong ?? 0),
        LatLng(destinationLat ?? 0, destinationLong ?? 0));
    notifyListeners();
  }

  Future<void> updateCameraLocation(
    LatLng source,
    LatLng destination,
  ) async {
    if (googleMapController == null) return;

    LatLngBounds bounds;

    if (source.latitude > destination.latitude &&
        source.longitude > destination.longitude) {
      bounds = LatLngBounds(southwest: destination, northeast: source);
    } else if (source.longitude > destination.longitude) {
      bounds = LatLngBounds(
          southwest: LatLng(source.latitude, destination.longitude),
          northeast: LatLng(destination.latitude, source.longitude));
    } else if (source.latitude > destination.latitude) {
      bounds = LatLngBounds(
          southwest: LatLng(destination.latitude, source.longitude),
          northeast: LatLng(source.latitude, destination.longitude));
    } else {
      bounds = LatLngBounds(southwest: source, northeast: destination);
    }

    CameraUpdate cameraUpdate = CameraUpdate.newLatLngBounds(bounds, 70);

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
