import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
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
  bool? approvalStatus = null;
  late LeaveProvider leaveProvider;
  final PagingController<int, ListItem> myLeaveListController =
      PagingController(firstPageKey: 1);
  final PagingController<int, ListItem> employeeLeaveListController =
      PagingController(firstPageKey: 1);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    tabController = TabController(length: 2, vsync: this);
    myLeaveListController.addPageRequestListener((pageKey) async {
      await myDayEndRequestPagination(pageKey);
    });
    employeeLeaveListController.addPageRequestListener((pageKey) async {
      await EmployeeDayEndRequestPagination(pageKey);
    });

    WidgetsBinding.instance.addPostFrameCallback(
      (_) async {
        leaveProvider = Provider.of<LeaveProvider>(context, listen: false);
        isFiltered = false;
      },
    );
  }

  Future<void> myDayEndRequestPagination(int pageKey) async {
    try {
      final newItems = await leaveProvider.apiCallGetMyLeaveList(
          pageNo: pageKey, approvalStatus: approvalStatus);
      bool isLastPage = (newItems?.data?.listItem?.length ?? 0) < 10;
      if (isLastPage) {
        myLeaveListController.appendLastPage(newItems?.data?.listItem ?? []);
      } else {
        final nextPageKey = pageKey + 1;
        myLeaveListController.appendPage(
            newItems?.data?.listItem ?? [], nextPageKey);
      }
    } catch (error) {
      myLeaveListController.error = error;
    }
  }

  Future<void> EmployeeDayEndRequestPagination(int pageKey) async {
    try {
      final newItems = await leaveProvider.apiCallGetEmployeeLeaveList(
          pageNo: pageKey, approvalStatus: approvalStatus);
      bool isLastPage = (newItems?.data?.listItem?.length ?? 0) < 10;
      if (isLastPage) {
        employeeLeaveListController
            .appendLastPage(newItems?.data?.listItem ?? []);
      } else {
        final nextPageKey = pageKey + 1;
        employeeLeaveListController.appendPage(
            newItems?.data?.listItem ?? [], nextPageKey);
      }
    } catch (error) {
      employeeLeaveListController.error = error;
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    myLeaveListController.dispose();
    employeeLeaveListController.dispose();
    leaveProvider.ApprovalStatus = null;
    leaveProvider.approvalNotesController.clear();
    super.dispose();
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
            AppUtils.commonContainer(
              color: AppConstant.whiteColor,
              padding: EdgeInsets.all(5),
              child: commonIconWidget(
                iconData: Icons.add,
                iconColor: AppConstant.appPrimaryColor,
                onTap: () {
                  Navigator.push(
                      context,
                      CupertinoPageRoute(
                        builder: (context) => ApplyLeaveScreen(),
                      )).then(
                    (value) {
                      selectedIndex == 0
                          ? myLeaveListController.refresh()
                          : employeeLeaveListController.refresh();
                    },
                  );
                },
              ),
            ),
            AppUtils.commonSizedBox(width: 10),
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
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
                child: TabBarView(
              physics: NeverScrollableScrollPhysics(),
              controller: tabController,
              children: [
                myLeaveRequests(),
                allLeaveRequests(),
              ],
            )),
            AppUtils.commonContainer(
              height: 50,
              margin: EdgeInsets.only(top: 0, left: 0, right: 0, bottom: 0),
              decoration: AppUtils.commonBoxDecoration(
                color: AppConstant.greyColor.withOpacity(0.2),
              ),
              child: TabBar.secondary(
                  onTap: (value) async {
                    setState(() {
                      selectedIndex = value;
                    });
                    selectedIndex == 0 ? myLeaveListController.refresh() : employeeLeaveListController.refresh();
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

  myLeaveRequests() {
    return PagedListView<int, ListItem>(
      pagingController: myLeaveListController,
      physics: BouncingScrollPhysics(),
      padding: AppUtils.edgeInsetsOnly(bottom: 20),
      builderDelegate: PagedChildBuilderDelegate<ListItem>(
        animateTransitions: true,
        firstPageProgressIndicatorBuilder: (context) {
          return Center(
            child: AppUtils.loaderWidget(),
          );
        },
        noItemsFoundIndicatorBuilder: (context) {
          return AppUtils.commonNoDataFound(
            text: "No Leaves Found",
            onPressed: () {
              myLeaveListController.refresh();
            },
          );
        },
        newPageProgressIndicatorBuilder: (context) {
          return Padding(
            padding: EdgeInsets.only(top: 30),
            child: AppUtils.loaderWidget(),
          );
        },
        itemBuilder: (context, item, index) {
          return AppUtils.commonContainer(
            width: double.infinity,
            margin: const EdgeInsets.only(left: 10, right: 10, top: 20),
            padding:
                const EdgeInsets.only(left: 15, right: 15, top: 20, bottom: 10),
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
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        // mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AppUtils.commonTextWidget(
                                text: item.userName ?? "",
                                fontSize: 14,
                                textColor:
                                    AppConstant.blackColor.withOpacity(0.9),
                                fontWeight: FontWeight.w500,
                              ),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  AppUtils.commonTextWidget(
                                    text:
                                        "${AppUtils.formatDateString(item.leaveStartDate ?? "", "dd MMM")} To ${AppUtils.formatDateString(item.leaveEndDate ?? "", "dd MMM")}",
                                    fontSize: 10,
                                    textColor:
                                        AppConstant.blackColor.withOpacity(0.9),
                                    fontWeight: FontWeight.w400,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  AppUtils.commonSizedBox(width: 5),
                                  CircleAvatar(
                                    radius: 3,
                                    backgroundColor:
                                        AppConstant.blackColor.withOpacity(0.6),
                                  ),
                                  AppUtils.commonSizedBox(width: 5),
                                  AppUtils.commonTextWidget(
                                      text: item.isFullDay == true
                                          ? "Full Day"
                                          : "Half Day",
                                      fontWeight: FontWeight.w400,
                                      textColor: AppConstant.blackColor
                                          .withOpacity(0.9),
                                      fontSize: 10),
                                  AppUtils.commonSizedBox(width: 5),
                                  CircleAvatar(
                                    radius: 3,
                                    backgroundColor:
                                        AppConstant.blackColor.withOpacity(0.6),
                                  ),
                                  AppUtils.commonSizedBox(width: 5),
                                  AppUtils.commonTextWidget(
                                      text: item.leaveCategoryTotName ?? "",
                                      fontWeight: FontWeight.w500,
                                      textColor: AppConstant.blackColor
                                          .withOpacity(0.9),
                                      fontSize: 10)
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                      // SizedBox(width: 40),
                      AppUtils.commonContainer(
                          padding: AppUtils.edgeInsetsOnly(
                              bottom: 3, top: 3, left: 10, right: 10),
                          decoration: AppUtils.commonBoxDecoration(
                            borderRadius: BorderRadius.circular(6),
                            color: item.isApproved == null
                                ? AppConstant.greyColor
                                : item.isApproved == false
                                    ? Colors.red
                                    : Colors.green,
                          ),
                          child: AppUtils.commonTextWidget(
                              text: item.isApproved == null
                                  ? "Pending"
                                  : item.isApproved == false
                                      ? "Rejected"
                                      : "Approved",
                              fontWeight: FontWeight.w400,
                              textColor: AppConstant.whiteColor,
                              fontSize: 10))
                    ],
                  ),
                ),
                AppUtils.commonSizedBox(height: 5),
                Divider(
                  color: AppConstant.greyColor.withOpacity(0.3),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    AppUtils.commonTextWidget(
                        text: "Reason",
                        fontSize: 14,
                        textColor: AppConstant.blackColor.withOpacity(0.9),
                        fontWeight: FontWeight.w500),
                  ],
                ),
                AppUtils.commonSizedBox(height: 5),
                AppUtils.commonTextWidget(
                    text: item.leaveReason ?? "",
                    fontSize: 12,
                    textColor: AppConstant.blackColor.withOpacity(0.9),
                    fontWeight: FontWeight.w400),
              ],
            ),
          );
        },
      ),
    );
  }

  allLeaveRequests() {
    return PagedListView<int, ListItem>(
        pagingController: employeeLeaveListController,
        physics: BouncingScrollPhysics(),
        padding: AppUtils.edgeInsetsOnly(bottom: 5),
        builderDelegate: PagedChildBuilderDelegate<ListItem>(
            animateTransitions: true,
            firstPageProgressIndicatorBuilder: (context) {
              return Center(
                child: AppUtils.loaderWidget(),
              );
            },
            noItemsFoundIndicatorBuilder: (context) {
              return AppUtils.commonNoDataFound(
                text: "No Leaves Found",
                onPressed: () {
                  myLeaveListController.refresh();
                },
              );
            },
            newPageProgressIndicatorBuilder: (context) {
              return Padding(
                padding: EdgeInsets.only(top: 30),
                child: AppUtils.loaderWidget(),
              );
            },
            itemBuilder: (context, item, index) {
              return AppUtils.commonContainer(
                width: double.infinity,
                margin: const EdgeInsets.only(left: 10, right: 10, top: 20),
                padding: EdgeInsets.only(
                    left: 15,
                    right: 15,
                    top: 20,
                    bottom: item.isApproved != null ? 10 : 0),
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
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            // mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  AppUtils.commonTextWidget(
                                    text: item.userName ?? "",
                                    fontSize: 14,
                                    textColor:
                                        AppConstant.blackColor.withOpacity(0.9),
                                    fontWeight: FontWeight.w500,
                                  ),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      AppUtils.commonTextWidget(
                                        text:
                                            "${AppUtils.formatDateString(item.leaveStartDate ?? "", "dd MMM")} To ${AppUtils.formatDateString(item.leaveEndDate ?? "", "dd MMM")}",
                                        fontSize: 10,
                                        textColor: AppConstant.blackColor
                                            .withOpacity(0.9),
                                        fontWeight: FontWeight.w400,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      AppUtils.commonSizedBox(width: 5),
                                      CircleAvatar(
                                        radius: 3,
                                        backgroundColor: AppConstant.blackColor
                                            .withOpacity(0.6),
                                      ),
                                      AppUtils.commonSizedBox(width: 5),
                                      AppUtils.commonTextWidget(
                                          text: item.isFullDay == true
                                              ? "Full Day"
                                              : "Half Day",
                                          fontWeight: FontWeight.w400,
                                          textColor: AppConstant.blackColor
                                              .withOpacity(0.9),
                                          fontSize: 10),
                                      AppUtils.commonSizedBox(width: 5),
                                      CircleAvatar(
                                        radius: 3,
                                        backgroundColor: AppConstant.blackColor
                                            .withOpacity(0.6),
                                      ),
                                      AppUtils.commonSizedBox(width: 5),
                                      AppUtils.commonTextWidget(
                                          text: item.leaveCategoryTotName ?? "",
                                          fontWeight: FontWeight.w500,
                                          textColor: AppConstant.blackColor
                                              .withOpacity(0.9),
                                          fontSize: 10)
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                          // SizedBox(width: 40),
                          AppUtils.commonContainer(
                              padding: AppUtils.edgeInsetsOnly(
                                  bottom: 3, top: 3, left: 10, right: 10),
                              decoration: AppUtils.commonBoxDecoration(
                                borderRadius: BorderRadius.circular(6),
                                color: item.isApproved == null
                                    ? AppConstant.greyColor
                                    : item.isApproved == false
                                        ? Colors.red
                                        : Colors.green,
                              ),
                              child: AppUtils.commonTextWidget(
                                  text: item.isApproved == null
                                      ? "Pending"
                                      : item.isApproved == false
                                          ? "Rejected"
                                          : "Approved",
                                  fontWeight: FontWeight.w400,
                                  textColor: AppConstant.whiteColor,
                                  fontSize: 10))
                        ],
                      ),
                    ),
                    AppUtils.commonSizedBox(height: 5),
                    Divider(
                      color: AppConstant.greyColor.withOpacity(0.3),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        AppUtils.commonTextWidget(
                            text: "Reason",
                            fontSize: 14,
                            textColor: AppConstant.blackColor.withOpacity(0.9),
                            fontWeight: FontWeight.w500),
                      ],
                    ),
                    AppUtils.commonSizedBox(height: 5),
                    AppUtils.commonTextWidget(
                        text: item.leaveReason ?? "",
                        fontSize: 12,
                        textColor: AppConstant.blackColor.withOpacity(0.9),
                        fontWeight: FontWeight.w400),
                    if (item.isApproved == null)
                      Column(
                        children: [
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
                                    showDialog(
                                      context: context,
                                      builder: (context) {
                                        return AppUtils.showNotesForm(
                                          context: context,
                                          title: "Leave Reject",
                                          textFieldText: "Reject Comment",
                                          controller: leaveProvider
                                              .rejectionNotesController,
                                          onSave: () async {
                                            await leaveProvider
                                                .apiCallApplyRejectLeave(
                                              pkId: item.pkId,
                                              userId: item.userId,

                                              isApproved: false,
                                              approvedRejectedOn:
                                                  DateTime.now().toString(),
                                              onSuccess: () async {
                                                employeeLeaveListController
                                                    .refresh();
                                              },
                                            );
                                          },
                                        );
                                      },
                                    );
                                    // AppUtils.showDialogBoxWithTwoButton(
                                    //     onSuccess: () async {
                                    //       await leaveProvider
                                    //           .apiCallApplyRejectLeave(
                                    //         pkId: item.pkId,
                                    //         userId: item.userId,
                                    //         approvedRejectedBy: userName,
                                    //         isApproved: true,
                                    //         approvedRejectedOn:
                                    //             DateTime.now().toString(),
                                    //         onSuccess: () async {
                                    //           employeeLeaveListController.refresh();
                                    //         },
                                    //       );
                                    //     },
                                    //     onCancel: () {},
                                    //     context: context,
                                    //     onSuccessString: "Approve",
                                    //     onCancelString: "Cancel",
                                    //     text:
                                    //         "Do you want to approve Leave request ${item.userName} ",
                                    //     titleText: "Leave Request");
                                  },
                                  child: AppUtils.commonContainer(
                                    padding: AppUtils.edgeInsetsOnly(
                                        top: 5, bottom: 15),
                                    color: Colors.white,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.close,
                                          color: Colors.red,
                                          size: 26,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: InkWell(
                                  onTap: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) {
                                        return AppUtils.showNotesForm(
                                          context: context,
                                          title: "Leave Approval",
                                          textFieldText: "Approval Comment",
                                          controller: leaveProvider
                                              .approvalNotesController,
                                          onSave: () async {
                                            await leaveProvider
                                                .apiCallApplyRejectLeave(
                                              pkId: item.pkId,
                                              userId: item.userId,
                                              isApproved: true,
                                              approvedRejectedOn:
                                                  DateTime.now().toString(),
                                              onSuccess: () async {
                                                employeeLeaveListController
                                                    .refresh();
                                              },
                                            );
                                          },
                                        );
                                      },
                                    );
                                    // AppUtils.showDialogBoxWithTwoButton(
                                    //     onSuccess: () async {
                                    //       await leaveProvider
                                    //           .apiCallApplyRejectLeave(
                                    //         pkId: item.pkId,
                                    //         userId: item.userId,
                                    //         approvedRejectedBy: userName,
                                    //         isApproved: true,
                                    //         approvedRejectedOn:
                                    //             DateTime.now().toString(),
                                    //         onSuccess: () async {
                                    //           employeeLeaveListController.refresh();
                                    //         },
                                    //       );
                                    //     },
                                    //     onCancel: () {},
                                    //     context: context,
                                    //     onSuccessString: "Approve",
                                    //     onCancelString: "Cancel",
                                    //     text:
                                    //         "Do you want to approve Leave request ${item.userName} ",
                                    //     titleText: "Leave Request");
                                  },
                                  child: AppUtils.commonContainer(
                                    padding: AppUtils.edgeInsetsOnly(
                                        top: 5, bottom: 15),
                                    color: Colors.white,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.check,
                                          color: Colors.green,
                                          size: 26,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          )
                        ],
                      )
                  ],
                ),
              );
            }));
  }

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
        leaveProvider.manageApprovalStatus(null);
        selectedIndex == 0
            ? myLeaveListController.refresh()
            : employeeLeaveListController.refresh();

        break;
      case 2:
        leaveProvider.manageApprovalStatus(true);
        selectedIndex == 0
            ? myLeaveListController.refresh()
            : employeeLeaveListController.refresh();

        break;
      case 3:
        leaveProvider.manageApprovalStatus(false);
        selectedIndex == 0
            ? myLeaveListController.refresh()
            : employeeLeaveListController.refresh();

        break;
      default:
        message = "Unknown option";
    }
  }
}
