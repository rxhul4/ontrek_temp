import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:ontrek/core/utils/app_constant.dart';
import 'package:ontrek/core/utils/widget_utils.dart';

import '../../../core/utils/image_path.dart';

class TrackScreen extends StatefulWidget {
  ScrollController? scrollController;

  TrackScreen({super.key, this.scrollController});

  @override
  State<TrackScreen> createState() => _TrackScreenState();
}

class _TrackScreenState extends State<TrackScreen> {
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
        child: Column(
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
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Column(
                  children: [
                    WidgetUtils.commonContainer(
                      width: 30,
                      height: 5,
                      decoration: WidgetUtils.commonBoxDecoration(
                          color: AppConstant.greyColor.withOpacity(0.3),
                          borderRadius:
                              WidgetUtils.borderRadiusAll(raduis: 12)),
                    ),
                    Row(
                      children: [
                        WidgetUtils.commonContainer(
                            height: 45,
                            width: 45,
                            decoration: WidgetUtils.commonBoxDecoration(
                              shape: BoxShape.circle,
                              border:
                                  Border.all(color: Colors.grey, width: 1.2),
                            ),
                            child:
                                Icon(Icons.location_pin, color: Colors.cyan)),
                        WidgetUtils.commonSizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              WidgetUtils.commonTextWidget(
                                text: "Track",
                                fontWeight: FontWeight.w600,
                                textColor: AppConstant.blackColor,
                                letterSpacing: 0.2,
                                fontSize: 15,
                              ),
                              WidgetUtils.commonTextWidget(
                                text: "Select a user to locate",
                                fontWeight: FontWeight.w400,
                                textColor:
                                    AppConstant.blackColor.withOpacity(0.3),
                                letterSpacing: 0,
                                fontSize: 13,
                              ),
                            ],
                          ),
                        ),
                        commonIconWidget(
                          iconData: Icons.search,
                          onTap: () {},
                        ),
                        WidgetUtils.commonSizedBox(width: 10),
                        commonIconWidget(
                          iconData: Icons.repeat,
                          onTap: () {},
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: GridView.builder(
                itemCount: 32,
                shrinkWrap: true,
                controller: widget.scrollController,
                padding: WidgetUtils.edgeInsetsAll(allPadding: 10),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4, childAspectRatio: 4 / 4.5),
                itemBuilder: (BuildContext context, int index) {
                  return trackGrid();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget commonIconWidget({Function()? onTap, IconData? iconData}) {
    return InkWell(
      onTap: onTap,
      child: Icon(
        iconData,
        size: 26,
        color: AppConstant.blackColor.withOpacity(0.6),
      ),
    );
  }

  Widget trackGrid() {
    return Column(
      children: [
        WidgetUtils.commonContainer(
          padding: WidgetUtils.edgeInsetsAll(allPadding: 25),
          decoration: WidgetUtils.commonBoxDecoration(
              shape: BoxShape.circle,
              color: AppConstant.greyColor.withOpacity(0.2),
              border: Border.all(color: AppConstant.primaryColor, width: 1.2),
              image: DecorationImage(image: AssetImage(profileImage))),
        ),
        WidgetUtils.commonSizedBox(height: 8),
        WidgetUtils.commonTextWidget(
            text: 'You', textColor: AppConstant.blackColor, fontSize: 12),
        WidgetUtils.commonTextWidget(
            text: 'Last week', textColor: Colors.cyan, fontSize: 10),
      ],
    );
  }
}
// dummy code
