import 'package:flutter/material.dart';
import 'package:ontrek/core/utils/app_constant.dart';
import 'package:ontrek/core/utils/widget_utils.dart';



class TrackScreen extends StatefulWidget {
  const TrackScreen({super.key});

  @override
  State<TrackScreen> createState() => _TrackScreenState();
}

class _TrackScreenState extends State<TrackScreen> {
  DraggableScrollableController draggableScrollableController =
  DraggableScrollableController();
  @override
  Widget build(BuildContext context) {
    return  Positioned.fill(
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
          return SingleChildScrollView(
            controller: scrollController,
            child: Container(

              // height: double.infinity,
              width: double.infinity,
              decoration: WidgetUtils.commonBoxDecoration(

                  color: AppConstant.whiteColor,
                  borderRadius: WidgetUtils.borderRadiousonly(
                      topright: 30, topleft: 30)),
              child: Column(
                children: [
                  WidgetUtils.commonTextWidget(
                      text: "text", textColor: Colors.red),
                  WidgetUtils.commonTextWidget(
                      text: "text", textColor: Colors.red),
                  WidgetUtils.commonTextWidget(
                      text: "text", textColor: Colors.red),
                  WidgetUtils.commonTextWidget(
                      text: "text", textColor: Colors.red),
                  WidgetUtils.commonTextWidget(
                      text: "text", textColor: Colors.red),
                  WidgetUtils.commonTextWidget(
                      text: "text", textColor: Colors.red),
                  WidgetUtils.commonTextWidget(
                      text: "text", textColor: Colors.red),
                  WidgetUtils.commonTextWidget(
                      text: "text", textColor: Colors.red),
                  WidgetUtils.commonTextWidget(
                      text: "text", textColor: Colors.red),
                  WidgetUtils.commonTextWidget(
                      text: "text", textColor: Colors.red),
                  WidgetUtils.commonTextWidget(
                      text: "text", textColor: Colors.red),
                  WidgetUtils.commonTextWidget(
                      text: "text", textColor: Colors.red),
                  WidgetUtils.commonTextWidget(
                      text: "text", textColor: Colors.red),
                  WidgetUtils.commonTextWidget(
                      text: "text", textColor: Colors.red),
                  WidgetUtils.commonTextWidget(
                      text: "text", textColor: Colors.red),
                  WidgetUtils.commonTextWidget(
                      text: "text", textColor: Colors.red),
                  WidgetUtils.commonTextWidget(
                      text: "text", textColor: Colors.red),
                  WidgetUtils.commonTextWidget(
                      text: "text", textColor: Colors.red),
                  WidgetUtils.commonTextWidget(
                      text: "text", textColor: Colors.red),
                  WidgetUtils.commonTextWidget(
                      text: "text", textColor: Colors.red),
                  WidgetUtils.commonTextWidget(
                      text: "text", textColor: Colors.red),
                  WidgetUtils.commonTextWidget(
                      text: "text", textColor: Colors.red),
                  WidgetUtils.commonTextWidget(
                      text: "text", textColor: Colors.red),
                  WidgetUtils.commonTextWidget(
                      text: "text", textColor: Colors.red),
                  WidgetUtils.commonTextWidget(
                      text: "text", textColor: Colors.red),
                  WidgetUtils.commonTextWidget(
                      text: "text", textColor: Colors.red),
                  WidgetUtils.commonTextWidget(
                      text: "text", textColor: Colors.red),
                  WidgetUtils.commonTextWidget(
                      text: "text", textColor: Colors.red),
                  WidgetUtils.commonTextWidget(
                      text: "text", textColor: Colors.red),
                  WidgetUtils.commonTextWidget(
                      text: "text", textColor: Colors.red),
                  WidgetUtils.commonTextWidget(
                      text: "text", textColor: Colors.red),
                  WidgetUtils.commonTextWidget(
                      text: "text", textColor: Colors.red),
                  WidgetUtils.commonTextWidget(
                      text: "text", textColor: Colors.red),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
