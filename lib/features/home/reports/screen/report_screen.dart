import 'package:flutter/material.dart';
import 'package:ontrek/core/storage/preference_helper.dart';
import 'package:ontrek/core/utils/App_utils.dart';
import 'package:ontrek/core/utils/app_constant.dart';
import 'package:ontrek/features/home/reports/model/report_model.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen>  with TickerProviderStateMixin  {
  String? userId;
  late List<UserAttendenceReport> chartData = [];
  late TooltipBehavior tooltipBehavior;
  late TabController tabController;
  int selectedIndex = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    userId = PreferenceHelper.getString(PreferenceHelper.USER_ID);
    chartData = reportData();
    tabController = TabController(length: 2, vsync: this);
    tooltipBehavior = TooltipBehavior(enable: true);
  }

  @override
  Widget build(BuildContext context) {
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
                  reportCardDaily(),
                  reportCardMonthly(),
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
                  Tab(text: 'Daily Report'),
                  Tab(text: 'Monthly Report'),
                ]),
          ),

        ],
      ),
    );
  }

  bool _isExpanded = false;
  List<bool> isExpandedList = List.generate(5, (index) => false); // Assuming 5 items


  Widget reportCardMonthly(){
    return SingleChildScrollView(
      physics: BouncingScrollPhysics(),
      child: Column(
        children: [
          AppUtils.commonContainer(
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
            child: SfCartesianChart(
              tooltipBehavior: tooltipBehavior,
              title: ChartTitle(text: "Monthly Track Reports of Employee"),
              legend: Legend(isVisible: true),
              series: [
                StackedColumnSeries<UserAttendenceReport,String>(
                    dataSource: chartData,
                    enableTooltip: true,
                    name: "Internet",
                    xValueMapper: (UserAttendenceReport data, _) => data.userId,
                    yValueMapper: (UserAttendenceReport data, _) => data.sumInternetOffMinutes),
                StackedColumnSeries<UserAttendenceReport,String>(
                    dataSource: chartData,
                    enableTooltip: true,
                    name: "Gps",
                    xValueMapper: (UserAttendenceReport data, _) => data.userId,
                    yValueMapper: (UserAttendenceReport data, _) => data.sumGpsOffMinutes),
                StackedColumnSeries<UserAttendenceReport,String>(
                    dataSource: chartData,
                    enableTooltip: true,
                    name: "Waiting",
                    xValueMapper: (UserAttendenceReport data, _) => data.userId,
                    yValueMapper: (UserAttendenceReport data, _) => data.sumWaitingMinutes),
                StackedColumnSeries<UserAttendenceReport,String>(
                    dataSource: chartData,
                    enableTooltip: true,
                    name: "Traveling",
                    xValueMapper: (UserAttendenceReport data, _) => data.userId,
                    yValueMapper: (UserAttendenceReport data, _) => data.sumAppOffTime),
              ],
              primaryXAxis: CategoryAxis(),

            ),
          ),
          ListView.builder(
            itemCount: 5,
            shrinkWrap: true,
            padding: AppUtils.edgeInsetsOnly(bottom: 20),
            physics: NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              return  GestureDetector(
                onTap: () {
                  isExpandedList[index] = !isExpandedList[index];
                  setState(() {

                  });
                },
                child: AnimatedContainer(
                  duration: !isExpandedList[index] ? Duration(milliseconds: 0) : Duration(milliseconds: 700),
                  width: double.infinity,
                  margin: const EdgeInsets.only(left: 10, right: 10, top: 20),
                  padding: isExpandedList[index]
                      ? const EdgeInsets.only(left: 15, right: 15, top: 20, bottom: 0)
                      : const EdgeInsets.only(left: 15, right: 15, top: 20, bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        blurRadius: 8,
                        blurStyle: BlurStyle.solid,
                        spreadRadius: 0.8,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 3,
                            child: AppUtils.commonTextWidget(
                             text:  "12 July 2024",
                              textColor: AppConstant.appPrimaryColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(width: 50),
                          Expanded(
                            flex: 2,
                            child: AppUtils.commonTextWidget(
                              text:  "Kuldeep Chauhan",
                              textColor: AppConstant.appPrimaryColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      if (isExpandedList[index]) ...[
                        SizedBox(height: 10),
                        Divider(
                          color: Colors.grey.withOpacity(0.3),
                        ),
                        SizedBox(height: 10),
                        GridView.builder(
                          shrinkWrap: true,
                          padding: EdgeInsets.only(bottom: 20),
                          physics: NeverScrollableScrollPhysics(),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 60,
                            mainAxisSpacing: 10,
                          ),
                          itemCount: 6,
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onTap: () {
                                // Add your navigation logic here
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.all(Radius.circular(10)),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.2),
                                      blurRadius: 8,
                                      blurStyle: BlurStyle.solid,
                                      spreadRadius: 0.8,
                                    ),
                                  ],
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    SizedBox(height: 10),
                                    AppUtils.commonTextWidget(
                                      text:  "Waiting",
                                      textColor: AppConstant.appPrimaryColor,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    Divider(
                                      indent: 10,
                                      endIndent: 10,
                                      color: Colors.grey.withOpacity(0.3),
                                    ),

                                    AppUtils.commonTextWidget(
                                      text:  "500",
                                      textColor: AppConstant.appPrimaryColor,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    )
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },),
        ],
      ),
    );
  }
  Widget reportCardDaily(){
    return Column(
      children: [
        AppUtils.commonContainer(
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
          child: SfCartesianChart(
            tooltipBehavior: tooltipBehavior,
            title: ChartTitle(text: "Monthly Track Reports of Employee"),
            legend: Legend(isVisible: true),
            series: [
              StackedColumnSeries<UserAttendenceReport,String>(
                  dataSource: chartData,
                  enableTooltip: true,
                  name: "Internet",
                  xValueMapper: (UserAttendenceReport data, _) => data.userId,
                  yValueMapper: (UserAttendenceReport data, _) => data.sumInternetOffMinutes),
              StackedColumnSeries<UserAttendenceReport,String>(
                  dataSource: chartData,
                  enableTooltip: true,
                  name: "Gps",
                  xValueMapper: (UserAttendenceReport data, _) => data.userId,
                  yValueMapper: (UserAttendenceReport data, _) => data.sumGpsOffMinutes),
              StackedColumnSeries<UserAttendenceReport,String>(
                  dataSource: chartData,
                  enableTooltip: true,
                  name: "Waiting",
                  xValueMapper: (UserAttendenceReport data, _) => data.userId,
                  yValueMapper: (UserAttendenceReport data, _) => data.sumWaitingMinutes),
              StackedColumnSeries<UserAttendenceReport,String>(
                  dataSource: chartData,
                  enableTooltip: true,
                  name: "Traveling",
                  xValueMapper: (UserAttendenceReport data, _) => data.userId,
                  yValueMapper: (UserAttendenceReport data, _) => data.sumAppOffTime),
            ],
            primaryXAxis: CategoryAxis(),

          ),
        ),
        AppUtils.commonContainer(
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
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 3,child: AppUtils.commonTextWidget(text: "12 July 2024",fontSize: 12,fontWeight: FontWeight.w500,textColor: AppConstant.appPrimaryColor)),
                  AppUtils.commonSizedBox(width: 50),
                  Expanded(flex: 2,child: AppUtils.commonTextWidget(text: "Kuldeep Chauhan",fontSize: 12,fontWeight: FontWeight.w500,textColor: AppConstant.appPrimaryColor,/*overflow: TextOverflow.ellipsis*/)),
                ],
              ),

              AppUtils.commonSizedBox(height: 10,),
              Divider(
                color: AppConstant.greyColor.withOpacity(0.3),
              ),
              AppUtils.commonSizedBox(height: 10,),
              GridView.builder(
                shrinkWrap: true,
                padding: AppUtils.edgeInsetsOnly(bottom: 20),
                physics: NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    // childAspectRatio: 4/2,
                    crossAxisSpacing: 60,
                    mainAxisSpacing: 10),
                itemCount: 6,
                // Set the number of items in the grid
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      // navigateToScreenFnc(index, context);
                      // Navigator.push(context, CupertinoPageRoute(builder: (context) => TaskListScreen(),));
                    },
                    child: AppUtils.commonContainer(
                      // margin: AppUtils.edgeInsetsOnly(top: 0,bottom: 0,right: 0,left: 0),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: AppUtils.borderRadiusAll(raduis: 10),
                          boxShadow: [
                            BoxShadow(
                                color: AppConstant.greyColor
                                    .withOpacity(0.2),
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
                              text: "Waiting",
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
                              text: "50",
                              textColor: AppConstant.appPrimaryColor,
                              fontSize: 16,
                              fontWeight: FontWeight.w500),


                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  List<UserAttendenceReport> reportData() {
    List<UserAttendenceReport> _chartData = [
      UserAttendenceReport(
        userId: "1",
        absentDays: 5,
        sumAppOffTime: 10,
        sumGpsOffMinutes: 15,
        sumInternetOffMinutes: 15,
        sumWaitingMinutes: 200,
      ),
      UserAttendenceReport(
        userId: "2",
        absentDays: 15,
        sumAppOffTime: 26,
        sumGpsOffMinutes: 18,
        sumInternetOffMinutes: 50,
        sumWaitingMinutes: 360,
      ),
      UserAttendenceReport(
        userId: "3",
        absentDays: 10,
        sumAppOffTime: 35,
        sumGpsOffMinutes: 96,
        sumInternetOffMinutes: 28,
        sumWaitingMinutes: 400,
      ),
      UserAttendenceReport(
        userId: "4",
        absentDays: 18,
        sumAppOffTime: 10,
        sumGpsOffMinutes: 168,
        sumInternetOffMinutes: 26,
        sumWaitingMinutes: 260,
      ),
      UserAttendenceReport(
        userId: "5",
        absentDays: 25,
        sumAppOffTime: 19,
        sumGpsOffMinutes: 35,
        sumInternetOffMinutes: 35,
        sumWaitingMinutes: 352,
      ),
      UserAttendenceReport(
        userId: "6",
        absentDays: 25,
        sumAppOffTime: 19,
        sumGpsOffMinutes: 35,
        sumInternetOffMinutes: 35,
        sumWaitingMinutes: 352,
      ),
      UserAttendenceReport(
        userId: "7",
        absentDays: 25,
        sumAppOffTime: 19,
        sumGpsOffMinutes: 35,
        sumInternetOffMinutes: 35,
        sumWaitingMinutes: 352,
      ),
      UserAttendenceReport(
        userId: "8",
        absentDays: 25,
        sumAppOffTime: 19,
        sumGpsOffMinutes: 35,
        sumInternetOffMinutes: 35,
        sumWaitingMinutes: 352,
      ),
      UserAttendenceReport(
        userId: "9",
        absentDays: 25,
        sumAppOffTime: 19,
        sumGpsOffMinutes: 35,
        sumInternetOffMinutes: 35,
        sumWaitingMinutes: 352,
      ),
      UserAttendenceReport(
        userId: "10",
        absentDays: 25,
        sumAppOffTime: 19,
        sumGpsOffMinutes: 35,
        sumInternetOffMinutes: 35,
        sumWaitingMinutes: 352,
      ),
      
    ];
    return _chartData;
  }
}
