import 'package:flutter/material.dart';
import 'package:ontrek/core/utils/App_utils.dart';
import 'package:ontrek/core/utils/app_constant.dart';

class HolidayScreen extends StatefulWidget {
  const HolidayScreen({super.key});

  @override
  State<HolidayScreen> createState() => _HolidayScreenState();
}

class _HolidayScreenState extends State<HolidayScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstant.whiteColor,
      appBar: AppUtils.commonAppBar(
          context: context,
          isBack: true,
          isBorder: true,
          title: "Holidays",
          isCenter: true),
      body: ListView.builder(
        shrinkWrap: true,
        physics: const BouncingScrollPhysics(),
        itemCount: 20,
        itemBuilder: (context, index) {
          return AppUtils.commonContainer(
            margin: const EdgeInsets.only(left: 10, right: 10, top: 20),
            decoration: BoxDecoration(
              color: AppConstant.whiteColor,
              borderRadius: AppUtils.borderRadiusAll(raduis: 10),
              boxShadow: [
                BoxShadow(
                  color: AppConstant.greyColor.withOpacity(0.3),
                  blurRadius: 8,
                  blurStyle: BlurStyle.solid,
                  spreadRadius: 0.8,
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: AppUtils.edgeInsetsOnly(bottom: 20, left: 20, right: 10),
                  padding: AppUtils.edgeInsetsOnly(bottom: 20, right: 10, left: 10, top: 15),
                  decoration: AppUtils.commonBoxDecoration(
                    borderRadius: AppUtils.borderRadiousonly(
                      bottomleft: 10,
                      bottomright: 10,
                    ),
                    color: AppConstant.appPrimaryColor,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppUtils.commonTextWidget(
                        text: "${index + 1}",
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                        textColor: AppConstant.whiteColor,
                      ),
                      AppUtils.commonTextWidget(
                        text: "October",
                        fontWeight: FontWeight.w300,
                        fontSize: 10,
                        textColor: AppConstant.whiteColor,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Container(
                    padding: AppUtils.edgeInsetsOnly(top: 10, left: 10, right: 10, bottom: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppUtils.commonTextWidget(
                          text: "Holiday Title",
                          textColor: AppConstant.appPrimaryColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                        AppUtils.commonTextWidget(
                          text: "Holiday Description which come from BackEnd and show which date festival how we celebrate.",
                          textColor: AppConstant.appPrimaryColor,
                          fontWeight: FontWeight.w400,
                          fontSize: 12,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
