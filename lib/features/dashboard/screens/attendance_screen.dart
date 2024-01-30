import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:ontrek/core/utils/app_constant.dart';
import 'package:ontrek/core/utils/widget_utils.dart';

class AttendanceScreen extends StatefulWidget {
  double? height;
  ScrollController? scrollController;
  Function? onTap;

  AttendanceScreen({super.key, this.height, this.scrollController,this.onTap});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen>
    with SingleTickerProviderStateMixin {
  AnimationController? controller;
  bool isTaped= false;

  DraggableScrollableController draggableScrollableController =
      DraggableScrollableController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initAnimateController();
  }

  initAnimateController() {
    controller =
        AnimationController(vsync: this, duration: Duration(seconds: 1));
    controller?.addListener(() {
      setState(() {});
    });
  }

  bool? isDayStarted= false;
  bool? isCheckIn= false;
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
          borderRadius: WidgetUtils.borderRadiousonly(topright: 18, topleft: 18),
          color: AppConstant.whiteColor,
        ),
        child: SingleChildScrollView(
          controller: widget.scrollController,
          physics: NeverScrollableScrollPhysics(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center, // Aligns children at the center vertically
            children: [
              WidgetUtils.commonContainer(
                decoration: WidgetUtils.commonBoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      width: 1,
                      color: AppConstant.greyColor.withOpacity(0.3),
                    ),
                  ),
                  borderRadius: WidgetUtils.borderRadiousonly(topleft: 18, topright: 18),
                  color: Colors.white,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
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
              SizedBox(height: 40), // Added vertical spacing
              Center(
                child: buttonWidget(120,() {

                }),
              ),
              SizedBox(height: 30), // Added vertical spacing
              Visibility(
                visible: !isTaped,
                child: WidgetUtils.commonTextWidget(
                  text: "Press & Hold",
                  letterSpacing: 0.2,
                  fontWeight: FontWeight.w600,
                  textColor: AppConstant.blackColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  Widget buttonWidget(double size,Function()? onTap) {
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
          setState(() {
            isDayStarted = true;

          });
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
      child: AnimatedBuilder(
        animation: controller!,

        builder: (BuildContext context, Widget? child) {
          double scaleFactor = isTaped  ? 2.0 : 1.0; // Adjust the scale factor as needed
          return AnimatedContainer(
            curve: Curves.bounceInOut,
            duration: const Duration(milliseconds: 300),
            width: isTaped ?  140 :size * scaleFactor,
            height: isTaped ?  140 :size * scaleFactor,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: isDayStarted ?? false ? AppConstant.blueColor.withOpacity(0.5):Colors.lightGreen.withOpacity(0.5),
                  spreadRadius: isTaped ? 1  : 3 ,
                  blurRadius: isTaped ?  2: 5,
                  offset: Offset(0,0),
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: <Widget>[
                Transform.scale(
                  scale: isTaped ? 4 :3.6, // Adjust the scale factor as needed
                  child: CircularProgressIndicator(
                    value: 1.0,
                    strokeWidth: 2,
                    strokeCap: StrokeCap.round,
                    valueColor: AlwaysStoppedAnimation<Color>(
                        isDayStarted ?? false ? Colors.blue.withOpacity(0.1):AppConstant.greyColor.withOpacity(0.1)),
                  ),
                ),
                Transform.scale(
                  scale: isTaped ? 4 :3.6, // Adjust the scale factor as needed
                  child: CircularProgressIndicator(
                    value: controller?.value,
                    strokeCap: StrokeCap.round,
                    strokeWidth: 2,
                    valueColor:  AlwaysStoppedAnimation<Color>(isDayStarted ?? false ? Colors.blue:Colors.lightGreen),
                  ),
                ),
                WidgetUtils.commonContainer(
                  height: isTaped ? 140 :120,
                  width: isTaped ? 140:120,
                  decoration: WidgetUtils.commonBoxDecoration(
                    color: isDayStarted ?? false ?  Colors.blue :Colors.lightGreen,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: WidgetUtils.commonTextWidget(
                      text: isDayStarted ?? false ? "Checkin":"In",
                      fontSize: isDayStarted ?? false ? 18 :26,
                      textColor: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }






}
