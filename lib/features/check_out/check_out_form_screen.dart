import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:local_auth/local_auth.dart';
import 'package:ontrek/core/common_widgets/app_scaffold.dart';
import 'package:ontrek/core/common_widgets/textfield_widget.dart';
import 'package:ontrek/core/storage/preference_helper.dart';
import 'package:ontrek/core/utils/App_utils.dart';
import 'package:ontrek/core/utils/app_constant.dart';
import 'package:ontrek/features/attendance/screen/attendance_screen.dart';
import 'package:ontrek/features/dashboard/screens/dashboard_screen.dart';
import 'package:permission_handler/permission_handler.dart';

class CheckOutFormScreen extends StatefulWidget {
  Function(Position)? onLocationFetch;

  CheckOutFormScreen({super.key, this.onLocationFetch});

  @override
  State<CheckOutFormScreen> createState() => _CheckOutFormScreenState();
}

class _CheckOutFormScreenState extends State<CheckOutFormScreen> {
  TextEditingController companyNameController = TextEditingController();
  TextEditingController clientNameController = TextEditingController();
  TextEditingController visitDiscussionNameController = TextEditingController();
  LocalAuthentication _localAuthentication = LocalAuthentication();
  bool isBiometricAvailable = false;
  bool isLoading = false;

  checkBiometricAvailable() async {
    isBiometricAvailable = await _localAuthentication.canCheckBiometrics;
    if (kDebugMode) {
      print("isBiometricAvailable $isBiometricAvailable");
    }
  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    checkBiometricAvailable();
  }

  doLocalVerification(Function afterSuccessfulVerificationFnc) async {
    if (isBiometricAvailable) {
      bool isAuthenticated = await _localAuthentication.authenticate(
          localizedReason: "Authenticate using Biometrics",
          options: const AuthenticationOptions(
              stickyAuth: true, useErrorDialogs: true));
      if (isAuthenticated) {
        if (kDebugMode) {
          print("isAuthenticated $isAuthenticated");
        }

        // openDialogFnc("Authentication Successful");
        afterSuccessfulVerificationFnc();
      } else {
        if (kDebugMode) {
          print("isAuthenticated $isAuthenticated");
        }
        openDialogFnc("Authentication Fail! Please Try Again");
      }
    } else {
      if (kDebugMode) {
        print("Biometric Auth is not available on this device");
      }
      showDialog(
        context: context,
        builder: (context) =>
            showDialogBox(
                "Biometric Auth is not available on this device", context),
      );
    }
  }

  openDialogFnc(String text) {
    showDialog(
      context: context,
      builder: (context) => showDialogBox(text, context),
    );
  }

