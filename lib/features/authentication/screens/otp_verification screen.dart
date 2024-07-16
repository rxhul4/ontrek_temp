import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ontrek/core/common_widgets/app_scaffold.dart';
import 'package:ontrek/core/utils/App_utils.dart';
import 'package:ontrek/core/utils/app_constant.dart';
import 'package:ontrek/core/utils/image_path.dart';
import 'package:ontrek/features/dashboard/screens/dashboard_screen.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';

class OTPVerificationCode extends StatefulWidget {
  final String? appUserId;
  final String? phoneNumber;
  final int? countryCode;

  OTPVerificationCode({super.key, this.appUserId, this.phoneNumber, this.countryCode});

  @override
  State<OTPVerificationCode> createState() => _OTPVerificationCodeState();
}

class _OTPVerificationCodeState extends State<OTPVerificationCode> {
  late AuthenticationProvider authenticationProvider;
  TextEditingController otpController = TextEditingController();
  int secondRemaining = 30;
  bool enableResend = false;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      authenticationProvider = Provider.of<AuthenticationProvider>(context, listen: false);
      otpController.clear();
      authenticationProvider.userid = widget.appUserId;
      startTimer();
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void startTimer() {
    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (secondRemaining != 0) {
          secondRemaining--;
        } else {
          enableResend = true;
          timer.cancel();
        }
      });
    });
  }

  void resendCode() {
    authenticationProvider.apiCallVerifyNumber(
      phoneNumber: widget.phoneNumber,
      countryCodeFromOtp: widget.countryCode,
      isFromOtpScreen: true,
      navigatorFnc: () {},
    );
    secondRemaining = 30;
    enableResend = false;
    startTimer();
    setState(() {});
  }

  String formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    String formattedMinutes = minutes.toString().padLeft(2, '0');
    String formattedSeconds = remainingSeconds.toString().padLeft(2, '0');
    return '$formattedMinutes:$formattedSeconds';
  }

  @override
  Widget build(BuildContext context) {
    authenticationProvider = Provider.of<AuthenticationProvider>(context);
    final mediaQuery = MediaQuery.of(context);
    final isLandscape = mediaQuery.orientation == Orientation.landscape;

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
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minWidth: constraints.maxWidth,
                minHeight: constraints.maxHeight,
              ),
              child: IntrinsicHeight(
                child: Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20),
                  child: Column(
                    children: [
                      Container(
                        margin: EdgeInsets.only(bottom: 30, top: isLandscape ? 20 : 50),
                        child: Image.asset(
                          mobileVerificationImage,
                          height: isLandscape ? constraints.maxHeight * 0.4 : constraints.maxWidth * 0.7,
                          width: isLandscape ? constraints.maxHeight * 0.4 : constraints.maxWidth * 0.7,
                        ),
                      ),
                      Spacer(),
                      Column(
                        children: [
                          AppUtils.commonContainer(
                            margin: EdgeInsets.only(bottom: 20),
                            child: AppUtils.commonTextWidget(
                              text: "Enter your One Time Password",
                              textColor: AppConstant.blackColor,
                              fontSize: 14,
                              textAlign: TextAlign.center,
                              letterSpacing: 0.1,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          otpView(context, otpController),
                          AppUtils.commonElevatedBtn(
                            isLoading: authenticationProvider.isFetching,
                            topMargin: 20,
                            width: double.infinity,
                            height: 50,
                            text: "Verify OTP",
                            bgColor: AppConstant.appPrimaryColor.withOpacity(0.9),
                            borderRadiusAll: 8,
                            onPressed: () {
                              authenticationProvider.checkValidationAndCallVerifyOtpApi(
                                controller: otpController,
                                navigatorFnc: () {
                                  Navigator.pushAndRemoveUntil(
                                    context,
                                    CupertinoPageRoute(
                                      builder: (context) => DashBoard(),
                                    ),
                                        (Route<dynamic> route) => false,
                                  );
                                },
                              );
                            },
                          ),
                          !enableResend
                              ? AppUtils.commonContainer(
                            margin: AppUtils.edgeInsetsOnly(bottom: 10,top: 40),
                            child: TextButton(
                              onPressed: () {

                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  AppUtils.commonTextWidget(
                                    text: "Didn't receive? Resend in",
                                    textColor: AppConstant.blackColor,
                                    fontWeight: FontWeight.w400,
                                  ),
                                  AppUtils.commonSizedBox(
                                    width: 3,
                                  ),
                                  AppUtils.commonTextWidget(
                                    text: secondRemaining < 10 ? '00:${secondRemaining.toString().padLeft(2, '0')}' : formatTime(secondRemaining),
                                    textColor: AppConstant.appPrimaryColor,
                                  ),
                                ],
                              ),
                            ),
                          )
                              : AppUtils.commonContainer(
                            margin: AppUtils.edgeInsetsOnly(bottom: 10,top: 40),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                TextButton(
                                  style: TextButton.styleFrom(
                                    padding: EdgeInsets.zero,
                                  ),
                                  onPressed: () {
                                    resendCode();
                                  },
                                  child: AppUtils.commonTextWidget(
                                    text: "Resend Code",
                                    fontWeight: FontWeight.w500,
                                    textColor: AppConstant.appPrimaryColor,
                                    letterSpacing: 0.1,
                                  ),
                                ),
                              ],
                            ),
                          ),

                        ],
                      ),
                      // Spacer(),
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
