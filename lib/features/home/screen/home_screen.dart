import 'package:app_settings/app_settings.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:ontrek/core/storage/preference_helper.dart';
import 'package:ontrek/core/utils/App_utils.dart';
import 'package:ontrek/core/utils/app_constant.dart';
import 'package:ontrek/core/utils/image_path.dart';
import 'package:ontrek/features/home/customer/screen/cutomer_screen.dart';
import 'package:ontrek/features/home/day_end_request_approval/screens/day_end_approval_screen.dart';
import 'package:ontrek/features/home/expanse/screen/expanse_screen.dart';
import 'package:ontrek/features/home/holidays/screen/holiday_screen.dart';
import 'package:ontrek/features/home/leave/screen/leave_screen.dart';
import 'package:ontrek/features/home/reports/screen/report_screen.dart';
import 'package:ontrek/features/leads/screen/lead_screen.dart';
import 'package:ontrek/features/task_list/screen/task_list_screen.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map<String, dynamic> HomeScreenData = {};
  String? profilePicture;
  String? username;
  String? orgName;

  List<String> HomeScreenImg = [
    taskIconPath,
    leadIconPath,
    reportsImagePath,
    dayEndImagePath,
    leaveImagePath,
    reimbursementImagePath,
    holidayImagePath,
  ];

  List<String> HomeScreenTitle = [
    "Task",
    "Lead",
    "Reports",
    "Day End",
    "Leave",
    "Expense",
    "Holidays"
  ];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    profilePicture = PreferenceHelper.getString(PreferenceHelper.PROFILE_PIC);
    username =  PreferenceHelper.getString(PreferenceHelper.USER_NAME);
    orgName =  PreferenceHelper.getString(PreferenceHelper.ORG_NAME);
  }


  @override
  Widget build(BuildContext context) {
    return Animate(
      effects: const [
        SlideEffect(
            end: Offset(0, 0),
            curve: Curves.decelerate,
            begin: Offset(0, 1),
            duration: Duration(milliseconds: 700)),
      ],
      child: Scaffold(
        backgroundColor: AppConstant.whiteColor,
        appBar: AppBar(
          surfaceTintColor: AppConstant.whiteColor,
          forceMaterialTransparency: true,
          centerTitle: false,
          title: Column(crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppUtils.commonTextWidget(text: username ?? "",textColor: AppConstant.blackColor,fontSize: 16),
              AppUtils.commonTextWidget(text: orgName ?? "",textColor: AppConstant.blackColor,fontSize: 10),
            ],
          ),
          actions: [
            AppUtils.commonContainer(
              margin: AppUtils.edgeInsetsOnly(right: 10),
              height: 45,
              width: 45,
              decoration: AppUtils.commonBoxDecoration(
                  shape: BoxShape.circle,
                  border:
                  Border.all(color: AppConstant.appPrimaryColor)),
              child: ClipOval(
                child: AppUtils.commonCacheNetworkImage(
                    imgUrl: profilePicture
                ),
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: AppUtils.edgeInsetsOnly(left: 10, right: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppUtils.commonSizedBox(height: 20),
                  Column(
                    children: [
                      GridView.builder(
                        shrinkWrap: true,
                        padding: AppUtils.edgeInsetsOnly(bottom: 20),
                        physics: NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            // childAspectRatio: 4/2,
                            crossAxisSpacing: 30,
                            mainAxisSpacing: 30),
                        itemCount: HomeScreenImg.length,
                        // Set the number of items in the grid
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () {
                              navigateToScreenFnc(index, context);
                              // Navigator.push(context, CupertinoPageRoute(builder: (context) => TaskListScreen(),));
                            },
                            child: AppUtils.commonContainer(
                              decoration: BoxDecoration(
                                  color: AppConstant.whiteColor,
                                  borderRadius:
                                      AppUtils.borderRadiusAll(raduis: 10),
                                  boxShadow: [
                                    BoxShadow(
                                        color: AppConstant.greyColor
                                            .withOpacity(0.2),
                                        blurRadius: 8,
                                        blurStyle: BlurStyle.solid,
                                        spreadRadius: 0.8),
                                  ]),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    HomeScreenImg[index],
                                    width: 38,
                                    height: 38,
                                  ),
                                  SizedBox(height: 10),
                                  AppUtils.commonTextWidget(
                                      text: HomeScreenTitle[index],
                                      textColor: AppConstant.appPrimaryColor,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w500),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void navigateToScreenFnc(int index, BuildContext context) {
    switch (index) {
      case 0:
        Navigator.push(context,
            CupertinoPageRoute(builder: (context) => TaskListScreen()));
        break;
      case 1:
        Navigator.push(
            context,
            CupertinoPageRoute(
              builder: (context) => LeadScreen(),
            ));
        break;
      case 2:
        // for Reports
        Navigator.push(
            context,
            CupertinoPageRoute(
              builder: (context) => ReportScreen(),
            ));
        break;
      case 3:
        // DayEnd Manual request Screen
        Navigator.push(
            context,
            CupertinoPageRoute(
              builder: (context) => DayEndApprovalScreen(),
            ));
        //   AppSettings.openAppSettings();
        break;
      case 4:
        //Leave Management
        Navigator.push(
            context,
            CupertinoPageRoute(
              builder: (context) => LeaveScreen(),
            ));
        break;

      case 5 :
        //Expanse Management
        Navigator.push(
            context,
            CupertinoPageRoute(
              builder: (context) => ExpenseScreen(),
            ));

        break;
      case 6:
        // holidays screen
        Navigator.push(
            context,
            CupertinoPageRoute(
              builder: (context) => HolidayScreen(),
            ));

        break;
      default:
        break;
    }
  }
}
