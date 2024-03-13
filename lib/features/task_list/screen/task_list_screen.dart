import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:ontrek/core/utils/app_constant.dart';
import 'package:ontrek/core/utils/App_utils.dart';
import 'package:ontrek/core/utils/image_path.dart';
import 'package:ontrek/features/add_task/screen/add_task_screen.dart';
import 'package:ontrek/features/task_list/model/task_model.dart';
import 'package:ontrek/features/task_list/provider/task_provider.dart';
import 'package:provider/provider.dart';
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
  PanelController panelController = PanelController();
  late TabController tabController;
  int selectedIndex = 0;
  bool isRefreshing = false;
  GetTaskModel? getTaskModel;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    selectedDate = DateTime.now();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      panelController.animatePanelToSnapPoint(
          duration: Duration(milliseconds: 0));
      final getMdl = Provider.of<TaskProvider>(context, listen: false);
      callGetSalesManListApi(getMdl);
    });
    tabController = TabController(length: 2, vsync: this);
    tabController.addListener(() {
      setState(() {
        selectedIndex = tabController.index;
      });
    });
  }

  callGetSalesManListApi(TaskProvider getMdl) {
    if (kDebugMode) {
      print("taskApi");
    }

    getMdl
        .apiCallGetTaskByIdList(
            date: AppUtils.getDate(
                date: selectedDate.toString(), format: AppConstant.dateFormat))
        .then((value) {
      getTaskModel = value;
      if (getTaskModel?.isError == false &&
          getTaskModel?.isValidationFailed == false) {
      } else {
        if(!mounted){}
        AppUtils.dialogWidget(getTaskModel?.message ?? "",context);
      }
    });
  }

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
                    taskIconPath),
            AppUtils.commonContainer(
              height: 30,
              margin: EdgeInsets.only(top: 20, left: 30, right: 30, bottom: 20),
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
              children: [
                assignedToMeTabBar(height, width, p0),
                allTaskTabBar(height, width, p0)
              ],
            ))
          ],
        );
      },
    );
  }

