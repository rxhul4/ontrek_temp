import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl_phone_field/country_picker_dialog.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:ontrek/core/common_widgets/app_scaffold.dart';
import 'package:ontrek/core/common_widgets/custom_upgrader_message.dart';
import 'package:ontrek/core/utils/App_utils.dart';
import 'package:ontrek/core/utils/app_constant.dart';
import 'package:ontrek/core/utils/image_path.dart';

import 'package:ontrek/features/authentication/providers/auth_provider.dart';
import 'package:ontrek/features/authentication/screens/otp_verification%20screen.dart';
import 'package:provider/provider.dart';
import 'package:upgrader/upgrader.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  AuthenticationProvider? authenticationProvider;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      authenticationProvider = Provider.of<AuthenticationProvider>(context, listen: false);
      authenticationProvider?.mobileNumberController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authenticationProvider = Provider.of<AuthenticationProvider>(context);
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
          title: AppUtils.commonTextWidget(
            text: "Mobile Number Verification",
            textColor: AppConstant.blackColor.withOpacity(0.7),
            fontSize: 14,
          ),
          centerTitle: true,
          actions: [
            GestureDetector(
              onTap: () {
                AppUtils.launchToBrowser(Uri.parse("https://ontrek.in/privacy-policy"));
              },
              child: Padding(
                padding: const EdgeInsets.only(right: 10),
                child: Icon(Icons.security, color: AppConstant.blackColor),
              ),
            )
          ],
        ),
        body: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minWidth: constraints.maxWidth,
                  minHeight: constraints.maxHeight,
                ),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20,right: 20),
                    child: Column(
                      children: [
                        Container(
                          margin: EdgeInsets.only(bottom: 30, top: 50),
                          child: Image.asset(
                            mobileVerificationImage,
                            height: constraints.maxWidth * 0.7,
                            width: constraints.maxWidth * 0.7,
                          ),
                        ),
                        Spacer(),
                        Column(
                          children: [
                            AppUtils.commonContainer(
                              margin: EdgeInsets.only(bottom: 30),
                              child: AppUtils.commonTextWidget(
                                text: "Enter your mobile number",
                                textColor: AppConstant.blackColor,
                                fontSize: 14,
                                textAlign: TextAlign.center,
                                letterSpacing: 0.1,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Theme(
                              data: ThemeData(
                                dialogBackgroundColor: Colors.white,
                                dialogTheme: DialogThemeData(
                                  backgroundColor: Colors.white,
                                  surfaceTintColor: Colors.white,
                                ),
                              ),
                              child: IntlPhoneField(
                                textAlignVertical: TextAlignVertical.center,
                                flagsButtonPadding: EdgeInsets.zero,
                                onCountryChanged: (value) {
                                  value.dialCode;
                                  authenticationProvider.mobileNumberController.clear();
                                },
                                initialCountryCode: "IN",
                                autovalidateMode: AutovalidateMode.onUserInteraction,
                                disableLengthCheck: false,
                                showCountryFlag: true,
                                showDropdownIcon: false,
                                flagsButtonMargin: const EdgeInsets.only(left: 10),
                                controller: authenticationProvider.mobileNumberController,
                                onChanged: (value) {
                                  try {
                                    value.isValidNumber.call();
                                    authenticationProvider.saveCountryCode(countryCodeFromView: value.countryCode);
                                    authenticationProvider.validation(isValidFromView: true);
                                  } catch (e) {
                                    authenticationProvider.validation(isValidFromView: false);
                                  }
                                },
                                pickerDialogStyle: PickerDialogStyle(
                                  backgroundColor: AppConstant.whiteColor,
                                  searchFieldPadding: AppUtils.edgeInsetsOnly(left: 10, right: 10),
                                  searchFieldCursorColor: AppConstant.appPrimaryColor,
                                  listTilePadding: AppUtils.edgeInsetsOnly(left: 10, right: 10),
                                  countryCodeStyle: AppUtils.appTextStyle(),
                                  countryNameStyle: AppUtils.appTextStyle(),
                                ),
                                dropdownTextStyle: AppUtils.appTextStyle(),
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppConstant.blackColor,
                                  fontFamily: "Poppins",
                                  fontWeight: FontWeight.w500,
                                ),
                                decoration: InputDecoration(
                                  contentPadding: EdgeInsets.symmetric(vertical: 20),
                                  hintText: "Phone Number",
                                  hintStyle: TextStyle(
                                    fontSize: 14,
                                    color: AppConstant.greyColor,
                                    fontFamily: "Poppins",
                                    fontWeight: FontWeight.w500,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: AppConstant.greyColor.withOpacity(0.5),
                                    ),
                                    borderRadius: BorderRadius.all(Radius.circular(8)),
                                  ),
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: AppConstant.greyColor.withOpacity(0.5),
                                    ),
                                    borderRadius: BorderRadius.all(Radius.circular(8)),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: AppConstant.appPrimaryColor.withOpacity(0.5),
                                    ),
                                    borderRadius: BorderRadius.all(Radius.circular(8)),
                                  ),
                                ),
                              ),
                            ),

                            AppUtils.commonElevatedBtn(
                              isLoading: authenticationProvider.isLoading,
                              topMargin: 20,
                              width: double.infinity,
                              height: 50,
                              text: "Send OTP",
                              bgColor: AppConstant.appPrimaryColor.withOpacity(0.9),
                              borderRadiusAll: 8,
                              onPressed: () {
                                authenticationProvider.checkValidationAndCallLoginApi(
                                  navigatorFnc: () {
                                    Navigator.push(
                                      context,
                                      CupertinoPageRoute(
                                        builder: (context) => OTPVerificationCode(
                                          appUserId: authenticationProvider.userid,
                                          countryCode: authenticationProvider.countryCode,
                                          phoneNumber: authenticationProvider.mobileNumberController.text,
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          ],
                        ),
                        Spacer(),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
