import 'dart:async';
import 'package:flutter/material.dart';
import 'package:ontrek/core/utils/app_constant.dart';
import 'package:ontrek/core/utils/image_path.dart';
import 'package:ontrek/core/utils/widget_utils.dart';
import 'package:ontrek/features/authentication/screens/login_screen.dart';
import 'package:ontrek/features/dashboard/screens/dashboard_screen.dart';

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
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => DashBoard()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstant.primaryColor,
      // body: Center(
      //     child: WidgetUtils.imageAsset(
      //         imagePath: logoImagePath,
      //         width: 100,
      //         height: 100,
      //         fit: BoxFit.cover,
      //         imageColor: AppConstant.btnColor)),
    );
  }
}
