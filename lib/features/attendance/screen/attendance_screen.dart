import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ontrek/core/storage/preference_helper.dart';
import 'package:ontrek/core/utils/app_constant.dart';
import 'package:ontrek/core/utils/App_utils.dart';
import 'package:local_auth/local_auth.dart';
import 'package:ontrek/features/check_out/check_out_form_screen.dart';

class AttendanceScreen extends StatefulWidget {
  double? height;
  ScrollController? scrollController;
  Function(Position)? onLocationFetch;

  AttendanceScreen(
      {super.key, this.height, this.scrollController, this.onLocationFetch});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen>
    with SingleTickerProviderStateMixin {
  AnimationController? controller;
  DraggableScrollableController draggableScrollableController =
      DraggableScrollableController();
  LocalAuthentication _localAuthentication = LocalAuthentication();
  bool isBiometricAvailable = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initAnimateController();
    checkBiometricAvailable();
    isDayStart.value = PreferenceHelper.getBool(PreferenceHelper.DayStart);
    isCheckIn.value = PreferenceHelper.getBool(PreferenceHelper.checkIn);
  }

  initAnimateController() {
    controller =
        AnimationController(vsync: this, duration: Duration(seconds: 1));
    controller?.addListener(() {
      setState(() {});
    });
  }

  ValueNotifier<bool> isDayStart = ValueNotifier(false);
  ValueNotifier<bool> isCheckIn = ValueNotifier(false);
  ValueNotifier<bool> isDayEnd = ValueNotifier(false);
  bool isTapped = false;
  bool isFromLogOutButton = false;
  bool isLoading = false;
  Position? position;

  checkBiometricAvailable() async {
    isBiometricAvailable = await _localAuthentication.canCheckBiometrics;
    if (kDebugMode) {
      print("isBiometricAvailable-$isBiometricAvailable");
    }
  }

