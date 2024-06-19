import 'dart:convert';
import 'dart:ui';

import 'package:app_settings/app_settings.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ontrek/core/common_widgets/loader_widget.dart';
import 'package:ontrek/core/storage/preference_helper.dart';
import 'package:ontrek/core/utils/app_constant.dart';
import 'package:ontrek/core/utils/App_utils.dart';
import 'package:ontrek/core/utils/image_path.dart';
import 'package:ontrek/features/attendance/model/add_activity_model.dart';
import 'package:ontrek/features/attendance/model/get_last_activity_model.dart';
import 'package:ontrek/features/attendance/provider/attendance_provider.dart';
import 'package:ontrek/features/attendance/screen/pending_dayend_screen.dart';

import 'package:ontrek/features/check_out/screen/check_out_form_screen.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'dart:async';

import 'package:upgrader/upgrader.dart';

class AttendanceScreen extends StatefulWidget {
  double? height;
  Function(LatLng)? onLocationFetch;

  AttendanceScreen({super.key, this.height, this.onLocationFetch});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen>
    with SingleTickerProviderStateMixin {
  AnimationController? controller;
  bool isTapped = false;
  bool isFromLogOutButton = false;
  bool isLoading = false;
  Position? position;
  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  CreateActivityModel? createActivityModel;
  FlutterBackgroundService service = FlutterBackgroundService();
  late AttendanceProvider attendanceProvider;
  String? sessionOnlyDate;

  @override
  void initState() {
    // TODO: implement initState

    initAnimateController();
    if (!mounted) {}
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final attendanceProvider =
          Provider.of<AttendanceProvider>(context, listen: false);
      attendanceProvider.getAllConfiguration();
      attendanceProvider.panelController
          .animatePanelToPosition(0.99, duration: Duration(milliseconds: 500));
      attendanceProvider.isAllowCheckInCheckOut =
          PreferenceHelper.getBool(PreferenceHelper.AllowCheckInCheckOut);
      attendanceProvider.checkBiometricAvailable();
      attendanceProvider.batteryPercentage();
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
        AnimationController(vsync: this, duration: const Duration(seconds: 1));
    controller?.addListener(() {
      if (!mounted) {}
      setState(() {});
    });
  }

  //call General api
  Future<CreateActivityModel?> callCreateActivityApi({
    AttendanceProvider? attendanceProvider,
    String? totTrackingEventCode,
  }) async {
    try {
      CreateActivityModel? createActivityModel =
          await attendanceProvider?.apiCallCreateActivity(
        totTrackingEventCode: totTrackingEventCode,
        isFromCheckOut: false,
      );
      return createActivityModel;
    } catch (e) {
      print("catch_at_callCreateActivityApi$e");
    }
    return createActivityModel;
  }

  callDayStartApiAndUpdateUI(AttendanceProvider? attendanceProvider) async {
    try {
      var response = await callCreateActivityApi(
          totTrackingEventCode: AppConstant.dayStartEvent,
          attendanceProvider: attendanceProvider);

      if (response?.isError == false && response?.isValidationFailed == false) {

        await attendanceProvider?.EventUpdateProcess(response?.data?.lastActivityDto);

        if(response?.data?.lastActivityDto?.sessionId != null){
          if (widget.onLocationFetch != null) {
            widget.onLocationFetch!(LatLng(response?.data?.lastActivityDto?.lastActivityLat ?? 0.0, response?.data?.lastActivityDto?.lastActivityLong ?? 0.0));
          }
          service.invoke("dayStart");
        }
      } else {
        if (response?.isError == true) {
          AppUtils.showDialogBoxWithOneButton(
              titleText: "Error",
              context: context,
              text: "Something went wrong, Please try again later!");
        }
        if (response?.isValidationFailed == true) {
          if (response?.errorCode == "App.DayEnd.Pending.Operation") {
            AppUtils.showDialogBoxWithOneButton(
                titleText: "Day end Pending",
                context: context,
                text: response?.message ?? "",
                btnText: "Open Form",
                onTap: () {
                  Navigator.push(
                      context,
                      CupertinoPageRoute(
                        builder: (context) => PendingDayEndScreen(
                            sessionId: response?.data?.lastActivityDto?.sessionId,
                            sessionStartDate: sessionOnlyDate),
                      )).then(
                    (value) async {
                      AppUtils.showDialogBoxWithOneButton(
                          context: context,
                          titleText: "Requested",
                          text:
                              "Your request has been submitted. Please wait for approval.");
                    },
                  );
                });
          } else {
            AppUtils.showDialogBoxWithOneButton(context: context,titleText: "Requested",text: response?.message ?? "",);
          }
        }
      }
    } catch (e) {
      print("catch_at_dayStartApi$e");
    }
  }

  callCheckInApiAndUpdateUI(AttendanceProvider? attendanceProvider) async {
    //getCurrent Location for UI and api
    try {

      service.invoke("checkIn_beforeEvent");

      var response = await callCreateActivityApi(totTrackingEventCode: AppConstant.checkInEvent,attendanceProvider: attendanceProvider);

      //check api success or not
      if (response?.isError == false && response?.isValidationFailed == false) {

        await attendanceProvider?.EventUpdateProcess(response?.data?.lastActivityDto);

        if (widget.onLocationFetch != null) {
          widget.onLocationFetch!(LatLng(response?.data?.lastActivityDto?.lastActivityLat ?? 0.0, response?.data?.lastActivityDto?.lastActivityLong ?? 0.0));
        }

        service.invoke("checkIn_afterEvent");

      } else {
        if (response?.isError == true) {
          AppUtils.showDialogBoxWithOneButton(
              titleText: "Error",
              context: context,
              text: "Something went wrong, Please try again later!");
        }
        if (response?.isValidationFailed == true) {
          AppUtils.showDialogBoxWithOneButton(
              titleText: "Information",
              context: context,
              text: response?.message ?? "");
        }
      }
    } catch (e) {
      print("catch_at_checkInApi");
    }
  }



  callDayEndApiAndUpdateUI(AttendanceProvider? attendanceProvider) async {
    try {

      var response = await callCreateActivityApi(totTrackingEventCode: AppConstant.dayEndEvent,attendanceProvider: attendanceProvider);

      if (response?.isError == false && response?.isValidationFailed == false) {

        await attendanceProvider?.EventUpdateProcess(response?.data?.lastActivityDto);


        if (widget.onLocationFetch != null) {
          widget.onLocationFetch!(LatLng(response?.data?.lastActivityDto?.lastActivityLat ?? 0.0, response?.data?.lastActivityDto?.lastActivityLong ?? 0.0));
        }
        attendanceProvider?.isDayEnd.value = false;
      } else {
        if (response?.isError == true) {
          AppUtils.showDialogBoxWithOneButton(
              titleText: "Error",
              context: context,
              text: "Something went wrong, Please try again later!");
        }
        if (response?.isValidationFailed == true) {
          AppUtils.showDialogBoxWithOneButton(
              titleText: "Information",
              context: context,
              text: response?.message ?? "");
        }
      }
    } catch (e) {
      print("catch_at_checkInApi");
    }
  }





  Future checkOutFunction() async {
    bool isLocationServiceAvailable = await AppUtils.checkLocationServiceAvailability();
    bool isInternetAvailable = await AppUtils.checkInternetConnectivity();
    if (isLocationServiceAvailable && isInternetAvailable) {
      try {
        String? sessionId = PreferenceHelper.getString(PreferenceHelper.SESSION_ID);
        if(sessionId != null || sessionId != ""){
          Navigator.push(context, CupertinoPageRoute(builder: (context) => CheckOutFormScreen(sessionId: sessionId ))).then((value1) {
            if(value1 != null){
              if (widget.onLocationFetch != null) {
                widget.onLocationFetch!(value1);
              }
            }
          });
        }
      } catch (e) {
        print("catch_at_checkOutFunction$e");
      }
    }else{
      AppUtils.showDialogBoxWithOneButton(
        titleText: "Internet/Gps Off",
        text: "Kindly turn on Internet and Gps.",
        context: context,
        btnText: "OK",
      );
    }
    return position;
  }


  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    attendanceProvider = Provider.of<AttendanceProvider>(context);
    return AppUtils.commonSlidePanel(
        maxHeight: height * 0.4,
        minHeight: height * 0.083,
        controller: attendanceProvider.panelController,
        isDraggable: true,
        panelBuilder: (p0) {
          return Column(
            children: [
              AppUtils.buildHeader(
                  height: height,
                  width: width,
                  title: attendanceProvider.userName,
                  subTitle: attendanceProvider.orgName,
                  leadingImage: profileImage,
                  borderColor: Colors.red,
                  iconColor: AppConstant.appPrimaryColor,
                  backgroundColor: Colors.white),
              Expanded(
                child: Center(
                  child: Container(
                    // padding: EdgeInsets.only(top: height * 0.2 / 2.5),
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        ValueListenableBuilder(
                          valueListenable: attendanceProvider.isDayEnd,
                          builder: (context, value, child) {
                            return Center(
                              child: attendanceProvider
                                          .isAllowCheckInCheckOut ==
                                      false
                                  ? dayStartDayEndBtn(
                                      attendanceProvider, height, width)
                                  : !attendanceProvider.isDayEnd.value
                                      ? buttonWidget(
                                          attendanceProvider, height, width)
                                      : logOut(
                                          attendanceProvider, height, width),
                            );
                          },
                        ),
                        // buttonWidget(height,width,postMdl),
                        SizedBox(
                          height: 15,
                        ),
                        attendanceProvider.isAllowCheckInCheckOut == false
                            ? AppUtils.commonTextWidget(
                                text: "Press & Hold",
                                fontSize: 14,
                                letterSpacing: 0.2,
                                fontWeight: FontWeight.w600,
                                textColor: AppConstant.blackColor,
                              )
                            : !attendanceProvider.isDayStart.value ||
                                    attendanceProvider.isCheckIn.value
                                ? AppUtils.commonTextWidget(
                                    text: "Press & Hold",
                                    fontSize: 14,
                                    letterSpacing: 0.2,
                                    fontWeight: FontWeight.w600,
                                    textColor: AppConstant.blackColor,
                                  )
                                : GestureDetector(
                                    onTap: attendanceProvider.toggleButtons,
                                    child: AppUtils.commonTextWidget(
                                      text: !attendanceProvider.isDayEnd.value
                                          ? "Show End"
                                          : "Show CheckIn",
                                      fontSize: 14,
                                      letterSpacing: 0.2,
                                      fontWeight: FontWeight.w600,
                                      textColor:
                                          !attendanceProvider.isDayEnd.value
                                              ? Colors.red
                                              : AppConstant.appPrimaryColor,
                                    )),
                      ],
                    ),
                  ),
                ),
              )
            ],
          );
        });
    // panel: Stack(
    //   children: [
    //     Container(
    //       padding: EdgeInsets.only(top: height * 0.2 / 2),
    //       alignment: Alignment.center,
    //       child: Column(
    //         mainAxisAlignment: MainAxisAlignment.center,
    //         crossAxisAlignment: CrossAxisAlignment.center,
    //         children: [
    //           ValueListenableBuilder(
    //             valueListenable: attendanceProvider.isDayEnd,
    //             builder: (context, value, child) {
    //               return Center(
    //                 child:
    //                     attendanceProvider.isAllowCheckInCheckOut == false
    //                         ? dayStartDayEndBtn(
    //                             attendanceProvider, height, width)
    //                         : !attendanceProvider.isDayEnd.value
    //                             ? buttonWidget(
    //                                 attendanceProvider, height, width)
    //                             : logOut(attendanceProvider, height, width),
    //               );
    //             },
    //           ),
    //           // buttonWidget(height,width,postMdl),
    //           SizedBox(
    //             height: 15,
    //           ),
    //           attendanceProvider.isAllowCheckInCheckOut == false
    //               ? AppUtils.commonTextWidget(
    //                   text: "Press & Hold",
    //                   fontSize: 14,
    //                   letterSpacing: 0.2,
    //                   fontWeight: FontWeight.w600,
    //                   textColor: AppConstant.blackColor,
    //                 )
    //               : !attendanceProvider.isDayStart.value ||
    //                       attendanceProvider.isCheckIn.value
    //                   ? AppUtils.commonTextWidget(
    //                       text: "Press & Hold",
    //                       fontSize: 14,
    //                       letterSpacing: 0.2,
    //                       fontWeight: FontWeight.w600,
    //                       textColor: AppConstant.blackColor,
    //                     )
    //                   : GestureDetector(
    //                       onTap: attendanceProvider.toggleButtons,
    //                       child: AppUtils.commonTextWidget(
    //                         text: !attendanceProvider.isDayEnd.value
    //                             ? "Show End"
    //                             : "Show CheckIn",
    //                         fontSize: 14,
    //                         letterSpacing: 0.2,
    //                         fontWeight: FontWeight.w600,
    //                         textColor: !attendanceProvider.isDayEnd.value
    //                             ? Colors.red
    //                             : AppConstant.appPrimaryColor,
    //                       )),
    //         ],
    //       ),
    //     ),
    //     AppUtils.buildHeader(
    //         height: height,
    //         width: width,
    //         title: attendanceProvider.userName,
    //         subTitle: attendanceProvider.orgName,
    //         leadingImage: profileImage,
    //         borderColor: Colors.red,
    //         iconColor: AppConstant.appPrimaryColor,
    //         backgroundColor: Colors.white),
    //   ],
    // ));
  }

  Widget buttonWidget(AttendanceProvider postMdl, height, width) {
    return ValueListenableBuilder(
      valueListenable: attendanceProvider.isDayStart,
      builder: (context, value, child) {
        return ValueListenableBuilder(
          valueListenable: attendanceProvider.isCheckIn,
          builder: (context, value, child) {
            return GestureDetector(
              onTapDown: (details) {
                if (!attendanceProvider.isLoading) {
                  setState(() {
                    isTapped = true;
                  });
                } else {
                  setState(() {
                    isTapped = false;
                  });
                }

                controller?.forward().whenComplete(() async {
                  bool? isAlwaysOnLocation =
                      await Permission.locationAlways.isGranted;
                  bool? isInternetAvailable =
                      await AppUtils.checkInternetConnectivity();
                  bool? isGpsAvailable =
                      await AppUtils.checkLocationServiceAvailability();
                  HapticFeedback.vibrate();
                  controller?.reset();
                  if (isInternetAvailable) {
                    if (isAlwaysOnLocation) {
                      if (isGpsAvailable) {
                        if (!attendanceProvider.isDayStart.value) {
                          if (attendanceProvider.isAllowFgAuth == true) {
                            attendanceProvider.doLocalVerification(
                              afterSuccessfulVerificationFnc: () async {
                                if (attendanceProvider.isLocationRestricted ==
                                    true) {
                                  Position position =
                                      await Geolocator.getCurrentPosition(
                                          desiredAccuracy:
                                              LocationAccuracy.best);
                                  double? distance = Geolocator.distanceBetween(
                                      attendanceProvider
                                              .restrictedLocationLat ??
                                          0,
                                      attendanceProvider
                                              .restrictedLocationLong ??
                                          0,
                                      position.latitude,
                                      position.longitude);
                                  if (distance <
                                      (attendanceProvider
                                              .restrictedLocationMeter ??
                                          50)) {
                                    await callDayStartApiAndUpdateUI(postMdl);
                                  } else {
                                    AppUtils.showDialogBoxWithOneButton(
                                        titleText: "Premises",
                                        text: "You are not at Office Location",
                                        context: context);
                                  }
                                } else {
                                  await callDayStartApiAndUpdateUI(postMdl);
                                }
                              },
                            );
                          } else {
                            if (attendanceProvider.isLocationRestricted ==
                                true) {
                              Position position =
                                  await Geolocator.getCurrentPosition(
                                      desiredAccuracy: LocationAccuracy.best);
                              double? distance = Geolocator.distanceBetween(
                                  attendanceProvider.restrictedLocationLat ?? 0,
                                  attendanceProvider.restrictedLocationLong ??
                                      0,
                                  position.latitude,
                                  position.longitude);
                              if (distance <
                                  (attendanceProvider.restrictedLocationMeter ??
                                      50)) {
                                await callDayStartApiAndUpdateUI(postMdl);
                              } else {
                                AppUtils.showDialogBoxWithOneButton(
                                    titleText: "Premises",
                                    text: "You are not at Office Location",
                                    context: context);
                              }
                            } else {
                              await callDayStartApiAndUpdateUI(postMdl);
                            }
                          }
                        } else if (!attendanceProvider.isCheckIn.value) {
                          PreferenceHelper.reload().then((value) async {
                            if (attendanceProvider.isAllowFgAuth == true) {
                              attendanceProvider.doLocalVerification(
                                afterSuccessfulVerificationFnc: () async {
                                  await callCheckInApiAndUpdateUI(postMdl);
                                },
                              );
                            } else {
                              await callCheckInApiAndUpdateUI(postMdl);
                            }
                          });
                        } else {
                          checkOutFunction();
                        }
                      } else {
                        AppUtils.commonGpsDialog();
                      }
                    } else {
                      AppUtils.commonAlwaysOnDialog();
                    }
                  } else {
                    AppUtils.commonInternetDialog();
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
                              color: !attendanceProvider.isDayStart.value
                                  ? Colors.lightGreen
                                  : Colors.blue,
                            )
                          : Positioned.fill(
                              child: CircularProgressIndicator(
                                value: controller?.value,
                                strokeCap: StrokeCap.round,
                                strokeWidth: 8,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    !attendanceProvider.isDayStart.value
                                        ? Colors.lightGreen
                                        : Colors.blue),
                              ),
                            ),
                      Positioned.fill(
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
                          color: !attendanceProvider.isDayStart.value
                              ? Colors.lightGreen.withOpacity(0.8)
                              : Colors.blue.withOpacity(0.7),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: !attendanceProvider.isDayStart.value
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
                            text: !attendanceProvider.isDayStart.value
                                ? "Start"
                                : !attendanceProvider.isCheckIn.value
                                    ? "Check-In"
                                    : "Check-Out",
                            fontSize:
                                !attendanceProvider.isDayStart.value ? 16 : 12,
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
          if (!attendanceProvider.isLoading) {
            setState(() {
              isFromLogOutButton = true;
            });
          } else {
            setState(() {
              isFromLogOutButton = false;
            });
          }

          controller?.forward().whenComplete(() async {
            HapticFeedback.vibrate();
            controller?.reset();

            AppUtils.showDialogBoxWithTwoButton(
                titleText: "Day End",
                context: context,
                text: "Are you sure you want to end the day?",
                onSuccessString: "YES",
                onCancelString: "NO",
                onSuccess: () async {
                  bool? isInternetAvailable =
                      await AppUtils.checkInternetConnectivity();
                  bool? isGpsAvailable =
                      await AppUtils.checkLocationServiceAvailability();
                  if (isInternetAvailable) {
                    if (isGpsAvailable) {
                      PreferenceHelper.reload().then((value) async {
                        if (attendanceProvider.isAllowFgAuth == true) {
                          attendanceProvider.doLocalVerification(
                            afterSuccessfulVerificationFnc: () async {
                              if (attendanceProvider.isLocationRestricted ==
                                  true) {
                                Position position =
                                    await Geolocator.getCurrentPosition(
                                        desiredAccuracy: LocationAccuracy.best);
                                double? distance = Geolocator.distanceBetween(
                                    attendanceProvider.restrictedLocationLat ??
                                        0,
                                    attendanceProvider.restrictedLocationLong ??
                                        0,
                                    position.latitude,
                                    position.longitude);
                                if (distance <
                                    (attendanceProvider
                                            .restrictedLocationMeter ??
                                        50)) {
                                  callDayEndApiAndUpdateUI(postMdl);
                                } else {
                                  AppUtils.showDialogBoxWithOneButton(
                                      titleText: "Premises",
                                      text: "You are not at Office Location",
                                      context: context);
                                }
                              } else {
                                callDayEndApiAndUpdateUI(postMdl);
                              }
                            },
                          );
                        } else {
                          if (attendanceProvider.isLocationRestricted == true) {
                            Position position =
                                await Geolocator.getCurrentPosition(
                                    desiredAccuracy: LocationAccuracy.best);
                            double? distance = Geolocator.distanceBetween(
                                attendanceProvider.restrictedLocationLat ?? 0,
                                attendanceProvider.restrictedLocationLong ?? 0,
                                position.latitude,
                                position.longitude);
                            if (distance <
                                (attendanceProvider.restrictedLocationMeter ??
                                    50)) {
                              callDayEndApiAndUpdateUI(postMdl);
                            } else {
                              AppUtils.showDialogBoxWithOneButton(
                                  titleText: "Premises",
                                  text: "You are not at Office Location",
                                  context: context);
                            }
                          } else {
                            callDayEndApiAndUpdateUI(postMdl);
                          }
                        }
                      });
                    } else {
                      AppUtils.commonGpsDialog();
                    }
                  } else {
                    AppUtils.commonInternetDialog();
                  }
                },
                onCancel: () {
                  setState(() {
                    isFromLogOutButton = false;
                  });
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
                        child: CircularProgressIndicator(
                          value: controller?.value,
                          strokeCap: StrokeCap.round,
                          strokeWidth: 8,
                          valueColor:
                              const AlwaysStoppedAnimation<Color>(Colors.red),
                        ),
                      ),
                Positioned.fill(
                  child: CircularProgressIndicator(
                    value: 1.0,
                    strokeWidth: 8,
                    strokeCap: StrokeCap.round,
                    valueColor: AlwaysStoppedAnimation<Color>(
                        AppConstant.greyColor.withOpacity(0.2)),
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
                        offset: const Offset(0, 0),
                      ),
                    ],
                  ),
                  child: Center(
                    child: AppUtils.commonTextWidget(
                      text: "End",
                      fontSize: 16,
                      textColor: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget dayStartDayEndBtn(
      AttendanceProvider attendanceProvider, height, width) {
    return ValueListenableBuilder(
      valueListenable: attendanceProvider.isDayStart,
      builder: (context, value, child) {
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
              if (!attendanceProvider.isLoading) {
                setState(() {
                  isFromLogOutButton = true;
                });
              } else {
                isFromLogOutButton = false;
              }

              controller?.forward().whenComplete(() async {
                HapticFeedback.vibrate();
                controller?.reset();
                bool? isInternetAvailable =
                    await AppUtils.checkInternetConnectivity();
                bool? isGpsAvailable =
                    await AppUtils.checkLocationServiceAvailability();
                bool? isAlwaysOnLocation =
                    await Permission.locationAlways.isGranted;
                if (isInternetAvailable) {
                  if (isAlwaysOnLocation) {
                    if (isGpsAvailable) {
                      PreferenceHelper.reload().then((value) async {
                        if (attendanceProvider.isAllowFgAuth == true) {
                          attendanceProvider.doLocalVerification(
                              afterSuccessfulVerificationFnc: () async {
                            if (attendanceProvider.isLocationRestricted ==
                                true) {
                              Position position =
                                  await Geolocator.getCurrentPosition(
                                      desiredAccuracy: LocationAccuracy.best);

                              double? distance = Geolocator.distanceBetween(
                                  attendanceProvider.restrictedLocationLat ?? 0,
                                  attendanceProvider.restrictedLocationLong ??
                                      0,
                                  position.latitude,
                                  position.longitude);
                              if (distance <
                                  (attendanceProvider.restrictedLocationMeter ??
                                      50)) {
                                if (!attendanceProvider.isDayStart.value) {
                                  callDayStartApiAndUpdateUI(
                                      attendanceProvider);
                                } else {
                                  callDayEndApiAndUpdateUI(attendanceProvider);
                                }
                              } else {
                                AppUtils.showDialogBoxWithOneButton(
                                    titleText: "Premises",
                                    text: "You are not at Office Location",
                                    context: context);
                              }
                            } else {
                              print(
                                  "isLocationRestricted${attendanceProvider.isLocationRestricted}");
                              if (!attendanceProvider.isDayStart.value) {
                                callDayStartApiAndUpdateUI(attendanceProvider);
                              } else {
                                callDayEndApiAndUpdateUI(attendanceProvider);
                              }
                            }
                          });
                        } else {
                          if (attendanceProvider.isLocationRestricted == true) {
                            Position position =
                                await Geolocator.getCurrentPosition(
                                    desiredAccuracy: LocationAccuracy.low);

                            double? distance = Geolocator.distanceBetween(
                                attendanceProvider.restrictedLocationLat ?? 0,
                                attendanceProvider.restrictedLocationLong ?? 0,
                                position.latitude,
                                position.longitude);
                            if (distance <
                                (attendanceProvider.restrictedLocationMeter ??
                                    50)) {
                              if (!attendanceProvider.isDayStart.value) {
                                callDayStartApiAndUpdateUI(attendanceProvider);
                              } else {
                                callDayEndApiAndUpdateUI(attendanceProvider);
                              }
                            } else {
                              AppUtils.showDialogBoxWithOneButton(
                                  titleText: "Premises",
                                  text: "You are not at Office Location",
                                  context: context);
                            }
                          } else {
                            print(
                                "isLocationRestricted${attendanceProvider.isLocationRestricted}");
                            if (!attendanceProvider.isDayStart.value) {
                              callDayStartApiAndUpdateUI(attendanceProvider);
                            } else {
                              callDayEndApiAndUpdateUI(attendanceProvider);
                            }
                          }
                        }
                      });
                    } else {
                      AppUtils.commonGpsDialog();
                    }
                  } else {
                    AppUtils.commonAlwaysOnDialog();
                  }
                } else {
                  AppUtils.commonInternetDialog();
                }
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
                    attendanceProvider.isLoading
                        ? LoaderWidget(
                            color: !attendanceProvider.isDayStart.value
                                ? Colors.lightGreen
                                : Colors.red)
                        : Positioned.fill(
                            child: CircularProgressIndicator(
                              value: controller?.value,
                              strokeCap: StrokeCap.round,
                              strokeWidth: 8,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  !attendanceProvider.isDayStart.value
                                      ? Colors.lightGreen
                                      : Colors.red),
                            ),
                          ),
                    Positioned.fill(
                      child: CircularProgressIndicator(
                        value: 1.0,
                        strokeWidth: 8,
                        strokeCap: StrokeCap.round,
                        valueColor: AlwaysStoppedAnimation<Color>(
                            AppConstant.greyColor.withOpacity(0.2)),
                      ),
                    ),
                    AnimatedContainer(
                      margin: const EdgeInsets.all(2.8),
                      duration: const Duration(milliseconds: 300),
                      height: isFromLogOutButton ? 120 : 100,
                      width: isFromLogOutButton ? 120 : 100,
                      decoration: AppUtils.commonBoxDecoration(
                        color: !attendanceProvider.isDayStart.value
                            ? Colors.lightGreen.withOpacity(0.8)
                            : Colors.red.withOpacity(0.8),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: !attendanceProvider.isDayStart.value
                                ? Colors.lightGreen.withOpacity(0.3)
                                : Colors.red.withOpacity(0.3),
                            spreadRadius: isFromLogOutButton ? 1 : 2,
                            blurRadius: isFromLogOutButton ? 1 : 2,
                            offset: const Offset(0, 0),
                          ),
                        ],
                      ),
                      child: Center(
                        child: AppUtils.commonTextWidget(
                          text: !attendanceProvider.isDayStart.value
                              ? "Start"
                              : "End",
                          fontSize: 16,
                          textColor: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
