import 'package:app_settings/app_settings.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:ontrek/core/storage/preference_helper.dart';
import 'package:ontrek/core/utils/app_constant.dart';
import 'package:ontrek/core/utils/App_utils.dart';
import 'package:ontrek/features/authentication/screens/login_with_phone_number.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class ProfileScreen extends StatefulWidget {
  ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  PanelController panelController = PanelController();
  String? userName;
  String? profileImage;
  String? orgName;
  String? manager;
  FlutterBackgroundService service = FlutterBackgroundService();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    userName = PreferenceHelper.getString(PreferenceHelper.USER_NAME);
    profileImage = PreferenceHelper.getString(PreferenceHelper.PROFILE_PIC);
    orgName = PreferenceHelper.getString(PreferenceHelper.ORG_NAME);
    manager = PreferenceHelper.getString(PreferenceHelper.REPORTING_MANAGER);
  }

  List<String> profileOptionsList = [
    // "Reimbursement",
    // "Settings",
    "Help",
    "FAQ",
    "Terms & Conditions",
    "Privacy Policy",
    "App Settings",
    "Sign Out",
  ];
  List<IconData> profileOptionsListIcons = [
    // Icons.monetization_on,
    // Icons.settings,
    Icons.chat,
    Icons.help_outline_outlined,
    Icons.verified,
    Icons.privacy_tip,
    Icons.app_settings_alt,
    Icons.logout,
  ];

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    // double width = MediaQuery.of(context).size.width;

    return AppUtils.commonSlidePanel(
      controller: panelController,
      maxHeight: height,
      minHeight: height,
      isDraggable: false,
      panelSnapping: false,
      panelBuilder: (p0) {
        return Column(
          children: [
            AppUtils.commonContainer(
              height: MediaQuery.of(context).size.height / 3,
              width: double.infinity,
              color: AppConstant.whiteColor.withOpacity(0.3),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Stack(
                    alignment: Alignment.topRight,
                    children: [
                      AppUtils.commonContainer(
                        height: 80,
                        width: 80,
                        decoration: AppUtils.commonBoxDecoration(
                            shape: BoxShape.circle,
                            border:
                                Border.all(color: AppConstant.appPrimaryColor)),
                        child: ClipOval(
                          child: AppUtils.commonNetworkImageWidget(
                              path: profileImage),
                        ),
                      ),
                      AppUtils.commonContainer(
                        padding: EdgeInsets.all(5),
                        decoration: AppUtils.commonBoxDecoration(
                            color: AppConstant.appPrimaryColor,
                            shape: BoxShape.circle),
                        child: Icon(Icons.edit, size: 15, color: Colors.white),
                      )
                    ],
                  ),
                  AppUtils.commonSizedBox(height: 10),
                  AppUtils.commonTextWidget(
                      text: userName ?? "",
                      textColor: AppConstant.blackColor,
                      fontWeight: FontWeight.w500,
                      fontSize: 18),
                  AppUtils.commonTextWidget(
                      text: orgName ?? "",
                      textColor: AppConstant.blackColor.withOpacity(0.6),
                      fontSize: 12),
                ],
              ),
            ),
            AppUtils.commonContainer(
              decoration: AppUtils.commonBoxDecoration(
                border: Border(
                  bottom: BorderSide(color: AppConstant.greyColor, width: 0),
                ),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.only(left: 10, right: 10),
                leading: SizedBox(
                  height: 50,
                  width: 50,
                  child: ClipOval(
                    child: AppUtils.commonNetworkImageWidget(
                      path: profileImage,
                    ),
                  ),
                ),
                title: AppUtils.commonTextWidget(
                    text: manager ?? "",
                    textColor: AppConstant.blackColor,
                    fontWeight: FontWeight.w500),
                subtitle: AppUtils.commonTextWidget(
                    text: 'Reporting Manager',
                    textColor: AppConstant.blackColor.withOpacity(0.6),
                    fontSize: 12),
                trailing: IconButton(
                  onPressed: () {
                    openDialogFnc();
                  },
                  icon: Icon(Icons.call, color: Colors.blue.shade800),
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                controller: p0,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: height -
                          (MediaQuery.of(context).size.height / 3) -
                          60,
                      child: ListView.builder(
                        padding: const EdgeInsets.only(bottom: 30),
                        physics: const BouncingScrollPhysics(),
                        itemCount: profileOptionsList.length,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () {
                              executeOperation(index, context);
                            },
                            child: Row(
                              children: [
                                Expanded(
                                    child: Icon(
                                  profileOptionsListIcons[index],
                                )),
                                Expanded(flex: 7,
                                  child: AppUtils.commonContainer(
                                    padding: const EdgeInsets.only(
                                      top: 5,
                                      bottom: 5,
                                    ),
                                    decoration: BoxDecoration(
                                      border: Border(
                                        top: index == 0
                                            ? BorderSide(
                                                width: 0.5,
                                                color: Colors.grey.shade400)
                                            : BorderSide.none,
                                        bottom: BorderSide(
                                          width: 0.5,
                                          color: Colors.grey.shade400,
                                        ),
                                      ),
                                    ),
                                    child: CupertinoListTile(
                                      leadingToTitle: 0,
                                      leadingSize: 0,
                                      padding: EdgeInsets.zero,
                                      title: AppUtils.commonTextWidget(
                                        text: profileOptionsList[index],
                                        textColor: AppConstant.blackColor
                                            .withOpacity(0.7),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget profileOptions({
    IconData? icon,
    required String text,
    required int index,
    required int itemCount,
  }) {
    return Column(
      children: [
        ListTile(
          contentPadding: EdgeInsets.only(left: 10),
          leading: Icon(icon, color: AppConstant.blackColor.withOpacity(0.5)),
          title: AppUtils.commonContainer(
            child: AppUtils.commonTextWidget(
                text: text, textColor: AppConstant.blackColor),
          ),
        ),
        if (index < itemCount - 1) Divider(indent: 50, height: 0),
      ],
    );
  }

  openDialogFnc() {
    showDialog(
      context: context,
      builder: (context) => showDialogBox(context),
    );
  }

  AlertDialog showDialogBox(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppConstant.appPrimaryColor,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10))),
      contentPadding:
          AppUtils.edgeInsetsOnly(right: 15, left: 15, top: 10, bottom: 10),
      insetPadding: AppUtils.edgeInsetsAll(allPadding: 0),
      titlePadding: AppUtils.edgeInsetsAll(allPadding: 0),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            AppUtils.commonSizedBox(
              height: 40,
              width: 40,
            ),
            AppUtils.commonTextWidget(
                // textColor: App,
                text: "Contact Info",
                fontSize: 16),
            AppUtils.commonContainer(
                height: 40,
                width: 40,
                child: IconButton(
                    color: AppConstant.whiteColor,
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: Icon(Icons.close)))
          ],
        ),
        AppUtils.commonSizedBox(height: 10),
        Visibility(
          visible: false,
          child: AppUtils.commonTextWidget(
            text: "No contact info found",
            fontSize: 14,
          ),
        ),
        Visibility(
          visible: true,
          child: GestureDetector(
            onTap: () {
              // AppUtils.launchToBrowser(
              //     Uri.parse(
              //         "tel:${getSalesMenListModelData?[index].primaryPhoneNo}"));
            },
            child: AppUtils.commonContainer(
              padding: AppUtils.edgeInsetsAll(allPadding: 15),
              width: double.infinity,
              decoration: AppUtils.commonBoxDecoration(
                  border: Border.all(
                    color: AppConstant.greyColor.withOpacity(0.5),
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(5),
                  color: AppConstant.whiteColor),
              child: Row(
                children: [
                  Icon(Icons.call, color: AppConstant.appPrimaryColor),
                  AppUtils.commonSizedBox(width: 5),
                  AppUtils.commonTextWidget(
                      letterSpacing: 2,
                      text: "910679588",
                      // text: getSalesMenListModelData?[
                      // index]
                      //     .primaryPhoneNo ??
                      //     '',
                      fontSize: 14,
                      textColor: AppConstant.appPrimaryColor),
                ],
              ),
            ),
          ),
        ),
        AppUtils.commonSizedBox(height: 10),
        Visibility(
          visible: true,
          child: GestureDetector(
            onTap: () {
              // AppUtils.launchToBrowser(
              //     Uri.parse(
              //         "tel:${getSalesMenListModelData?[index].altPhoneNo}"));
            },
            child: AppUtils.commonContainer(
              padding: AppUtils.edgeInsetsAll(allPadding: 15),
              width: double.infinity,
              decoration: AppUtils.commonBoxDecoration(
                border: Border.all(
                    color: AppConstant.greyColor.withOpacity(0.5), width: 1),
                borderRadius: BorderRadius.circular(5),
                color: AppConstant.whiteColor,
              ),
              child: Row(
                children: [
                  Icon(Icons.call, color: AppConstant.appPrimaryColor),
                  AppUtils.commonSizedBox(width: 5),
                  AppUtils.commonTextWidget(
                      letterSpacing: 2,
                      text: "7435019181",
                      // text: getSalesMenListModelData?[
                      // index]
                      //     .altPhoneNo ??
                      //     '',
                      fontSize: 14,
                      textColor: AppConstant.appPrimaryColor),
                ],
              ),
            ),
          ),
        ),
        AppUtils.commonSizedBox(height: 10),
      ]),
    );
  }

  void executeOperation(int index, BuildContext context) {
    switch (index) {
      case 0:
        AppUtils.showDialogBoxWithOneButton(
          titleText: "Help",
          text: "You Tapped on Help",
          context: context,
        );
        break;
      case 1:
        AppUtils.showDialogBoxWithOneButton(
          titleText: "FAQ",
          text: "You Tapped on FAQ",
          context: context,
        );
        break;
      case 2:
        AppUtils.showDialogBoxWithOneButton(
          titleText: "Terms & Conditions",
          text: "You Tapped on Terms & Conditions",
          context: context,
        );
        break;
      case 3:
        AppUtils.showDialogBoxWithOneButton(
          titleText: "Privacy & Policy",
          text: "You Tapped on Privacy & Policy",
          context: context,
        );
        break;
      case 4:
        AppSettings.openAppSettings();
        break;
      case 5:
        AppUtils.showDialogBoxWithTwoButton(
          titleText: "Sign Out",
          context: context,
          text: "Are you sure you want to Sign Out?",
          onSuccessString: "Sign Out",
          onCancelString: "Cancel",
          onSuccess: () async {
            bool isRunning = await service.isRunning();
            if (isRunning) {
              service.invoke("stopService");
            }
            PreferenceHelper.clear();
            Navigator.pushReplacement(
              context,
              CupertinoPageRoute(
                builder: (context) => LoginScreen(),
              ),
            );
          },
          onCancel: () {},
        );
        break;
      default:
        break;
    }
  }
}
