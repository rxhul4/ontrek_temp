import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:ontrek/core/common_widgets/custom_upgrader_message.dart';
import 'package:ontrek/core/storage/preference_helper.dart';
import 'package:ontrek/core/utils/app_constant.dart';
import 'package:ontrek/core/utils/App_utils.dart';
import 'package:ontrek/core/utils/image_path.dart';
import 'package:ontrek/features/task_list/model/task_model.dart';
import 'package:ontrek/features/task_list/provider/task_provider.dart';
import 'package:ontrek/features/view_task/screen/view_task_screen.dart';
import 'package:provider/provider.dart';

class TaskListScreen extends StatefulWidget {
  ScrollController? scrollController;

  TaskListScreen({super.key, this.scrollController});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen>
    with TickerProviderStateMixin {
  late TabController tabController;
  int selectedIndex = 0;
  bool isRefreshing = false;
  GetAllTaskModel? getTaskModel;
  late TaskProvider taskProvider;
  String? userId;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      userId = PreferenceHelper.getString(PreferenceHelper.USER_ID);
      taskProvider = Provider.of<TaskProvider>(context, listen: false);
      taskProvider.selectedDate = DateTime.now();
      await callCallGetTaskByIdListApi(taskProvider: taskProvider);

    });
    tabController = TabController(length: 2, vsync: this);
  }

  callCallGetTaskByIdListApi({required TaskProvider taskProvider}) {
    taskProvider.apiCallGetTaskByIdList(
        date: taskProvider.selectedDate.toString());
  }

  @override
  Widget build(BuildContext context) {
    taskProvider = Provider.of<TaskProvider>(context);
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: AppConstant.whiteColor,

      // appBar: AppUtils.commonAppBar(
      //   context: context,
      //   title: "Task",
      //   isBack: true,
      //   isBorder: false,
      //   isCenter: true,
      //   isActionWidgetAvailable: true,
      //   actions: [
      //
      //     commonIconWidget(
      //             iconData: Icons.repeat,
      //             iconColor: AppConstant.appPrimaryColor,
      //             onTap: () {
      //               callCallGetTaskByIdListApi(taskProvider: taskProvider);
      //             },
      //           ),
      //     AppUtils.commonSizedBox(width: 15)
      //
      //   ]
      // ),
      body: SafeArea(
        child: Column(
          children: [

            AppUtils.buildHeader(
                height: height,
                width: width,
                borderRadius: 0,
                leadingOnTap: () {
                  Navigator.pop(context);
                },
                actionWidget: [
                  commonIconWidget(
                    iconData: Icons.calendar_month_rounded,
                    onTap: openDatePicker,
                  ),
                  AppUtils.commonSizedBox(width: 10),
                  commonIconWidget(
                    iconData: Icons.repeat,
                    onTap: () {
                      callCallGetTaskByIdListApi(taskProvider: taskProvider);
                    },
                  ),
                ],
                title: "Task",
                subTitle: "Select a Task",
                backgroundColor: AppConstant.whiteColor,
                leadingImage: taskIconPath),

            AppUtils.commonContainer(
              height: 30,
              margin: EdgeInsets.only(top: 20, left: 30, right: 30, bottom: 20),
              decoration: AppUtils.commonBoxDecoration(
                color: AppConstant.greyColor.withOpacity(0.2),
                borderRadius: AppUtils.borderRadiusAll(raduis: 5),
              ),
              child: TabBar.secondary(
                  onTap: (value) {
                    setState(() {
                      selectedIndex = value;
                    });
                    callCallGetTaskByIdListApi(taskProvider: taskProvider);
                  },
                  physics: const NeverScrollableScrollPhysics(),
                  isScrollable: false,
                  indicatorSize: TabBarIndicatorSize.tab,
                  controller: tabController,
                  padding: AppUtils.edgeInsetsAll(allPadding: 2),
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
                    assignedToMeTabBar(height, width),
                    allTaskTabBar(height, width)
                  ],
                ))

          ],
        ),
      ),
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
  Widget assignedToMeTabBar(height, width) {
    return taskProvider.isFetching
        ? Column(
      mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Align(
                  alignment: Alignment.center,
                  child: AppUtils.loaderWidget()),
            ],
          )
        : (taskProvider.getAllTaskModel?.data?.where((element) => element.assignedTo == userId && element.taskStatus != "Complete",).toList().length ?? 0) <= 0 ||
                taskProvider.getAllTaskModel?.data?.where((element) => element.assignedTo == userId && element.taskStatus != "Complete",).toList() == null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // AppUtils.commonSizedBox(height: 15),
                  AppUtils.commonSizedBox(
                    height: 100,
                    child: const Image(
                      image: AssetImage(noDataFound),
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
              )
            : SingleChildScrollView(
                // controller: p0,
      physics: BouncingScrollPhysics(),
                child: Padding(
                  padding:
                  const EdgeInsets.only(left: 15, right: 15, bottom: 100 ,top: 0),
                  child: taskListWidget(taskProvider.getAllTaskModel?.data
                          ?.where((element) =>
                              element.assignedTo == userId &&
                              element.taskStatus != "Complete")
                          .toList() ??
                      []),
                ),
              );
  }

  //All Task
  Widget allTaskTabBar(
    height,
    width,
  ) {
    return taskProvider.isFetching
        ? Column(
      mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AppUtils.loaderWidget(),
            ],
          )
        : taskProvider.getAllTaskModel?.data?.length == null ||
                (taskProvider.getAllTaskModel?.data?.length ?? 0) <= 0
            ? Column(
                children: [
                  AppUtils.commonSizedBox(height: 15),
                  AppUtils.commonSizedBox(
                    height: 100,
                    child: const Image(
                      image: AssetImage(noDataFound),
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
              )
            : SingleChildScrollView(
        physics: BouncingScrollPhysics(),
                child: Padding(
                  padding:
                      const EdgeInsets.only(left: 15, right: 15, bottom: 100 ,top: 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppUtils.commonTextWidget(
                          text: "Active Task",
                          fontSize: 12,
                          textColor: AppConstant.blackColor.withOpacity(0.9),
                          fontWeight: FontWeight.w500),
                      allTaskListWidget(taskProvider.getAllTaskModel?.data
                              ?.where(
                                  (element) => element.taskStatus != "Overdue")
                              .toList() ??
                          []),
                      AppUtils.commonSizedBox(height: 15),
                      AppUtils.commonTextWidget(
                          text: "Overdue Task",
                          fontSize: 12,
                          textColor: AppConstant.blackColor.withOpacity(0.9),
                          fontWeight: FontWeight.w500),
                      allTaskListWidget(taskProvider.getAllTaskModel?.data
                              ?.where(
                                  (element) => element.taskStatus == "Overdue")
                              .toList() ??
                          []),
                    ],
                  ),
                ),
              );
  }

  Widget taskListWidget(List<Data> allTaskDataList) {
    // return (allTaskDataList.length ?? 0) <= 0
    //     ? Column(
    //         mainAxisAlignment: MainAxisAlignment.center,
    //         crossAxisAlignment: CrossAxisAlignment.center,
    //         children: [
    //           AppUtils.commonSizedBox(height: 15),
    //           Center(
    //             child: AppUtils.commonSizedBox(
    //               height: 100,
    //               child: const Image(
    //                 image: AssetImage(noDataFound),
    //               ),
    //             ),
    //           ),
    //           AppUtils.commonTextWidget(
    //             text: 'No task Found',
    //             textColor: AppConstant.blackColor.withOpacity(0.6),
    //             fontSize: 14,
    //             fontWeight: FontWeight.w500,
    //             letterSpacing: 0,
    //           ),
    //         ],
    //       )
    //     :
    return ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: allTaskDataList.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      CupertinoPageRoute(
                          builder: (context) => ViewTaskScreen(
                                taskFormId: allTaskDataList[index].taskFormId,
                                taskTitle: allTaskDataList[index].taskTitle,
                                taskStatus: allTaskDataList[index].taskStatus,
                              ))).then((value) {
                    callCallGetTaskByIdListApi(taskProvider: taskProvider);
                  });
                },
                child: AppUtils.commonContainer(
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
                              spreadRadius: 0.1),
                        ]),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            commonIconWidget(
                                iconData: Icons.calendar_month_rounded,
                                size: 16,
                                iconColor:
                                    AppConstant.greyColor.withOpacity(0.8)),
                            AppUtils.commonSizedBox(width: 5),
                            AppUtils.commonTextWidget(
                                text: AppUtils.getDate(
                                    date:
                                        allTaskDataList[index].createdOn ?? "",
                                    format: "dd MMM yyyy"),
                                textColor:
                                    AppConstant.greyColor.withOpacity(0.8),
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
                                        "${allTaskDataList[index].taskTitle} - ${allTaskDataList[index].taskDescription} ",
                                    textColor:
                                        AppConstant.blackColor.withOpacity(0.9),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    overflow: TextOverflow.ellipsis,
                                    letterSpacing: -0.1)),
                            AppUtils.commonSizedBox(width: 15),
                            AppUtils.commonTextWidget(
                              text: AppUtils.getDate(
                                  date: allTaskDataList[index].createdOn ?? "",
                                  format: "hh:mm a"),
                              textColor:
                                  AppConstant.blackColor.withOpacity(0.9),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                        AppUtils.commonSizedBox(height: 5),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Expanded(
                            //   child: Row(
                            //     children: [
                            //       Icon(
                            //         Icons.location_on,
                            //         size: 14,
                            //         color: AppConstant.appPrimaryColor,
                            //       ),
                            //       Expanded(
                            //           child: AppUtils.commonTextWidget(
                            //               text: "Tomato's Restaurant uisadjfasfhg",
                            //               textColor:
                            //                   AppConstant.greyColor.withOpacity(0.8),
                            //               fontSize: 10,
                            //               fontWeight: FontWeight.w500,
                            //               overflow: TextOverflow.ellipsis)),
                            //       AppUtils.commonSizedBox(width: 10),
                            //     ],
                            //   ),
                            // ),
                            Expanded(
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.person,
                                    size: 14,
                                    color: Colors.red,
                                  ),
                                  AppUtils.commonSizedBox(width: 5),
                                  Expanded(
                                      child: AppUtils.commonTextWidget(
                                          text: allTaskDataList[index]
                                                  .createdBy ??
                                              "",
                                          textColor: AppConstant.greyColor
                                              .withOpacity(0.8),
                                          fontSize: 10,
                                          fontWeight: FontWeight.w500,
                                          overflow: TextOverflow.ellipsis)),
                                  AppUtils.commonSizedBox(width: 30),
                                ],
                              ),
                            ),
                            AppUtils.commonContainer(
                                padding: AppUtils.edgeInsetsOnly(
                                    bottom: 3, top: 3, left: 10, right: 10),
                                decoration: AppUtils.commonBoxDecoration(
                                    borderRadius: BorderRadius.circular(6),
                                    color: AppUtils.switchCaseForTaskStatus(
                                        allTaskDataList[index].taskStatus ??
                                            "")),
                                child: AppUtils.commonTextWidget(
                                    text:
                                        allTaskDataList[index].taskStatus ?? "",
                                    fontWeight: FontWeight.w400,
                                    textColor: AppConstant.whiteColor,
                                    fontSize: 10))
                          ],
                        )
                      ],
                    )),
              );
            },
          );
  }

  Widget allTaskListWidget(List<Data> allTaskDataList) {
    return (allTaskDataList.length ?? 0) <= 0
        ? Align(
      alignment: Alignment.center,
          child: Column(
            children: [
          AppUtils.commonSizedBox(height: 15),
          AppUtils.commonSizedBox(
            height: 100,
            child: const Image(
              image: AssetImage(noDataFound),
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
              ),
        )
        :
   ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: allTaskDataList.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            Navigator.push(
                context,
                CupertinoPageRoute(
                    builder: (context) => ViewTaskScreen(
                      taskFormId: allTaskDataList[index].taskFormId,
                      taskTitle: allTaskDataList[index].taskTitle,
                      taskStatus: allTaskDataList[index].taskStatus,
                    ))).then((value) {
              callCallGetTaskByIdListApi(taskProvider: taskProvider);
            });
          },
          child: AppUtils.commonContainer(
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
                        spreadRadius: 0.1),
                  ]),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      commonIconWidget(
                          iconData: Icons.calendar_month_rounded,
                          size: 16,
                          iconColor:
                          AppConstant.greyColor.withOpacity(0.8)),
                      AppUtils.commonSizedBox(width: 5),
                      AppUtils.commonTextWidget(
                          text: AppUtils.getDate(
                              date:
                              allTaskDataList[index].createdOn ?? "",
                              format: "dd MMM yyyy"),
                          textColor:
                          AppConstant.greyColor.withOpacity(0.8),
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
                              "${allTaskDataList[index].taskTitle} - ${allTaskDataList[index].taskDescription} ",
                              textColor:
                              AppConstant.blackColor.withOpacity(0.9),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              overflow: TextOverflow.ellipsis,
                              letterSpacing: -0.1)),
                      AppUtils.commonSizedBox(width: 15),
                      AppUtils.commonTextWidget(
                        text: AppUtils.getDate(
                            date: allTaskDataList[index].createdOn ?? "",
                            format: "hh:mm a"),
                        textColor:
                        AppConstant.blackColor.withOpacity(0.9),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                  AppUtils.commonSizedBox(height: 5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Expanded(
                      //   child: Row(
                      //     children: [
                      //       Icon(
                      //         Icons.location_on,
                      //         size: 14,
                      //         color: AppConstant.appPrimaryColor,
                      //       ),
                      //       Expanded(
                      //           child: AppUtils.commonTextWidget(
                      //               text: "Tomato's Restaurant uisadjfasfhg",
                      //               textColor:
                      //                   AppConstant.greyColor.withOpacity(0.8),
                      //               fontSize: 10,
                      //               fontWeight: FontWeight.w500,
                      //               overflow: TextOverflow.ellipsis)),
                      //       AppUtils.commonSizedBox(width: 10),
                      //     ],
                      //   ),
                      // ),
                      Expanded(
                        child: Row(
                          children: [
                            Icon(
                              Icons.person,
                              size: 14,
                              color: Colors.red,
                            ),
                            AppUtils.commonSizedBox(width: 5),
                            Expanded(
                                child: AppUtils.commonTextWidget(
                                    text: allTaskDataList[index]
                                        .createdBy ??
                                        "",
                                    textColor: AppConstant.greyColor
                                        .withOpacity(0.8),
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                    overflow: TextOverflow.ellipsis)),
                            AppUtils.commonSizedBox(width: 30),
                          ],
                        ),
                      ),
                      AppUtils.commonContainer(
                          padding: AppUtils.edgeInsetsOnly(
                              bottom: 3, top: 3, left: 10, right: 10),
                          decoration: AppUtils.commonBoxDecoration(
                              borderRadius: BorderRadius.circular(6),
                              color: AppUtils.switchCaseForTaskStatus(
                                  allTaskDataList[index].taskStatus ??
                                      "")),
                          child: AppUtils.commonTextWidget(
                              text:
                              allTaskDataList[index].taskStatus ?? "",
                              fontWeight: FontWeight.w400,
                              textColor: AppConstant.whiteColor,
                              fontSize: 10))
                    ],
                  )
                ],
              )),
        );
      },
    );
  }

  Future<void> openDatePicker() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: taskProvider.selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      initialEntryMode: DatePickerEntryMode.calendarOnly,
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
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
            )
                .copyWith(background: AppConstant.whiteColor)
                .copyWith(background: AppConstant.whiteColor),
            // Other theme modifications as needed...
          ),
          child: child ?? Container(),
        );
      },
    );

    if (picked != null && picked != taskProvider.selectedDate) {
      setState(() {
        taskProvider.selectedDate = picked;
      });
      callCallGetTaskByIdListApi(taskProvider: taskProvider);
    }
  }
}
