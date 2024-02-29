import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:ontrek/core/utils/app_constant.dart';
import 'package:ontrek/core/utils/App_utils.dart';
import 'package:ontrek/features/add_task/screen/add_task_screen.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class TaskListScreen extends StatefulWidget {
  ScrollController? scrollController;

  TaskListScreen({super.key, this.scrollController});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen>
    with TickerProviderStateMixin {
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
              selectionColor:
                  AppConstant.appPrimaryColor, // Selected date color
            ),
            colorScheme: ColorScheme.light(
              background: Colors.white,
              onBackground: AppConstant.greyColor.withOpacity(0.5),
              primary: AppConstant.appPrimaryColor, // Button color
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

  late TabController tabController;
  int selectedIndex = 0;
  bool isRefreshing = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      panelController.animatePanelToSnapPoint(
          duration: Duration(milliseconds: 0));
    });
    tabController = TabController(length: 2, vsync: this);
    tabController.addListener(() {
      setState(() {
        selectedIndex = tabController.index;
      });
    });
  }

  PanelController panelController = PanelController();

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return AppUtils.commonSlidePanel(
      panelSnapping: true,
      maxHeight: height,
      minHeight: height * 0.09,
      controller: panelController,
      isDraggable: true,
      snapPoint: 0.35,
      panelBuilder: (p0) {
        return Column(
          children: [
            AppUtils.buildHeader(
                height: height,
                width: width,
                actionWidget: [
                  commonIconWidget(
                    iconData: Icons.calendar_month_rounded,
                    onTap: openDatePicker,
                  ),
                  AppUtils.commonSizedBox(width: 10),
                  commonIconWidget(iconData: Icons.repeat, onTap: refresh),
                ],
                title: "Task",
                subTitle: "Select a Task",
                backgroundColor: AppConstant.whiteColor,
                leadingImage:
                    "https://media.istockphoto.com/id/1256489977/vector/tasks-check-checklist-blue-icon.jpg?s=612x612&w=0&k=20&c=dUctYWRSmMz1uiSFCCcJUKOyeoxVbvPuLugf8CLQiSo="),
            AppUtils.commonContainer(
              height: 30,
              margin: EdgeInsets.only(top: 20, left: 30, right: 30,bottom: 20),
              decoration: AppUtils.commonBoxDecoration(
                color: AppConstant.greyColor.withOpacity(0.2),
                borderRadius: AppUtils.borderRadiusAll(raduis: 5),
              ),
              child: TabBar.secondary(
                physics: NeverScrollableScrollPhysics(),

                  isScrollable: false,
                  indicatorSize: TabBarIndicatorSize.tab,
                  controller: tabController,
                  padding: AppUtils.edgeInsetsAll(allPadding: 2),
                  // enableFeedback: true,
                  labelColor: Colors.white,
                  unselectedLabelStyle: const TextStyle(
                    fontFamily: "Poppins",
                    letterSpacing: 0.2,
                    fontWeight: FontWeight.w400,
                    fontSize: 12,
                  ),
                  indicatorWeight: 0,
                  dividerHeight: 0,
                  labelStyle: const TextStyle(
                    fontFamily: "Poppins",
                    letterSpacing: 0.2,
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
                  automaticIndicatorColorAdjustment: true,
                  indicator: BoxDecoration(
                      color: AppConstant.appPrimaryColor,
                      borderRadius: AppUtils.borderRadiusAll(raduis: 5)),
                  tabs: const [
                    Tab(text: 'ASSIGNED TO ME'),
                    Tab(text: 'All TASK'),
                  ]),
            ),
            Expanded(
                child: TabBarView(
                   physics: NeverScrollableScrollPhysics(),
              controller: tabController,
              children: [assignedToMeTabBar(height,width,p0), allTaskTabBar(height,width,p0)],
            ))
          ],
        );
      },
    );
  }

//Icon
  Widget commonIconWidget(
      {Function()? onTap, IconData? iconData, Color? iconColor}) {
    return InkWell(
      onTap: onTap,
      child: Icon(
        iconData,
        size: 26,
        color: iconColor ?? AppConstant.blackColor.withOpacity(0.6),
      ),
    );
  }

  //assigned to me
  Widget assignedToMeTabBar(height,width,p0) {
    return isRefreshing
        ? Padding(
            padding: const EdgeInsets.only(top: 80),
            child: Align(
                alignment: Alignment.topCenter,
                child: CircularProgressIndicator(
                  color: AppConstant.appPrimaryColor,
                )),
          )
        : Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              AppUtils.commonSizedBox(height: 15),
              AppUtils.commonSizedBox(
                height: 100,
                child: const Image(
                  image: NetworkImage(
                      'https://img.freepik.com/free-vector/phone-customization-concept-illustration_114360-4313.jpg?w=740&t=st=1706681307~exp=1706681907~hmac=8f1c6ec99afe4718ced3a79d82c4a2ac18e02ac10e72275d713f62911d901586'),
                ),
              ),
              AppUtils.commonTextWidget(
                text: 'No task assigned!',
                textColor: AppConstant.blackColor.withOpacity(0.6),
                fontSize: 14,
                fontWeight: FontWeight.w500,
                letterSpacing: 0,
              ),
              AppUtils.commonTextWidget(
                  letterSpacing: 0,
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  text: 'New task will be notified',
                  textColor: AppConstant.blackColor.withOpacity(0.5)),
            ],
          );
  }

  //All Task
  Widget allTaskTabBar(height,width,p0) {
    return isRefreshing
        ? Padding(
            padding: const EdgeInsets.only(top: 80),
            child: Align(
                alignment: Alignment.topCenter,
                child: CircularProgressIndicator(
                  color: AppConstant.appPrimaryColor,
                )),
          )
        : Column(
            children: [
              AppUtils.commonSizedBox(height: 15),
              AppUtils.commonSizedBox(
                height: 100,
                child: const Image(
                  image: NetworkImage(
                      'https://img.freepik.com/free-vector/phone-customization-concept-illustration_114360-4313.jpg?w=740&t=st=1706681307~exp=1706681907~hmac=8f1c6ec99afe4718ced3a79d82c4a2ac18e02ac10e72275d713f62911d901586'),
                ),
              ),
              AppUtils.commonTextWidget(
                text: 'No task assigned!',
                textColor: AppConstant.blackColor.withOpacity(0.6),
                fontSize: 14,
                fontWeight: FontWeight.w500,
                letterSpacing: 0,
              ),
              AppUtils.commonTextWidget(
                  letterSpacing: 0,
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  text: 'New task will be notified',
                  textColor: AppConstant.blackColor.withOpacity(0.5)),
            ],
          );
    // :   ListView.builder(
    //   controller: p0,
    //   itemCount: 50,
    //   shrinkWrap: true,
    //
    //   // physics: NeverScrollableScrollPhysics(),
    //   padding: AppUtils.edgeInsetsOnly(
    //       bottom: 100, left: 10,right: 10),
    //   itemBuilder: (BuildContext context, int index) {
    //     return Text("${index}");
    //   },
    // );
  }



  refresh() async {
    setState(() {
      isRefreshing = true;
    });

    // Simulate a delay to show the refresh indicator for 3 seconds.
    await Future.delayed(const Duration(seconds: 3));

    setState(() {
      isRefreshing = false;
    });
  }
}
