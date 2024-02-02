import 'package:flutter/material.dart';
import 'package:ontrek/core/common_widgets/textfield_widget.dart';
import 'package:ontrek/core/utils/app_constant.dart';
import 'package:ontrek/core/utils/widget_utils.dart';
import 'package:ontrek/features/dashboard/screens/dashboard_screen.dart';
import 'package:upgrader/upgrader.dart';

class LogInScreen extends StatefulWidget {
  const LogInScreen({Key? key}) : super(key: key);

  @override
  State<LogInScreen> createState() => _LogInScreenState();
}

class _LogInScreenState extends State<LogInScreen> {
  Color emailFillColor = AppConstant.textFieldBgColor;
  Color passFillColor = AppConstant.textFieldBgColor;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Scaffold(
            backgroundColor: AppConstant.primaryColor,
            body: UpgradeAlert(
              upgrader: Upgrader(debugLogging: true),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AppUtils.commonContainer(
                      margin: AppUtils.edgeInsetsOnly(left: 20, right: 20),
                      width: double.infinity,
                      // height: MediaQuery.sizeOf(context).height / 2.5,
                      decoration: AppUtils.commonBoxDecoration(
                          color: AppConstant.whiteColor,
                          borderRadius: AppUtils.borderRadiusAll(raduis: 8)),
                      child: Column(
                        children: [
                          AppUtils.commonContainer(
                            decoration: AppUtils.commonBoxDecoration(
                                borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(8),
                                    topRight: Radius.circular(8)),
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                      color: AppConstant.primaryColor,
                                      blurRadius: 8.0,
                                      offset: Offset(0.0, 0.75))
                                ]),
                            height: 60,
                            child: Padding(
                              padding:
                                  AppUtils.edgeInsetsOnly(left: 16, right: 11),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  AppUtils.commonTextWidget(
                                      text: "ALREADY MEMBERS",
                                      fontWeight: FontWeight.bold,
                                      textColor: AppConstant.primaryColor),
                                  AppUtils.commonInkWell(
                                    onTap: () {},
                                    child: AppUtils.commonContainer(
                                      decoration: AppUtils.commonBoxDecoration(
                                          borderRadius:
                                              AppUtils.borderRadiusAll(
                                                  raduis: 5)),
                                      padding: AppUtils.edgeInsetsOnly(
                                          top: 2, bottom: 2, left: 5, right: 5),
                                      child: AppUtils.commonTextWidget(
                                          text: "Need help?",
                                          letterSpacing: 0.5,
                                          textColor: AppConstant.greyColor),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Padding(
                            padding: AppUtils.edgeInsetsOnly(
                                left: 16, right: 16, top: 30),
                            child: Column(
                              children: [
                                AppTextField(hintText: "Email"),
                                AppUtils.commonSizedBox(height: 20),
                                AppTextField(hintText: "Password"),
                                AppUtils.commonSizedBox(height: 20),
                                AppUtils.commonElevatedBtn(
                                    onPressed: () {
                                      // Navigator.push(
                                      //     context,
                                      //     MaterialPageRoute(
                                      //       builder: (context) =>
                                      //           DashboardScreen(),
                                      //     ));
                                    },
                                    text: "SIGN IN",
                                    bgColor: AppConstant.btnColor,
                                    height: 45,
                                    width: double.infinity),
                                AppUtils.commonSizedBox(height: 20),
                              ],
                            ),
                          ),
                        ],
                      )),
                  AppUtils.commonSizedBox(height: 30),
                  AppUtils.commonTextWidget(
                      text: "Don't have an account yet ?",
                      letterSpacing: 0.5,
                      fontWeight: FontWeight.w600,
                      textColor: AppConstant.whiteColor),
                  AppUtils.commonInkWell(
                    onTap: () {},
                    child: AppUtils.commonContainer(
                      decoration: AppUtils.commonBoxDecoration(
                          borderRadius: AppUtils.borderRadiusAll(raduis: 5)),
                      padding: AppUtils.edgeInsetsOnly(
                          top: 2, bottom: 2, left: 5, right: 5),
                      child: AppUtils.commonTextWidget(
                          text: "Create an account",
                          letterSpacing: 0.5,
                          fontWeight: FontWeight.w600,
                          textColor: AppConstant.btnColor),
                    ),
                  ),
                ],
              ),
            )),
      ),
    );
  }
}
