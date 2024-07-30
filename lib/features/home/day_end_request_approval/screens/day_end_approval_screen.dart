import 'package:flutter/material.dart';
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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback(
          (timeStamp) async {
        dayEndRequestProvider =
            Provider.of<DayEndRequestProvider>(context, listen: false);
        userId = PreferenceHelper.getString(PreferenceHelper.USER_ID);
        await dayEndRequestProvider.apiCallGetDayEndRequestList(
            isApproved: false);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    dayEndRequestProvider = Provider.of<DayEndRequestProvider>(context);
    return Scaffold(
      backgroundColor: AppConstant.whiteColor,
      appBar: AppUtils.commonAppBar(
          context: context, isBorder: true, isBack: true, title: "Day-end"),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
                child: TabBarView(
                  physics: NeverScrollableScrollPhysics(),
                  controller: tabController,
                  children: [
                    myDayEndRequests(
                        dayEndRequestProvider.dayEndRequestModel?.data
                            ?.listItem
                            ?.where(
                              (element) => element.userId == userId,
                        )
                            .toList()),
                    allDayEndRequests(
                        dayEndRequestProvider.dayEndRequestModel?.data
                            ?.listItem
                            ?.where(
                              (element) => element.userId != userId,
                        )
                            .toList()),
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
                      await dayEndRequestProvider.apiCallGetDayEndRequestList(
                          isApproved: false);
                    } else {
                      await dayEndRequestProvider.apiCallEmployeeRequests(
                          isApproved: false);
                    }
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

  myDayEndRequests(List<ListItem>? myRequest) {
    return dayEndRequestProvider.isFetching
        ? AppUtils.loaderWidget()
        : myRequest?.length == 0 || myRequest == null || myRequest == []
        ? AppUtils.commonNoDataFound(
      text: "No Request Found",
      onPressed: () {},
    )
        : ListView.builder(
      physics: BouncingScrollPhysics(),
      shrinkWrap: true,
      itemCount: myRequest.length,
      padding: AppUtils.edgeInsetsOnly(
          bottom: 20, top: 0, left: 0, right: 0),
      itemBuilder: (context, index) {
        return AppUtils.commonContainer(
          width: double.infinity,
          margin: const EdgeInsets.only(
              left: 10, right: 10, top: 20, bottom: 0),
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
                              text:
                              myRequest[index].requestedBy ?? "",
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
                              text: AppUtils.getDate(
                                date:
                                myRequest[index].attendanceDate ??
                                    "",
                                format: "dd MMM yyyy hh:mm a",
                              ),
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
                        color: myRequest[index].isApproved == true
                            ? Colors.green
                            : AppConstant.greyColor,
                      ),
                      child: AppUtils.commonTextWidget(
                          text: myRequest[index].isApproved == true
                              ? "Approved"
                              : "Pending",
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
                          textColor:
                          AppConstant.blackColor.withOpacity(0.9),
                          fontWeight: FontWeight.w500)
                    ],
                  ),
                ],
              ),
              AppUtils.commonSizedBox(height: 8),
              AppUtils.commonTextWidget(
                  text: myRequest[index].comment ?? "",
                  fontSize: 12,
                  textColor: AppConstant.blackColor.withOpacity(0.9),
                  fontWeight: FontWeight.w400),
              // AppUtils.commonSizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  allDayEndRequests(List<ListItem>? employeeRequests) {
    return dayEndRequestProvider.isFetching
        ? AppUtils.loaderWidget()
        : employeeRequests?.length == 0 ||
        employeeRequests == null ||
        employeeRequests == []
        ? AppUtils.commonNoDataFound(
      text: "No Request Found",
      onPressed: () {},
    )
        : ListView.builder(
      physics: BouncingScrollPhysics(),
      shrinkWrap: true,
      itemCount: employeeRequests.length,
      padding: AppUtils.edgeInsetsOnly(
          bottom: 20, top: 0, left: 0, right: 0),
      itemBuilder: (context, index) {
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
                              text: employeeRequests[index].requestedBy ?? "",
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
                              text: AppUtils.getDate(
                                date: employeeRequests[index].attendanceDate ??
                                    "",
                                format: "dd MMM yyyy hh:mm a",
                              ),
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
                        color: employeeRequests[index].isApproved == false
                            ? AppConstant.greyColor
                            : Colors.green,
                      ),
                      child: AppUtils.commonTextWidget(
                          text: employeeRequests[index].isApproved == true
                              ? "Approved"
                              : "Pending",
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
                          text: "Comment",
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
                  text: employeeRequests[index].comment ?? "",
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
                      onSuccess: () async {
                        await dayEndRequestProvider.apiCallApproveRequest(
                            userId: employeeRequests[index].userId,
                          sessionId: employeeRequests[index].sessionId,
                          sessionEndDateTime: employeeRequests[index].requestedDate,

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
                  padding:
                  AppUtils.edgeInsetsOnly(top: 5, bottom: 15),
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
