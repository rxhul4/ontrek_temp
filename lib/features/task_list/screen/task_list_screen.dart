import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:ontrek/core/utils/app_constant.dart';
import 'package:ontrek/core/utils/widget_utils.dart';

class TaskListScreen extends StatefulWidget {
  ScrollController? scrollController;

  TaskListScreen({super.key, this.scrollController});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> with TickerProviderStateMixin {
  DraggableScrollableController draggableScrollableController =
      DraggableScrollableController();


  @override
  Widget build(BuildContext context) {
    TabController tabController = TabController(length: 2, vsync: this);
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
        child: SingleChildScrollView(
          controller: widget.scrollController,
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
                    // mainAxisAlignment: MainAxisAlignment.center,
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
                              color: AppConstant.blueColor,
                              border:
                                  Border.all(color: Colors.grey, width: 1.2),
                            ),
                          ),
                          WidgetUtils.commonSizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                WidgetUtils.commonTextWidget(
                                  text: "Task",
                                  fontWeight: FontWeight.w600,
                                  textColor: AppConstant.blackColor,
                                  letterSpacing: 0.2,
                                  fontSize: 15,
                                ),
                                WidgetUtils.commonTextWidget(
                                  text: "Select a task",
                                  fontWeight: FontWeight.w500,
                                  textColor:
                                      AppConstant.blackColor.withOpacity(0.2),
                                  letterSpacing: 0.1,
                                  fontSize: 13,
                                ),
                              ],
                            ),
                          ),
                          commonIconWidget(
                              iconData: Icons.calendar_month, onTap: () {}),
                          WidgetUtils.commonSizedBox(width: 10),
                          commonIconWidget(iconData: Icons.add, onTap: () {}),
                          WidgetUtils.commonSizedBox(width: 10),
                          commonIconWidget(
                              iconData: Icons.refresh, onTap: () {}),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: WidgetUtils.edgeInsetsAll(allPadding: 20),
                child: Column(
                  children: [
                    DecoratedBox(
                        decoration: WidgetUtils.commonBoxDecoration(
                            color: AppConstant.greyColor.withOpacity(0.3),
                            borderRadius: WidgetUtils.borderRadiusAll(raduis: 10)),
                      child: Row(
                        children: [
                          Expanded(child: Container(
                              padding: EdgeInsets.all(10),
                              decoration: WidgetUtils.commonBoxDecoration(
                         color: AppConstant.blueColor,
                           borderRadius: WidgetUtils.borderRadiusAll(raduis: 10)),child: Text('ASSIGNED TO ME'))),
                          Expanded(child: Container(
                              padding: EdgeInsets.all(10),
                              decoration: WidgetUtils.commonBoxDecoration(
                                  // color: AppConstant.greyColor.withOpacity(0.3),
                                  borderRadius: WidgetUtils.borderRadiusAll(raduis: 10)),child: Text('ALL TASK'))),

                        ],
                      ),
                    )
                    // DecoratedBox(
                    //   decoration: WidgetUtils.commonBoxDecoration(
                    //       color: AppConstant.greyColor.withOpacity(0.3),
                    //       borderRadius: WidgetUtils.borderRadiusAll(raduis: 10)),
                    //   child: TabBar(
                    //       indicator: WidgetUtils.commonBoxDecoration(
                    //         borderRadius:  WidgetUtils.borderRadiusAll(raduis: 10),
                    //           color: AppConstant.blueColor,
                    //       ),
                    //        controller: tabController,
                    //       isScrollable: true,
                    //       dividerHeight: 0,
                    //       indicatorSize: TabBarIndicatorSize.tab,
                    //       tabs: [
                    //         Tab(child: WidgetUtils.commonTextWidget(text: 'ASSIGNED TO ME')),
                    //         Tab(child: WidgetUtils.commonTextWidget(text: 'ALL TASK')),
                    //       ],
                    //     ),
                    // ),

                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget commonIconWidget({Function()? onTap, IconData? iconData}) {
    return GestureDetector(onTap: onTap, child: Icon(iconData));
  }
}
