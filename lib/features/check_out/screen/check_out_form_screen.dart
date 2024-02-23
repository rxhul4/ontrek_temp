import 'dart:io';

import 'package:battery_plus/battery_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:local_auth/local_auth.dart';
import 'package:ontrek/core/common_widgets/app_scaffold.dart';
import 'package:ontrek/core/common_widgets/textfield_widget.dart';
import 'package:ontrek/core/storage/preference_helper.dart';
import 'package:ontrek/core/utils/App_utils.dart';
import 'package:ontrek/core/utils/app_constant.dart';
import 'package:ontrek/features/attendance/model/add_activity_model.dart';
import 'package:ontrek/features/attendance/provider/attendance_provider.dart';
import 'package:ontrek/features/check_out/model/check_out_form_model.dart';
import 'package:ontrek/features/check_out/provider/check_out_form_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

class CheckOutFormScreen extends StatefulWidget {
  Function(Position)? onLocationFetch;

  CheckOutFormScreen({super.key, this.onLocationFetch});

  @override
  State<CheckOutFormScreen> createState() => _CheckOutFormScreenState();
}

class _CheckOutFormScreenState extends State<CheckOutFormScreen> {
  TextEditingController companyNameController = TextEditingController();
  TextEditingController customerNameController = TextEditingController();
  TextEditingController customerPhoneNumberController = TextEditingController();
  TextEditingController visitDiscussionNameController = TextEditingController();
  LocalAuthentication _localAuthentication = LocalAuthentication();
  bool isBiometricAvailable = false;
  bool isLoading = false;
  String? userUid;
  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  AndroidDeviceInfo? androidInfo;
  var battery = Battery();
  int? batteryLevel;
  bool showNoDataFound = true;
  AddActivityModel? addActivityModel;
  CheckOutFormModel? checkOutFormModel;
  int selectedRadio = 1;
  String? totType;

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
    userUid = PreferenceHelper.getString(PreferenceHelper.USER_UID);
    deviceInfo.androidInfo.then((value) {
      androidInfo = value;
    });
    battery.batteryLevel.then((value) {
      batteryLevel = value;
      print("battery_level${batteryLevel}");
    });

