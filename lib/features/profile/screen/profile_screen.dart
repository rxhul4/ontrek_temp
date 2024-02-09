import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:ontrek/core/utils/app_constant.dart';
import 'package:ontrek/core/utils/App_utils.dart';


class ProfileScreen extends StatefulWidget {
  ScrollController? scrollController;

  ProfileScreen({super.key, this.scrollController});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  DraggableScrollableController draggableScrollableController =
      DraggableScrollableController();

  @override
  Widget build(BuildContext context) {
    return Animate(
      effects: const [
        SlideEffect(
            end: Offset(0, 0),
            curve: Curves.decelerate,
            begin: Offset(0, 1),
            duration: Duration(milliseconds: 600)),
      ],
      child: Container(
        decoration: AppUtils.commonBoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                spreadRadius: 0,
                blurRadius: 8,
                offset: Offset(0, -10), // This will create a top shadow
              ),
            ],
            borderRadius:
                AppUtils.borderRadiousonly(topright: 18, topleft: 18),
            color: AppConstant.whiteColor),
        child: Column(
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
                          color: AppConstant.greyColor.withOpacity(0.3),
                          border: Border.all(
                              color: AppConstant.greyColor.withOpacity(0.5)),
                        ),
                        child: Icon(Icons.person,color: AppConstant.blackColor,size: 40,)
                      ),
                      AppUtils.commonContainer(
                        padding: EdgeInsets.all(5),
                        decoration: AppUtils.commonBoxDecoration(
                            color: Colors.white, shape: BoxShape.circle),
                        child: Icon(Icons.edit, size: 15),
                      )
                    ],
                  ),
                  AppUtils.commonSizedBox(height: 10),
                  AppUtils.commonTextWidget(
                      text: 'Vatsal',
                      textColor: AppConstant.blackColor,
                      fontWeight: FontWeight.w500,
                      fontSize: 18),
                  AppUtils.commonTextWidget(
                      text: 'Epist Interior Pvt Ltd',
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
                contentPadding: EdgeInsets.only(left: 10, right: 10),
                leading: AppUtils.commonContainer(
                  width: 40,
                  height: 40,
                  decoration: AppUtils.commonBoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: AppConstant.greyColor.withOpacity(0.5)),
                      color: AppConstant.greyColor.withOpacity(0.3)
                  ),
                  child: Icon(Icons.person,color: AppConstant.blackColor,size: 22,)
                ),
                title: AppUtils.commonTextWidget(
                    text: 'Kenil Patel',
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
                scrollDirection: Axis.vertical,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListView.builder(
                      controller: widget.scrollController,
                      itemCount: profileOptionsList.length,
                      shrinkWrap: true,
                      // scrollDirection: Axis.vertical,
                      physics: NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        return InkWell(
                          onTap: () {
                            print(profileOptionsList[index]);
                          },
                          child: profileOptions(
                            icon: profileOptionsListIcons[index],
                            text: profileOptionsList[index],
                            index: index,
                            itemCount: profileOptionsList.length,
                          ),
                        );
                      },
                    ),
                    const Divider(),
                    Padding(
                      padding: AppUtils.edgeInsetsOnly(left: 10, bottom: 8),
                      child: AppUtils.commonTextWidget(
                          text: 'Version', textColor: AppConstant.blackColor),
                    ),
                    // Text('${infoOfDevice?.version.release.toString()}')
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );

  }

  List<String> profileOptionsList = [
    "Reimbursement",
    "Settings",
    "Help",
    "FAQ",
    "Terms & Conditions",
    "Privacy Policy",
    "App Settings",
    "Sign Out",
  ];
  List<IconData> profileOptionsListIcons = [
    Icons.monetization_on,
    Icons.settings,
    Icons.chat,
    Icons.help_outline_outlined,
    Icons.verified,
    Icons.privacy_tip,
    Icons.app_settings_alt,
    Icons.logout,
  ];

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

      contentPadding: AppUtils.edgeInsetsOnly(
          right: 15,
          left: 15,
          top: 10,
          bottom: 10),
      insetPadding: AppUtils.edgeInsetsAll(
          allPadding: 0),
      titlePadding: AppUtils.edgeInsetsAll(
          allPadding: 0),
      content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment:
              MainAxisAlignment
                  .spaceBetween,
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
                          Navigator.pop(
                              context);
                        },
                        icon: Icon(
                            Icons.close)))
              ],
            ),
            AppUtils.commonSizedBox(
                height: 10),

            Visibility(
              visible: false,
              child: AppUtils.commonTextWidget(
                margin: AppUtils.edgeInsetsOnly(top: 30,bottom: 30),
                text: "No contact info found",
                fontSize: 14,
              ),
            ),

            Visibility(
              visible:true,
              child: GestureDetector(
                onTap: () {
                  // AppUtils.launchToBrowser(
                  //     Uri.parse(
                  //         "tel:${getSalesMenListModelData?[index].primaryPhoneNo}"));
                },
                child: AppUtils.commonContainer(
                  padding:
                  AppUtils.edgeInsetsAll(
                      allPadding: 15),
                  width: double.infinity,
                  decoration: AppUtils
                      .commonBoxDecoration(
                    border: Border.all(
                        color: AppConstant.greyColor.withOpacity(0.5),
                        width: 1,),
                    borderRadius:
                    BorderRadius.circular(
                        5),
                    color: AppConstant.whiteColor
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.call,
                          color: AppConstant.appPrimaryColor
                      ),
                      AppUtils.commonSizedBox(
                          width: 5),
                      AppUtils.commonTextWidget(
                        letterSpacing: 2,
                        text: "910679588",
                        // text: getSalesMenListModelData?[
                        // index]
                        //     .primaryPhoneNo ??
                        //     '',
                        fontSize: 14,
                        textColor: AppConstant.appPrimaryColor
                      ),
                    ],
                  ),
                ),
              ),
            ),
            AppUtils.commonSizedBox(
                height: 10),
            Visibility(
              visible:true,
              child: GestureDetector(
                onTap: () {
                  // AppUtils.launchToBrowser(
                  //     Uri.parse(
                  //         "tel:${getSalesMenListModelData?[index].altPhoneNo}"));
                },
                child: AppUtils.commonContainer(
                  padding:
                  AppUtils.edgeInsetsAll(
                      allPadding: 15),
                  width: double.infinity,
                  decoration: AppUtils
                      .commonBoxDecoration(
                    border: Border.all(
                        color:AppConstant.greyColor.withOpacity(0.5),
                        width: 1),
                    borderRadius:
                    BorderRadius.circular(
                        5),
                    color: AppConstant.whiteColor,
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.call,
                          color : AppConstant.appPrimaryColor
                      ),
                      AppUtils.commonSizedBox(
                          width: 5),
                      AppUtils.commonTextWidget(letterSpacing: 2,
                        text: "7435019181",
                        // text: getSalesMenListModelData?[
                        // index]
                        //     .altPhoneNo ??
                        //     '',
                        fontSize: 14,
                          textColor: AppConstant.appPrimaryColor
                      ),
                    ],
                  ),
                ),
              ),
            ),
            AppUtils.commonSizedBox(
                height: 10),
          ]),
    );
  }
}