  @override
  Widget build(BuildContext context) {

    return Animate(
      effects: const  [
        SlideEffect(
            end: Offset(0, 0),
            curve: Curves.decelerate,
            begin: Offset(0, 1),
            duration: Duration(milliseconds: 600)),
      ],
      child: Container(
        decoration: AppUtils.commonBoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              spreadRadius: 0,
              blurRadius: 8,

              offset: Offset(0, -10), // This will create a top shadow
            ),
          ],
          borderRadius: AppUtils.borderRadiousonly(topright: 18, topleft: 18),
          color: AppConstant.whiteColor,
        ),
        child: SingleChildScrollView(
          controller: widget.scrollController,
          physics: NeverScrollableScrollPhysics() ,
          // physics: widget.scrollController!.position.pixels > 0.4 ? NeverScrollableScrollPhysics() :AlwaysScrollableScrollPhysics(),


          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,

            children: [
              AppUtils.commonContainer(
                decoration: AppUtils.commonBoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      width: 1,
                      color: AppConstant.greyColor.withOpacity(0.3),
                    ),
                  ),
                  borderRadius:
                  AppUtils.borderRadiousonly(topleft: 18, topright: 18),
                  color: Colors.white,
                ),
                child: Padding(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Column(
                    children: [
                      AppUtils.commonContainer(
                        width: 30,
                        height: 5,
                        decoration: AppUtils.commonBoxDecoration(
                            color: AppConstant.greyColor.withOpacity(0.3),
                            borderRadius:
                            AppUtils.borderRadiusAll(raduis: 12)),
                      ),
                      Row(
                        children: [
                          AppUtils.commonContainer(
                            height: 45,
                            width: 45,
                            decoration: AppUtils.commonBoxDecoration(
                              shape: BoxShape.circle,
                              color: AppConstant.greyColor,
                              border: Border.all(color: Colors.red, width: 1.2),
                            ),
                          ),
                          AppUtils.commonSizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AppUtils.commonTextWidget(
                                text: "Vatsal",
                                fontWeight: FontWeight.w600,
                                textColor: AppConstant.blackColor,
                                letterSpacing: 0.2,
                                fontSize: 15,
                              ),
                              AppUtils.commonTextWidget(
                                text: "Epistic interiour Pvt Ltd",
                                fontWeight: FontWeight.w500,
                                textColor: AppConstant.blackColor.withOpacity(0.7),
                                letterSpacing: 0.1,
                                fontSize: 13,
                              ),
                            ],
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 50),
              // Added vertical spacing

              Column(

                children: [
                  ValueListenableBuilder(
                    valueListenable: isDayEnd,
                    builder: (context, value, child) {
                      return Center(
                        child: !isDayEnd.value ? buttonWidget() : logOut() ,
                      );
                    },
                  ),
                  AppUtils.commonSizedBox(height: 20),
                  !isDayStart.value
                      ? Visibility(
                    visible: !isTapped,
                    child: AppUtils.commonTextWidget(
                      text: "Press & Hold",
                      fontSize: 14,
                      letterSpacing: 0.2,
                      fontWeight: FontWeight.w600,
                      textColor: AppConstant.blackColor,
                    ),
                  )
                      : GestureDetector(
                      onTap: () {
                        setState(() {
                          isDayEnd.value = !isDayEnd.value; // Toggle the value
                        });

                      },
                      child: Visibility(
                        visible: !isFromLogOutButton,
                        child: AppUtils.commonTextWidget(
                          text:  isDayEnd.value ? "Show Hide" : "Show Off",
                          fontSize: 14,
                          letterSpacing: 0.2,
                          fontWeight: FontWeight.w600,
                          textColor:isDayEnd.value ? AppConstant.appPrimaryColor : Colors.red ,
                        ),
                      )),
                ],
              ),

              SizedBox(height: 30),
              // Added vertical spacing


            ],
          ),
        ),
      ),
    );
  }

  Future getCurrentLocation() async {
    bool isLocationServiceAvailable =
        await AppUtils.checkLocationServiceAvailability();
    // PreferenceHelper.setBool(PreferenceHelper.DayStart, true);
    // isDayStart.value = PreferenceHelper.getBool(PreferenceHelper.DayStart);

    if (isLocationServiceAvailable) {
      try {
        Position position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.medium);
        return position;
      } catch (e) {
        print("Catch at DayStart${e}");
      }
    }
  }

  Future loginFunction() async {
    bool isLocationServiceAvailable =
        await AppUtils.checkLocationServiceAvailability();
    PreferenceHelper.setBool(PreferenceHelper.DayStart, true);
    isDayStart.value = PreferenceHelper.getBool(PreferenceHelper.DayStart);

    if (isLocationServiceAvailable) {
      try {
        Position position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.medium);
        return position;
      } catch (e) {
        print("Catch at DayStart${e}");
      }
    }
  }

  Future checkInFunction() async {
    bool isLocationServiceAvailable =
        await AppUtils.checkLocationServiceAvailability();
    PreferenceHelper.setBool(PreferenceHelper.checkIn, true);
    isCheckIn.value = PreferenceHelper.getBool(PreferenceHelper.checkIn);

    if (isLocationServiceAvailable) {
      try {
        Position position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.medium);
        return position;
      } catch (e) {
        print("Catch at DayStart${e}");
      }
    }
  }

  Future checkOutFunction() async {
    bool isLocationServiceAvailable =
        await AppUtils.checkLocationServiceAvailability();

    if (isLocationServiceAvailable) {
      try {
        Navigator.push(
            context,
            MaterialPageRoute(
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
      bool isLocationServiceAvailable =
          await AppUtils.checkLocationServiceAvailability();
      PreferenceHelper.setBool(PreferenceHelper.checkIn, false);
      PreferenceHelper.setBool(PreferenceHelper.DayStart, false);
      isDayStart.value = PreferenceHelper.getBool(PreferenceHelper.DayStart);
      isCheckIn.value = PreferenceHelper.getBool(PreferenceHelper.checkIn);
      if (isLocationServiceAvailable) {
        try {
          Position position = await Geolocator.getCurrentPosition(
              desiredAccuracy: LocationAccuracy.medium);
          return position;
        } catch (e) {
          print("Catch at DayStart${e}");
        }
      }
    } catch (e) {
      print("catch at dayEnd ${e}");
    }
  }

  Widget buttonWidget() {
    return ValueListenableBuilder(
      valueListenable: isDayStart,
      builder: (context, value, child) {
        return ValueListenableBuilder(
          valueListenable: isCheckIn,
          builder: (context, value, child) {
            return GestureDetector(
              // onHorizontalDragStart: (details) {
              //   setState(() {
              //     isTapped = true;
              //   });
              //   controller?.forward();
              // },
              // onVerticalDragStart: (details) {
              //   setState(() {
              //     isTapped = true;
              //   });
              //   controller?.forward();
              // },
              // onVerticalDragEnd: (details) {
              //   setState(() {
              //     isTapped = false;
              //   });
              //   controller?.reverse();
              // },
              // onHorizontalDragEnd: (details) {
              //   setState(() {
              //     isTapped = false;
              //   });
              //   controller?.reverse();
              // },
              onTapDown: (details) {
                setState(() {
                  isTapped = true;
                });
                controller?.forward().whenComplete(() async {
                  HapticFeedback.vibrate();

                  controller?.reset();
                  if (!isDayStart.value) {
                    doLocalVerification(doVerificationForLogIn);
                  } else if (!isCheckIn.value) {
                    doLocalVerification(doVerificationForCheckIn);
                  } else
                    checkOutFunction();
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
                      Positioned.fill(
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
                              AppConstant.greyColor.withOpacity(0.2)
                              // dayEnd == true ? Colors.red :!isDayStart.value
                              //     ? AppConstant.greyColor
                              //     : Colors.blue
                              ),
                        ),
                      ),
                      AnimatedContainer(
                        margin: EdgeInsets.all(3),
                        duration: const Duration(milliseconds: 300),
                        height: isTapped ? 120 : 100,
                        width: isTapped ? 120 : 100,
                        decoration: AppUtils.commonBoxDecoration(
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
                            fontSize: !isDayStart.value ? 22 : 13,
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

  doVerificationForCheckIn() {
    return checkInFunction().then((value) {
      if (widget.onLocationFetch != null) {
        widget.onLocationFetch!(value);
      }
    });
  }

  doVerificationForLogIn() {
    return loginFunction().then((value) {
      if (widget.onLocationFetch != null) {
        widget.onLocationFetch!(value);
      }
    });
  }

  Widget logOut() {
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
            doVerificationAndLogout();
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
                Positioned.fill(
                  // scale: isFromLogOutButton ? 4 : 3.6,
                  // Adjust the scale factor as needed
                  child: CircularProgressIndicator(
                    value: controller?.value,
                    strokeCap: StrokeCap.round,
                    strokeWidth: 8,
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.red),
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
                  margin: const EdgeInsets.all(3),
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
                      fontSize: 20,
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

  doVerificationAndLogout() {
    return doLocalVerification(() {
      controller?.reset();
      setState(() {
        isLoading = true;
      });
      if (isDayStart.value) {
        logOutFunction().then((value) {
          if (widget.onLocationFetch != null) {
            widget.onLocationFetch!(value);
            isFromLogOutButton = false;
          }
          isDayEnd.value = false;
          setState(() {
            isLoading = false;
          });
        });
      }
    });
  }

  openDialogFnc(String text) {
    showDialog(
      context: context,
      builder: (context) => showDialogBox(text, context),
    );
  }

  AlertDialog showDialogBox(String text, BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10))),
      // Remove border radius
      insetPadding: const EdgeInsets.all(0),
      titlePadding: const EdgeInsets.all(0),
      contentPadding:
          const EdgeInsets.only(top: 30, bottom: 10, left: 20, right: 20),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Text(text, textAlign: TextAlign.center,),
          AppUtils.commonTextWidget(
              text: text,
              textAlign: TextAlign.center,
              textColor: AppConstant.blackColor,
              fontWeight: FontWeight.w400),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                style: TextButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10))),
                onPressed: () {
                  Navigator.pop(context);
                },
                child: AppUtils.commonTextWidget(
                    text: "OK",
                    textColor: AppConstant.appPrimaryColor,
                    letterSpacing: 1,
                    fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ],
      ),
    );
  }

  doLocalVerification(Function afterSuccessfulVerificationFnc) async {
    if (isBiometricAvailable) {
      bool isAuthenticated = await _localAuthentication.authenticate(
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
      showDialog(
        context: context,
        builder: (context) => showDialogBox(
            "Biometric Auth is not available on this device", context),
      );
    }
  }
}
