import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:geolocator/geolocator.dart';
import 'package:ontrek/core/storage/preference_helper.dart';
import 'package:ontrek/core/utils/app_constant.dart';
import 'package:ontrek/core/utils/widget_utils.dart';

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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initAnimateController();
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


  @override
  Widget build(BuildContext context) {
    return Animate(
      effects: [
        ScaleEffect(
          curve: Curves.ease,
          begin: Offset(0, -1),
          duration: Duration(milliseconds: 100),
        ),
      ],
      child: Container(
        decoration: AppUtils.commonBoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              spreadRadius: 0,
              blurRadius: 18,

              offset: Offset(0, -20), // This will create a top shadow
            ),
          ],
          borderRadius:
              AppUtils.borderRadiousonly(topright: 18, topleft: 18),
          color: AppConstant.whiteColor,
        ),
        child: SingleChildScrollView(
          controller: widget.scrollController,
          physics: NeverScrollableScrollPhysics(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,

            // Aligns children at the center vertically
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
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  child: Row(
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
                ),
              ),
              SizedBox(height: 40),
              // Added vertical spacing

              ValueListenableBuilder(
                valueListenable: isDayEnd,
                builder: (context, value, child) {
                  return Center(
                    child: !isDayEnd.value ? buttonWidget() :  logOut(),
                  );
                },
              ),

              SizedBox(height: 30),
              // Added vertical spacing

              !isDayStart.value  ? Visibility(
                visible: !isTapped,
                child: AppUtils.commonTextWidget(
                  text:  "Press & Hold",
                  fontSize:  14 ,
                  letterSpacing: 0.2,
                  fontWeight: FontWeight.w600 ,
                  textColor:
                   AppConstant.blackColor ,
                ),
              ):GestureDetector(
                  onTap: () {
                    isDayEnd.value = true;
                  },
                  child: Visibility(
                    visible:  !isFromLogOutButton,
                    child: AppUtils.commonTextWidget(
                      text:  "Show Off" ,
                      fontSize:  16 ,
                      letterSpacing: 0.2,
                      fontWeight: FontWeight.w600 ,
                      textColor: Colors.red ,
                    ),
                  )
              ),
            ],
          ),
        ),
      ),
    );
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
    PreferenceHelper.setBool(PreferenceHelper.checkIn, false);
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
              onHorizontalDragStart: (details) {
                setState(() {
                  isTapped = true;
                });
                controller?.forward();
              },
              onVerticalDragStart: (details) {
                setState(() {
                  isTapped = true;
                });
                controller?.forward();
              },
              onVerticalDragEnd: (details) {
                setState(() {
                  isTapped = false;
                });
                controller?.reverse();
              },
              onHorizontalDragEnd: (details) {
                setState(() {
                  isTapped = false;
                });
                controller?.reverse();
              },
              onTapDown: (details) {
                setState(() {
                  isTapped = true;
                });
                controller?.forward().whenComplete(() {
                  controller?.reset();
                  if (!isDayStart.value) {
                    loginFunction().then((value) {
                      if (widget.onLocationFetch != null) {
                        widget.onLocationFetch!(value);

                      }
                    });
                  } else if (!isCheckIn.value) {
                    checkInFunction().then((value) {
                      if (widget.onLocationFetch != null) {
                        widget.onLocationFetch!(value);
                      }
                    });
                  }else {
                    checkOutFunction().then((value) {
                      if (widget.onLocationFetch != null) {
                        widget.onLocationFetch!(value);
                        // isDayEnd.value = false;
                      }
                    });
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
                effects: [ScaleEffect(begin: Offset(0,0),duration: Duration(milliseconds: 300,),curve: Curves.easeOut)],

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
                          color:!isDayStart.value
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
                            fontSize: !isDayStart.value ? 26 : 14,
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
  Widget logOut() {
    return Animate(
      effects: [ScaleEffect(begin: Offset(0,0),duration: Duration(milliseconds: 300,),curve: Curves.easeOut)],
      child: GestureDetector(
        onHorizontalDragStart: (details) {
          setState(() {
            isFromLogOutButton = true;
          });
          controller?.forward();
        },
        onVerticalDragStart: (details) {
          setState(() {
            isFromLogOutButton = true;
          });
          controller?.forward();
        },
        onVerticalDragEnd: (details) {
          setState(() {
            isFromLogOutButton = false;
          });
          controller?.reverse();
        },
        onHorizontalDragEnd: (details) {
          setState(() {
            isFromLogOutButton = false;
          });
          controller?.reverse();
        },
        onTapDown: (details) {
          setState(() {
            isFromLogOutButton = true;
          });
          controller?.forward().whenComplete(() {
            controller?.reset();
            setState(() {
              isLoading = true;
            });
            if(isDayStart.value){
              logOutFunction().then((value) {
                if(widget.onLocationFetch != null){
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
        },
        onTapUp: (details) {
          setState(() {
            isFromLogOutButton = false;
          });
          controller?.reverse();
        },

        // child: AnimatedBuilder(
        //   animation: controller!,
        //   builder: (BuildContext context, Widget? child) {
        //     double scaleFactor =
        //         isTaped ? 2.0 : 1.0; // Adjust the scale factor as needed
        child: Animate(

          effects: [ScaleEffect(begin: Offset(0,0),duration: Duration(milliseconds: 300,),curve: Curves.easeOut)],
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
                    valueColor: const AlwaysStoppedAnimation<Color>(
                        Colors.red),
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
                  margin: EdgeInsets.all(3),
                  duration: const Duration(milliseconds: 300),
                  height: isFromLogOutButton ? 120 : 100,
                  width: isFromLogOutButton ? 120 : 100,
                  decoration: AppUtils.commonBoxDecoration(
                    color:Colors.red.withOpacity(0.8),
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
        //   },
        // ),
      ),
    );
  }

}
