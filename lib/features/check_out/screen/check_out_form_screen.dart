import 'dart:convert';
import 'dart:io';

import 'package:battery_plus/battery_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
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
import 'package:ontrek/features/check_out/model/get_visit_note_model.dart';
import 'package:ontrek/features/check_out/provider/check_out_form_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

class CheckOutFormScreen extends StatefulWidget {
  Function(Position)? onLocationFetch;

  CheckOutFormScreen({
    super.key,
    this.onLocationFetch,
  });

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
  int? battery;

  // var battery = Battery();
  int? batteryLevel;
  String? image64;
  bool showNoDataFound = false;
  CreateActivityModel? createActivityModel;
  GetTotByGroupTypeModel? getTotByGroupTypeModel;
  FlutterBackgroundService service = FlutterBackgroundService();
  late CheckOutProvider checkOutProvider;
  late AttendanceProvider attendanceProvider;
  String? selectedTotValue;
  String? selectedTotId;
  bool? isAllowFgAuth;

  checkBiometricAvailable() async {
    isBiometricAvailable = await _localAuthentication.canCheckBiometrics;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    userUid = PreferenceHelper.getString(PreferenceHelper.USER_ID);
    isAllowFgAuth = PreferenceHelper.getBool(PreferenceHelper.ALLOW_FG_AUTH);
    batteryPercentage();
    checkBiometricAvailable();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      checkOutProvider = Provider.of<CheckOutProvider>(context, listen: false);
      attendanceProvider =
          Provider.of<AttendanceProvider>(context, listen: false);
      callGetTotByType(checkOutProvider);
    });
  }

  batteryPercentage() async {
    battery = await AppUtils.getBatteryLevel();
  }

  callGetTotByType(CheckOutProvider getMdl) {
    getMdl
        .apiCallGetTotByType(groupType: AppConstant.visitTypeCode)
        .then((value) {
      getTotByGroupTypeModel = value;
      if (getTotByGroupTypeModel?.isValidationFailed == false &&
          getTotByGroupTypeModel?.isError == false) {
        selectedTotValue = getTotByGroupTypeModel?.data?.first.totValue;
        selectedTotId = getTotByGroupTypeModel?.data?.first.totId;
      } else {
        if (getTotByGroupTypeModel?.isError == true) {
          AppUtils.showDialogBoxWithOneButton(
            titleText: "Error",
              context: context,
              text: "Something went wrong, Please try again later!");
        }
        if (getTotByGroupTypeModel?.isValidationFailed == true) {
          AppUtils.showDialogBoxWithOneButton(
              context: context, text: getTotByGroupTypeModel?.message ?? "");
        }
      }
    });
  }

  callAddActivityApi({
    required AttendanceProvider postMdl,
    Position? position,
  }) {
    postMdl
        .apiCallCreateActivity(
            picturePath: image64,
            isFromCheckOut: true,
            userId: userUid,
            totTrackingEventCode: AppConstant.checkOutEvent,
            latitude: position?.latitude,
            longitude: position?.longitude,
            batteryLevel: attendanceProvider.battery,
            companyName: companyNameController.text,
            customerName: customerNameController.text,
            customerPhoneNumber: customerPhoneNumberController.text,
            visitDiscussion: visitDiscussionNameController.text,
            visitTypeCode: selectedTotId)
        .then((value) {
      createActivityModel = value;
      if (createActivityModel?.isError == false &&
          createActivityModel?.isValidationFailed == false) {
        checkOutFunction();
        // PreferenceHelper.setString(PreferenceHelper.WAITING_START_TIME, DateTime.now().toString());
        service.invoke("checkout_update", {
          "waitingStartTime": DateTime.now().toString(),
          "lastLat": position?.latitude,
          "lastLong": position?.longitude,
        });
      } else {
        if (createActivityModel?.isError == true) {
          AppUtils.showDialogBoxWithOneButton(
              titleText: "Error",
              context: context,
              text: "Something went wrong, Please try again later!");
        }
        if (createActivityModel?.isValidationFailed == true) {
          AppUtils.showDialogBoxWithOneButton(
              context: context, text: createActivityModel?.message ?? "");
        }
      }
    });
    setState(() {
      isLoading = true;
    });
  }

  checkOutFunction() async {
    PreferenceHelper.setBool(PreferenceHelper.checkIn, false);
    PreferenceHelper.setString(
        PreferenceHelper.WAITING_START_TIME, DateTime.now().toString());
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    attendanceProvider = Provider.of<AttendanceProvider>(context);
    checkOutProvider = Provider.of<CheckOutProvider>(context);
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
                onTap: checkOutProvider.isFetching
                    ? () {}
                    : () {
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
          body: checkOutProvider.isFetching
              ? AppUtils.loaderWidget()
              : Stack(
                  children: [
                    Column(
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            physics: isLoading
                                ? NeverScrollableScrollPhysics()
                                : AlwaysScrollableScrollPhysics(),
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  left: 10, right: 10, top: 10, bottom: 10),
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
                                                  decoration: AppUtils
                                                      .commonBoxDecoration(
                                                    color: AppConstant
                                                        .greyWithShade,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                  ),
                                                  child:
                                                      // isImageLoading
                                                      Image.file(
                                                    _image ??
                                                        File(
                                                            _image?.path ?? ""),
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
                                                child:
                                                    AppUtils.commonTextWidget(
                                                  text: "Remove",
                                                  textColor: Colors.red,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w600,
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
                                              padding: AppUtils.edgeInsetsOnly(
                                                  left: 15, right: 15),
                                              // alignment: Alignment.center,
                                              height: 50,
                                              width: double.infinity,
                                              decoration:
                                                  AppUtils.commonBoxDecoration(
                                                color:
                                                    AppConstant.greyWithShade,
                                                borderRadius:
                                                    BorderRadius.circular(5),
                                                border: Border.all(
                                                    color: AppConstant
                                                        .appPrimaryColor),
                                              ),
                                              child: Center(
                                                child:
                                                    AppUtils.commonTextWidget(
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
                                      controller: customerPhoneNumberController,
                                      textInputType: TextInputType.number),
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
                                      const SizedBox(
                                        height: 5,
                                      ),
                                      radioWidget()
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
                            onPressed: isLoading
                                ? () {}
                                : () {
                                    checkValidation(attendanceProvider);
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
                            child: AppUtils.loaderWidget(
                                color: AppConstant.appPrimaryColor),
                          )
                        : SizedBox(),
                  ],
                )),
    );
  }

  radioWidget() {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      itemCount: getTotByGroupTypeModel?.data?.length ?? 0,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisSpacing: 30,
        mainAxisExtent: 60,
        crossAxisCount: 2,
      ),
      itemBuilder: (context, index) {
        return RadioListTile(
          contentPadding: AppUtils.edgeInsetsAll(allPadding: 0),
          title: AppUtils.commonTextWidget(
              text: getTotByGroupTypeModel?.data?[index].totValue ?? "",
              fontWeight: FontWeight.w500,
              textColor: AppConstant.blackColor,
              fontSize: 12),
          activeColor: AppConstant.appPrimaryColor,
          value: getTotByGroupTypeModel?.data?[index].totValue,
          groupValue: selectedTotValue,
          onChanged: (value) {
            setState(() {
              selectedTotValue = getTotByGroupTypeModel?.data?[index].totValue;
              selectedTotId = getTotByGroupTypeModel?.data?[index].totId;
            });
          },
        );
      },
    );
  }

  commonTextField(
      {String? text,
      int? maxLine,
      required TextEditingController controller,
      TextInputType? textInputType}) {
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
          readOnly: isLoading ? true : false,
          controller: controller,
          hintText: text ?? "",
          maxLines: maxLine ?? 1,
          cursorColor: AppConstant.appPrimaryColor.withOpacity(0.9),
          allBorderRadius: 5,
          fillColor: AppConstant.whiteColor,
          hintTextColor: AppConstant.greyColor.withOpacity(0.5),
          textInputType: textInputType,
        ),
      ],
    );
  }

  var imageFull;
  File? _image;
  ImagePicker? imagePicker;

  Future<String?> getImage() async {
    // Request camera permission
    var status = await Permission.camera.request();

    // Check if permission is permanently denied or denied
    if (status.isPermanentlyDenied || status.isDenied) {
      openAppSettings();
      return null; // Return null as permission is not granted
    }

    // Permission is granted, proceed to pick image from camera
    final imagePicker = ImagePicker();
    final image = await imagePicker.pickImage(
      source: ImageSource.camera,
      imageQuality: 25,
    );

    // Check if image is picked successfully
    if (image != null) {
      final bytes = await image.readAsBytes();
      setState(() {
        image64 = "data:image/png;base64," + base64Encode(bytes);
        _image = File(image.path);
      });
      return image64; // Return base64 encoded image
    } else {
      // Image picking is cancelled or failed
      return null;
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
    } catch (e) {}
    return position;
  }

  doLocalVerification(
      {required Function() afterSuccessfulVerificationFnc}) async {
    if (isBiometricAvailable) {
      bool isAuthenticated = await _localAuthentication.authenticate(
          localizedReason: "Authenticate using Biometrics",
          options: const AuthenticationOptions(
              stickyAuth: true, useErrorDialogs: true));
      if (isAuthenticated) {
        afterSuccessfulVerificationFnc();
      } else {
        if (kDebugMode) {}
        AppUtils.showDialogBoxWithOneButton(
            context: context, text: "Authentication Fail! Please Try Again");
        // openDialogFnc("Authentication Fail! Please Try Again");
      }
    } else {
      AppUtils.showDialogBoxWithOneButton(
          context: context,
          text: "Biometric Auth is not available on this device");
      // openDialogFnc("Biometric Auth is not available on this device");
    }
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
    } else if (customerPhoneNumberController.text.isEmpty) {
      AppUtils.showSnackBarWithColor(
          context: context,
          message: "Enter Customer Phone Number",
          giveColor: Colors.red);
    } else if (visitDiscussionNameController.text.isEmpty) {
      AppUtils.showSnackBarWithColor(
          context: context,
          message: "Enter Visit Discussion",
          giveColor: Colors.red);
    } else {
      if (isAllowFgAuth == true) {
        doLocalVerification(afterSuccessfulVerificationFnc: () {
          getLocationAndRedirect(postMdl);
        });
      } else {
        getLocationAndRedirect(postMdl);
      }
    }
  }

  getLocationAndRedirect(postMdl) {
    return getCurrentLocation().then((value) async {
      await callAddActivityApi(postMdl: postMdl, position: value);
    });
  }
}
