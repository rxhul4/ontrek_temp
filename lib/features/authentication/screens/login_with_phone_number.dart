import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl_phone_field/country_picker_dialog.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:ontrek/core/common_widgets/app_scaffold.dart';
import 'package:ontrek/core/utils/App_utils.dart';
import 'package:ontrek/core/utils/app_constant.dart';
import 'package:ontrek/core/utils/image_path.dart';

import 'package:ontrek/features/authentication/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {





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
                              dialogTheme: DialogTheme(
                                  backgroundColor: Colors.white,
                                  surfaceTintColor: Colors.white)),
                          child: IntlPhoneField(
                            onCountryChanged: (value) {
                              value.dialCode;
                              authenticationProvider.mobileNumberController.clear();
                            },
                            initialCountryCode: "IN",
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            disableLengthCheck: false,
                            showCountryFlag: true,
                            showDropdownIcon: false,
                            flagsButtonMargin: const EdgeInsets.only(
                              left: 10,
                            ),
                            controller: authenticationProvider.mobileNumberController,
                            onChanged: (value) {
                              try {
                                value.isValidNumber.call();
                                authenticationProvider.saveCountryCode(countryCodeFromView: value.countryCode);

                                authenticationProvider.validation(isValidFromView: true);
                                print("yes");
                              } catch (e) {
                                authenticationProvider.validation(isValidFromView: false);
                                print("no");
                              }
                            },
                            pickerDialogStyle: PickerDialogStyle(
                              searchFieldPadding:
                                  AppUtils.edgeInsetsOnly(left: 10, right: 10),
                              searchFieldCursorColor:
                                  AppConstant.appPrimaryColor,
                              listTilePadding:
                                  AppUtils.edgeInsetsOnly(left: 10, right: 10),
                              countryCodeStyle: AppUtils.appTextStyle(),
                              countryNameStyle: AppUtils.appTextStyle(),
                              // backgroundColor: Colors.white,
                            ),
                            dropdownTextStyle: AppUtils.appTextStyle(),
                            style: TextStyle(
                              fontSize: 14,
                              color: AppConstant.blackColor,
                              fontFamily: "Poppins",
                              fontWeight: FontWeight.w500,
                            ),
                            decoration: InputDecoration(
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
                                borderRadius:
                                    BorderRadius.all(Radius.circular(8)),
                              ),
                              border: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: AppConstant.greyColor.withOpacity(0.5),
                                ),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(8)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: AppConstant.appPrimaryColor
                                      .withOpacity(0.5),
                                ),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(8)),
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
                            print(
                                "onPressed-----${authenticationProvider.mobileNumberController.text}");
                            print("onPressed-----${authenticationProvider.countryCode}");
                            authenticationProvider.checkValidationAndCallLoginApi();
                          },
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                                margin: EdgeInsets.only(bottom: 10, top: 110),
                                child: AppUtils.commonTextWidget(
                                    text: "Need help? ",
                                    fontWeight: FontWeight.w400,
                                    textColor: AppConstant.appPrimaryColor,
                                    fontSize: 14)),
                            Container(
                                margin: EdgeInsets.only(bottom: 10, top: 110),
                                child: AppUtils.commonTextWidget(
                                    text: "Contact Admin",
                                    fontWeight: FontWeight.w600,
                                    textColor: AppConstant.appPrimaryColor,
                                    fontSize: 14)),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ),
            );
          })),
    );
  }
}
