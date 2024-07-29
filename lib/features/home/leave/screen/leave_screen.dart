import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ontrek/core/services/network_repository.dart';
import 'package:ontrek/core/utils/App_utils.dart';
import 'package:ontrek/core/utils/app_constant.dart';
import 'package:ontrek/features/home/leave/model/my_leave_list_mode.dart';
import 'package:ontrek/features/home/leave/provider/leave_provider.dart';
import 'package:ontrek/features/home/leave/screen/apply_leave_screen.dart';
import 'package:provider/provider.dart';

class LeaveScreen extends StatefulWidget {
  const LeaveScreen({super.key});

  @override
  State<LeaveScreen> createState() => _LeaveScreenState();
}

class _LeaveScreenState extends State<LeaveScreen>
    with TickerProviderStateMixin {
  late TabController tabController;
  int selectedIndex = 0;
  bool? isFiltered;
  late LeaveProvider leaveProvider;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback(
      (_) async {
        leaveProvider = Provider.of<LeaveProvider>(context, listen: false);
        await leaveProvider.apiCallGetMyLeaveList();
        isFiltered = false;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    leaveProvider = Provider.of<LeaveProvider>(context);
    return Scaffold(
      backgroundColor: AppConstant.whiteColor,
      appBar: AppUtils.commonAppBar(
          context: context,
          isBorder: true,
          isBack: true,
          title: "Leave",
          isActionWidgetAvailable: true,
          actions: [
            InkWell(
              onTap: () {
                _showPopupMenu(context);
              },
              child: Padding(
                padding: AppUtils.edgeInsetsOnly(right: 15),
                child: Icon(
                  Icons.more_vert,
                  color: AppConstant.appPrimaryColor,
                  size: 24,
                ),
              ),
            )
          ]),
      floatingActionButton: GestureDetector(
        onTap: () {
          Navigator.push(
              context,
              CupertinoPageRoute(
                builder: (context) => ApplyLeaveScreen(),
              ));
        },
        child: AppUtils.commonContainer(
          margin: const EdgeInsets.only(top: 20, bottom: 60, right: 10),
          padding:
              const EdgeInsets.only(top: 13, bottom: 13, right: 30, left: 30),
          decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: AppUtils.borderRadiusAll(raduis: 10)),
          child: AppUtils.commonTextWidget(
            text: "Apply",
            fontWeight: FontWeight.w400,
            textColor: AppConstant.whiteColor,
            fontSize: 12,
          ),
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
                myLeaveRequests(leaveProvider.myLeaveListModel?.data?.listItem),
                allLeaveRequests(
                    leaveProvider.myLeaveListModel?.data?.listItem),
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
                  onTap: (value) async {
                    setState(() {
                      selectedIndex = value;
                    });
                    if (selectedIndex == 0) {
                      await leaveProvider.apiCallGetMyLeaveList();
                    } else {
                      await leaveProvider.apiCallGetEmployeeLeaveList();
                    }
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
                    Tab(text: 'My Leave Request'),
                    Tab(text: 'Employee Leave Request'),
                  ]),
            ),
          ],
        ),
      ),
    );
  }

  void _showPopupMenu(BuildContext context) async {
    ;
    await showMenu(
      context: context,
      position: RelativeRect.fromLTRB(20, 50, 15, 0),
      items: [
        PopupMenuItem(
          child: Text("Pending"),
          value: 1,
        ),
        PopupMenuItem(
          child: Text("Approve"),
          value: 2,
        ),
        PopupMenuItem(
          child: Text("Rejected"),
          value: 3,
        ),
      ],
      elevation: 8.0,
    ).then((value) {
      if (value != null) {
        _handleMenuItemClick(value);
      }
    });
  }

  void _handleMenuItemClick(int value) {
    String message;
    switch (value) {
      case 1:
        selectedIndex == 0
            ? leaveProvider.apiCallGetMyLeaveList(
                approvalStatus: null,
              )
            : leaveProvider.apiCallGetEmployeeLeaveList(
                approvalStatus: null,
              );
        break;
      case 2:
        selectedIndex == 0
            ? leaveProvider.apiCallGetMyLeaveList(
          approvalStatus: true,
        )
            : leaveProvider.apiCallGetEmployeeLeaveList(
          approvalStatus: true,

        );


        setState(() {
          isFiltered = true;
        });
        break;
      case 3:
        selectedIndex == 0
            ? leaveProvider.apiCallGetMyLeaveList(
          approvalStatus: false,
        )
            : leaveProvider.apiCallGetEmployeeLeaveList(
          approvalStatus: false,
        );
        setState(() {
          isFiltered = true;
        });
        break;
      default:
        message = "Unknown option";
    }
  }

  myLeaveRequests(List<ListItem>? myLeaveData) {
    return leaveProvider.isFetching
        ? AppUtils.loaderWidget()
        : myLeaveData?.length == 0 || myLeaveData == [] || myLeaveData == null
            ? AppUtils.commonNoDataFound(
                text: "No Data Found",
                onPressed: () {
                  leaveProvider.apiCallGetMyLeaveList();
                },
              )
            : ListView.builder(
                physics: BouncingScrollPhysics(),
                shrinkWrap: true,
                itemCount: myLeaveData.length,
                padding: AppUtils.edgeInsetsOnly(
                    bottom: 20, top: 0, left: 0, right: 0),
                itemBuilder: (context, index) {
                  return AppUtils.commonContainer(
                    width: double.infinity,
                    margin: const EdgeInsets.only(left: 10, right: 10, top: 20),
                    padding: const EdgeInsets.only(
                        left: 15, right: 15, top: 20, bottom: 20),
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
                                flex: 4,
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
                                        text: myLeaveData[index].userName ?? "",
                                        fontSize: 12,
                                        textColor: AppConstant.blackColor
                                            .withOpacity(0.9),
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
                                    Expanded(
                                      child: AppUtils.commonTextWidget(
                                        text:
                                            "${AppUtils.formatDateString(myLeaveData[index].leaveStartDate ?? "", "dd-MM")} To ${AppUtils.formatDateString(myLeaveData[index].leaveEndDate ?? "", "dd-MM")}",
                                        fontSize: 12,
                                        textColor: AppConstant.blackColor
                                            .withOpacity(0.9),
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
                                    text: "Approval Status",
                                    fontSize: 12,
                                    textColor:
                                        AppConstant.blackColor.withOpacity(0.9),
                                    fontWeight: FontWeight.w500)
                              ],
                            ),
                            AppUtils.commonContainer(
                                padding: AppUtils.edgeInsetsOnly(
                                    bottom: 3, top: 3, left: 10, right: 10),
                                decoration: AppUtils.commonBoxDecoration(
                                  borderRadius: BorderRadius.circular(6),
                                  color: myLeaveData[index].isApproved == null
                                      ? AppConstant.greyColor:myLeaveData[index].isApproved == false ? Colors.red
                                      : Colors.green,
                                ),
                                child: AppUtils.commonTextWidget(
                                    text: myLeaveData[index].isApproved == null
                                        ? "Pending" : myLeaveData[index].isApproved == false? "Rejected"
                                        : "Approved",
                                    fontWeight: FontWeight.w400,
                                    textColor: AppConstant.whiteColor,
                                    fontSize: 10))
                          ],
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
                                  Icons.time_to_leave,
                                  color: Colors.orange,
                                  size: 18,
                                ),
                                AppUtils.commonSizedBox(width: 5),
                                AppUtils.commonTextWidget(
                                    text: "Half/Full Day",
                                    fontSize: 12,
                                    textColor:
                                        AppConstant.blackColor.withOpacity(0.9),
                                    fontWeight: FontWeight.w500)
                              ],
                            ),
                            AppUtils.commonContainer(
                                padding: AppUtils.edgeInsetsOnly(
                                    bottom: 3, top: 3, left: 10, right: 10),
                                decoration: AppUtils.commonBoxDecoration(
                                  borderRadius: BorderRadius.circular(6),
                                  color: myLeaveData[index].isFullDay == true
                                      ? Colors.green
                                      : Colors.amber,
                                ),
                                child: AppUtils.commonTextWidget(
                                    text: myLeaveData[index].isFullDay == true
                                        ? "Full Day"
                                        : "Half Day",
                                    fontWeight: FontWeight.w400,
                                    textColor: AppConstant.whiteColor,
                                    fontSize: 10))
                          ],
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
                                  Icons.category_outlined,
                                  color: Colors.blue,
                                  size: 18,
                                ),
                                AppUtils.commonSizedBox(width: 5),
                                AppUtils.commonTextWidget(
                                    text: "Leave Category",
                                    fontSize: 12,
                                    textColor:
                                        AppConstant.blackColor.withOpacity(0.9),
                                    fontWeight: FontWeight.w500)
                              ],
                            ),
                            AppUtils.commonTextWidget(
                                text: myLeaveData[index].leaveCategoryTotName ??
                                    "",
                                fontWeight: FontWeight.w500,
                                textColor: AppConstant.blackColor,
                                fontSize: 14)
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
                                        "Reason",
                                    fontSize: 12,
                                    textColor:
                                        AppConstant.blackColor.withOpacity(0.9),
                                    fontWeight: FontWeight.w500)
                              ],
                            ),
                          ],
                        ),
                        AppUtils.commonSizedBox(height: 8),
                        AppUtils.commonTextWidget(
                            text: myLeaveData[index].leaveReason ?? "",
                            fontSize: 12,
                            textColor: AppConstant.blackColor.withOpacity(0.9),
                            fontWeight: FontWeight.w400),
                      ],
                    ),
                  );
                },
              );
  }

  allLeaveRequests(List<ListItem>? myEmployeeLeaveData) {
    return leaveProvider.isFetching
        ? AppUtils.loaderWidget()
        : myEmployeeLeaveData?.length == 0 ||
                myEmployeeLeaveData == [] ||
                myEmployeeLeaveData == null
            ? AppUtils.commonNoDataFound(
                text: "No Data Found",
                onPressed: () {
                  leaveProvider.apiCallGetEmployeeLeaveList();
                },
              )
            : ListView.builder(
                physics: BouncingScrollPhysics(),
                shrinkWrap: true,
                itemCount: myEmployeeLeaveData.length,
                padding: AppUtils.edgeInsetsOnly(
                    bottom: 20, top: 0, left: 0, right: 0),
                itemBuilder: (context, index) {
                  return AppUtils.commonContainer(
                    width: double.infinity,
                    margin: const EdgeInsets.only(left: 10, right: 10, top: 20),
                    padding:  EdgeInsets.only(
                        left: 15, right: 15, top: 20, bottom: isFiltered == true? 20 : 0),
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
                                flex: 3,
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
                                        text: myEmployeeLeaveData[index]
                                                .userName ??
                                            "",
                                        fontSize: 12,
                                        textColor: AppConstant.blackColor
                                            .withOpacity(0.9),
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
                                        text:
                                            "${AppUtils.formatDateString(myEmployeeLeaveData[index].leaveStartDate ?? "", "dd-MM")} To ${AppUtils.formatDateString(myEmployeeLeaveData[index].leaveEndDate ?? "", "dd-MM")}",
                                        fontSize: 12,
                                        textColor: AppConstant.blackColor
                                            .withOpacity(0.9),
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
                                    text: "Approval Status",
                                    fontSize: 12,
                                    textColor:
                                        AppConstant.blackColor.withOpacity(0.9),
                                    fontWeight: FontWeight.w500)
                              ],
                            ),
                            AppUtils.commonContainer(
                                padding: AppUtils.edgeInsetsOnly(
                                    bottom: 3, top: 3, left: 10, right: 10),
                                decoration: AppUtils.commonBoxDecoration(
                                  borderRadius: BorderRadius.circular(6),
                                  color: myEmployeeLeaveData[index].isApproved == null
                                      ? AppConstant.greyColor:myEmployeeLeaveData[index].isApproved == false ? Colors.red
                                      : Colors.green,
                                ),
                                child: AppUtils.commonTextWidget(
                                    text: myEmployeeLeaveData[index].isApproved == null
                                        ? "Pending" : myEmployeeLeaveData[index].isApproved == false? "Rejected"
                                        : "Approved",
                                    fontWeight: FontWeight.w400,
                                    textColor: AppConstant.whiteColor,
                                    fontSize: 10))
                          ],
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
                                  Icons.time_to_leave,
                                  color: Colors.orange,
                                  size: 18,
                                ),
                                AppUtils.commonSizedBox(width: 5),
                                AppUtils.commonTextWidget(
                                    text: "Half/Full Day",
                                    fontSize: 12,
                                    textColor:
                                        AppConstant.blackColor.withOpacity(0.9),
                                    fontWeight: FontWeight.w500)
                              ],
                            ),
                            AppUtils.commonContainer(
                                padding: AppUtils.edgeInsetsOnly(
                                    bottom: 3, top: 3, left: 10, right: 10),
                                decoration: AppUtils.commonBoxDecoration(
                                  borderRadius: BorderRadius.circular(6),
                                  color: myEmployeeLeaveData[index].isFullDay ==
                                          true
                                      ? Colors.green
                                      : Colors.amber,
                                ),
                                child: AppUtils.commonTextWidget(
                                    text:
                                        myEmployeeLeaveData[index].isFullDay ==
                                                true
                                            ? "Full Day"
                                            : "Half Day",
                                    fontWeight: FontWeight.w400,
                                    textColor: AppConstant.whiteColor,
                                    fontSize: 10))
                          ],
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
                                  Icons.category_outlined,
                                  color: Colors.blue,
                                  size: 18,
                                ),
                                AppUtils.commonSizedBox(width: 5),
                                AppUtils.commonTextWidget(
                                    text: "Leave Category",
                                    fontSize: 12,
                                    textColor:
                                        AppConstant.blackColor.withOpacity(0.9),
                                    fontWeight: FontWeight.w500)
                              ],
                            ),
                            AppUtils.commonTextWidget(
                                text: myEmployeeLeaveData[index]
                                        .leaveCategoryTotName ??
                                    "",
                                fontWeight: FontWeight.w500,
                                textColor: AppConstant.blackColor,
                                fontSize: 14)
                          ],
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
                                  Icons.notes,
                                  color: Colors.purpleAccent,
                                  size: 18,
                                ),
                                AppUtils.commonSizedBox(width: 5),
                                AppUtils.commonTextWidget(
                                    text: /* viewTaskProvider
                                          .taskByIdModel?.data?.taskTitle ??*/
                                        "Reason",
                                    fontSize: 12,
                                    textColor:
                                        AppConstant.blackColor.withOpacity(0.9),
                                    fontWeight: FontWeight.w500)
                              ],
                            ),
                          ],
                        ),
                        AppUtils.commonSizedBox(height: 5),
                        AppUtils.commonTextWidget(
                            text: "Test Data for Leave approval design",
                            fontSize: 12,
                            textColor: AppConstant.blackColor.withOpacity(0.9),
                            fontWeight: FontWeight.w400),
                        AppUtils.commonSizedBox(height: 5),
                        if(isFiltered == false)

                          Column(children: [
                            Divider(
                              color: AppConstant.greyColor.withOpacity(0.3),
                            ),
                            // AppUtils.commonSizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: InkWell(
                                    onTap: () {
                                      AppUtils.showDialogBoxWithTwoButton(
                                          onSuccess: () async{
                                            await leaveProvider.apiCallApplyRejectLeave(
                                              pkId: myEmployeeLeaveData[index].pkId,
                                              userId: myEmployeeLeaveData[index].userId,
                                              approvedRejectedBy: userName,
                                              isApproved: false,
                                              approvedRejectedOn: DateTime.now().toString(),
                                              onSuccess: () async{
                                                await leaveProvider.apiCallGetEmployeeLeaveList();
                                              },
                                            );
                                          },
                                          onCancel: () {},
                                          context: context,
                                          onSuccessString: "Reject",
                                          onCancelString: "Cancel",
                                          text:
                                          "Do you want to reject Day end request ${myEmployeeLeaveData[index].userName} ",
                                          titleText: "DayEnd Request");
                                    },
                                    child: AppUtils.commonContainer(
                                      padding: AppUtils.edgeInsetsOnly(top: 5, bottom: 15),
                                      color: Colors.white,
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.close,color: Colors.red,size: 26,),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: InkWell(
                                    onTap: () {
                                      AppUtils.showDialogBoxWithTwoButton(
                                          onSuccess: () async{
                                            await leaveProvider.apiCallApplyRejectLeave(
                                              pkId: myEmployeeLeaveData[index].pkId,
                                              userId: myEmployeeLeaveData[index].userId,
                                              approvedRejectedBy: userName,
                                              isApproved: true,
                                              approvedRejectedOn: DateTime.now().toString(),
                                              onSuccess: () async{
                                                await leaveProvider.apiCallGetEmployeeLeaveList();
                                              },
                                            );
                                          },
                                          onCancel: () {},
                                          context: context,
                                          onSuccessString: "Approve",
                                          onCancelString: "Cancel",
                                          text:
                                          "Do you want to approve Day end request ${myEmployeeLeaveData[index].userName} ",
                                          titleText: "DayEnd Request");
                                    },
                                    child: AppUtils.commonContainer(
                                      padding:
                                      AppUtils.edgeInsetsOnly(top: 5, bottom: 15),
                                      color: Colors.white,
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.check,color: Colors.green,size: 26,),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            )
                          ],)

                      ],
                    ),
                  );
                },
              );
  }
}
