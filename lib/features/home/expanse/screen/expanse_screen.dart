import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ontrek/core/utils/App_utils.dart';
import 'package:ontrek/core/utils/app_constant.dart';
import 'package:ontrek/features/home/leave/screen/apply_leave_screen.dart';

class ExpenseScreen extends StatefulWidget {
  const ExpenseScreen({super.key});

  @override
  State<ExpenseScreen> createState() => _ExpenseScreenState();
}

class _ExpenseScreenState extends State<ExpenseScreen>
    with TickerProviderStateMixin {
  late TabController tabController;
  int selectedIndex = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstant.whiteColor,
      appBar: AppUtils.commonAppBar(
          context: context, isBorder: true, isBack: true, title: "Expense"),
      floatingActionButton: GestureDetector(
        onTap: () {
          Navigator.push(context, CupertinoPageRoute(builder: (context) => ApplyLeaveScreen(),));
        },
        child: AppUtils.commonContainer(
          margin: const EdgeInsets.only(top: 20,bottom: 60,right: 10),
          padding:
          const EdgeInsets.only(top: 13, bottom: 13,right: 30,left: 30),
          decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: AppUtils.borderRadiusAll(raduis: 10)),
          child: AppUtils.commonTextWidget(text: "Add",fontWeight: FontWeight.w400,textColor: AppConstant.whiteColor,fontSize: 12,),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
                child: TabBarView(
                  physics: NeverScrollableScrollPhysics(),
                  controller: tabController,
                  children: [
                    myExpenses(),
                    employeeExpenses(),
                    // allDayEndRequests(),
                  ],
                )),
            AppUtils.commonContainer(
              height: 50,
              margin: EdgeInsets.only(top: 0, left: 0, right: 0, bottom: 0),
              decoration: AppUtils.commonBoxDecoration(
                color: AppConstant.greyColor.withOpacity(0.2),
                // borderRadius: AppUtils.borderRadiusAll(raduis: 5),
              ),
              child: TabBar.secondary(
                  onTap: (value) {
                    setState(() {
                      selectedIndex = value;
                    });
                    // callCallGetTaskByIdListApi(taskProvider: taskProvider);
                  },
                  physics: const NeverScrollableScrollPhysics(),
                  isScrollable: false,
                  indicatorSize: TabBarIndicatorSize.tab,
                  controller: tabController,
                  // padding: AppUtils.edgeInsetsAll(allPadding: 2),
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
                    // borderRadius: AppUtils.borderRadiusAll(raduis: 5)
                  ),
                  tabs: const [
                    // Tab(text: 'All'),
                    Tab(text: 'My Expenses'),
                    Tab(text: 'Employee Expenses'),
                  ]),
            ),
          ],
        ),
      ),
    );
  }

  myExpenses() {
    return ListView.builder(
      physics: BouncingScrollPhysics(),
      shrinkWrap: true,
      itemCount: 10,
      padding: AppUtils.edgeInsetsOnly(bottom: 20, top: 0, left: 0, right: 0),
      itemBuilder: (context, index) {
        return AppUtils.commonContainer(
          width: double.infinity,
          margin: const EdgeInsets.only(left: 10, right: 10, top: 20),
          padding:
          const EdgeInsets.only(left: 15, right: 15, top: 20, bottom: 20),
          decoration: BoxDecoration(
              color: AppConstant.whiteColor,
              borderRadius: AppUtils.borderRadiusAll(raduis: 10),
              boxShadow: [
                BoxShadow(
                    color: AppConstant.greyColor.withOpacity(0.3),
                    blurRadius: 8,
                    blurStyle: BlurStyle.solid,
                    spreadRadius: 0.8),
              ]),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppUtils.commonContainer(
                width: double.infinity,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      flex: 2,
                      child: Row(
                        children: [
                          const Icon(
                            Icons.person,
                            color: Colors.orangeAccent,
                            size: 18,
                          ),
                          AppUtils.commonSizedBox(width: 5),
                          Expanded(
                            child: AppUtils.commonTextWidget(
                              text: "Demo Name",
                              fontSize: 12,
                              textColor:
                              AppConstant.blackColor.withOpacity(0.9),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 40),
                    // Adjust the width as per your requirement
                    Flexible(
                      flex: 2,
                      child: Row(
                        children: [
                          const Icon(
                            Icons.timer_outlined,
                            color: Colors.green,
                            size: 15,
                          ),
                          AppUtils.commonSizedBox(width: 3),
                          Expanded(
                            child: AppUtils.commonTextWidget(
                              text: AppUtils.getDate(
                                date: "2024-07-07T23:20:00Z",
                                format: "dd MMM yyyy hh:mm a",
                              ),
                              fontSize: 12,
                              textColor:
                              AppConstant.blackColor.withOpacity(0.9),
                              fontWeight: FontWeight.w500,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              AppUtils.commonSizedBox(height: 5),
              Divider(
                color: AppConstant.greyColor.withOpacity(0.3),
              ),
              AppUtils.commonSizedBox(height: 5),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.task_sharp,
                        color: Colors.blue,
                        size: 18,
                      ),
                      AppUtils.commonSizedBox(width: 5),
                      AppUtils.commonTextWidget(
                          text: "Expense Status",
                          fontSize: 12,
                          textColor: AppConstant.blackColor.withOpacity(0.9),
                          fontWeight: FontWeight.w500)
                    ],
                  ),
                  AppUtils.commonContainer(
                      padding: AppUtils.edgeInsetsOnly(
                          bottom: 3, top: 3, left: 10, right: 10),
                      decoration: AppUtils.commonBoxDecoration(
                        borderRadius: BorderRadius.circular(6),
                        color: AppConstant.appPrimaryColor,
                      ),
                      child: AppUtils.commonTextWidget(
                          text: "Approved",
                          fontWeight: FontWeight.w400,
                          textColor: AppConstant.whiteColor,
                          fontSize: 10))
                ],
              ),
              AppUtils.commonSizedBox(height: 5),
              Divider(
                color: AppConstant.greyColor.withOpacity(0.3),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.notes,
                        color: Colors.purpleAccent,
                        size: 18,
                      ),
                      AppUtils.commonSizedBox(width: 5),
                      AppUtils.commonTextWidget(
                          text: /* viewTaskProvider
                                          .taskByIdModel?.data?.taskTitle ??*/
                          "Comment",
                          fontSize: 12,
                          textColor: AppConstant.blackColor.withOpacity(0.9),
                          fontWeight: FontWeight.w500)
                    ],
                  ),
                ],
              ),
              AppUtils.commonSizedBox(height: 8),
              AppUtils.commonTextWidget(
                  text: "Test Data for Expense approval design",
                  fontSize: 12,
                  textColor: AppConstant.blackColor.withOpacity(0.9),
                  fontWeight: FontWeight.w400),
            ],
          ),
        );
      },
    );
  }
  employeeExpenses() {
    return ListView.builder(
      physics: BouncingScrollPhysics(),
      shrinkWrap: true,
      itemCount: 10,
      padding: AppUtils.edgeInsetsOnly(bottom: 20, top: 0, left: 0, right: 0),
      itemBuilder: (context, index) {
        return AppUtils.commonContainer(
          width: double.infinity,
          margin: const EdgeInsets.only(left: 10, right: 10, top: 20),
          padding:
          const EdgeInsets.only(left: 15, right: 15, top: 20, bottom: 0),
          decoration: BoxDecoration(
              color: AppConstant.whiteColor,
              borderRadius: AppUtils.borderRadiusAll(raduis: 10),
              boxShadow: [
                BoxShadow(
                    color: AppConstant.greyColor.withOpacity(0.3),
                    blurRadius: 8,
                    blurStyle: BlurStyle.solid,
                    spreadRadius: 0.8),
              ]),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppUtils.commonContainer(
                width: double.infinity,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      flex: 2,
                      child: Row(
                        children: [
                          const Icon(
                            Icons.person,
                            color: Colors.orangeAccent,
                            size: 18,
                          ),
                          AppUtils.commonSizedBox(width: 5),
                          Expanded(
                            child: AppUtils.commonTextWidget(
                              text: "Demo Name",
                              fontSize: 12,
                              textColor:
                              AppConstant.blackColor.withOpacity(0.9),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 40),
                    // Adjust the width as per your requirement
                    Flexible(
                      flex: 2,
                      child: Row(
                        children: [
                          const Icon(
                            Icons.timer_outlined,
                            color: Colors.green,
                            size: 15,
                          ),
                          AppUtils.commonSizedBox(width: 3),
                          Expanded(
                            child: AppUtils.commonTextWidget(
                              text: AppUtils.getDate(
                                date: "2024-07-07T23:20:00Z",
                                format: "dd MMM yyyy hh:mm a",
                              ),
                              fontSize: 12,
                              textColor:
                              AppConstant.blackColor.withOpacity(0.9),
                              fontWeight: FontWeight.w500,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              AppUtils.commonSizedBox(height: 5),
              Divider(
                color: AppConstant.greyColor.withOpacity(0.3),
              ),
              AppUtils.commonSizedBox(height: 5),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.task_sharp,
                        color: Colors.blue,
                        size: 18,
                      ),
                      AppUtils.commonSizedBox(width: 5),
                      AppUtils.commonTextWidget(
                          text: "Expense Status",
                          fontSize: 12,
                          textColor: AppConstant.blackColor.withOpacity(0.9),
                          fontWeight: FontWeight.w500)
                    ],
                  ),
                  AppUtils.commonContainer(
                      padding: AppUtils.edgeInsetsOnly(
                          bottom: 3, top: 3, left: 10, right: 10),
                      decoration: AppUtils.commonBoxDecoration(
                        borderRadius: BorderRadius.circular(6),
                        color: AppConstant.appPrimaryColor,
                      ),
                      child: AppUtils.commonTextWidget(
                          text: "Approved",
                          fontWeight: FontWeight.w400,
                          textColor: AppConstant.whiteColor,
                          fontSize: 10))
                ],
              ),
              AppUtils.commonSizedBox(height: 5),
              Divider(
                color: AppConstant.greyColor.withOpacity(0.3),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.notes,
                        color: Colors.purpleAccent,
                        size: 18,
                      ),
                      AppUtils.commonSizedBox(width: 5),
                      AppUtils.commonTextWidget(
                          text: /* viewTaskProvider
                                          .taskByIdModel?.data?.taskTitle ??*/
                          "Comment",
                          fontSize: 12,
                          textColor: AppConstant.blackColor.withOpacity(0.9),
                          fontWeight: FontWeight.w500)
                    ],
                  ),
                ],
              ),
              AppUtils.commonSizedBox(height: 8),
              AppUtils.commonTextWidget(
                  text: "Test Data for Expense approval design",
                  fontSize: 12,
                  textColor: AppConstant.blackColor.withOpacity(0.9),
                  fontWeight: FontWeight.w400),
              AppUtils.commonSizedBox(height: 10),
              Divider(
                color: AppConstant.greyColor.withOpacity(0.3),
              ),
              // AppUtils.commonSizedBox(height: 10),
              InkWell(
                onTap: () {
                  AppUtils.showDialogBoxWithTwoButton(
                      onSuccess: () {},
                      onCancel: () {},
                      context: context,
                      onSuccessString: "Approve",
                      onCancelString: "Cancel",
                      text:
                      "Do you want to approve Expense request ${"Kuldeep"} ",
                      titleText: "DayEnd Request");
                },
                child: AppUtils.commonContainer(
                  padding: AppUtils.edgeInsetsOnly(top: 5, bottom: 15),
                  color: Colors.white,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AppUtils.commonTextWidget(
                          text: "Approve",
                          textColor: AppConstant.appPrimaryColor,
                          fontWeight: FontWeight.w500,
                          fontSize: 14),
                    ],
                  ),
                ),
              )
            ],
          ),
        );
      },
    );
  }
}
