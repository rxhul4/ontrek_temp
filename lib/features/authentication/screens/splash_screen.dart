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
import 'package:ontrek/features/permissions/location_permission_screen.dart';
import 'package:permission_handler/permission_handler.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool? isLogIn;
  int? roleId;
  bool? isDayStart;
  bool? isCheckIn;

  gotoLogin() async {
    isLogIn = PreferenceHelper.getBool(PreferenceHelper.IS_LOGIN);
    roleId = PreferenceHelper.getInt(PreferenceHelper.ROLE_ID);
    isDayStart = PreferenceHelper.getBool(PreferenceHelper.DayStart);
    isCheckIn = PreferenceHelper.getBool(PreferenceHelper.checkIn);
    var status = await Permission.location.status;
    print("isLogIn $isLogIn");
    print("roleId $roleId");
    print("isDayStart $isDayStart");
    print("isCheckIn $isCheckIn");
    print("status $status");
    Timer(const Duration(milliseconds: 3000), () {

      // if(status.isGranted){
      //   if(isLogIn??  false){
      //     Navigator.pushReplacement(context, CupertinoPageRoute(builder: (context) => DashBoard(),));
      //   }else{
      //     Navigator.pushReplacement(context, CupertinoPageRoute(builder: (context) => LogInScreen(),));
      //   }
      // }else{
      //   Navigator.pushReplacement(context, CupertinoPageRoute(builder: (context) => LocationPermissionScreen(),));
      // }

      if (status.isGranted) {
        if (isLogIn ?? false) {
          Navigator.pushReplacement(context, CupertinoPageRoute(builder: (context) => DashBoard(),));
          if (isDayStart ?? false) {
            if (isCheckIn ?? false) {
              Navigator.pushReplacement(
                context,
                CupertinoPageRoute(builder: (context) => DashBoard()),
              );
            } else {
              Navigator.pushReplacement(
                context,
                CupertinoPageRoute(builder: (context) => DashBoard()),
              );
            }
          } else {
            Navigator.pushReplacement(
              context,
              CupertinoPageRoute(builder: (context) => DashBoard()),
            );
          }
        } else {
          Navigator.pushReplacement(
            context,
            CupertinoPageRoute(builder: (context) => LoginScreen()),
          );
        }
      } else {
        Navigator.pushReplacement(
            context,
            CupertinoPageRoute(
              builder: (context) => LocationPermissionScreen(),
            ));
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
              margin: AppUtils.edgeInsetsOnly(bottom: 25),
              child: AppUtils.commonTextWidget(
                text: "Location Intelligence and Analytics App",
                fontWeight: FontWeight.w400,
                textColor: AppConstant.appPrimaryColor,
                fontSize: 13,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ));
  }
}
