import 'package:battery_plus/battery_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:ontrek/core/common_widgets/loader_widget.dart';
import 'package:ontrek/core/storage/preference_helper.dart';
import 'package:ontrek/core/utils/app_constant.dart';
import 'package:ontrek/core/utils/App_utils.dart';
import 'package:local_auth/local_auth.dart';
import 'package:ontrek/core/utils/image_path.dart';
import 'package:ontrek/features/attendance/model/add_activity_model.dart';
import 'package:ontrek/features/attendance/provider/attendance_provider.dart';

import 'package:ontrek/features/check_out/screen/check_out_form_screen.dart';
import 'package:provider/provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class AttendanceScreen extends StatefulWidget {
  double? height;
  Function(Position)? onLocationFetch;

  AttendanceScreen({super.key, this.height, this.onLocationFetch});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen>
    with SingleTickerProviderStateMixin {
  AnimationController? controller;
  LocalAuthentication localAuthentication = LocalAuthentication();
  bool isBiometricAvailable = false;
  String? userId;
  ValueNotifier<bool> isDayStart = ValueNotifier(false);
  ValueNotifier<bool> isCheckIn = ValueNotifier(false);
  ValueNotifier<bool> isDayEnd = ValueNotifier(false);
  bool? isWaiting;
  bool isTapped = false;
  bool isFromLogOutButton = false;
  bool isLoading = false;
  Position? position;
  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  AndroidDeviceInfo? androidInfo;
  var battery = Battery();
  int? batteryLevel;
  CreateActivityModel? createActivityModel;
  FlutterBackgroundService service = FlutterBackgroundService();

  @override
  void initState() {
    // TODO: implement initState
    initAnimateController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {}
      panelController.animatePanelToPosition(0.99,
          duration: Duration(milliseconds: 500), curve: Curves.linear);
    });
    checkBiometricAvailable();
    isDayStart.value = PreferenceHelper.getBool(PreferenceHelper.DayStart);
    isCheckIn.value = PreferenceHelper.getBool(PreferenceHelper.checkIn);
    userId = PreferenceHelper.getString(PreferenceHelper.USER_UID);
    print("userUid====${userId}");
    deviceInfo.androidInfo.then((value) {
      androidInfo = value;
    });
    battery.batteryLevel.then((value) {
      batteryLevel = value;
      print("battery_level${batteryLevel}");
    });
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose

    controller?.dispose();
    super.dispose();
  }

  initAnimateController() {
    controller =
        AnimationController(vsync: this, duration: Duration(seconds: 2));
    controller?.addListener(() {
      if (!mounted) {}
      setState(() {});
    });
  }

  checkBiometricAvailable() async {
    isBiometricAvailable = await localAuthentication.canCheckBiometrics;
    if (kDebugMode) {
      print("isBiometricAvailable-$isBiometricAvailable");
    }
  }

  callAddActivityApi(
      {required AttendanceProvider postMdl,
      dynamic position,
      String? totEventCode,
      bool? isFromCheckIn = false,
      bool? isFromLogOutBtn = false}) {
    print("userUid${userId}");
    postMdl
        .apiCallCreateActivity(
      userId: userId,
      totTrackingEventCode: totEventCode,
      isFromCheckOut: false,
      batteryLevel: batteryLevel,
      latitude: position.latitude,
      longitude: position.longitude,
    )
        .then((value) {
      createActivityModel = value;

      if (createActivityModel?.isError == false &&
          createActivityModel?.isValidationFailed == false) {
        PreferenceHelper.setDouble(
            PreferenceHelper.LAST_LAT, position.latitude ?? 0);
        PreferenceHelper.setDouble(
            PreferenceHelper.LAST_LONG, position.longitude ?? 0);
        PreferenceHelper.setString(
            PreferenceHelper.WAITING_START_TIME, DateTime.now().toString());
        if (isFromLogOutBtn ?? false) {
          callLogOutFunction(position);
        } else {
          isFromCheckIn ?? false
              ? callCheckInFunction(position)
              : callLoginFunction(position);
          if (isFromCheckIn ?? false) {
            callCheckInFunction(position);
          } else {
            print("day start 200");
            // PreferenceHelper.setInt(PreferenceHelper.DAY_START_DAY_END_ID,
            //     addDayStartDayEndModel?.data?.dayStartDayEndId ?? 0);
            // PreferenceHelper.setString(
            //     PreferenceHelper.LAST_ADD_ROUTE_DATETIME, DateTime.now().toString());
            // PreferenceHelper.setString(
            //     PreferenceHelper.LAST_DAY_START_DATETIME,
            //     AppUtils.dateFormat(
            //         dateFormat: "yyyy-MM-dd 23:59:59", date: DateTime.now()));

            callLoginFunction(position);
          }
        }
      } else {
        print("day start not 200");
        openDialogFnc(createActivityModel?.message.toString() ?? "");
      }
    });
  }

  PanelController panelController = PanelController();

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    final postMdl = Provider.of<AttendanceProvider>(context);
    return AppUtils.commonSlidePanel(
        maxHeight: height * 0.4,
        minHeight: height * 0.09,
        controller: panelController,
        isDraggable: true,
        // snapPoint: 0.01,
        panel: Stack(
          children: [
            Container(
              padding: EdgeInsets.only(top: height * 0.2 / 2),
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ValueListenableBuilder(
                    valueListenable: isDayEnd,
                    builder: (context, value, child) {
                      return Center(
                        child: !isDayEnd.value
                            ? buttonWidget(postMdl, height, width)
                            : logOut(postMdl, height, width),
                      );
                    },
                  ),
                  // buttonWidget(height,width,postMdl),
                  SizedBox(
                    height: 15,
                  ),
                  !isDayStart.value
                      ? AppUtils.commonTextWidget(
                          text: "Press & Hold",
                          fontSize: 14,
                          letterSpacing: 0.2,
                          fontWeight: FontWeight.w600,
                          textColor: AppConstant.blackColor,
                        )
                      : GestureDetector(
                          onTap: () {
                            setState(() {
                              isDayEnd.value =
                                  !isDayEnd.value; // Toggle the value
                            });
                          },
                          child: AppUtils.commonTextWidget(
                            text: isDayEnd.value ? "Show Hide" : "Show Off",
                            fontSize: 14,
                            letterSpacing: 0.2,
                            fontWeight: FontWeight.w600,
                            textColor: isDayEnd.value
                                ? AppConstant.appPrimaryColor
                                : Colors.red,
                          )),
                ],
              ),
            ),
            AppUtils.buildHeader(
                height: height,
                width: width,
                title: "Vatsal",
                subTitle: "Epistic interiour Pvt Ltd",
                leadingImage: profileImage,
                borderColor: Colors.red,
                iconColor: AppConstant.appPrimaryColor,
                backgroundColor: Colors.white),
          ],
        ));
    // return Animate(
    //   effects: const  [
    //     SlideEffect(
    //         end: Offset(0, 0),
    //         curve: Curves.decelerate,
    //         begin: Offset(0, 1),
    //         duration: Duration(milliseconds: 600)),
    //   ],
    //   child: Container(
    //     decoration: AppUtils.commonBoxDecoration(
    //       boxShadow: [
    //         BoxShadow(
    //           color: Colors.black.withOpacity(0.15),
    //           spreadRadius: 0,
    //           blurRadius: 8,
    //
    //           offset: Offset(0, -10), // This will create a top shadow
    //         ),
    //       ],
    //       borderRadius: AppUtils.borderRadiousonly(topright: 18, topleft: 18),
    //       color: AppConstant.whiteColor,
    //     ),
    //     child: SingleChildScrollView(
    //       controller: widget.scrollController,
    //       physics: NeverScrollableScrollPhysics() ,
    //
    //
    //       child: Column(
    //         mainAxisAlignment: MainAxisAlignment.spaceAround,
    //
    //         children: [
    //           AppUtils.commonContainer(
    //             decoration: AppUtils.commonBoxDecoration(
    //               border: Border(
    //                 bottom: BorderSide(
    //                   width: 1,
    //                   color: AppConstant.greyColor.withOpacity(0.3),
    //                 ),
    //               ),
    //               borderRadius:
    //               AppUtils.borderRadiousonly(topleft: 18, topright: 18),
    //               color: Colors.white,
    //             ),
    //             child: Padding(
    //               padding:
    //               const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
    //               child: Column(
    //                 children: [
    //                   AppUtils.commonContainer(
    //                     width: 30,
    //                     height: 5,
    //                     decoration: AppUtils.commonBoxDecoration(
    //                         color: AppConstant.greyColor.withOpacity(0.3),
    //                         borderRadius:
    //                         AppUtils.borderRadiusAll(raduis: 12)),
    //                   ),
    //                   Row(
    //                     children: [
    //                       AppUtils.commonContainer(
    //                         height: 45,
    //                         width: 45,
    //                         decoration: AppUtils.commonBoxDecoration(
    //                           shape: BoxShape.circle,
    //                           color: AppConstant.greyColor,
    //                           border: Border.all(color: Colors.red, width: 1.2),
    //                         ),
    //                       ),
    //                       AppUtils.commonSizedBox(width: 10),
    //                       Column(
    //                         crossAxisAlignment: CrossAxisAlignment.start,
    //                         children: [
    //                           AppUtils.commonTextWidget(
    //                             text: "Vatsal",
    //                             fontWeight: FontWeight.w600,
    //                             textColor: AppConstant.blackColor,
    //                             letterSpacing: 0.2,
    //                             fontSize: 15,
    //                           ),
    //                           AppUtils.commonTextWidget(
    //                             text: "Epistic interiour Pvt Ltd",
    //                             fontWeight: FontWeight.w500,
    //                             textColor: AppConstant.blackColor.withOpacity(0.7),
    //                             letterSpacing: 0.1,
    //                             fontSize: 13,
    //                           ),
    //                         ],
    //                       )
    //                     ],
    //                   ),
    //                 ],
    //               ),
    //             ),
    //           ),
    //           // SizedBox(height: 50),
    //           // Added vertical spacing
    //
    //           Container(
    //             margin: AppUtils.edgeInsetsOnly(top: 50,bottom: 10),
    //
    //             child: Column(
    //               children: [
    //                 ValueListenableBuilder(
    //                   valueListenable: isDayEnd,
    //                   builder: (context, value, child) {
    //                     return Center(
    //                       child:  !isDayEnd.value ? buttonWidget(postMdl) : logOut(postMdl) ,
    //                     );
    //                   },
    //                 ),
    //                 AppUtils.commonSizedBox(height: 20),
    //                 !isDayStart.value
    //                     ? Visibility(
    //                   visible: !isTapped,
    //                   child: AppUtils.commonTextWidget(
    //                     text: "Press & Hold",
    //                     fontSize: 14,
    //                     letterSpacing: 0.2,
    //                     fontWeight: FontWeight.w600,
    //                     textColor: AppConstant.blackColor,
    //                   ),
    //                 )
    //                     : GestureDetector(
    //                     onTap: () {
    //                       setState(() {
    //                         isDayEnd.value = !isDayEnd.value; // Toggle the value
    //                       });
    //
    //                     },
    //                     child: Visibility(
    //                       visible: !isFromLogOutButton,
    //                       child: AppUtils.commonTextWidget(
    //                         text:  isDayEnd.value ? "Show Hide" : "Show Off",
    //                         fontSize: 14,
    //                         letterSpacing: 0.2,
    //                         fontWeight: FontWeight.w600,
    //                         textColor:isDayEnd.value ? AppConstant.appPrimaryColor : Colors.red ,
    //                       ),
    //                     )),
    //               ],
    //             ),
    //           ),
    //
    //           // Added vertical spacing
    //
    //
    //         ],
    //       ),
    //     ),
    //   ),
    // );
  }

  Future getCurrentLocation() async {
    bool isLocationServiceAvailable =
        await AppUtils.checkLocationServiceAvailability();

    if (isLocationServiceAvailable) {
      try {
        Position position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.medium);
        return position;
      } catch (e) {
        print("Catch at DayStart${e}");
        openDialogFnc("Please Enable Your Location Service");
      }
    }
  }

  Future loginFunction() async {
    try {
      service.startService();
      PreferenceHelper.setBool(PreferenceHelper.DayStart, true);
      isDayStart.value = PreferenceHelper.getBool(PreferenceHelper.DayStart);
    } catch (e) {
      print("loginFunction_is_in_catch");
    }
  }

  Future<void> checkInFunction() async {
    try {

      PreferenceHelper.setBool(PreferenceHelper.checkIn, true);
      isCheckIn.value = PreferenceHelper.getBool(PreferenceHelper.checkIn);
    } catch (e) {
      print("Error: $e");
    }
  }

  // Future checkInFunction() async {
  //   // bool isLocationServiceAvailable =
  //   // await AppUtils.checkLocationServiceAvailability();
  //   try{
  //
  //       service.invoke("stopService");
  //       // PreferenceHelper.setBool(PreferenceHelper.ISWAITING, false);
  //       PreferenceHelper.setBool(PreferenceHelper.checkIn, true);
  //       isCheckIn.value = PreferenceHelper.getBool(PreferenceHelper.checkIn);
  //       await service.startService();
  //
  //
  //
  //
  //
  //   }catch(e){
  //     print("try_again_later");
  //   }
  //
  //
  //   // if (isLocationServiceAvailable) {
  //   //   try {
  //   //     Position position = await Geolocator.getCurrentPosition(
  //   //         desiredAccuracy: LocationAccuracy.medium);
  //   //     return position;
  //   //   } catch (e) {
  //   //     print("Catch at DayStart${e}");
  //   //   }
  //   // }
  // }

  Future checkOutFunction() async {
    bool isLocationServiceAvailable =
        await AppUtils.checkLocationServiceAvailability();

    if (isLocationServiceAvailable) {
      try {
        Navigator.push(
            context,
            CupertinoPageRoute(
              builder: (context) => CheckOutFormScreen(),
            )).then((value1) {
          isCheckIn.value = PreferenceHelper.getBool(PreferenceHelper.checkIn);
          getCurrentLocation().then((value) {
            if (widget.onLocationFetch != null) {
              widget.onLocationFetch!(value);
            }
          });
        });
        return position;
      } catch (e) {
        print("Catch at DayStart${e}");
      }
    }
    return position;
  }

  Future logOutFunction() async {
    try {
      // bool isLocationServiceAvailable =
      // await AppUtils.checkLocationServiceAvailability();
      service.invoke("stopService");
      PreferenceHelper.setBool(PreferenceHelper.checkIn, false);
      PreferenceHelper.setBool(PreferenceHelper.DayStart, false);
      isDayStart.value = PreferenceHelper.getBool(PreferenceHelper.DayStart);
      isCheckIn.value = PreferenceHelper.getBool(PreferenceHelper.checkIn);
      isDayEnd.value = false;
    } catch (e) {
      print("catch at dayEnd ${e}");
    }
  }

  Widget buttonWidget(AttendanceProvider postMdl, height, width) {
    return ValueListenableBuilder(
      valueListenable: isDayStart,
      builder: (context, value, child) {
        return ValueListenableBuilder(
          valueListenable: isCheckIn,
          builder: (context, value, child) {
            return GestureDetector(
              onTapDown: (details) {
                setState(() {
                  isTapped = true;
                });
                controller?.forward().whenComplete(() async {
                  HapticFeedback.vibrate();

                  controller?.reset();
                  if (!isDayStart.value) {
                    doLocalVerification(
                      afterSuccessfulVerificationFnc: () {
                        // loginFunction();
                        getCurrentLocation().then((value) {
                          callAddActivityApi(
                              postMdl: postMdl,
                              position: value,
                              totEventCode: AppConstant.dayStartEvent,
                              isFromCheckIn: false);
                        });
                      },
                    );
                  } else if (!isCheckIn.value) {
                    doLocalVerification(
                      afterSuccessfulVerificationFnc: () async{

                        getCurrentLocation().then((value1) {
                          PreferenceHelper.reload().then((value){
                            Future.delayed(Duration(seconds: 1));
                            print("${value?.getBool(PreferenceHelper.ISWAITING)}");
                            isWaiting =  value?.getBool(PreferenceHelper.ISWAITING);
                            print("waiting__$isWaiting");


                            if(isWaiting != null){
                              if (isWaiting ?? false) {
                                postMdl
                                    .callCreateWaitingActivityApi(
                                    userId: userId,
                                    isWaitingStart: false,
                                    position: value1)
                                    .then((value) async {
                                  await callAddActivityApi(
                                      postMdl: postMdl,
                                      position: value1,
                                      totEventCode: AppConstant.checkInEvent,
                                      isFromCheckIn: true
                                  );
                                });
                              }
                            }
                          });


                        });
                      },
                    );
                  } else {
                    checkOutFunction();
                  }
                });
              },
              onTapUp: (details) {
                setState(() {
                  isTapped = false;
                });
                controller?.reverse();
              },
              onTapCancel: () {
                setState(() {
                  isTapped = false;
                });
                controller?.reverse();
              },
              child: Animate(
                effects: [
                  ScaleEffect(
                      begin: Offset(0, 0),
                      duration: Duration(
                        milliseconds: 300,
                      ),
                      curve: Curves.easeOut)
                ],
                child: AppUtils.commonContainer(
                  decoration: AppUtils.commonBoxDecoration(
                    shape: BoxShape.circle,
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: <Widget>[
                      postMdl.isLoading
                          ? LoaderWidget(
                              color: !isDayStart.value
                                  ? Colors.lightGreen
                                  : Colors.blue,
                            )
                          : Positioned.fill(
                              // scale: isTapped ? 4 : 3.6,
                              // Adjust the scale factor as needed
                              child: CircularProgressIndicator(
                                value: controller?.value,
                                strokeCap: StrokeCap.round,
                                strokeWidth: 8,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    !isDayStart.value
                                        ? Colors.lightGreen
                                        : Colors.blue),
                              ),
                            ),
                      Positioned.fill(
                        // scale: isTapped ? 4 : 3.6,
                        // Adjust the scale factor as needed
                        child: CircularProgressIndicator(
                          value: 1,
                          strokeWidth: 8,
                          strokeCap: StrokeCap.round,
                          valueColor: AlwaysStoppedAnimation<Color>(
                              AppConstant.greyColor.withOpacity(0.2)),
                        ),
                      ),
                      AnimatedContainer(
                        // padding: EdgeInsets.all(35),
                        curve: Curves.decelerate,
                        margin: EdgeInsets.all(2.8),
                        duration: const Duration(milliseconds: 300),
                        height: isTapped ? 120 : 100,
                        width: isTapped ? 120 : 100,
                        decoration: BoxDecoration(
                          color: !isDayStart.value
                              ? Colors.lightGreen.withOpacity(0.8)
                              : Colors.blue.withOpacity(0.7),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: !isDayStart.value
                                  ? Colors.lightGreen.withOpacity(0.3)
                                  : Colors.blue.withOpacity(0.3),
                              spreadRadius: isTapped ? 1 : 2,
                              blurRadius: isTapped ? 1 : 2,
                              offset: Offset(0, 0),
                            ),
                          ],
                        ),
                        child: Center(
                          child: AppUtils.commonTextWidget(
                            text: !isDayStart.value
                                ? "In"
                                : !isCheckIn.value
                                    ? "Check-In"
                                    : "Check-Out",
                            fontSize: !isDayStart.value ? 20 : 12,
                            textColor: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget logOut(postMdl, height, width) {
    return Animate(
      effects: const [
        ScaleEffect(
            begin: Offset(0, 0),
            duration: Duration(
              milliseconds: 300,
            ),
            curve: Curves.easeOut)
      ],
      child: GestureDetector(
        onTapDown: (details) {
          setState(() {
            isFromLogOutButton = true;
          });
          controller?.forward().whenComplete(() {
            HapticFeedback.vibrate();
            controller?.reset();
            doLocalVerification(afterSuccessfulVerificationFnc: () {
              if (isDayStart.value) {
                // logOutFunction();
                getCurrentLocation().then((value1) {
                  PreferenceHelper.reload().then((value) {
                    Future.delayed(Duration(seconds: 1));
                    print("logout_Waiting${value?.getBool(PreferenceHelper.ISWAITING)}");
                    isWaiting = value?.getBool(PreferenceHelper.ISWAITING);
                    print("logout_Waiting$isWaiting");

                    if(isWaiting != null){
                      if (isWaiting ?? false) {
                        postMdl
                            .callCreateWaitingActivityApi(
                            userId: userId,
                            isWaitingStart: false,
                            position: value1)
                            .then((value) async {
                          await callAddActivityApi(
                            postMdl: postMdl,
                            isFromLogOutBtn: true,
                            totEventCode: AppConstant.dayEndEvent,
                            position: value1,
                          );
                        });
                      }else{
                        callAddActivityApi(
                          postMdl: postMdl,
                          isFromLogOutBtn: true,
                          totEventCode: AppConstant.dayEndEvent,
                          position: value1,
                        );
                      }
                    }


                  });


                });
              }
            });
          });
        },
        onTapUp: (details) {
          setState(() {
            isFromLogOutButton = false;
          });
          controller?.reverse();
        },

        child: Animate(
          effects: const [
            ScaleEffect(
                begin: Offset(0, 0),
                duration: Duration(
                  milliseconds: 300,
                ),
                curve: Curves.easeOut)
          ],
          child: AppUtils.commonContainer(
            decoration: AppUtils.commonBoxDecoration(
              shape: BoxShape.circle,
            ),
            child: Stack(
              alignment: Alignment.center,
              children: <Widget>[
                postMdl.isLoading
                    ? LoaderWidget(color: Colors.red)
                    : Positioned.fill(
                        // scale: isFromLogOutButton ? 4 : 3.6,
                        // Adjust the scale factor as needed
                        child: CircularProgressIndicator(
                          value: controller?.value,
                          strokeCap: StrokeCap.round,
                          strokeWidth: 8,
                          valueColor:
                              const AlwaysStoppedAnimation<Color>(Colors.red),
                        ),
                      ),
                Positioned.fill(
                  // scale: isFromLogOutButton ? 4 : 3.6,
                  // Adjust the scale factor as needed
                  child: CircularProgressIndicator(
                    value: 1.0,
                    strokeWidth: 8,
                    strokeCap: StrokeCap.round,
                    valueColor: AlwaysStoppedAnimation<Color>(
                        AppConstant.greyColor.withOpacity(0.2)
                        // dayEnd == true ? Colors.red :!isDayStart.value
                        //     ? AppConstant.greyColor
                        //     : Colors.blue
                        ),
                  ),
                ),
                AnimatedContainer(
                  margin: const EdgeInsets.all(2.8),
                  duration: const Duration(milliseconds: 300),
                  height: isFromLogOutButton ? 120 : 100,
                  width: isFromLogOutButton ? 120 : 100,
                  decoration: AppUtils.commonBoxDecoration(
                    color: Colors.red.withOpacity(0.8),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.red.withOpacity(0.3),
                        spreadRadius: isFromLogOutButton ? 1 : 2,
                        blurRadius: isFromLogOutButton ? 1 : 2,
                        offset: Offset(0, 0),
                      ),
                    ],
                  ),
                  child: Center(
                    child: AppUtils.commonTextWidget(
                      text: "Out",
                      fontSize: 18,
                      textColor: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        //   },
        // ),
      ),
    );
  }

  callCheckInFunction(dynamic position) {
    return checkInFunction().then((value) {
      if (widget.onLocationFetch != null) {
        widget.onLocationFetch!(position);
      }
    });
  }

  callLoginFunction(dynamic position) {
    return loginFunction().then((value) {
      if (widget.onLocationFetch != null) {
        widget.onLocationFetch!(position);
      }
    });
  }

  callLogOutFunction(dynamic position) {
    return logOutFunction().then((value) {
      if (widget.onLocationFetch != null) {
        widget.onLocationFetch!(position);
        isFromLogOutButton = false;
      }
      isDayEnd.value = false;
      setState(() {
        isLoading = false;
      });
    });
  }

  openDialogFnc(String text) {
    return AppUtils.dialogWidget(text, context);
  }

  doLocalVerification(
      {required Function() afterSuccessfulVerificationFnc}) async {
    if (isBiometricAvailable) {
      bool isAuthenticated = await localAuthentication.authenticate(
          localizedReason: "Authenticate using Biometrics",
          options: const AuthenticationOptions(
              stickyAuth: true, useErrorDialogs: true));
      if (isAuthenticated) {
        if (kDebugMode) {
          print("isAuthenticated $isAuthenticated");
        }

        // openDialogFnc("Authentication Successful");
        afterSuccessfulVerificationFnc();
      } else {
        if (kDebugMode) {
          print("isAuthenticated $isAuthenticated");
        }
        openDialogFnc("Authentication Fail! Please Try Again");
      }
    } else {
      if (kDebugMode) {
        print("Biometric Auth is not available on this device");
      }
      openDialogFnc("Biometric Auth is not available on this device");
    }
  }
}
