import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:ontrek/core/utils/app_constant.dart';
import 'package:ontrek/core/utils/widget_utils.dart';


class AttendanceScreen extends StatefulWidget {
  double? height;

  AttendanceScreen({super.key,this.height});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {

  DraggableScrollableController draggableScrollableController =
  DraggableScrollableController();

  @override
  Widget build(BuildContext context) {
    return  Animate(

      effects: [ScaleEffect(curve: Curves.easeOut,begin: Offset(20,20),duration: Duration(milliseconds: 180)), ],
      child: Positioned.fill(
        child: DraggableScrollableSheet(
          shouldCloseOnMinExtent: true,
          snap: true,
          expand: false,
          snapAnimationDuration: Duration(milliseconds: 300),
          initialChildSize: 0.4,
          maxChildSize: 0.9,
          minChildSize: 0.4,
          controller: draggableScrollableController,
          builder: (context, scrollController) {
            return Container(
              decoration: WidgetUtils.commonBoxDecoration(boxShadow: [  BoxShadow(
                color: Colors.black.withOpacity(0.15),
                spreadRadius: 0,
                blurRadius: 8,
                offset: Offset(0, -10), // This will create a top shadow
              ),],borderRadius: WidgetUtils.borderRadiousonly(topright: 18,topleft: 18),color: AppConstant.whiteColor),
              child: ListView.builder(
                itemCount: 20,
                shrinkWrap: true,
                controller: scrollController,
                itemBuilder: (context, index) {
                return Center(
                  child: WidgetUtils.commonTextWidget(
                      text: "text", textColor: Colors.red),
                );
              },),
            );
          },
        ),
      ),
    );
  }
}
