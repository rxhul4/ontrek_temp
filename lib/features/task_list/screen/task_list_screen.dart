import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:ontrek/core/utils/app_constant.dart';
import 'package:ontrek/core/utils/App_utils.dart';
import 'package:ontrek/features/add_task/screen/add_task_screen.dart';

class TaskListScreen extends StatefulWidget {
  ScrollController? scrollController;

  TaskListScreen({super.key, this.scrollController});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen>
    with TickerProviderStateMixin {
  DraggableScrollableController draggableScrollableController =
      DraggableScrollableController();
  DateTime? selectedDate;

  Future<void> openDatePicker() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      initialEntryMode: DatePickerEntryMode.calendarOnly,
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            backgroundColor: AppConstant.whiteColor,
            dialogBackgroundColor: AppConstant.whiteColor,
            scaffoldBackgroundColor: AppConstant.whiteColor,
            textSelectionTheme: TextSelectionThemeData(
              selectionColor: AppConstant.blueColor, // Selected date color
            ),
            colorScheme: ColorScheme.light(
              background: Colors.white,
              onBackground: AppConstant.greyColor.withOpacity(0.5),
              primary: AppConstant.blueColor, // Button color
              onPrimary: AppConstant.whiteColor, // Text color on button
            ).copyWith(background: AppConstant.whiteColor),
            // Other theme modifications as needed...
          ),
          child: child ?? Container(),
        );
      },
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        // historyDateController.text =
        //     dateFormat.format(picked); // Format date as dd-MM-yyyy
      });
      // callGetTimeline(getMdl);
    }
  }

  Future NavigateToAddTaskScreen() async {
    Navigator.push(
        context,
        DialogRoute(
          context: context,
          builder: (context) => AddTaskScreen(),
        ));
  }

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
        decoration: AppUtils.commonBoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                spreadRadius: 0,
                blurRadius: 8,
                offset: Offset(0, -10), // This will create a top shadow
              ),
            ],
            borderRadius:
                AppUtils.borderRadiousonly(topright: 18, topleft: 18),
            color: AppConstant.whiteColor),
        child: SingleChildScrollView(
          controller: widget.scrollController,
          child: Column(
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
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Column(
                    children: [
                      AppUtils.commonContainer(
                        width: 30,
                        height: 5,
                        decoration: AppUtils.commonBoxDecoration(
                            color: AppConstant.greyColor.withOpacity(0.3),
                            borderRadius:
                                AppUtils.borderRadiusAll(raduis: 12)),
                      ),
                      Row(
                        children: [
                          AppUtils.commonContainer(
                            height: 45,
                            width: 45,
                            decoration: AppUtils.commonBoxDecoration(
                              shape: BoxShape.circle,
                              color: AppConstant.blueColor,
                              border:
                                  Border.all(color: Colors.grey, width: 1.2),
                            ),
                          ),
                          AppUtils.commonSizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                AppUtils.commonTextWidget(
                                  text: "Task",
                                  fontWeight: FontWeight.w600,
                                  textColor: AppConstant.blackColor,
                                  letterSpacing: 0.2,
                                  fontSize: 15,
                                ),
                                AppUtils.commonTextWidget(
                                  text: "Select a task",
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
                            iconData: Icons.calendar_month,
                            onTap: openDatePicker,
                          ),
                          AppUtils.commonSizedBox(width: 10),
                          commonIconWidget(
                            iconData: Icons.add,
                            onTap: NavigateToAddTaskScreen,
                          ),
                          AppUtils.commonSizedBox(width: 10),
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
              Padding(
                padding:
                    AppUtils.edgeInsetsOnly(top: 15, left: 30, right: 30),
                child: Column(
                  children: [
                    AppUtils.commonContainer(
                        width: MediaQuery.of(context).size.width,
                        height: 30,
                        decoration: AppUtils.commonBoxDecoration(
                            color: AppConstant.greyColor.withOpacity(0.2),
                            borderRadius:
                                AppUtils.borderRadiusAll(raduis: 5)),
                        child: TabBar(
                            controller: tabController,
                            indicatorWeight: 0,
                            dividerHeight: 0.1,
                            indicatorSize: TabBarIndicatorSize.tab,
                            padding: AppUtils.edgeInsetsAll(allPadding: 2.5),
                            indicator: BoxDecoration(
                                color: AppConstant.blueColor,
                                borderRadius:
                                    AppUtils.borderRadiusAll(raduis: 5)),
                            labelColor: Colors.white,
                            labelStyle: const TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 12,
                            ),
                            unselectedLabelColor: Colors.black.withOpacity(0.5),
                            unselectedLabelStyle: const TextStyle(
                              fontWeight: FontWeight.w400,
                              fontSize: 12,
                            ),
                            tabs: const [
                              Tab(text: 'ASSIGNED TO ME'),
                              Tab(text: 'All TASK'),
                            ])),
                    SizedBox(
                      height: MediaQuery.of(context).size.height / 1.5,
                      child: TabBarView(
                          controller: tabController,
                          physics: NeverScrollableScrollPhysics(),
                          children: <Widget>[
                            assignedToMeTabBar(),
                            allTaskTabBar(),
                          ]),
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
    return InkWell(
      onTap: onTap,
      child: Icon(
        iconData,
        size: 26,
        color: AppConstant.blackColor.withOpacity(0.6),
      ),
    );
  }

  //assigned to me
  Widget assignedToMeTabBar() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        AppUtils.commonSizedBox(
          height: 100,
          child: const Image(
            image: NetworkImage(
                'https://img.freepik.com/free-vector/phone-customization-concept-illustration_114360-4313.jpg?w=740&t=st=1706681307~exp=1706681907~hmac=8f1c6ec99afe4718ced3a79d82c4a2ac18e02ac10e72275d713f62911d901586'),
          ),
        ),
        AppUtils.commonTextWidget(
            text: 'No task assigned!', textColor: AppConstant.blackColor),
        AppUtils.commonTextWidget(
            text: 'New task will be notified',
            textColor: AppConstant.blackColor.withOpacity(0.5)),
      ],
    );
  }

  //All Task
  Widget allTaskTabBar() {
    return Column(
      children: [
        AppUtils.commonSizedBox(
          height: 100,
          child: const Image(
            image: NetworkImage(
                'https://img.freepik.com/free-vector/phone-customization-concept-illustration_114360-4313.jpg?w=740&t=st=1706681307~exp=1706681907~hmac=8f1c6ec99afe4718ced3a79d82c4a2ac18e02ac10e72275d713f62911d901586'),
          ),
        ),
        AppUtils.commonTextWidget(
            text: 'No task assigned!', textColor: AppConstant.blackColor),
        AppUtils.commonTextWidget(
            text: 'New task will be notified',
            textColor: AppConstant.blackColor.withOpacity(0.5)),
      ],
    );
  }
}
