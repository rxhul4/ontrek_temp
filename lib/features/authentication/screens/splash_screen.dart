import 'dart:async';
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:ontrek/core/utils/App_utils.dart';
import 'package:ontrek/core/utils/app_constant.dart';
import 'package:ontrek/core/utils/image_path.dart';
import 'package:ontrek/features/dashboard/screens/dashboard_screen.dart';
import 'package:ontrek/features/permissions/location_permission_screen.dart';
import 'package:permission_handler/permission_handler.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    redirectToLogin();
  }

  redirectToLogin() {
    Timer(const Duration(milliseconds: 3000), () {
      askPermissionAndRedirect();

    });
  }

  Future askPermissionAndRedirect()async{
    var status = await Permission.location.status;
    if(status.isGranted){
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => DashBoard(),));
    }else{
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LocationPermissionScreen() ,));

    }
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
                    effects: [FadeEffect(curve: Curves.ease,duration: Duration(milliseconds: 3000)),ShimmerEffect(curve: Curves.ease,duration: Duration(milliseconds: 3000)),],
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
      )

    );
  }
}
