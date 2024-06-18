import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ontrek/core/common_widgets/app_scaffold.dart';
import 'package:ontrek/core/storage/preference_helper.dart';
import 'package:ontrek/core/utils/App_utils.dart';
import 'package:ontrek/core/utils/UserPermission.dart';
import 'package:ontrek/core/utils/app_constant.dart';
import 'package:ontrek/core/utils/image_path.dart';
import 'package:ontrek/features/authentication/screens/login_with_phone_number.dart';
import 'package:ontrek/features/dashboard/screens/dashboard_screen.dart';


class PermissionRequestScreen extends StatefulWidget {
  const PermissionRequestScreen({super.key});

  @override
  State<PermissionRequestScreen> createState() =>
      _PermissionRequestScreenState();
}

class _PermissionRequestScreenState extends State<PermissionRequestScreen> {
  bool? isLogIn;
  late ScrollController scrollController;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    isLogIn = PreferenceHelper.getBool(PreferenceHelper.IS_LOGIN);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      scrollController = ScrollController();
    });


  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      backgroundColor: AppConstant.whiteColor,
     appBar: AppBar(
       surfaceTintColor: AppConstant.transparentColor,
       backgroundColor: Colors.white,
       elevation: 0,
       centerTitle: true,
       actions: [
         GestureDetector(
           onTap: () {
             AppUtils.showDialogBoxForPrivacyPolicy(
                 titleText: "Location Access Policy",
                 context: context,
                 text3: "Application will collect user latitude and longitude and will send to server for business purpose. User location will be provided to respective organization user associated with for business purposes.",
                 text: "Location data is collected during active sessions for business purposes, even when the application is in the background. Location will not be collected for the user if there is no active session.");
           },
           child: Padding(
             padding: const EdgeInsets.only(right: 20,top: 10),
             child: Icon(Icons.security,color: AppConstant.blackColor,),
           ),
         )
       ],
     ),
      body: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Column(
              children: [
                Center(
                    child: AppUtils.commonTextWidget(
                        text: "ENABLE REQUIRED",
                        textColor: AppConstant.blackColor,
                        fontSize: 26,
                        textAlign: TextAlign.center,
                        letterSpacing: 1.3,
                        fontWeight: FontWeight.w500)),
                Center(
                    child: AppUtils.commonTextWidget(
                        text: "PERMISSIONS",
                        textColor: AppConstant.blackColor,
                        fontSize: 24,
                        textAlign: TextAlign.center,
                        letterSpacing: 1,
                        fontWeight: FontWeight.w500)),
              ],
            ),
            AppUtils.commonSizedBox(height: 20),
            Center(
              child: Image.asset(locationPermissionImage,
                  height: 300, width: 300),
            ),
            AppUtils.commonSizedBox(height: 20),
            Center(
                child: AppUtils.commonTextWidget(
                    text: "Please allow us to enable \n required permissions",
                    textColor: AppConstant.blackColor,
                    fontSize: 14,
                    textAlign: TextAlign.center,
                    letterSpacing: 1,
                    fontWeight: FontWeight.w500)),
            AppUtils.commonElevatedBtn(
                width: double.infinity,
                height: 50,
                text: "ALLOW",
                bgColor: AppConstant.appPrimaryColor.withOpacity(0.9),
                borderRadiusAll: 30,
                onPressed: () async{
                  UserPermission userPermission = UserPermission();
                  await userPermission.checkAndRequestPermissions();
                  bool isPermissionGranted = await userPermission.isAllPermissionsGranted();
                  if(isPermissionGranted == true){
                    if(isLogIn == true){
                      Navigator.pushReplacement(
                          context,
                          CupertinoPageRoute(
                            builder: (context) => DashBoard(),
                          ));
                    }else{
                      Navigator.pushReplacement(
                          context,
                          CupertinoPageRoute(
                            builder: (context) => LoginScreen(),
                          ));
                    }
                  }
                },),
          ],
        ),
      ),
    );
  }
}
