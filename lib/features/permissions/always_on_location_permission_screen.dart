import 'package:app_settings/app_settings.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ontrek/core/common_widgets/app_scaffold.dart';
import 'package:ontrek/core/storage/preference_helper.dart';
import 'package:ontrek/core/utils/App_utils.dart';
import 'package:ontrek/core/utils/app_constant.dart';
import 'package:ontrek/core/utils/image_path.dart';
import 'package:ontrek/features/authentication/screens/login_with_phone_number.dart';
import 'package:ontrek/features/dashboard/screens/dashboard_screen.dart';
import 'package:permission_handler/permission_handler.dart';

class AlwaysPermissionScreen extends StatefulWidget {
  const AlwaysPermissionScreen({super.key});

  @override
  State<AlwaysPermissionScreen> createState() =>
      _AlwaysPermissionScreenState();
}

class _AlwaysPermissionScreenState extends State<AlwaysPermissionScreen> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: AppScaffold(
        backgroundColor: AppConstant.whiteColor,
        body: Padding(
          padding: const EdgeInsets.all(50),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                children: [
                  Center(
                      child: AppUtils.commonTextWidget(
                          text: "ENABLE YOUR",
                          textColor: AppConstant.blackColor,
                          fontSize: 26,
                          textAlign: TextAlign.center,
                          letterSpacing: 1.3,
                          fontWeight: FontWeight.w500)),
                  Center(
                      child: AppUtils.commonTextWidget(
                          text: "ALWAYS LOCATION",
                          textColor: AppConstant.blackColor,
                          fontSize: 24,
                          textAlign: TextAlign.center,
                          letterSpacing: 1,
                          fontWeight: FontWeight.w500)),
                ],
              ),
              AppUtils.commonSizedBox(height: 30),
              Center(
                child: Image.asset(locationPermissionImage,
                    height: 300, width: 300),
              ),
              AppUtils.commonSizedBox(height: 30),
              Center(
                  child: AppUtils.commonTextWidget(
                      text: "Please allow us to access your\n always on location service",
                      textColor: AppConstant.blackColor,
                      fontSize: 14,
                      textAlign: TextAlign.center,
                      letterSpacing: 1,
                      fontWeight: FontWeight.w500)),
              AppUtils.commonElevatedBtn(
                  width: double.infinity,
                  height: 50,
                  text: "ENABLE ALWAYS LOCATION",
                  bgColor: AppConstant.appPrimaryColor.withOpacity(0.9),
                  borderRadiusAll: 30,
                  onPressed: askLocationPermission
              ),
              AppUtils.commonInkWell(
                  child: AppUtils.commonTextWidget(
                    text: "NOT NOW",
                    textColor: AppConstant.greyColor,
                  ),
                  onTap: () {
                    bool? isLogIn = PreferenceHelper.getBool(PreferenceHelper.IS_LOGIN);
                    if(isLogIn == true){
                      Navigator.pushReplacement(context, CupertinoPageRoute(builder: (context) => DashBoard(),));
                    }else{
                      Navigator.pushReplacement(context, CupertinoPageRoute(builder: (context) => LoginScreen(),));
                    }

                  })
            ],
          ),
        ),
      ),
    );
  }


  Future<void> askLocationPermission() async {
    final status = await Permission.locationAlways.request();
    if (status.isDenied) {
      // Permission still denied, ask again
      await askLocationPermission();
    } else if (status.isPermanentlyDenied) {
      // Permission permanently denied, show custom popup
      AppSettings.openAppSettings(type: AppSettingsType.location);
      // _showCustomPopup();
    }else{
      bool? isLogIn = PreferenceHelper.getBool(PreferenceHelper.IS_LOGIN);
      if(isLogIn == false){
        Navigator.pushReplacement(context, CupertinoPageRoute(builder: (context) => LoginScreen(),));
      }else{
        Navigator.pushReplacement(context, CupertinoPageRoute(builder: (context) => DashBoard(),));
      }

    }
  }

}