//Icon
  Widget commonIconWidget(
      {Function()? onTap, IconData? iconData, Color? iconColor, double? size}) {
    return InkWell(
      onTap: onTap,
      child: Icon(
        iconData,
        size: size ?? 26,
        color: iconColor ?? AppConstant.blackColor.withOpacity(0.6),
      ),
    );
  }

  //assigned to me
  Widget assignedToMeTabBar(height, width, p0) {
    return isRefreshing
        ? Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 80),
                child: Align(
                    alignment: Alignment.topCenter,
                    child: AppUtils.loaderWidget()),
              ),
            ],
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
  Widget allTaskTabBar(height, width, p0) {
    return isRefreshing
        ? Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 80),
                child: AppUtils.loaderWidget(),
              ),
            ],
          )
        // : Column(
        //     children: [
        //       AppUtils.commonSizedBox(height: 15),
        //       AppUtils.commonSizedBox(
        //         height: 100,
        //         child: const Image(
        //           image: NetworkImage(
        //               'https://img.freepik.com/free-vector/phone-customization-concept-illustration_114360-4313.jpg?w=740&t=st=1706681307~exp=1706681907~hmac=8f1c6ec99afe4718ced3a79d82c4a2ac18e02ac10e72275d713f62911d901586'),
        //         ),
        //       ),
        //       AppUtils.commonTextWidget(
        //         text: 'No task assigned!',
        //         textColor: AppConstant.blackColor.withOpacity(0.6),
        //         fontSize: 14,
        //         fontWeight: FontWeight.w500,
        //         letterSpacing: 0,
        //       ),
        //       AppUtils.commonTextWidget(
        //           letterSpacing: 0,
        //           fontSize: 12,
        //           fontWeight: FontWeight.w400,
        //           text: 'New task will be notified',
        //           textColor: AppConstant.blackColor.withOpacity(0.5)),
        //     ],
        //   );
        : SingleChildScrollView(
            controller: p0,
            child: Padding(
              padding: const EdgeInsets.only(left: 10, right: 10, bottom: 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppUtils.commonTextWidget(
                      text: "Active Task",
                      fontSize: 12,
                      textColor: AppConstant.blackColor.withOpacity(0.9),
                      fontWeight: FontWeight.w500),
                  activeTaskList(),
                  AppUtils.commonSizedBox(height: 15),
                  AppUtils.commonTextWidget(
                      text: "Overdue Task",
                      fontSize: 12,
                      textColor: AppConstant.blackColor.withOpacity(0.9),
                      fontWeight: FontWeight.w500),
                  overDueTaskList(),
                ],
              ),
            ),
          );
  }

  Widget activeTaskList() {
    return ListView.builder(
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: 15,
      itemBuilder: (context, index) {
        return AppUtils.commonContainer(
            margin: AppUtils.edgeInsetsOnly(
              top: 12,
            ),
            padding: AppUtils.edgeInsetsOnly(
                left: 10, right: 10, top: 10, bottom: 10),
            width: double.infinity,
            decoration: AppUtils.commonBoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: AppConstant.whiteColor,
                boxShadow: [
                  BoxShadow(
                      color: AppConstant.greyColor.withOpacity(0.2),
                      blurRadius: 8,
                      blurStyle: BlurStyle.solid,
                      spreadRadius: 0.1
                  ),
                ]),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // AppUtils.commonContainer(
                //   width: 50,
                //   height: 50,
                //   color: Colors.red
                // ),
                Row(
                  children: [
                    commonIconWidget(
                        iconData: Icons.calendar_month_rounded,
                        size: 16,
                        iconColor: AppConstant.greyColor.withOpacity(0.8)),
                    AppUtils.commonSizedBox(width: 5),
                    AppUtils.commonTextWidget(
                        text: "28 Feb 2024",
                        textColor: AppConstant.greyColor.withOpacity(0.8),
                        fontSize: 10,
                        fontWeight: FontWeight.w500)
                  ],
                ),
                AppUtils.commonSizedBox(height: 5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                        child: AppUtils.commonTextWidget(
                            text:
                                "Test Customer - Payment Collectionsdjlkasdfgasd",
                            textColor: AppConstant.blackColor.withOpacity(0.9),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            overflow: TextOverflow.ellipsis,
                            letterSpacing: -0.1)),
                    AppUtils.commonSizedBox(width: 15),
                    AppUtils.commonTextWidget(
                        text: "11:42 AM",
                        textColor: AppConstant.blackColor.withOpacity(0.9),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        overflow: TextOverflow.ellipsis,
                        margin: AppUtils.edgeInsetsOnly(left: 10)),
                  ],
                ),
                // AppUtils.commonSizedBox(height: 5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 14,
                            color: AppConstant.appPrimaryColor,
                          ),
                          Expanded(
                              child: AppUtils.commonTextWidget(
                                  text: "Tomato's Restaurant uisadjfasfhg",
                                  textColor:
                                      AppConstant.greyColor.withOpacity(0.8),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                  overflow: TextOverflow.ellipsis)),
                          AppUtils.commonSizedBox(width: 10),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Row(
                        children: [
                          Icon(
                            Icons.person,
                            size: 14,
                            color: Colors.red,
                          ),
                          Expanded(
                              child: AppUtils.commonTextWidget(
                                  text: "Mahesh Patelsjdfkjsadfjkasdhkfj",
                                  textColor:
                                      AppConstant.greyColor.withOpacity(0.8),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                  overflow: TextOverflow.ellipsis)),
                          AppUtils.commonSizedBox(width: 30),
                        ],
                      ),
                    ),
                    AppUtils.commonContainer(
                        padding: AppUtils.edgeInsetsOnly(
                            bottom: 3, top: 3, left: 15, right: 15),
                        decoration: AppUtils.commonBoxDecoration(
                            borderRadius: BorderRadius.circular(6),
                            color: Colors.red),
                        child: AppUtils.commonTextWidget(
                            text: "Overdue",
                            fontWeight: FontWeight.w400,
                            textColor: AppConstant.whiteColor,
                            fontSize: 10))
                  ],
                )
              ],
            ));
      },
    );
  }

  Widget overDueTaskList() {
    return ListView.builder(
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: 15,
      itemBuilder: (context, index) {
        return AppUtils.commonContainer(
            margin: AppUtils.edgeInsetsOnly(
              top: 12,
            ),
            padding: AppUtils.edgeInsetsOnly(
                left: 10, right: 10, top: 12, bottom: 12),
            width: double.infinity,
            decoration: AppUtils.commonBoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: AppConstant.whiteColor,
                boxShadow: [
                  BoxShadow(
                      color: AppConstant.greyColor.withOpacity(0.2),
                      blurRadius: 8,
                      blurStyle: BlurStyle.solid,
                      spreadRadius: 0.1
                  ),
                ]),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // AppUtils.commonContainer(
                //   width: 50,
                //   height: 50,
                //   color: Colors.red
                // ),
                Row(
                  children: [
                    commonIconWidget(
                        iconData: Icons.calendar_month_rounded,
                        size: 16,
                        iconColor: AppConstant.greyColor.withOpacity(0.8)),
                    AppUtils.commonSizedBox(width: 5),
                    AppUtils.commonTextWidget(
                        text: "28 Feb 2024",
                        textColor: AppConstant.greyColor.withOpacity(0.8),
                        fontSize: 10,
                        fontWeight: FontWeight.w500)
                  ],
                ),
                AppUtils.commonSizedBox(height: 5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                        child: AppUtils.commonTextWidget(
                            text:
                                "Test Customer - Payment Collectionsdjlkasdfgasd",
                            textColor: AppConstant.blackColor.withOpacity(0.9),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            overflow: TextOverflow.ellipsis,
                            letterSpacing: -0.1)),
                    AppUtils.commonSizedBox(width: 15),
                    AppUtils.commonTextWidget(
                        text: "11:42 AM",
                        textColor: AppConstant.blackColor.withOpacity(0.9),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        overflow: TextOverflow.ellipsis,
                        margin: AppUtils.edgeInsetsOnly(left: 10)),
                  ],
                ),
                // AppUtils.commonSizedBox(height: 5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 14,
                            color: AppConstant.appPrimaryColor,
                          ),
                          Expanded(
                              child: AppUtils.commonTextWidget(
                                  text: "Tomato's Restaurant uisadjfasfhg",
                                  textColor:
                                      AppConstant.greyColor.withOpacity(0.8),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                  overflow: TextOverflow.ellipsis)),
                          AppUtils.commonSizedBox(width: 10),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Row(
                        children: [
                          Icon(
                            Icons.person,
                            size: 14,
                            color: Colors.red,
                          ),
                          Expanded(
                              child: AppUtils.commonTextWidget(
                                  text: "Mahesh Patelsjdfkjsadfjkasdhkfj",
                                  textColor:
                                      AppConstant.greyColor.withOpacity(0.8),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                  overflow: TextOverflow.ellipsis)),
                          AppUtils.commonSizedBox(width: 30),
                        ],
                      ),
                    ),
                    AppUtils.commonContainer(
                        padding: AppUtils.edgeInsetsOnly(
                            bottom: 3, top: 3, left: 15, right: 15),
                        decoration: AppUtils.commonBoxDecoration(
                            borderRadius: BorderRadius.circular(6),
                            color: Colors.red),
                        child: AppUtils.commonTextWidget(
                            text: "Overdue",
                            fontWeight: FontWeight.w400,
                            textColor: AppConstant.whiteColor,
                            fontSize: 10))
                  ],
                )
              ],
            ));
      },
    );
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
}
