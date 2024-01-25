import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:ontrek/core/utils/app_constant.dart';
import 'package:ontrek/core/utils/widget_utils.dart';

class ProfileScreen extends StatefulWidget {
  ScrollController? scrollController;
  ProfileScreen({super.key,this.scrollController});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  DraggableScrollableController draggableScrollableController =
  DraggableScrollableController();
  @override
  Widget build(BuildContext context) {
    return Animate(
      effects: [
        ScaleEffect(
            curve: Curves.easeOutBack,
            begin: Offset(1.3, 1.3),
            duration: Duration(milliseconds: 180)),
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
