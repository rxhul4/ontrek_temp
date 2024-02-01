import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:ontrek/core/utils/app_constant.dart';
import 'package:ontrek/core/utils/widget_utils.dart';

import '../../../core/utils/image_path.dart';

class ProfileScreen extends StatefulWidget {
  ScrollController? scrollController;

  ProfileScreen({super.key, this.scrollController});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  DraggableScrollableController draggableScrollableController =
      DraggableScrollableController();

  // AndroidDeviceInfo? infoOfDevice;
  //
  // @override
  // void initState() {
  //   // TODO: implement initState
  //   super.initState();
  //   getDeviceInfo().then((value) {
  //     infoOfDevice = value;
  //   });
  // }
  //
  // DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  //
  // Future getDeviceInfo() async {
  //   AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
  //   print('Running on ${androidInfo.model}');
  //   print('Running on ${androidInfo.product}');
  //   print('Running on ${androidInfo.version.release}');
  //   return androidInfo;
  // }

  @override
  Widget build(BuildContext context) {
    return Animate(
      effects: [
        ScaleEffect(
          curve: Curves.bounceIn,
          begin: Offset(0, -1),
          duration: Duration(milliseconds: 300),
        ),
      ],
      child: Container(
        decoration: WidgetUtils.commonBoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                spreadRadius: 0,
                blurRadius: 8,
                offset: Offset(0, -10), // This will create a top shadow
              ),
            ],
            borderRadius:
                WidgetUtils.borderRadiousonly(topright: 18, topleft: 18),
            color: AppConstant.whiteColor),
        child: Column(
          children: [
            SingleChildScrollView(
              controller: widget.scrollController,
              physics: NeverScrollableScrollPhysics(),
              child: WidgetUtils.commonContainer(
                height: MediaQuery.of(context).size.height / 3,
                width: double.infinity,
                color: AppConstant.greyColor.withOpacity(0.3),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Stack(
                      alignment: Alignment.topRight,
                      children: [
                        WidgetUtils.commonContainer(
                          height: 80,
                          width: 80,
                          decoration: WidgetUtils.commonBoxDecoration(
                              shape: BoxShape.circle,
                              color: AppConstant.greyColor.withOpacity(0.3),
                              border: Border.all(
                                  color:
                                      AppConstant.greyColor.withOpacity(0.5)),
                              image: DecorationImage(
                                  fit: BoxFit.cover,
                                  image: AssetImage(profileImage))),
                        ),
                        WidgetUtils.commonContainer(
                          padding: EdgeInsets.all(5),
                          decoration: WidgetUtils.commonBoxDecoration(
                              color: Colors.white, shape: BoxShape.circle),
                          child: Icon(Icons.edit, size: 15),
                        )
                      ],
                    ),
                    WidgetUtils.commonSizedBox(height: 10),
                    WidgetUtils.commonTextWidget(
                        text: 'Vatsal',
                        textColor: AppConstant.blackColor,
                        fontWeight: FontWeight.w500,
                        fontSize: 18),
                    WidgetUtils.commonTextWidget(
                        text: 'Epist Interior Pvt Ltd',
                        textColor: AppConstant.blackColor.withOpacity(0.6),
                        fontSize: 12),
                  ],
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: AppConstant.greyColor, width: 0),
                ),
              ),
              child: ListTile(
                contentPadding: EdgeInsets.only(left: 10, right: 10),
                leading: WidgetUtils.commonContainer(
                  width: 40,
                  height: 40,
                  decoration: WidgetUtils.commonBoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                          fit: BoxFit.cover,image: AssetImage(profileImage)),
                      border: Border.all(
                          color: AppConstant.greyColor.withOpacity(0.5)),
                      color: AppConstant.greyColor.withOpacity(0.3)),
                ),
                title: WidgetUtils.commonTextWidget(
                    text: 'Kenil Patel',
                    textColor: AppConstant.blackColor,
                    fontWeight: FontWeight.w500),
                subtitle: WidgetUtils.commonTextWidget(
                    text: 'Reporting Manager',
                    textColor: AppConstant.blackColor.withOpacity(0.6),
                    fontSize: 12),
                trailing: IconButton(
                  onPressed: () {},
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
                      itemCount: profileOptionsList.length,
                      shrinkWrap: true,
                      scrollDirection: Axis.vertical,
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
                      padding: WidgetUtils.edgeInsetsOnly(left: 10, bottom: 8),
                      child: WidgetUtils.commonTextWidget(
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
          title: WidgetUtils.commonContainer(
            child: WidgetUtils.commonTextWidget(
                text: text, textColor: AppConstant.blackColor),
          ),
        ),
        if (index < itemCount - 1) Divider(indent: 50, height: 0),
      ],
    );
  }
}
