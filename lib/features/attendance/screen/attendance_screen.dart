import 'dart:ffi';
import 'dart:isolate';
import 'dart:ui';

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
import 'package:ontrek/core/storage/sql_db_service.dart';
import 'package:ontrek/core/utils/app_constant.dart';
import 'package:ontrek/core/utils/App_utils.dart';
import 'package:local_auth/local_auth.dart';
import 'package:ontrek/core/utils/image_path.dart';
import 'package:ontrek/features/attendance/model/add_activity_model.dart';
import 'package:ontrek/features/attendance/model/get_last_activity_model.dart';
import 'package:ontrek/features/attendance/provider/attendance_provider.dart';
import 'package:ontrek/features/authentication/providers/auth_provider.dart';

import 'package:ontrek/features/check_out/screen/check_out_form_screen.dart';
import 'package:provider/provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'package:path/path.dart' as newPath;

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
  bool isTapped = false;
  bool isFromLogOutButton = false;
  bool isLoading = false;
  Position? position;
  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  AndroidDeviceInfo? androidInfo;
  CreateActivityModel? createActivityModel;
  FlutterBackgroundService service = FlutterBackgroundService();
  final databaseService = DatabaseService();
  late AttendanceProvider attendanceProvider;
  String? userName = "";

  @override
  void initState() {
    // TODO: implement initState
    userName = PreferenceHelper.getString(PreferenceHelper.USER_NAME);
    initAnimateController();

    if(!mounted){
    }
    WidgetsBinding.instance.addPostFrameCallback((_) async{
      final attendanceProvider =
          Provider.of<AttendanceProvider>(context, listen: false);

      attendanceProvider.panelController.animatePanelToPosition(0.99);
      await attendanceProvider.callGetLastActivity();

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
  Future<CreateActivityModel?> callCreateActivityApi(
      {AttendanceProvider? attendanceProvider,
      String? totTrackingEventCode,
      Position? position}) async {
    try {
      String? userId = PreferenceHelper.getString(PreferenceHelper.USER_ID);
      CreateActivityModel? createActivityModel =
          await attendanceProvider?.apiCallCreateActivity(
        userId: userId,
        totTrackingEventCode: totTrackingEventCode,
        isFromCheckOut: false,
        latitude: position?.latitude,
        longitude: position?.longitude,
        batteryLevel: attendanceProvider.battery,
      );
      return createActivityModel;
    } catch (e) {
      print("catch_at_callCreateActivityApi$e");
    }
    return createActivityModel;
  }

  callDayStartApiAndUpdateUI(AttendanceProvider? attendanceProvider) {
    //getCurrent Location for UI and api

    try {
      attendanceProvider?.getCurrentLocation().then((value) async {
        // then call Api

        var response = await callCreateActivityApi(
            totTrackingEventCode: AppConstant.dayStartEvent,
            position: value,
            attendanceProvider: attendanceProvider);

        //check api success or not
        if (response?.isError == false &&
            response?.isValidationFailed == false) {
          //after success update UI

          PreferenceHelper.setDouble(
              PreferenceHelper.LAST_LAT, value?.latitude ?? 0);
          PreferenceHelper.setDouble(
              PreferenceHelper.LAST_LONG, value?.longitude ?? 0);
          PreferenceHelper.setString(
              PreferenceHelper.WAITING_START_TIME, DateTime.now().toString());
          callLoginFunction(value);
          double? lastLat =
              PreferenceHelper.getDouble(PreferenceHelper.LAST_LAT);
          double? lastLong =
              PreferenceHelper.getDouble(PreferenceHelper.LAST_LAT);
          String? waitingStartTime =
              PreferenceHelper.getString(PreferenceHelper.WAITING_START_TIME);

          FlutterBackgroundService().invoke("background", {
            "lastLat": lastLat,
            "lastLong": lastLong,
            "waitingStartTime": waitingStartTime,
          });
        }
      });
    } catch (e) {
      print("catch_at_dayStartApi");
      AppUtils.showDialogBoxWithOneButton(context: context ,text: "Something went wrong, Please try again later!");
      // AppUtils.dialogWidget(
      //     "Something went wrong, Please try again later!", context);
    }
  }

  callCheckInApiAndUpdateUI(AttendanceProvider? attendanceProvider) {
    //getCurrent Location for UI and api
    try {
      attendanceProvider?.getCurrentLocation().then((value) async {
        // then call Api
        var response = await callCreateActivityApi(
            totTrackingEventCode: AppConstant.checkInEvent,
            position: value,
            attendanceProvider: attendanceProvider);

        //check api success or not
        if (response?.isError == false &&
            response?.isValidationFailed == false) {
          //after success update UI
          callCheckInFunction(value);
        }
      });
    } catch (e) {
      print("catch_at_checkInApi");
      AppUtils.showDialogBoxWithOneButton(context: context ,text: "Something went wrong, Please try again later!");

    }
  }

  callDayEndApiAndUpdateUI(AttendanceProvider? attendanceProvider) {
    //getCurrent Location for UI and api
    try {
      attendanceProvider?.getCurrentLocation().then((value) async {
        // then call Api
        var response = await callCreateActivityApi(
            totTrackingEventCode: AppConstant.dayEndEvent,
            position: value,
            attendanceProvider: attendanceProvider);

        //check api success or not
        if (response?.isError == false &&
            response?.isValidationFailed == false) {
          //after success update UI
          callDayEndFunction(value);
        }
      });
    } catch (e) {
      print("catch_at_checkInApi");
      AppUtils.showDialogBoxWithOneButton(context: context ,text: "Something went wrong, Please try again later!");
    }
  }

  callWaitingEndApi(
      {AttendanceProvider? postMdl,
      Position? position,
      bool? checkIn,
      bool? dayEnd}) async {
    // then call Api
    try {
      var response = await callCreateActivityApi(
          totTrackingEventCode: AppConstant.trackingWaitingStopEvent,
          position: position,
          attendanceProvider: postMdl);

      //check api success or not
      if (response?.isError == false && response?.isValidationFailed == false) {
        //after success delete waiting flag from database
        PreferenceHelper.setBool(PreferenceHelper.isWaiting, false);
        attendanceProvider.isWaiting.value =
            PreferenceHelper.getBool(PreferenceHelper.isWaiting);
        service.invoke("update", {"isWaiting": false});
        if (checkIn == true) {
          await callCheckInApiAndUpdateUI(postMdl);
        }

        if (dayEnd == true) {
          await callDayEndApiAndUpdateUI(postMdl);
        }
      }
    } catch (e) {
      print("catch_at_waitingEndApi");
    }
  }

  callCheckInFunction(dynamic position) {
    return checkInAndUpdateUIFunction().then((value) {
      if (widget.onLocationFetch != null) {
        widget.onLocationFetch!(position);
      }
    });
  }

  callLoginFunction(dynamic position) {
    return dayStartAndUpdateUIFunction().then((value) {
      if (widget.onLocationFetch != null) {
        widget.onLocationFetch!(position);
      }
    });
  }

  callDayEndFunction(dynamic position) {
    return logOutAndUpdateUIFunction().then((value) {
      if (widget.onLocationFetch != null) {
        widget.onLocationFetch!(position);
        isFromLogOutButton = false;
      }
      attendanceProvider.isDayEnd.value = false;
    });
  }

  Future dayStartAndUpdateUIFunction() async {
    try {
      service.startService();
      PreferenceHelper.setBool(PreferenceHelper.DayStart, true);
      attendanceProvider.isDayStart.value =
          PreferenceHelper.getBool(PreferenceHelper.DayStart);
    } catch (e) {
      print("catch_at_dayStartAndUpdateUIFunction$e");
    }
  }

  Future<void> checkInAndUpdateUIFunction() async {
    try {
      PreferenceHelper.setBool(PreferenceHelper.checkIn, true);
      attendanceProvider.isCheckIn.value =
          PreferenceHelper.getBool(PreferenceHelper.checkIn);
    } catch (e) {
      print("catch_at_checkInAndUpdateUIFunction$e");
    }
  }

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
          attendanceProvider.isCheckIn.value =
              PreferenceHelper.getBool(PreferenceHelper.checkIn);
          attendanceProvider.getCurrentLocation().then((value) {
            if (widget.onLocationFetch != null) {
              widget.onLocationFetch!(value!);
            }
          });
        });
        return position;
      } catch (e) {
        print("catch_at_checkOutFunction$e");
      }
    }
    return position;
  }

  Future logOutAndUpdateUIFunction() async {
    try {
      service.invoke("stopService");
      PreferenceHelper.setBool(PreferenceHelper.checkIn, false);
      PreferenceHelper.setBool(PreferenceHelper.DayStart, false);
      attendanceProvider.isDayStart.value =
          PreferenceHelper.getBool(PreferenceHelper.DayStart);
      attendanceProvider.isCheckIn.value =
          PreferenceHelper.getBool(PreferenceHelper.checkIn);
      attendanceProvider.isDayEnd.value = false;
    } catch (e) {
      print("catch_at_logOutAndUpdateUIFunction$e");
    }
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    attendanceProvider = Provider.of<AttendanceProvider>(context);
    print("isDayStartValue${attendanceProvider.isDayStart.value}");
    print("isCheckIn${attendanceProvider.isCheckIn.value}");
    return AppUtils.commonSlidePanel(
        maxHeight: height * 0.4,
        minHeight: height * 0.09,
        controller: attendanceProvider.panelController,
        isDraggable: true,
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
                    valueListenable: attendanceProvider.isDayEnd,
                    builder: (context, value, child) {
                      return Center(
                        child: !attendanceProvider.isDayEnd.value
                            ? buttonWidget(attendanceProvider, height, width)
                            : logOut(attendanceProvider, height, width),
                      );
                    },
                  ),
                  // buttonWidget(height,width,postMdl),
                  SizedBox(
                    height: 15,
                  ),
                  !attendanceProvider.isDayStart.value ||
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
                                ? "Show Out"
                                : "Show CheckIn",
                            fontSize: 14,
                            letterSpacing: 0.2,
                            fontWeight: FontWeight.w600,
                            textColor: !attendanceProvider.isDayEnd.value
                                ? Colors.red
                                : AppConstant.appPrimaryColor,
                          )),
                ],
              ),
            ),
            AppUtils.buildHeader(
                height: height,
                width: width,
                title: userName,
                subTitle: "Epistic interiour Pvt Ltd",
                leadingImage: profileImage,
                borderColor: Colors.red,
                iconColor: AppConstant.appPrimaryColor,
                backgroundColor: Colors.white),
          ],
        ));
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
                setState(() {
                  isTapped = true;
                });
                controller?.forward().whenComplete(() async {
                  HapticFeedback.vibrate();

                  controller?.reset();
                  if (!attendanceProvider.isDayStart.value) {
                    attendanceProvider.doLocalVerification(
                      afterSuccessfulVerificationFnc: () async {
                        await callDayStartApiAndUpdateUI(postMdl);
                      },
                    );
                  } else if (!attendanceProvider.isCheckIn.value) {
                    PreferenceHelper.reload().then((value) {
                      print(
                          "value_new_isWaiting${value?.getBool(PreferenceHelper.isWaiting)}");
                      attendanceProvider.isWaiting.value =
                          value?.getBool(PreferenceHelper.isWaiting) ?? false;
                      attendanceProvider.doLocalVerification(
                        afterSuccessfulVerificationFnc: () async {
                          print(
                              "isWaiting_from_UI${attendanceProvider.isWaiting.value}");

                          attendanceProvider
                              .getCurrentLocation()
                              .then((position) async {
                            if (attendanceProvider.isWaiting.value == true) {
                              await callWaitingEndApi(
                                  postMdl: postMdl,
                                  position: position,
                                  checkIn: true,
                                  dayEnd: false);
                            } else {
                              await callCheckInApiAndUpdateUI(postMdl);
                            }
                          });
                        },
                      );
                    });
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
                              color: !attendanceProvider.isDayStart.value
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
                                    !attendanceProvider.isDayStart.value
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
                                ? "In"
                                : !attendanceProvider.isCheckIn.value
                                    ? "Check-In"
                                    : "Check-Out",
                            fontSize:
                                !attendanceProvider.isDayStart.value ? 20 : 12,
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
            AppUtils.showDialogBoxWithTwoButton(
              context: context,
              text: "Are you sure you want to end the day?",
              onSuccessString: "YES",
              onCancelString: "NO",
              onSuccess: () {
                PreferenceHelper.reload().then((value) {
                  if (kDebugMode) {
                    print(
                        "value_new_isWaiting${value?.getBool(PreferenceHelper.isWaiting)}");
                  }
                  attendanceProvider.isWaiting.value =
                      value?.getBool(PreferenceHelper.isWaiting) ?? false;
                  attendanceProvider.doLocalVerification(
                    afterSuccessfulVerificationFnc: () async {
                      if (kDebugMode) {
                        print(
                            "isWaiting_from_UI${attendanceProvider.isWaiting.value}");
                      }
                      attendanceProvider
                          .getCurrentLocation()
                          .then((position) async {
                        print(
                            "condtion${attendanceProvider.isWaiting.value == true}");
                        if (attendanceProvider.isWaiting.value == true) {
                          await callWaitingEndApi(
                              postMdl: postMdl,
                              position: position,
                              dayEnd: true,
                              checkIn: false);
                        } else {
                          await callDayEndApiAndUpdateUI(postMdl);
                        }
                      });
                    },
                  );
                });
              },
              onCancel: (){
                setState(() {
                  isFromLogOutButton = false;
                });
              }
            );

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
      ),
    );
  }
}
