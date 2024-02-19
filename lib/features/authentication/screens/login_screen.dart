import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_geocoding_api/google_geocoding_api.dart';
import 'package:ontrek/core/common_widgets/textfield_widget.dart';
import 'package:ontrek/core/storage/preference_helper.dart';

import 'package:ontrek/core/utils/app_constant.dart';
import 'package:ontrek/core/utils/App_utils.dart';
import 'package:ontrek/core/utils/image_path.dart';
import 'package:ontrek/features/authentication/models/login_model.dart';
import 'package:ontrek/features/authentication/providers/auth_provider.dart';
import 'package:ontrek/features/dashboard/screens/dashboard_screen.dart';
import 'package:provider/provider.dart';
import 'package:upgrader/upgrader.dart';

class LogInScreen extends StatefulWidget {
  const LogInScreen({Key? key}) : super(key: key);

  @override
  State<LogInScreen> createState() => _LogInScreenState();
}

class _LogInScreenState extends State<LogInScreen> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool isLoading = false;
  LoginModel? loginModel;
  AndroidDeviceInfo? myDeviceInfo;
  Position? locationOfLogin;

  callLogInApi(AuthenticationProvider postMdl,value) async{
    postMdl
        .apiCallLogin(
      email: emailController.text.trim(),
      password: passwordController.text,
      latitude: locationOfLogin?.latitude,
      longitude: locationOfLogin?.longitude,
    )
        .then((value) {
      loginModel = value;
      if (loginModel?.code == 200) {
        if (loginModel?.data?.roleId == 1) {
          // AppUtils.showCustomDialog(ctx: context, dialogMessage: "Unauthorized User");
          openDialogFnc("Unauthorized User", context);
        } else {
          saveDataToPrefAndRedirect(loginModel);
        }
      } else {
        openDialogFnc(loginModel?.message ?? "", context);
      }
    });
  }

  saveDataToPrefAndRedirect(LoginModel? loginModel) {
    saveDataToPref().then((value) {
      if (loginModel?.data?.roleId == 1 || loginModel?.data?.roleId == 2) {
        openDialogFnc("Unauthorized User", context);
      } else {
        Navigator.pushReplacement(
            context,
            CupertinoPageRoute(
              builder: (context) => DashBoard(),
            ));
      }
    });
  }

  Future<bool> saveDataToPref() async {
    PreferenceHelper.setBool(PreferenceHelper.IS_LOGIN, true);
    PreferenceHelper.setString(
        PreferenceHelper.FULL_NAME, loginModel?.data?.fullName ?? '');
    PreferenceHelper.setString(
        PreferenceHelper.PROFILE_PIC, loginModel?.data?.profilePic ?? '');
    PreferenceHelper.setString(
        PreferenceHelper.EMAIL, loginModel?.data?.userEmail ?? '');
    PreferenceHelper.setString(
        PreferenceHelper.PHONE_NO, loginModel?.data?.phoneNo ?? '');
    PreferenceHelper.setString(
        PreferenceHelper.ROLE_NAME, loginModel?.data?.roleName ?? '');
    PreferenceHelper.setString(
        PreferenceHelper.AUTH_TOKEN, loginModel?.data?.token ?? '');
    PreferenceHelper.setString(
        PreferenceHelper.USER_UID, loginModel?.data?.userUid ?? "");
    PreferenceHelper.setInt(
        PreferenceHelper.ROLE_ID, loginModel?.data?.roleId ?? 0);
    // PreferenceHelper.setObject(
    //     PreferenceHelper.USER_DATA, loginModel?.data);

    print("data : ${PreferenceHelper.getBool(PreferenceHelper.IS_LOGIN)}");
    return true;
  }
  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    deviceInfo.androidInfo.then((value) {
      myDeviceInfo = value;
    });

  }
  Future getLocation()async{
     locationOfLogin = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.low);

    return locationOfLogin;
  }





  @override
  Widget build(BuildContext context) {
    final postMdl = Provider.of<AuthenticationProvider>(context);
    return SafeArea(
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Scaffold(
            backgroundColor: AppConstant.appPrimaryColor,
            body: UpgradeAlert(
              upgrader: Upgrader(debugLogging: true),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AppUtils.commonContainer(
                      margin: AppUtils.edgeInsetsOnly(top: 120, bottom: 80),
                      alignment: Alignment.topCenter,
                      child: Image.asset(
                        logoImagePath,
                        color: AppConstant.whiteColor,
                        width: 130,
                        height: 130,
                      ),
                    ),
                    // Padding(padding: AppUtils.edgeInsetsOnly(left: 10),child: AppUtils.commonTextWidget(text: "Login",textColor: AppConstant.whiteColor,fontWeight: FontWeight.w500,fontSize: 24)),
                    AppUtils.commonContainer(
                        alignment: Alignment.center,
                        margin: EdgeInsets.only(left: 10, right: 10),
                        padding: EdgeInsets.only(left: 10, right: 10),
                        decoration: AppUtils.commonBoxDecoration(
                          boxShadow: [
                            BoxShadow(
                                color: AppConstant.greyColor,
                                spreadRadius: 3,
                                blurRadius: 10,
                                offset: Offset(0, 0))
                          ],
                          color: AppConstant.whiteColor,
                          borderRadius: AppUtils.borderRadiusAll(raduis: 10),
                        ),
                        child: Column(
                          children: [
                            AppUtils.commonSizedBox(height: 20),
                            AppUtils.commonTextWidget(
                                text: "LogIn",
                                fontSize: 22,
                                fontWeight: FontWeight.w500,
                                textColor: AppConstant.appPrimaryColor),
                            AppUtils.commonSizedBox(height: 30),
                            AppTextField(
                              controller: emailController,
                              maxLines: 1,
                              hintText: "Email",
                              cursorColor: AppConstant.appPrimaryColor,
                              enabledBorderColor: AppConstant.greyColor,
                              hintTextColor: AppConstant.appPrimaryColor,
                              focusedBorderColor: AppConstant.appPrimaryColor,
                            ),
                            AppUtils.commonSizedBox(height: 15),
                            AppTextField(
                              controller: passwordController,
                              maxLines: 1,
                              hintText: "Password",
                              cursorColor: AppConstant.appPrimaryColor,
                              enabledBorderColor: AppConstant.greyColor,
                              hintTextColor: AppConstant.appPrimaryColor,
                              focusedBorderColor: AppConstant.appPrimaryColor,
                            ),
                            AppUtils.commonSizedBox(height: 15),
                            Align(
                              alignment: Alignment.centerRight,
                              child: AppUtils.commonInkWell(
                                  onTap: () {},
                                  child: AppUtils.commonTextWidget(
                                      text: "Forgot Password?",
                                      textColor: AppConstant.appPrimaryColor)),
                            ),
                            AppUtils.commonInkWell(
                              onTap: () {
                                  checkValidation(postMdl);
                              },
                              child: AppUtils.commonContainer(
                                  height: 56,
                                  margin: AppUtils.edgeInsetsOnly(
                                      top: 15, bottom: 15),
                                  decoration: AppUtils.commonBoxDecoration(
                                      color: AppConstant.appPrimaryColor,
                                      borderRadius: AppUtils.borderRadiusAll(
                                        raduis: 10,
                                      )),
                                  child: postMdl.isLoading
                                      ? AppUtils.loaderWidget(
                                          color: AppConstant.whiteColor)
                                      : Center(
                                          child: AppUtils.commonTextWidget(
                                              text: "Login",
                                              textColor: AppConstant.whiteColor,
                                              fontWeight: FontWeight.w500,
                                              fontSize: 16))),
                            ),
                          ],
                        ))
                  ],
                ),
              ),
            )),
      ),
    );
  }

  openDialogFnc(String text, BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AppUtils.dialogWidget(text, context),
    );
  }

  checkValidation(AuthenticationProvider postMdl) {
    if (emailController.text.isEmpty) {
      AppUtils.showSnackBarWithColor(
          context: context, message: "Enter Email", giveColor: Colors.red);
    } else if (!AppUtils.validateEmail(emailController.text.trim())) {
      AppUtils.showSnackBarWithColor(
          context: context,
          message: "Enter Valid Email Address",
          giveColor: Colors.red);
    } else if (passwordController.text.isEmpty) {
      AppUtils.showSnackBarWithColor(
          context: context, message: "Enter Password", giveColor: Colors.red);
    } else if (passwordController.text.length < 8) {
      AppUtils.showSnackBarWithColor(
          context: context,
          message: "Enter at least 8 Password",
          giveColor: Colors.red);
    } else {
      // callLogInApi(postMdl);
      getLocation().then((value) {
        print(value.latitude);

        callLogInApi(postMdl,value);
      });
    }
  }
}
