import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:ontrek/core/common_widgets/app_scaffold.dart';
import 'package:ontrek/core/utils/App_utils.dart';
import 'package:ontrek/core/utils/app_constant.dart';
import 'package:ontrek/core/utils/image_path.dart';
import 'package:ontrek/features/dashboard/screens/dashboard_screen.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationPermissionScreen extends StatefulWidget {
  const LocationPermissionScreen({super.key});

  @override
  State<LocationPermissionScreen> createState() =>
      _LocationPermissionScreenState();
}

class _LocationPermissionScreenState extends State<LocationPermissionScreen> {
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
                          text: "LOCATION",
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
                      text: "Please allow us to access your\n location service",
                      textColor: AppConstant.blackColor,
                      fontSize: 14,
                      textAlign: TextAlign.center,
                      letterSpacing: 1,
                      fontWeight: FontWeight.w500)),
              AppUtils.commonElevatedBtn(
                width: double.infinity,
                height: 50,
                text: "ENABLE LOCATION",
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
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DashBoard(),
                        ));
                  })
            ],
          ),
        ),
      ),
    );
  }


  Future<void> askLocationPermission() async {
    final status = await Permission.location.request();
    if (status.isDenied) {
      // Permission still denied, ask again
      await askLocationPermission();
    } else if (status.isPermanentlyDenied) {
      // Permission permanently denied, show custom popup
      AppSettings.openAppSettings(type: AppSettingsType.location);
      // _showCustomPopup();
    }else{
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => DashBoard(),));
    }
  }

}
