import 'package:flutter/material.dart';
import 'package:ontrek/core/services/network_repository.dart';
import 'package:ontrek/core/storage/preference_helper.dart';
import 'package:ontrek/core/utils/App_utils.dart';
import 'package:ontrek/core/utils/app_constant.dart';
import 'package:ontrek/features/home/reports/model/get_all_report_model.dart';
import 'package:ontrek/features/home/reports/model/report_model.dart';
import 'package:ontrek/features/home/reports/provider/report_provider.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen>
    with TickerProviderStateMixin {
  String? userId;
  String? userName;
  late TooltipBehavior tooltipBehavior;
  late TabController tabController;
  int selectedIndex = 0;
  late ReportProvider reportProvider;
  List<bool> isExpandedList = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    tabController = TabController(length: 2, vsync: this);
    tooltipBehavior = TooltipBehavior(enable: true);
    WidgetsBinding.instance.addPostFrameCallback(
      (_) async {
        reportProvider = Provider.of<ReportProvider>(context, listen: false);
        if (selectedIndex == 0) {
          reportProvider.apiCallGetAllReport(
              reportType: 1,
              userId: userId,
              reportDate: AppUtils.getDate(
                  date: DateTime.now().toString(), format: "yyyy-MM-dd"));
        } else {
          reportProvider.apiCallGetAllReport(
              userId: userId,
              reportDate: AppUtils.getDate(
                  date: DateTime.now().toString(), format: "yyyy-MM-01"));
        }
        userId = PreferenceHelper.getString(PreferenceHelper.USER_ID);
        userName = PreferenceHelper.getString(PreferenceHelper.USER_NAME);
        isExpandedList = List.generate(
            reportProvider.getAllReportModel?.data?.userAttendenceReport
                    ?.firstWhere(
                      (element) => element.userId == userId,
                    )
                    .userAttendenceDetail
                    ?.length ??
                0,
            (index) => false);
        setState(() {});
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    reportProvider = Provider.of<ReportProvider>(context);
    return Scaffold(
      backgroundColor: AppConstant.whiteColor,
      appBar: AppUtils.commonAppBar(
        context: context,
        title: "Reports",
        isBack: true,
        isCenter: true,
        isBorder: true,
      ),
      body: Column(
        children: [
          Expanded(
              child: TabBarView(
            physics: NeverScrollableScrollPhysics(),
            controller: tabController,
            children: [
              reportCardDaily(
                  reportProvider.getAllReportModel?.data?.userAttendenceReport
                      ?.where(
                        (element) => element.userId == userId,
                      )
                      .toList()),
              reportCardMonthly(
                  reportProvider.getAllReportModel?.data?.userAttendenceReport
                      ?.firstWhere(
                        (element) => element.userId == userId,
                      )
                      .userAttendenceDetail,
                  reportProvider),
              // allDayEndRequests(),
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
                  if (selectedIndex == 0) {
                    await reportProvider.apiCallGetAllReport(
                        reportType: 1,
                        userId: userId,
                        reportDate: AppUtils.getDate(
                            date: DateTime.now().toString(),
                            format: "yyyy-MM-dd"));
                  } else {
                    await reportProvider.apiCallGetAllReport(
                        userId: userId,
                        reportDate: AppUtils.getDate(
                            date: DateTime.now().toString(),
                            format: "yyyy-MM-01"));
                    isExpandedList = List.generate(
                        reportProvider
                                .getAllReportModel?.data?.userAttendenceReport
                                ?.firstWhere(
                                  (element) => element.userId == userId,
                                )
                                .userAttendenceDetail
                                ?.length ??
                            0,
                        (index) => false);
                    setState(() {});
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
                  Tab(text: 'Daily Report'),
                  Tab(text: 'Monthly Report'),
                ]),
          ),
        ],
      ),
    );
  }

// daily report widget
  Widget reportCardDaily(List<UserAttendenceReport>? userAttendenceReport) {
    return reportProvider.isFetching
        ? AppUtils.loaderWidget()
        : userAttendenceReport == null || userAttendenceReport.length == 0
            ? AppUtils.commonNoDataFound(
                text: "No Data Found",
                onPressed: () async {
                  await reportProvider.apiCallGetAllReport(
                      reportType: 1,
                      userId: userId,
                      reportDate: AppUtils.getDate(
                          date: DateTime.now().toString(),
                          format: "yyyy-MM-dd"));
                },
              )
            : SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                child: Column(
                  children: [
                    AppUtils.commonContainer(
                      width: double.infinity,
                      margin:
                          const EdgeInsets.only(left: 10, right: 10, top: 20),
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
                      child: SfCartesianChart(
                        tooltipBehavior: tooltipBehavior,
                        title: ChartTitle(
                            text: "Daily Track Reports of Employee"),
                        legend: Legend(isVisible: true),
                        series: [
                          StackedColumnSeries<UserAttendenceReport, String>(
                              dataSource: userAttendenceReport,
                              enableTooltip: true,
                              name: "Internet",
                              width: 0.05,
                              xValueMapper: (UserAttendenceReport data, _) =>
                                  data.datePeriod,
                              yValueMapper: (UserAttendenceReport data, _) =>
                                  data.sumInternetOffMinutes),
                          StackedColumnSeries<UserAttendenceReport, String>(
                              dataSource: userAttendenceReport,
                              enableTooltip: true,
                              name: "Gps",
                              width: 0.05,
                              xValueMapper: (UserAttendenceReport data, _) =>
                                  data.datePeriod,
                              yValueMapper: (UserAttendenceReport data, _) =>
                                  data.sumGpsOffMinutes),
                          StackedColumnSeries<UserAttendenceReport, String>(
                              dataSource: userAttendenceReport,
                              enableTooltip: true,
                              name: "Waiting",
                              width: 0.05,
                              xValueMapper: (UserAttendenceReport data, _) =>
                                  data.datePeriod,
                              yValueMapper: (UserAttendenceReport data, _) =>
                                  data.sumWaitingMinutes),
                          StackedColumnSeries<UserAttendenceReport, String>(
                              dataSource: userAttendenceReport,
                              enableTooltip: true,
                              name: "Traveling",
                              width: 0.05,
                              xValueMapper: (UserAttendenceReport data, _) =>
                                  data.datePeriod,
                              yValueMapper: (UserAttendenceReport data, _) =>
                                  data.sumTravellingMinutes),
                          StackedColumnSeries<UserAttendenceReport, String>(
                              dataSource: userAttendenceReport,
                              enableTooltip: true,
                              name: "Meeting",
                              width: 0.05,
                              xValueMapper: (UserAttendenceReport data, _) =>
                              data.datePeriod,
                              yValueMapper: (UserAttendenceReport data, _) =>
                              data.sumMeetingMinutes),
                        ],
                        primaryXAxis: CategoryAxis(),
                      ),
                    ),
                    AppUtils.commonContainer(
                      width: double.infinity,
                      margin:
                          const EdgeInsets.only(left: 10, right: 10, top: 20),
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
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 3,
                                child: AppUtils.commonTextWidget(
                                  text: userAttendenceReport?.first.datePeriod
                                          .toString() ??
                                      "",
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  textColor: AppConstant.appPrimaryColor,
                                ),
                              ),
                              Container(
                                width: MediaQuery.of(context).size.width / 3,
                                child: AppUtils.commonTextWidget(
                                  text: userName ?? "",
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  textColor: AppConstant.appPrimaryColor,
                                  overflow: TextOverflow
                                      .ellipsis, // Ensure text does not overflow
                                ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AppUtils.commonSizedBox(
                                height: 10,
                              ),
                              Divider(
                                color: AppConstant.greyColor.withOpacity(0.3),
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  CommonContainerOfReportData(
                                      title: "Attendance",
                                      value: userAttendenceReport
                                                  .first.absentDays ==
                                              0
                                          ? "P"
                                          : "A",
                                      valueColor: userAttendenceReport
                                                  .first.absentDays ==
                                              0
                                          ? Colors.green
                                          : Colors.red),
                                  CommonContainerOfReportData(
                                      title: "Check in",
                                      value: userAttendenceReport
                                          .first.meetingCount
                                          .toString()),
                                  CommonContainerOfReportData(
                                      title: "Km",
                                      value: userAttendenceReport
                                          .first.sumTotalKm
                                          .toString()),
                                ],
                              ),
                              Row(
                                children: [
                                  CommonContainerOfReportData(
                                      title: "Waiting",
                                      value: userAttendenceReport
                                          ?.first.sumWaitingMinutes
                                          .toString()),
                                  CommonContainerOfReportData(
                                      title: "Internet",
                                      value: userAttendenceReport
                                          ?.first.sumInternetOffMinutes
                                          .toString()),
                                  CommonContainerOfReportData(
                                      title: "Gps",
                                      value: userAttendenceReport
                                          ?.first.sumGpsOffMinutes
                                          .toString()),
                                ],
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
  }

// Monthly report widget
  Widget reportCardMonthly(List<UserAttendenceDetail>? userAttendenceDetail,
      ReportProvider reportProvider) {
    return reportProvider.isFetching
        ? AppUtils.loaderWidget()
        : userAttendenceDetail == null || userAttendenceDetail.length == 0
            ? AppUtils.commonNoDataFound(
                text: "No Data Found",
                onPressed: () async {
                  await reportProvider.apiCallGetAllReport(
                      reportType: 1,
                      userId: userId,
                      reportDate: AppUtils.getDate(
                          date: DateTime.now().toString(),
                          format: "yyyy-MM-dd"));
                },
              )
            : SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                child: Column(
                  children: [
                    AppUtils.commonContainer(
                      width: double.infinity,
                      margin:
                          const EdgeInsets.only(left: 10, right: 10, top: 20),
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
                      child: SfCartesianChart(
                        tooltipBehavior: tooltipBehavior,


                        title: ChartTitle(
                            text: "Monthly Track Reports of Employee"),
                        legend: Legend(isVisible: true),
                        series: [
                          StackedColumnSeries<UserAttendenceDetail, String>(
                              dataSource: userAttendenceDetail,
                              enableTooltip: true,
                              name: "Internet",
                              width: 0.05,
                              xValueMapper: (UserAttendenceDetail data, _) =>
                                  AppUtils.extractDay(data.reportDate ?? "" , "d/M/yyyy"),
                              yValueMapper: (UserAttendenceDetail data, _) =>
                                  data.internetOffMinutes),
                          StackedColumnSeries<UserAttendenceDetail, String>(
                              dataSource: userAttendenceDetail,
                              enableTooltip: true,
                              name: "Gps",
                              width: 0.05,
                              xValueMapper: (UserAttendenceDetail data, _) =>
                                  AppUtils.extractDay(data.reportDate ?? "" , "d/M/yyyy"),
                              yValueMapper: (UserAttendenceDetail data, _) =>
                                  data.gpsOffMinutes),
                          StackedColumnSeries<UserAttendenceDetail, String>(
                              dataSource: userAttendenceDetail,
                              enableTooltip: true,
                              name: "Waiting",
                              width: 0.05,
                              xValueMapper: (UserAttendenceDetail data, _) =>
                                  AppUtils.extractDay(data.reportDate ?? "" , "d/M/yyyy"),
                              yValueMapper: (UserAttendenceDetail data, _) =>
                                  data.waitingMinutes),
                          StackedColumnSeries<UserAttendenceDetail, String>(
                              dataSource: userAttendenceDetail,
                              enableTooltip: true,
                              name: "Traveling",
                              width: 0.05,
                              xValueMapper: (UserAttendenceDetail data, _) =>
                                  AppUtils.extractDay(data.reportDate ?? "" , "d/M/yyyy"),
                              yValueMapper: (UserAttendenceDetail data, _) =>
                                  data.travellingMinutes),
                          StackedColumnSeries<UserAttendenceDetail, String>(
                              dataSource: userAttendenceDetail,
                              enableTooltip: true,
                              name: "Meeting",
                              width: 0.05,
                              xValueMapper: (UserAttendenceDetail data, _) =>
                                  AppUtils.extractDay(data.reportDate ?? "" , "d/M/yyyy"),
                              yValueMapper: (UserAttendenceDetail data, _) =>
                              data.meetingMinutes),
                        ],
                        primaryXAxis: CategoryAxis(),
                      ),
                    ),
                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 20, left: 10),
                          child: AppUtils.commonTextWidget(
                              text: "Datewise Reports",
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                              textColor:
                                  AppConstant.greyColor.withOpacity(0.8)),
                        )
                      ],
                    ),
                    ListView.builder(
                      itemCount: userAttendenceDetail.length,
                      shrinkWrap: true,
                      padding: AppUtils.edgeInsetsOnly(bottom: 20),
                      physics: NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              isExpandedList[index] = !isExpandedList[index];
                            });
                          },
                          child: AnimatedContainer(
                            duration: Duration(milliseconds: 300),
                            width: double.infinity,
                            margin: const EdgeInsets.only(
                                left: 10, right: 10, top: 20),
                            padding: isExpandedList[index]
                                ? const EdgeInsets.only(
                                    left: 15, right: 15, top: 20, bottom: 0)
                                : const EdgeInsets.only(
                                    left: 15, right: 15, top: 20, bottom: 20),
                            decoration: BoxDecoration(
                                color: AppConstant.whiteColor,
                                borderRadius:
                                    AppUtils.borderRadiusAll(raduis: 10),
                                boxShadow: [
                                  BoxShadow(
                                      color: AppConstant.greyColor
                                          .withOpacity(0.3),
                                      blurRadius: 8,
                                      blurStyle: BlurStyle.solid,
                                      spreadRadius: 0.8),
                                ]),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    AppUtils.commonTextWidget(
                                      text: userAttendenceDetail[index]
                                              .reportDate ??
                                          "",
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      textColor: AppConstant.appPrimaryColor,
                                    ),
                                    Icon(isExpandedList[index] == true ? Icons.arrow_drop_up :Icons.arrow_drop_down,color: AppConstant.appPrimaryColor,size: 20,)
                                  ],
                                ),
                                if (isExpandedList[index])
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      AppUtils.commonSizedBox(
                                        height: 10,
                                      ),
                                      Divider(
                                        color: AppConstant.greyColor
                                            .withOpacity(0.3),
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          CommonContainerOfReportData(
                                              title: "Attendance",
                                              value: userAttendenceDetail[index]
                                                  .attendenceType,
                                              valueColor:
                                                  userAttendenceDetail[index]
                                                              .attendenceType ==
                                                          "P"
                                                      ? Colors.green
                                                      : Colors.red),
                                          CommonContainerOfReportData(
                                              title: "Check in",
                                              value: userAttendenceDetail[index]
                                                  .meetingCount
                                                  .toString()),
                                          CommonContainerOfReportData(
                                              title: "Km",
                                              value: userAttendenceDetail[index]
                                                  .totalKm
                                                  .toString()),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          CommonContainerOfReportData(
                                              title: "Waiting",
                                              value: userAttendenceDetail[index]
                                                  .waitingMinutes
                                                  .toString()),
                                          CommonContainerOfReportData(
                                              title: "Internet",
                                              value: userAttendenceDetail[index]
                                                  .internetOffMinutes
                                                  .toString()),
                                          CommonContainerOfReportData(
                                              title: "Gps",
                                              value: userAttendenceDetail[index]
                                                  .gpsOffMinutes
                                                  .toString()),
                                        ],
                                      )
                                    ],
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              );
  }

  //Card widget
  Widget CommonContainerOfReportData(
      {String? title, String? value, Color? valueColor}) {
    return Expanded(
      flex: 1,
      child: AppUtils.commonContainer(
        margin:
            AppUtils.edgeInsetsOnly(top: 10, bottom: 15, right: 10, left: 10),
        padding:
            AppUtils.edgeInsetsOnly(top: 10, bottom: 15, right: 10, left: 10),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: AppUtils.borderRadiusAll(raduis: 10),
            boxShadow: [
              BoxShadow(
                  color: AppConstant.greyColor.withOpacity(0.2),
                  blurRadius: 8,
                  blurStyle: BlurStyle.solid,
                  spreadRadius: 0.8),
            ]),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 5),
            AppUtils.commonTextWidget(
                text: title ?? "",
                textColor: AppConstant.appPrimaryColor,
                fontSize: 10,
                fontWeight: FontWeight.w500),
            Divider(
              indent: 10,
              endIndent: 10,
              color: AppConstant.greyColor.withOpacity(0.3),
            ),
            SizedBox(height: 5),
            AppUtils.commonTextWidget(
                text: value ?? "0",
                textColor: valueColor ?? AppConstant.appPrimaryColor,
                fontSize: 16,
                fontWeight: FontWeight.w500),
          ],
        ),
      ),
    );
  }
}
