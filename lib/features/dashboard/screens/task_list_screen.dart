import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:ontrek/core/utils/app_constant.dart';
import 'package:ontrek/core/utils/widget_utils.dart';


class TaskListScreen extends StatefulWidget {
  ScrollController? scrollController;
  TaskListScreen({super.key,this.scrollController});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  DraggableScrollableController draggableScrollableController =
  DraggableScrollableController();
  @override
  Widget build(BuildContext context) {
    return Animate(
      effects: [
        ScaleEffect(
            curve: Curves.ease,
            begin: Offset(0, -1),
            duration: Duration(milliseconds: 100)),
      ],
      child: Container(
        decoration: WidgetUtils.commonBoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                spreadRadius: 0,
                blurRadius: 8,
                offset: Offset(0, -10), // This will create a top shadow
              ),
            ],
            borderRadius:
            WidgetUtils.borderRadiousonly(topright: 18, topleft: 18),
            color: AppConstant.whiteColor),
        child: ListView.builder(
          itemCount: 20,
          shrinkWrap: true,
          controller: widget.scrollController,
          itemBuilder: (context, index) {
            return Center(
              child: WidgetUtils.commonTextWidget(
                  text: "text", textColor: Colors.red),
            );
          },
        ),
      ),
    );
  }
}
