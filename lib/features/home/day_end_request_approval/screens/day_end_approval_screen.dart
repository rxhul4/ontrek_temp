import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:ontrek/core/storage/preference_helper.dart';
import 'package:ontrek/core/utils/App_utils.dart';
import 'package:ontrek/core/utils/app_constant.dart';
import 'package:ontrek/features/home/day_end_request_approval/model/day_end_approval_model.dart';
import 'package:ontrek/features/home/day_end_request_approval/provider/day_end_request_provider.dart';
import 'package:provider/provider.dart';

class DayEndApprovalScreen extends StatefulWidget {
  const DayEndApprovalScreen({super.key});

  @override
  State<DayEndApprovalScreen> createState() => _DayEndApprovalScreenState();
}

class _DayEndApprovalScreenState extends State<DayEndApprovalScreen>
    with TickerProviderStateMixin {
  late TabController tabController;
  int selectedIndex = 0;
  late DayEndRequestProvider dayEndRequestProvider;
  String? userId;
  final PagingController<int, ListItem> myDayEndRequestController =
      PagingController(firstPageKey: 1);
  final PagingController<int, ListItem> employeeDayEndRequestController =
      PagingController(firstPageKey: 1);
  DateTime? employeeDayEndSelectedDate;
  DateTime? myDayEndSelectedDate;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    tabController = TabController(length: 2, vsync: this);
    myDayEndRequestController.addPageRequestListener((pageKey) async {
      await myDayEndRequestPagination(pageKey);
    });
    employeeDayEndRequestController.addPageRequestListener((pageKey) async {
      await EmployeeDayEndRequestPagination(pageKey);
    });
    WidgetsBinding.instance.addPostFrameCallback(
      (timeStamp) async {
        dayEndRequestProvider =
            Provider.of<DayEndRequestProvider>(context, listen: false);
        userId = PreferenceHelper.getString(PreferenceHelper.USER_ID);
        dayEndRequestProvider.myDayEndSelectedDate = null;
        dayEndRequestProvider.employeeDayEndSelectedDate = null;
        dayEndRequestProvider.isMyRequestApproved = null;
        dayEndRequestProvider.isMyRequestApproved = null;
      },
    );
  }

  Future<void> myDayEndRequestPagination(int pageKey) async {
    try {
      final newItems = await dayEndRequestProvider.apiCallGetDayEndRequestList(
          pageNo: pageKey, requestedDate: null);
      bool isLastPage = (newItems?.data?.listItem?.length ?? 0) < 10;
      if (isLastPage) {
        myDayEndRequestController
            .appendLastPage(newItems?.data?.listItem ?? []);
      } else {
        final nextPageKey = pageKey + 1;
        myDayEndRequestController.appendPage(
            newItems?.data?.listItem ?? [], nextPageKey);
      }
    } catch (error) {
      myDayEndRequestController.error = error;
    }
  }

  Future<void> EmployeeDayEndRequestPagination(int pageKey) async {
    try {
      final newItems = await dayEndRequestProvider.apiCallEmployeeRequests(
          pageNo: pageKey, requestedDate: null);
      bool isLastPage = (newItems?.data?.listItem?.length ?? 0) < 10;
      if (isLastPage) {
        employeeDayEndRequestController
            .appendLastPage(newItems?.data?.listItem ?? []);
      } else {
        final nextPageKey = pageKey + 1;
        employeeDayEndRequestController.appendPage(
            newItems?.data?.listItem ?? [], nextPageKey);
      }
    } catch (error) {
      employeeDayEndRequestController.error = error;
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    myDayEndRequestController.dispose();
    employeeDayEndRequestController.dispose();
    dayEndRequestProvider.isApproved = null;
    dayEndRequestProvider.employeeDayEndSelectedDate = null;
    dayEndRequestProvider.myDayEndSelectedDate = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    dayEndRequestProvider = Provider.of<DayEndRequestProvider>(context);
    return Scaffold(
      backgroundColor: AppConstant.whiteColor,
      appBar: AppUtils.commonAppBar(
          context: context,
          isBorder: true,
          isBack: true,
          title: "Day-end",
          isActionWidgetAvailable: true,
          actions: [
            commonIconWidget(
              iconData: Icons.calendar_month_rounded,
              onTap: selectedIndex == 0
                  ? openDatePickerForMyRequest
                  : openDatePickerForEmployeeRequest,
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
                myDayEndRequests(),
                allDayEndRequests(),
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
                    Tab(text: 'My Request'),
                    Tab(text: 'Employee Request'),
                  ]),
            ),
          ],
        ),
      ),
    );
  }



  myDayEndRequests() {
    return PagedListView<int, ListItem>(
      pagingController: myDayEndRequestController,
      builderDelegate: PagedChildBuilderDelegate<ListItem>(
        animateTransitions: true,
        firstPageProgressIndicatorBuilder: (context) {
          return Center(
            child: AppUtils.loaderWidget(),
          );
        },
        noItemsFoundIndicatorBuilder: (context) {
          return AppUtils.commonNoDataFound(
            text: "No Request Found",
            onPressed: () {
              myDayEndRequestController.refresh();
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
            margin:
            const EdgeInsets.only(left: 10, right: 10, top: 20, bottom: 0),
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
                                text: item.requestedBy ?? "",
                                fontSize: 14,
                                textColor:
                                AppConstant.blackColor.withOpacity(0.9),
                                fontWeight: FontWeight.w500,
                              ),
                              AppUtils.commonTextWidget(
                                text: AppUtils.getDate(
                                  date: item.attendanceDate ?? "",
                                  format: "dd MMM yyyy hh:mm a",
                                ),
                                fontSize: 10,
                                textColor:
                                AppConstant.blackColor.withOpacity(0.9),
                                fontWeight: FontWeight.w500,
                                overflow: TextOverflow.ellipsis,
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
                            color: item.isApproved == false
                                ? AppConstant.greyColor
                                : Colors.green,
                          ),
                          child: AppUtils.commonTextWidget(
                              text: item.isApproved == true
                                  ? "Approved"
                                  : "Pending",
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
                AppUtils.commonTextWidget(
                    text: "Comment",
                    fontSize: 14,
                    textColor:
                    AppConstant.blackColor.withOpacity(0.9),
                    fontWeight: FontWeight.w500),
                AppUtils.commonSizedBox(height: 5),
                AppUtils.commonTextWidget(
                    text: item.comment ?? "",
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

  allDayEndRequests() {
    return PagedListView<int, ListItem>(
        pagingController: employeeDayEndRequestController,
        builderDelegate: PagedChildBuilderDelegate<ListItem>(
            animateTransitions: true,
            firstPageProgressIndicatorBuilder: (context) {
              return Center(
                child: AppUtils.loaderWidget(),
              );
            },
            noItemsFoundIndicatorBuilder: (context) {
              return AppUtils.commonNoDataFound(
                text: "No Request Found",
                onPressed: () {
                  employeeDayEndRequestController.refresh();
                },
              );
            },
            firstPageErrorIndicatorBuilder: (context) {
              return AppUtils.commonNoDataFound(
                text: "No Request Found",
                onPressed: () {
                  employeeDayEndRequestController.refresh();
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
                padding: const EdgeInsets.only(
                    left: 15, right: 15, top: 20, bottom: 0),
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
                                    text: item.requestedBy ?? "",
                                    fontSize: 14,
                                    textColor:
                                    AppConstant.blackColor.withOpacity(0.9),
                                    fontWeight: FontWeight.w500,
                                  ),
                                  AppUtils.commonTextWidget(
                                    text: AppUtils.getDate(
                                      date: item.attendanceDate ?? "",
                                      format: "dd MMM yyyy hh:mm a",
                                    ),
                                    fontSize: 10,
                                    textColor:
                                    AppConstant.blackColor.withOpacity(0.9),
                                    fontWeight: FontWeight.w500,
                                    overflow: TextOverflow.ellipsis,
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
                                color: item.isApproved == false
                                    ? AppConstant.greyColor
                                    : Colors.green,
                              ),
                              child: AppUtils.commonTextWidget(
                                  text: item.isApproved == true
                                      ? "Approved"
                                      : "Pending",
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
                    AppUtils.commonTextWidget(
                        text: "Comment",
                        fontSize: 14,
                        textColor:
                        AppConstant.blackColor.withOpacity(0.9),
                        fontWeight: FontWeight.w500),
                    AppUtils.commonSizedBox(height: 5),
                    AppUtils.commonTextWidget(
                        text: item.comment ?? "",
                        fontSize: 12,
                        textColor: AppConstant.blackColor.withOpacity(0.9),
                        fontWeight: FontWeight.w400),
                    AppUtils.commonSizedBox(height: 10),
                    if(item.isApproved == false)
                      Column(
                        children: [
                          Divider(
                            color: AppConstant.greyColor.withOpacity(0.3),
                          ),
                          // AppUtils.commonSizedBox(height: 10),
                          InkWell(
                            onTap: () {
                              AppUtils.showDialogBoxWithTwoButton(
                                  onSuccess: () async {
                                    await dayEndRequestProvider.apiCallApproveRequest(
                                      userId: item.userId,
                                      sessionId: item.sessionId,
                                      sessionEndDateTime: item.requestedDate,
                                    );
                                  },
                                  onCancel: () {},
                                  context: context,
                                  onSuccessString: "Approve",
                                  onCancelString: "Cancel",
                                  text:
                                  "Do you want to approve Day end request ${"Kuldeep"} ",
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

  Future<void> openDatePickerForMyRequest() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: myDayEndSelectedDate,
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

    if (picked != null &&
        picked != dayEndRequestProvider.myDayEndSelectedDate) {
      setState(() {
        myDayEndSelectedDate = picked;
        dayEndRequestProvider.myDayEndSelectedDate = myDayEndSelectedDate.toString();
      });
      myDayEndRequestController.refresh();
    }
  }

  Future<void> openDatePickerForEmployeeRequest() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: employeeDayEndSelectedDate,
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

    if (picked != null &&
        picked != dayEndRequestProvider.employeeDayEndSelectedDate) {
      setState(() {
        dayEndRequestProvider.employeeDayEndSelectedDate = picked.toString();
      });
      dayEndRequestProvider.manageSelectedDate(dayEndRequestProvider.employeeDayEndSelectedDate);
      employeeDayEndRequestController.refresh();

    }
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
          child: Text("Approved"),
          value: 2,
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
        dayEndRequestProvider.manageApprovalStatus(false);
        selectedIndex == 0
            ? myDayEndRequestController.refresh()
            : employeeDayEndRequestController.refresh();
        break;
      case 2:
        dayEndRequestProvider.manageApprovalStatus(true);
        selectedIndex == 0
            ? myDayEndRequestController.refresh()
            : employeeDayEndRequestController.refresh();
        break;
      default:
        message = "Unknown option";
    }
  }

}
