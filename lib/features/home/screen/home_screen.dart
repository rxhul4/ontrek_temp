import 'package:app_settings/app_settings.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:ontrek/core/utils/App_utils.dart';
import 'package:ontrek/core/utils/app_constant.dart';
import 'package:ontrek/core/utils/image_path.dart';
import 'package:ontrek/features/task_list/screen/task_list_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}



class _HomeScreenState extends State<HomeScreen> {

  List<String> HomeScreenImg = [
    taskImagePathForHome,
    leadImagePathForHome,
    reportsImagePathForHome,
    dayEndImagePathForHome
  ];

  List<String> HomeScreenTitle = [
    "Task",
    "Lead",
    "Reports",
    "Day-End Request"
  ];
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
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: AppUtils.edgeInsetsOnly(left: 20, right: 20),
              child: Column(
                children: [
                  AppUtils.commonContainer(
                      margin: AppUtils.edgeInsetsOnly(
                        top: 20,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          AppUtils.commonTextWidget(
                              text: "Home",
                              fontSize: 28,
                              textColor: AppConstant.appPrimaryColor),
                          GestureDetector(
                              onTap: () {
                                AppSettings.openAppSettings();
                              },
                              child: Icon(
                                Icons.settings,
                                color: AppConstant.appPrimaryColor,
                                size: 28,
                              ))
                        ],
                      )),
                  AppUtils.commonSizedBox(height: 20),
                  Column(
                    children: [
                      GridView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            // childAspectRatio: 4/2,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10
                        ),
                        itemCount: 4, // Set the number of items in the grid
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(context, CupertinoPageRoute(builder: (context) => TaskListScreen(),));
                            },
                            child: AppUtils.commonContainer(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Image.asset(HomeScreenImg[index],width: 60,height: 60,),
                                  SizedBox(height: 10),
                                  // Add spacing between icon and text
                                  AppUtils.commonTextWidget(
                                    text: HomeScreenTitle[index],
                                    textColor: AppConstant.appPrimaryColor,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500
                                  ),
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
}
