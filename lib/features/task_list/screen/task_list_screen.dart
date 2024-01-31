import 'package:flutter/gestures.dart';
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
                    WidgetUtils.commonContainer(
                      width: MediaQuery.of(context).size.width,
                      height: 30,
                      decoration: WidgetUtils.commonBoxDecoration(
                        color: AppConstant.greyColor.withOpacity(0.2),
                        borderRadius: WidgetUtils.borderRadiusAll(raduis: 5)
                      ),
                      child: TabBar(
                       controller: tabController,
                       indicatorWeight: 0,
                       dividerHeight: 0.1,
                       indicatorSize: TabBarIndicatorSize.tab,
                       padding: WidgetUtils.edgeInsetsAll(allPadding: 2),
                       indicator: BoxDecoration(
                         color: AppConstant.blueColor,
                         borderRadius: WidgetUtils.borderRadiusAll(raduis: 5)
                       ),
                          labelColor: Colors.white,
                          unselectedLabelColor: Colors.black,
                          tabs: const [
                            Tab(text: 'ASSIGNED TO ME'),
                            Tab(text: 'All task'),
                        // Tab(child: WidgetUtils.commonTextWidget(text: 'ASSIGNED TO ME',fontSize: 12,textColor: Colors.black)),
                        // Tab(child: WidgetUtils.commonTextWidget(text: 'ALL TASK',fontSize: 12,textColor: Colors.black)),
                       ]
                      )
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height  / 1.5,
                      child: TabBarView(
                          controller: tabController,
                          physics: NeverScrollableScrollPhysics(),
                          children: <Widget>[
                            assignedToMeTabBar(),
                            allTaskTabBar(),
                          ]
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
//Icon
  Widget commonIconWidget({Function()? onTap, IconData? iconData}) {
    return GestureDetector(onTap: onTap, child: Icon(iconData,size: 30,color: AppConstant.blackColor.withOpacity(0.5),));
  }
  //assigned to me
  Widget assignedToMeTabBar (){
    return Column(
      children: [
        WidgetUtils.commonSizedBox(
            height: 100,
            child: const Image(
                image: NetworkImage('https://img.freepik.com/free-vector/phone-customization-concept-illustration_114360-4313.jpg?w=740&t=st=1706681307~exp=1706681907~hmac=8f1c6ec99afe4718ced3a79d82c4a2ac18e02ac10e72275d713f62911d901586'),
            ),
          ),
        WidgetUtils.commonTextWidget(text: 'No task assigned!', textColor: AppConstant.blackColor),
        WidgetUtils.commonTextWidget(text: 'New task will be notified', textColor: AppConstant.blackColor.withOpacity(0.5)),
      ],
    );
  }
  //All Task
  Widget allTaskTabBar (){
    return Column(
      children: [
        WidgetUtils.commonSizedBox(
          height: 100,
          child: const Image(
            image: NetworkImage('https://img.freepik.com/free-vector/phone-customization-concept-illustration_114360-4313.jpg?w=740&t=st=1706681307~exp=1706681907~hmac=8f1c6ec99afe4718ced3a79d82c4a2ac18e02ac10e72275d713f62911d901586'),
          ),
        ),
        WidgetUtils.commonTextWidget(text: 'No task assigned!', textColor: AppConstant.blackColor),
        WidgetUtils.commonTextWidget(text: 'New task will be notified', textColor: AppConstant.blackColor.withOpacity(0.5)),
      ],
    );
  }
}
