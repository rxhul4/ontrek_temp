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
  bool isTaped = false;

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
        decoration: WidgetUtils.commonBoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              spreadRadius: 0,
              blurRadius: 18,

              offset: Offset(0, -20), // This will create a top shadow
            ),
          ],
          borderRadius:
              WidgetUtils.borderRadiousonly(topright: 18, topleft: 18),
          color: AppConstant.whiteColor,
        ),
        child: SingleChildScrollView(
          controller: widget.scrollController,
          physics: NeverScrollableScrollPhysics(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            // Aligns children at the center vertically
            children: [
              WidgetUtils.commonContainer(
                decoration: WidgetUtils.commonBoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      width: 1,
                      color: AppConstant.greyColor.withOpacity(0.3),
                    ),
                  ),
                  borderRadius:
                      WidgetUtils.borderRadiousonly(topleft: 18, topright: 18),
                  color: Colors.white,
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  child: Row(
                    children: [
                      WidgetUtils.commonContainer(
                        height: 45,
                        width: 45,
                        decoration: WidgetUtils.commonBoxDecoration(
                          shape: BoxShape.circle,
                          color: AppConstant.greyColor,
                          border: Border.all(color: Colors.red, width: 1.2),
                        ),
                      ),
                      WidgetUtils.commonSizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          WidgetUtils.commonTextWidget(
                            text: "Vatsal",
                            fontWeight: FontWeight.w600,
                            textColor: AppConstant.blackColor,
                            letterSpacing: 0.2,
                            fontSize: 15,
                          ),
                          WidgetUtils.commonTextWidget(
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
                    child: buttonWidget(isDayEnd.value),
                  );
                },
              ),

              SizedBox(height: 30),
              // Added vertical spacing

              GestureDetector(
                onTap: () {
                  if(isDayStart.value){
                    isDayEnd.value = true;
                  }
                },
                child: ValueListenableBuilder(valueListenable: isDayStart, builder: (context, value, child) {

                  return  Visibility(
                    visible: !isDayStart.value,
                    child: WidgetUtils.commonTextWidget(
                      text: !isDayStart.value ? "Press & Hold" : "Show Off",
                      fontSize: !isDayStart.value ? 14 : 16,
                      letterSpacing: 0.2,
                      fontWeight:
                      !isDayStart.value ? FontWeight.w600 : FontWeight.w600,
                      textColor:
                      !isDayStart.value ? AppConstant.blackColor : Colors.red,
                    ),
                  );
                },)
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future dayStart() async {
    bool isLocationServiceAvailable =
        await WidgetUtils.checkLocationServiceAvailability();
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


  Future checkIn() async {
    bool isLocationServiceAvailable =
        await WidgetUtils.checkLocationServiceAvailability();
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
  Future checkOut() async {
    bool isLocationServiceAvailable =
    await WidgetUtils.checkLocationServiceAvailability();
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

  Future dayEndFunction() async {
    try {
      bool isLocationServiceAvailable =
      await WidgetUtils.checkLocationServiceAvailability();
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

  Widget buttonWidget(bool? dayEnd) {
    return ValueListenableBuilder(
      valueListenable: isDayStart,
      builder: (context, value, child) {
        return ValueListenableBuilder(
          valueListenable: isCheckIn,
          builder: (context, value, child) {
            return GestureDetector(
              onHorizontalDragStart: (details) {
                setState(() {
                  isTaped = true;
                });
                controller?.forward();
              },
              onVerticalDragStart: (details) {
                setState(() {
                  isTaped = true;
                });
                controller?.forward();
              },
              onVerticalDragEnd: (details) {
                setState(() {
                  isTaped = false;
                });
                controller?.reverse();
              },
              onHorizontalDragEnd: (details) {
                setState(() {
                  isTaped = false;
                });
                controller?.reverse();
              },
              onTapDown: (details) {
                setState(() {
                  isTaped = true;
                });
                controller?.forward().whenComplete(() {
                  controller?.reset();
                  if (!isDayStart.value) {
                    dayStart().then((value) {
                      if (widget.onLocationFetch != null) {
                        widget.onLocationFetch!(value);
                      }
                    });
                  } else if (!isCheckIn.value) {
                    checkIn().then((value) {
                      if (widget.onLocationFetch != null) {
                        widget.onLocationFetch!(value);
                      }
                    });
                  }else  {
                    // if(isDayStart.value){

                      // controller?.forward().whenComplete(() {
                        dayEndFunction().then((value) {
                          if (widget.onLocationFetch != null) {
                            widget.onLocationFetch!(value);
                            isDayEnd.value = false;
                          }

                          controller?.reset();
                        });

                      // });
                    // }
                  }
                });
              },
              onTapUp: (details) {
                setState(() {
                  isTaped = false;
                });
                controller?.reverse();
              },
              onTapCancel: () {
                setState(() {
                  isTaped = false;
                });
                controller?.reverse();
              },
              // child: AnimatedBuilder(
              //   animation: controller!,
              //   builder: (BuildContext context, Widget? child) {
              //     double scaleFactor =
              //         isTaped ? 2.0 : 1.0; // Adjust the scale factor as needed
              child: AnimatedContainer(
                curve: Curves.easeInOutQuad,
                duration: const Duration(milliseconds: 300),
                width: isTaped ? 140 : 120,
                height: isTaped ? 140 : 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: dayEnd == true
                          ? Colors.red.withOpacity(0.5)
                          : !isDayStart.value
                              ? Colors.lightGreen.withOpacity(0.5)
                              : Colors.blue.withOpacity(0.5),
                      spreadRadius: isTaped ? 1 : 2,
                      blurRadius: isTaped ? 1 : 2,
                      offset: Offset(0, 0),
                    ),
                  ],
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: <Widget>[
                    Transform.scale(
                      scale: isTaped ? 4 : 3.6,
                      // Adjust the scale factor as needed
                      child: CircularProgressIndicator(
                        value: 1.0,
                        strokeWidth: 1.5,
                        strokeCap: StrokeCap.round,
                        valueColor: AlwaysStoppedAnimation<Color>(
                            dayEnd == true ? AppConstant.greyColor.withOpacity(0.3) :AppConstant.greyColor.withOpacity(0.3)
                            // dayEnd == true ? Colors.red :!isDayStart.value
                            //     ? AppConstant.greyColor
                            //     : Colors.blue
                            ),
                      ),
                    ),
                    Transform.scale(
                      scale: isTaped ? 4 : 3.6,
                      // Adjust the scale factor as needed
                      child: CircularProgressIndicator(
                        value: controller?.value,
                        strokeCap: StrokeCap.round,
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(dayEnd == true
                            ? Colors.red
                            : !isDayStart.value
                                ? Colors.lightGreen
                                : Colors.blue),
                      ),
                    ),
                    AnimatedContainer(
                      duration: Duration(milliseconds: 300),
                      height: isTaped ? 140 : 120,
                      width: isTaped ? 140 : 120,
                      decoration: WidgetUtils.commonBoxDecoration(
                        color: dayEnd == true
                            ? Colors.red
                            : !isDayStart.value
                                ? Colors.lightGreen
                                : Colors.blue,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: WidgetUtils.commonTextWidget(
                          text: dayEnd == true
                              ? "Out"
                              : !isDayStart.value
                                  ? "In"
                                  : !isCheckIn.value
                                      ? "Check-In"
                                      : "Check-Out",
                          fontSize: !isDayStart.value ? 26 : 16,
                          textColor: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              //   },
              // ),
            );
          },
        );
      },
    );
  }
}
