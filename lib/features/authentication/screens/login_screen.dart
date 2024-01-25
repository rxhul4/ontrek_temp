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
                  WidgetUtils.commonContainer(
                      margin: WidgetUtils.edgeInsetsOnly(left: 20, right: 20),
                      width: double.infinity,
                      // height: MediaQuery.sizeOf(context).height / 2.5,
                      decoration: WidgetUtils.commonBoxDecoration(
                          color: AppConstant.whiteColor,
                          borderRadius: WidgetUtils.borderRadiusAll(raduis: 8)),
                      child: Column(
                        children: [
                          WidgetUtils.commonContainer(
                            decoration: WidgetUtils.commonBoxDecoration(
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
                                  WidgetUtils.edgeInsetsOnly(left: 16, right: 11),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  WidgetUtils.commonTextWidget(
                                      text: "ALREADY MEMBERS",
                                      fontWeight: FontWeight.bold,
                                      textColor: AppConstant.primaryColor),
                                  WidgetUtils.commonInkWell(
                                    onTap: () {},
                                    child: WidgetUtils.commonContainer(
                                      decoration: WidgetUtils.commonBoxDecoration(
                                          borderRadius:
                                              WidgetUtils.borderRadiusAll(
                                                  raduis: 5)),
                                      padding: WidgetUtils.edgeInsetsOnly(
                                          top: 2, bottom: 2, left: 5, right: 5),
                                      child: WidgetUtils.commonTextWidget(
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
                            padding: WidgetUtils.edgeInsetsOnly(
                                left: 16, right: 16, top: 30),
                            child: Column(
                              children: [
                                AppTextField(hintText: "Email"),
                                WidgetUtils.commonSizedBox(height: 20),
                                AppTextField(hintText: "Password"),
                                WidgetUtils.commonSizedBox(height: 20),
                                WidgetUtils.commonElevatedBtn(
                                    onPressed: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                DashboardScreen(),
                                          ));
                                    },
                                    text: "SIGN IN",
                                    bgColor: AppConstant.btnColor,
                                    height: 45,
                                    width: double.infinity),
                                WidgetUtils.commonSizedBox(height: 20),
                              ],
                            ),
                          ),
                        ],
                      )),
                  WidgetUtils.commonSizedBox(height: 30),
                  WidgetUtils.commonTextWidget(
                      text: "Don't have an account yet ?",
                      letterSpacing: 0.5,
                      fontWeight: FontWeight.w600,
                      textColor: AppConstant.whiteColor),
                  WidgetUtils.commonInkWell(
                    onTap: () {},
                    child: WidgetUtils.commonContainer(
                      decoration: WidgetUtils.commonBoxDecoration(
                          borderRadius: WidgetUtils.borderRadiusAll(raduis: 5)),
                      padding: WidgetUtils.edgeInsetsOnly(
                          top: 2, bottom: 2, left: 5, right: 5),
                      child: WidgetUtils.commonTextWidget(
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
