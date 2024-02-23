import 'package:flutter/material.dart';
import 'package:ontrek/core/utils/App_utils.dart';

class AppConstant {


  //tot tracking events
  static const String  dayStartEvent = "tracking_event_day_start" ;
  static const String  dayEndEvent = "tracking_event_day_end" ;
  static const String  checkInEvent = "tracking_event_check_in" ;
  static const String  checkOutEvent = "tracking_event_check_out" ;
  static const String  internetOffEvent = "tracking_event_internet_off" ;
  static const String  internetOnEvent = "tracking_internet_on" ;
  static const String  gpsOffEvent = "tracking_event_gps_off" ;
  static const String  gpsOnEvent = "tracking_event_gps_on" ;
  static const String  trackingWaitingStartEvent = "tracking_event_waiting_start" ;
  static const String  trackingWaitingStopEvent = "tracking_event_waiting_end" ;


  // date format
  static const String dateFormat= "yyyy-MM-dd'T'HH:mm:ss";

  // api method constant

  static String appLevelAuthKey = "abcd123xyz";


  //app colors constant
  static Color appPrimaryColor = Color.fromRGBO(27, 78, 137, 1);
  static Color whiteColor = Colors.white;
  static Color blackColor = Colors.black;
  static Color greyColor = Colors.grey;
  static Color primaryColor = const Color.fromRGBO(255, 185, 51, 1);
  static Color btnColor = const Color.fromRGBO(26,83,92, 1);
  static Color textFieldBgColor = const Color.fromRGBO(244,248,249, 1);
  static const Color greyWithShade = Color.fromRGBO(245, 246, 250, 1);


  static Color transparentColor = const Color(0x00000000);



}