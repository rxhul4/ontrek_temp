import 'package:flutter/material.dart';
import 'package:ontrek/core/utils/App_utils.dart';

class AppConstant {

  static const String appVersionAndroid = "1.0.2" ;
  //tot tracking events
  static const String  dayStartEvent = "826c88aa-d18e-46f4-967b-4f973126765e" ;
  static const String  dayEndEvent = "a2864068-8305-472f-a3a9-16d9e1d0e2dd" ;
  static const String  checkInEvent = "52bc86a1-403d-4d08-9293-a8204c84de31";
  static const String  checkOutEvent = "8a2b4e10-c17f-4f07-ae9d-f290555e17ed" ;
  static const String  internetOffEvent = "09f33108-8188-49c9-a7a4-6e350fe31b87" ;
  static const String  internetOnEvent = "269dc119-c567-43e0-8330-f26dfc09bfda" ;
  static const String  gpsOffEvent = "63df0ae8-76fd-44cb-8537-2edfc24dcebd" ;
  static const String  gpsOnEvent = "c6b715b5-646e-4536-8d15-6be4e5531471" ;
  static const String  trackingWaitingStartEvent = "9138f7f0-22c6-45b3-86f0-c2315f4eb502" ;
  static const String  trackingWaitingStopEvent = "714a0fbe-5485-4207-a147-b626738a5f2c" ;

  //totString
  static const String  visitTypeCode = "visit_type";
  static const String  taskStatusCode = "task_status";
  static const String  leadTypeCode = "lead_source" ;


  // error Message
  static const String  errorText = "Something went wrong!" ;
  // date format
  static const String dateFormat= "yyyy-MM-dd'T'HH:mm:ss";

  //app colors constant
  static Color appPrimaryColor = Color.fromRGBO(27, 27, 27, 1);
  static Color whiteColor = Colors.white;
  static Color blackColor = Colors.black;
  static Color greyColor = Colors.grey;
  static Color primaryColor = const Color.fromRGBO(255, 185, 51, 1);
  static Color btnColor = const Color.fromRGBO(26,83,92, 1);
  static Color textFieldBgColor = const Color.fromRGBO(244,248,249, 1);
  static const Color greyWithShade = Color.fromRGBO(245, 246, 250, 1);


  static Color transparentColor = const Color(0x00000000);



}