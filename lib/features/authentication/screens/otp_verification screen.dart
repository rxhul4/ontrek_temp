import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ontrek/core/common_widgets/app_scaffold.dart';
import 'package:ontrek/core/utils/App_utils.dart';
import 'package:ontrek/core/utils/app_constant.dart';
import 'package:ontrek/core/utils/image_path.dart';
import 'package:ontrek/features/dashboard/screens/dashboard_screen.dart';
import 'package:otp_text_field/otp_field.dart';
import 'package:otp_text_field/otp_text_field.dart';
import 'package:otp_text_field/style.dart';

class VerificationCode extends StatefulWidget {
  const VerificationCode({super.key});

  @override
  State<VerificationCode> createState() => _VerificationCodeState();
}

class _VerificationCodeState extends State<VerificationCode> {
  bool isUsernameEmpty = true;
  OtpFieldController otpController = OtpFieldController();
  int secondRemaining = 30;
  bool _enableResend = false;
  Timer? _timer;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    startTimer();
  }

  void startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (secondRemaining != 0) {
        setState(() {
          secondRemaining--;
        });
      } else {
        setState(() {
          _enableResend = true;
          _timer?.cancel();
        });
      }
    });
  }

  void _resendCode() {
    //other code here
    setState(() {
      secondRemaining = 30;
      _enableResend = false;
    });
    startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  bool isFieldEmpty(String text) {
    return text.trim().isEmpty;
  }

  @override
  Widget build(BuildContext context) {
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
                      OTPTextField(
                        style: TextStyle(
                          fontSize: 16,
                          color: AppConstant.blackColor,
                          fontFamily: "Poppins",
                          fontWeight: FontWeight.w500,
                        ),
                        fieldStyle: FieldStyle.box,
                        keyboardType: TextInputType.phone,
                        length: 4,
                        fieldWidth: 60,
                        margin: EdgeInsets.only(top: 10,bottom: 10),
                        width: double.infinity,
                        textFieldAlignment: MainAxisAlignment.spaceEvenly,
                        outlineBorderRadius: 5,
                        spaceBetween: 10,
                        contentPadding: EdgeInsets.all(20),
                        otpFieldStyle: OtpFieldStyle(
                          
                          enabledBorderColor: AppConstant.greyColor,
                          focusBorderColor: AppConstant.appPrimaryColor
                        ),
                        controller: otpController,
                      ),
                      AppUtils.commonElevatedBtn(
                        topMargin: 20,
                        width: double.infinity,
                        height: 50,
                        text: "Verify OTP",
                        bgColor: AppConstant.appPrimaryColor.withOpacity(0.9),
                        borderRadiusAll: 30,
                        onPressed: () {
                          // Add your onPressed logic here
                          Navigator.push(
                              context,
                              CupertinoPageRoute(
                                builder: (context) => DashBoard(),
                              ));
                        },
                      ),
                      !_enableResend
                          ? AppUtils.commonContainer(
                        margin:
                        const EdgeInsets.only(top: 110, bottom: 0),
                        child: Row(
                          crossAxisAlignment:
                          CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            AppUtils.commonTextWidget(text: "00:$secondRemaining",textColor: AppConstant.appPrimaryColor,),
                            AppUtils.commonSizedBox(
                              width: 3,
                            ),
                            AppUtils.commonTextWidget(text: "resend confirmation code.",textColor: AppConstant.appPrimaryColor,fontWeight: FontWeight.w400,),

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
                            _resendCode();
                          },
                          child: AppUtils.commonTextWidget(text: "Resend Code",fontWeight: FontWeight.w500,textColor: AppConstant.appPrimaryColor,letterSpacing: 0.1)
                        ),
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
}