    checkBiometricAvailable();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final getMdl = Provider.of<CheckOutProvider>(context, listen: false);
      callGetTotByType(getMdl);
    });
    totType = AppUtils.switchCaseForTotType(selectedRadio);
  }

  callGetTotByType(CheckOutProvider getMdl) {
    getMdl.apiCallGetTotByType().then((value) {
      checkOutFormModel = value;
      if (checkOutFormModel?.code != 200) {
        openDialogFnc(checkOutFormModel?.message ?? "");
        setState(() {
          showNoDataFound = true;
        });
      } else {
        setState(() {
          showNoDataFound = false;
        });
        selectedRadio =
            checkOutFormModel?.data?.map((e) => e.totSeq).first ?? 1;
      }
    });
  }

  callAddActivityApi({
    required AttendanceProvider postMdl,
    dynamic position,
  }) {
    print("userUid${userUid}");
    var dateOfDayStart =
        AppUtils.dateFormat(date: DateTime.now(), dateFormat: "yyyy-MM-dd");
    var timeOfDayStart = AppUtils.dateFormat(
        date: DateTime.now(), dateFormat: AppConstant.dateFormat);
    postMdl
        .apiCallAddActivity(
      imageFile: _image,
            eventTime: timeOfDayStart,
            eventDate: dateOfDayStart,
            userUid: userUid,
            deviceId: androidInfo?.id,
            deviceName: androidInfo?.brand,
            batteryLevel: batteryLevel,
            totTrackingEventCode: AppConstant.checkOutEvent,
            trackingAddress: "dwarkesh Business Hub",
            locAccuracy: 1,
            latitude: position.latitude,
            longitude: position.longitude,
            companyName: companyNameController.text,
            customerName: customerNameController.text,
            customerPhoneNumber: customerPhoneNumberController.text,
            visitDiscussion: visitDiscussionNameController.text,
            visitTypeCode: totType
    )
        .then((value) {
      addActivityModel = value;
      if (addActivityModel?.code == 200) {
        PreferenceHelper.setBool(PreferenceHelper.checkIn, false);
        Navigator.pop(context);
      } else {
        print("day start not 200");
        openDialogFnc(addActivityModel?.message.toString() ?? "");
      }
    });
  }

  doLocalVerification(
      {required Function() afterSuccessfulVerificationFnc}) async {
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
      openDialogFnc("Biometric Auth is not available on this device");
    }
  }

  openDialogFnc(String text) {
    showDialog(
      context: context,
      builder: (context) => AppUtils.dialogWidget(text, context),
    );
  }

  @override
  Widget build(BuildContext context) {
    final postMdl = Provider.of<AttendanceProvider>(context);
    final getMdl = Provider.of<CheckOutProvider>(context);
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
          body: getMdl.isFetching
              ? AppUtils.loaderWidget()
              : showNoDataFound
                  ? AppUtils.commonNoDataFound(onPressed: () {
                      callGetTotByType(getMdl);
                    })
                  : Stack(
                      children: [
                        Column(
                          children: [
                            Expanded(
                              child: SingleChildScrollView(
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      left: 10, right: 10, top: 10, bottom: 10),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                                      padding:
                                                          EdgeInsets.all(15),
                                                      height: 150,
                                                      width: 150,
                                                      decoration: AppUtils
                                                          .commonBoxDecoration(
                                                        color: AppConstant
                                                            .greyWithShade,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10),
                                                      ),
                                                      child:
                                                          // isImageLoading
                                                          Image.file(
                                                        _image ??
                                                            File(_image?.path ??
                                                                ""),
                                                        fit: BoxFit.cover,
                                                        height: 0,
                                                        width: 0,
                                                      )),
                                                  AppUtils.commonSizedBox(
                                                      height: 15),
                                                  AppUtils.commonInkWell(
                                                    onTap: () {
                                                      _image = null;
                                                      setState(() {});
                                                    },
                                                    child: AppUtils
                                                        .commonTextWidget(
                                                      text: "Remove",
                                                      textColor: Colors.red,
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  )
                                                ],
                                              ),
                                            )
                                          : InkWell(
                                              enableFeedback: true,
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                              onTap: () {
                                                getImage();
                                              },
                                              child: Center(
                                                child: AppUtils.commonContainer(
                                                  padding:
                                                      AppUtils.edgeInsetsOnly(
                                                          left: 15, right: 15),
                                                  // alignment: Alignment.center,
                                                  height: 50,
                                                  width: double.infinity,
                                                  decoration: AppUtils
                                                      .commonBoxDecoration(
                                                    color: AppConstant
                                                        .greyWithShade,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5),
                                                    border: Border.all(
                                                        color: AppConstant
                                                            .appPrimaryColor),
                                                  ),
                                                  child: Center(
                                                    child: AppUtils.commonTextWidget(
                                                        text:
                                                            "Add Visit Picture",
                                                        textColor: AppConstant
                                                            .blackColor
                                                            .withOpacity(0.6),
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        fontSize: 16),
                                                  ),
                                                ),
                                              ),
                                            ),
                                      AppUtils.commonSizedBox(height: 10),
                                      commonTextField(
                                          text: "Company Name",
                                          controller: companyNameController),
                                      AppUtils.commonSizedBox(height: 10),
                                      commonTextField(
                                          text: "Customer Name",
                                          controller: customerNameController),
                                      AppUtils.commonSizedBox(height: 10),
                                      commonTextField(
                                          text: "Customer Phone Number",
                                          controller:
                                              customerPhoneNumberController),
                                      AppUtils.commonSizedBox(height: 10),
                                      AppUtils.commonContainer(
                                          child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          AppUtils.commonTextWidget(
                                              text: "Visit Type",
                                              textColor: AppConstant.blackColor,
                                              fontWeight: FontWeight.w500,
                                              fontSize: 16),
                                          SizedBox(
                                            height: 5,
                                          ),
                                          GridView.builder(
                                            physics:
                                                NeverScrollableScrollPhysics(),
                                            shrinkWrap: true,
                                            padding: EdgeInsets.zero,
                                            itemCount: checkOutFormModel
                                                    ?.data?.length ??
                                                0,
                                            gridDelegate:
                                                SliverGridDelegateWithFixedCrossAxisCount(
                                              crossAxisSpacing: 30,
                                              mainAxisExtent: 60,
                                              crossAxisCount: 2,
                                            ),
                                            itemBuilder: (context, index) {
                                              print(
                                                  "data${checkOutFormModel?.data?[index].totSeq}");

                                              return GestureDetector(
                                                onTap: () {
                                                  setState(() {
                                                    selectedRadio =
                                                        checkOutFormModel
                                                                ?.data?[index]
                                                                .totSeq ??
                                                            1;
                                                    // switch (selectedRadio) {
                                                    //   case 1:
                                                    //     totType =
                                                    //         "visit_type_1";
                                                    //     break;
                                                    //   case 2:
                                                    //     totType = "visit_type_2";
                                                    //     break;
                                                    //   case 3:
                                                    //     totType =
                                                    //         "visit_type_3";
                                                    //     break;
                                                    //   case 4:
                                                    //     totType = "visit_type_4";
                                                    //     break;
                                                    //   default:
                                                    //     totType =
                                                    //         "visit_type_5";
                                                    //     break;
                                                    // }
                                                    totType =  AppUtils.switchCaseForTotType(selectedRadio);
                                                    print("totType${totType}");
                                                  });
                                                },
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: [
                                                    Radio(
                                                      activeColor: AppConstant
                                                          .appPrimaryColor,
                                                      // Customize your active color
                                                      value: checkOutFormModel
                                                          ?.data?[index].totSeq,
                                                      groupValue: selectedRadio,
                                                      onChanged: (value) {
                                                        setState(() {
                                                          selectedRadio =
                                                              value ?? 1;
                                                        });
                                                      },
                                                    ),
                                                    Expanded(
                                                      child: AppUtils
                                                          .commonTextWidget(
                                                        fontSize: 14,
                                                        textColor: AppConstant
                                                            .appPrimaryColor,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        text:
                                                            "${checkOutFormModel?.data?[index].totValue}",
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                          ),
                                        ],
                                      )),
                                      AppUtils.commonSizedBox(height: 10),
                                      commonTextField(
                                          text: "Visit Discussion",
                                          maxLine: 3,
                                          controller:
                                              visitDiscussionNameController),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Align(
                              alignment: Alignment.bottomCenter,
                              child: AppUtils.commonElevatedBtn(
                                backgroundColor: AppConstant.transparentColor,
                                onPressed: () {
                                  checkValidation(postMdl);
                                },
                                topMargin: 10,
                                bottomMargin: 10,
                                leftMargin: 10,
                                rightMargin: 10,
                                borderRadiusAll: 10,
                                text: "Submit",
                                fontSize: 16,
                                bgColor: AppConstant.appPrimaryColor,
                                height: 56,
                                width: double.infinity,
                              ),
                            ),
                          ],
                        ),
                        isLoading
                            ? Center(
                                child: AppUtils.loaderWidget(),
                              )
                            : SizedBox(),
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
          cursorColor: AppConstant.appPrimaryColor.withOpacity(0.9),
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
      imageFull = await ImagePicker.platform.getImageFromSource(
        source: ImageSource.camera,
      );


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

  Function? checkValidation(postMdl) {
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
    } else if (customerNameController.text.isEmpty) {
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
      doLocalVerification(afterSuccessfulVerificationFnc: () {
        getLocationAndRedirect(postMdl);
      });
    }
  }

  getLocationAndRedirect(postMdl) {
    return getCurrentLocation().then((value) {
      callAddActivityApi(postMdl: postMdl, position: value);
    });
  }
}
