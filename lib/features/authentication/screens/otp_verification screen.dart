import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ontrek/core/common_widgets/app_scaffold.dart';
import 'package:ontrek/core/storage/preference_helper.dart';
import 'package:ontrek/core/utils/App_utils.dart';
import 'package:ontrek/core/utils/app_constant.dart';
import 'package:ontrek/core/utils/image_path.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';

class OTPVerificationCode extends StatefulWidget {
  String? appUserId;

  OTPVerificationCode({super.key, this.appUserId});

  @override
  State<OTPVerificationCode> createState() => _OTPVerificationCodeState();
}

class _OTPVerificationCodeState extends State<OTPVerificationCode> {
  late AuthenticationProvider authenticationProvider;


  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      authenticationProvider = Provider.of<AuthenticationProvider>(context,listen: false);
      authenticationProvider.otpController.clear();
      authenticationProvider.userUid = widget.appUserId;
      authenticationProvider.startTimer();
    });

  }
  @override
  void dispose() {
    if (mounted) {
      authenticationProvider.otpController.dispose();
    }

    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
     authenticationProvider = Provider.of<AuthenticationProvider>(context);
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: AppScaffold(
        backgroundColor: AppConstant.whiteColor,
        appBar: AppBar(
          surfaceTintColor: AppConstant.transparentColor,
          backgroundColor: Colors.white,
          elevation: 0,
          leading: AppUtils.commonInkWell(
            borderRadius: BorderRadius.circular(30),
            onTap: () {
              Navigator.pop(context);
            },
            child: Container(
              padding: EdgeInsets.all(10),
              child: Icon(
                Icons.arrow_back_ios_new,
                color: AppConstant.blackColor.withOpacity(0.7),
                size: 20,
              ),
            ),
          ),
          title: AppUtils.commonTextWidget(
            text: "OTP Verification",
            textColor: AppConstant.blackColor.withOpacity(0.7),
            fontSize: 16,
          ),
          centerTitle: true,
        ),
        body: LayoutBuilder(builder: (context, constraints) {
          return SingleChildScrollView(
            child: Container(
              margin: const EdgeInsets.only(
                left: 20,
                right: 20,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                    minWidth: constraints.maxWidth,
                    minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        margin: EdgeInsets.only(bottom: 70, top: 50),
                        child: Image.asset(
                          mobileVerificationImage,
                          // Update with correct image path
                          height: 300,
                          width: 300,
                        ),
                      ),
                      AppUtils.commonContainer(
                        margin: EdgeInsets.only(bottom: 30),
                        child: AppUtils.commonTextWidget(
                          text: "Enter your One Time Password",
                          textColor: AppConstant.blackColor,
                          fontSize: 14,
                          textAlign: TextAlign.center,
                          letterSpacing: 0.1,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      otpView(context, authenticationProvider.otpController),
                      AppUtils.commonElevatedBtn(
                        isLoading: authenticationProvider.isLoading,
                        topMargin: 20,
                        width: double.infinity,
                        height: 50,
                        text: "Verify OTP",
                        bgColor: AppConstant.appPrimaryColor.withOpacity(0.9),
                        borderRadiusAll: 8,
                        onPressed: () {
                          // PreferenceHelper.setBool(PreferenceHelper.IS_LOGIN, true);
                          // authenticationProvider.navigatePushReplacementFnc(const DashBoard());
                          authenticationProvider.checkValidationAndCallVerifyOtpApi();

                        },
                      ),
                      !authenticationProvider.enableResend
                          ? AppUtils.commonContainer(
                              margin: const EdgeInsets.only(
                                top: 110,
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  AppUtils.commonTextWidget(
                                    text: "Did't receive? Resend in",
                                    textColor: AppConstant.blackColor,
                                    fontWeight: FontWeight.w400,
                                  ),
                                  AppUtils.commonSizedBox(
                                    width: 3,
                                  ),
                                  AppUtils.commonTextWidget(
                                    text: "00:${authenticationProvider.secondRemaining}",
                                    textColor: AppConstant.appPrimaryColor,
                                  ),
                                ],
                              ),
                            )
                          : AppUtils.commonContainer(
                              margin: const EdgeInsets.only(
                                top: 110,
                              ),
                              child: TextButton(
                                  style: TextButton.styleFrom(
                                      padding: EdgeInsets.zero),
                                  onPressed: () {
                                    authenticationProvider.resendCode();
                                  },
                                  child: AppUtils.commonTextWidget(
                                      text: "Resend Code",
                                      fontWeight: FontWeight.w500,
                                      textColor: AppConstant.appPrimaryColor,
                                      letterSpacing: 0.1)),
                            ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget otpView(BuildContext cntx, TextEditingController otpController) {
    return AppUtils.commonContainer(
      margin: AppUtils.edgeInsetsOnly(right: 15, left: 15),
      child: PinCodeTextField(
        controller: otpController,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        cursorColor: AppConstant.appPrimaryColor,
        cursorHeight: 26,
        cursorWidth: 2,
        length: 4,
        onChanged: (value) {
          print(value);
        },
        onCompleted: (value) {
          print("Completed: $value");
        },
        animationType: AnimationType.scale,
        enablePinAutofill: true,
        textStyle: TextStyle(
          fontSize: 16,
          color: AppConstant.blackColor,
          fontFamily: "Poppins",
          fontWeight: FontWeight.w500,
        ),
        pinTheme: PinTheme(
          borderWidth: 1,
          shape: PinCodeFieldShape.underline,
          fieldWidth: 60,
          activeFillColor: Colors.white,
          inactiveFillColor: Colors.white,
          selectedFillColor: Colors.white,
          activeColor: AppConstant.appPrimaryColor,
          inactiveColor: Colors.grey.withOpacity(0.8),
          selectedColor: AppConstant.appPrimaryColor,
        ),
        keyboardType: TextInputType.number,
        appContext: cntx,
      ),
    );
  }
}