  AlertDialog showDialogBox(String text, BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10))),
      // Remove border radius
      insetPadding: const EdgeInsets.all(0),
      titlePadding: const EdgeInsets.all(0),
      contentPadding:
      const EdgeInsets.only(top: 30, bottom: 10, left: 20, right: 20),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Text(text, textAlign: TextAlign.center,),
          AppUtils.commonTextWidget(
              text: text,
              textAlign: TextAlign.center,
              textColor: AppConstant.blackColor,
              fontWeight: FontWeight.w400),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                style: TextButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10))),
                onPressed: () {
                  Navigator.pop(context);
                },
                child: AppUtils.commonTextWidget(
                    text: "OK",
                    textColor: AppConstant.blueColor,
                    letterSpacing: 1,
                    fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: AppScaffold(
          appBar: AppBar(
            surfaceTintColor: AppConstant.transparentColor,
            backgroundColor: Colors.white,
            elevation: 0,
            leading: InkWell(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Icon(
                  Icons.arrow_back_ios_new,
                  color: AppConstant.blackColor.withOpacity(0.7),
                  size: 24,
                )),
            title: AppUtils.commonTextWidget(
                text: "Check Out Form",
                textColor: AppConstant.blackColor.withOpacity(0.7),
                fontSize: 18),
            centerTitle: true,
            bottom: PreferredSize(
              preferredSize: Size.zero,
              child: AppUtils.commonContainer(
                  decoration: AppUtils.commonBoxDecoration(
                      border: Border(
                          bottom: BorderSide(
                              color: AppConstant.blackColor.withOpacity(0.4),
                              width: 0.3)))),
            ),
          ),
          body: Stack(
            children: [
              SingleChildScrollView(
                child: Padding(
                  padding: AppUtils.edgeInsetsOnly(
                      left: 10, right: 10, top: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppUtils.commonTextWidget(
                          text: "Add Image",
                          textColor: AppConstant.blackColor,
                          fontWeight: FontWeight.w500,
                          fontSize: 16),
                      SizedBox(
                        height: 10,
                      ),
                      _image != null
                          ? Align(
                        alignment: Alignment.center,
                        child: Column(
                          children: [
                            AppUtils.commonContainer(
                                padding: EdgeInsets.all(15),
                                height: 150,
                                width: 150,
                                decoration: AppUtils.commonBoxDecoration(
                                  color: AppConstant.greyWithShade,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child:
                                // isImageLoading
                                Image.file(
                                  _image ?? File(_image?.path ?? ""),
                                  fit: BoxFit.cover,
                                  height: 0,
                                  width: 0,
                                )),
                            AppUtils.commonSizedBox(height: 15),
                            AppUtils.commonInkWell(
                              onTap: () {
                                _image = null;
                                setState(() {

                                });
                              },
                              child: AppUtils.commonTextWidget(text:"Remove",textColor: Colors.red,fontSize: 14,fontWeight: FontWeight.w600,
                              ),
                            )

                          ],
                        ),
                      )
                          : InkWell(
                        enableFeedback: true,
                        borderRadius: BorderRadius.circular(5),
                        onTap: () {
                          getImage();
                        },
                        child: Center(
                          child: AppUtils.commonContainer(
                            padding:
                            AppUtils.edgeInsetsOnly(left: 15, right: 15),
                            // alignment: Alignment.center,
                            height: 50,
                            width: double.infinity,
                            decoration: AppUtils.commonBoxDecoration(
                              color: AppConstant.greyWithShade,
                              borderRadius: BorderRadius.circular(5),
                              border: Border.all(color: AppConstant.blueColor),
                            ),
                            child: Center(
                              child: AppUtils.commonTextWidget(
                                  text: "Add Visit Picture",
                                  textColor:
                                  AppConstant.blackColor.withOpacity(0.6),
                                  fontWeight: FontWeight.w500,
                                  fontSize: 16),
                            ),
                          ),
                        ),
                      ),
                      AppUtils.commonSizedBox(height: 10),
                      commonTextField(text: "Company Name",
                          controller: companyNameController),
                      AppUtils.commonSizedBox(height: 10),
                      commonTextField(text: "Client name",
                          controller: clientNameController),
                      AppUtils.commonSizedBox(height: 10),
                      commonTextField(text: "Visit Discussion",
                          maxLine: 3,
                          controller: visitDiscussionNameController),

                      Align(
                        alignment: Alignment.bottomCenter,
                        child: AppUtils.commonElevatedBtn(
                          onPressed: () {
                            checkValidation();
                          },
                          topMargin: 20,
                          borderRadiusAll: 5,
                          text: "Submit",
                          fontSize: 16,
                          bgColor: AppConstant.blueColor,
                          height: 56,
                          width: double.infinity,

                        ),
                      )
                    ],
                  ),
                ),
              ),
              isLoading ? Center(child: CircularProgressIndicator(
                color: AppConstant.blueColor,),) : SizedBox(),
            ],
          )),
    );
  }

  commonTextField(
      {String? text, int? maxLine, required TextEditingController controller}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppUtils.commonTextWidget(
            text: text ?? "",
            textColor: AppConstant.blackColor,
            fontWeight: FontWeight.w500,
            fontSize: 16),
        SizedBox(
          height: 5,
        ),
        AppTextField(
          controller: controller,
          hintText: text ?? "",
          maxLines: maxLine ?? 1,
          cursorColor: AppConstant.blueColor.withOpacity(0.9),
          allBorderRadius: 5,
          fillColor: AppConstant.whiteColor,
          hintTextColor: AppConstant.greyColor.withOpacity(0.5),
        ),
      ],
    );
  }

  var imageFull;
  File? _image;

  Future getImage() async {
    var status1 = await Permission.camera.request();
    if (status1.isDenied || status1.isPermanentlyDenied) {
      print(status1.isPermanentlyDenied);
      print(status1.isDenied);
      // openAppSettings();
    } else {
      print(status1.isPermanentlyDenied);
      print(status1.isDenied);
      imageFull = await ImagePicker.platform
          .getImageFromSource(source: ImageSource.camera);

      final bytes = await imageFull.readAsBytes();
      print("sljkdfhushdkf${bytes}");
      final kb= bytes.length / 1024;
      final mb =  kb / 1024;
      print("sljkdfhushdkf${kb}");
      if (imageFull?.path != null) {
        setState(() {
          _image = File(imageFull?.path ?? '');
        });
      }
    }
  }

  Future getCurrentLocation() async {
    setState(() {
      isLoading = true;
    });
    var currentLocation;
    Position position = await Geolocator.getCurrentPosition();
    try {
      currentLocation = LatLng(position.latitude, position.longitude);
      print("jskdfhjsdhfkjdf${currentLocation}");
    } catch (e) {
      print("erorrrrrrr${e}");
    }
    return currentLocation;
  }

  Function? checkValidation() {
    if (_image == null) {
      AppUtils.showSnackBarWithColor(
          context: context,
          message: "Please Select Image",
          giveColor: Colors.red);
    } else if (companyNameController.text.isEmpty) {
      AppUtils.showSnackBarWithColor(
          context: context,
          message: "Enter Company Name",
          giveColor: Colors.red);
    } else if (clientNameController.text.isEmpty) {
      AppUtils.showSnackBarWithColor(
          context: context,
          message: "Enter Client Name",
          giveColor: Colors.red);
    } else if (visitDiscussionNameController.text.isEmpty) {
      AppUtils.showSnackBarWithColor(
          context: context,
          message: "Enter Visit Discussion",
          giveColor: Colors.red);
    } else {
      doLocalVerification(getLocationAndRedirect);
    }
  }

  getLocationAndRedirect() {
    return getCurrentLocation().then((value) {
      PreferenceHelper.setBool(PreferenceHelper.checkIn, false);
      Navigator.pop(context);
      setState(() {
        isLoading = false;
      });
    }
    );
  }

}
