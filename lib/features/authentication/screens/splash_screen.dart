import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:ontrek/core/storage/preference_helper.dart';
import 'package:ontrek/core/utils/App_utils.dart';
import 'package:ontrek/core/utils/app_constant.dart';
import 'package:ontrek/core/utils/image_path.dart';
import 'package:ontrek/features/authentication/screens/login_with_phone_number.dart';
import 'package:ontrek/features/dashboard/screens/dashboard_screen.dart';
import 'package:ontrek/features/permissions/always_on_location_permission_screen.dart';
import 'package:ontrek/features/permissions/location_permission_screen.dart';
import 'package:permission_handler/permission_handler.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool? isLogIn;
  String? roleId;
  bool? isDayStart;
  bool? isCheckIn;
  bool? isWaiting;

  gotoLogin() async {
    isLogIn = PreferenceHelper.getBool(PreferenceHelper.IS_LOGIN);
    roleId = PreferenceHelper.getString(PreferenceHelper.ROLE_ID);
    isDayStart = PreferenceHelper.getBool(PreferenceHelper.DayStart);
    isCheckIn = PreferenceHelper.getBool(PreferenceHelper.checkIn);
    isWaiting = PreferenceHelper.getBool(PreferenceHelper.isWaiting);
    var status = await Permission.location.status;
    var statusOfAlwaysOnLocation = await Permission.locationAlways.status;
    print("isLogIn $isLogIn");
    print("roleId $roleId");
    print("isDayStart $isDayStart");
    print("isCheckIn $isCheckIn");
    print("isWaiting $isWaiting");
    print("status $status");
    Timer(const Duration(milliseconds: 3000), () {
      if(status.isGranted){
        if(statusOfAlwaysOnLocation.isGranted){
          if(isLogIn == true){
            Navigator.pushReplacement(context, CupertinoPageRoute(builder: (context) => const DashBoard(),));
          }else{
            Navigator.pushReplacement(context, CupertinoPageRoute(builder: (context) => const LoginScreen(),));
          }
        }else{
          Navigator.pushReplacement(context, CupertinoPageRoute(builder: (context) => const AlwaysPermissionScreen(),));
        }

      }else{
        Navigator.pushReplacement(context, CupertinoPageRoute(builder: (context) => const LocationPermissionScreen(),));
      }

    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    // redirectToLogin();
    gotoLogin();
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppConstant.whiteColor,
        body: Column(
          // mainAxisAlignment: MainAxisAlignment.spaceBetween,
          // crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Center(
                    child: Animate(
                      effects: [
                        FadeEffect(
                            curve: Curves.ease,
                            duration: Duration(milliseconds: 3000)),
                        ShimmerEffect(
                            curve: Curves.ease,
                            duration: Duration(milliseconds: 3000)),
                      ],
                      child: Image.asset(
                        logoImagePath,
                        color: AppConstant.appPrimaryColor,
                        width: 200,
                        height: 200,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              alignment: Alignment.bottomCenter,
              margin: AppUtils.edgeInsetsOnly(bottom: 20),
              child: AppUtils.commonTextWidget(
                text: "Every Step, Every Move, Always in Control",
                fontWeight: FontWeight.w500,
                textColor: AppConstant.appPrimaryColor,
                fontSize: 13,
                letterSpacing: 00,
              ),
            ),
          ],
        ));
  }
}
