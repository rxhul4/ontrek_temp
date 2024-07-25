import 'package:flutter/material.dart';
import 'package:ontrek/core/utils/App_utils.dart';
import 'package:ontrek/core/utils/app_constant.dart';
import 'package:ontrek/features/home/holidays/provider/holiday_provider.dart';
import 'package:provider/provider.dart';

class HolidayScreen extends StatefulWidget {
  const HolidayScreen({super.key});

  @override
  State<HolidayScreen> createState() => _HolidayScreenState();
}

class _HolidayScreenState extends State<HolidayScreen> {
  Map<String, String> splitDateString(String dateStr) {
    List<String> dateParts = dateStr.split('-');

    if (dateParts.length != 3) {
      throw FormatException('Invalid date format. Expected format: yyyy-MM-dd');
    }

    return {
      'year': dateParts[0],
      'month': dateParts[1],
      'day': dateParts[2],
    };
  }

  late HolidayProvider holidayProvider;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) async {
        holidayProvider = Provider.of<HolidayProvider>(context, listen: false);
        await holidayProvider.apiCallGetDayEndRequestList();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    holidayProvider = Provider.of<HolidayProvider>(context);
    return Scaffold(
      backgroundColor: AppConstant.whiteColor,
      appBar: AppUtils.commonAppBar(
          context: context,
          isBack: true,
          isBorder: true,
          title: "Holidays",
          isCenter: true),
      body: holidayProvider.isFetching
          ? AppUtils.loaderWidget()
          : holidayProvider.getHolidayListModel?.data?.length == 0 ||
                  holidayProvider.getHolidayListModel?.data == [] ||
                  holidayProvider.getHolidayListModel?.data == null
              ? AppUtils.commonNoDataFound(
                  text: "No Holidays Found",
                  onPressed: () async{
                    await holidayProvider.apiCallGetDayEndRequestList();
                  },
                )
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const BouncingScrollPhysics(),
                  itemCount: holidayProvider.getHolidayListModel?.data?.length,
                  itemBuilder: (context, index) {
                    return AppUtils.commonContainer(
                      margin:
                          const EdgeInsets.only(left: 10, right: 10, top: 20),
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
                          // Container(
                          //   margin:
                          //       AppUtils.edgeInsetsOnly(bottom: 20, left: 20, right: 10),
                          //   padding: AppUtils.edgeInsetsOnly(
                          //       bottom: 20, right: 10, left: 10, top: 15),
                          //   decoration: AppUtils.commonBoxDecoration(
                          //     borderRadius: AppUtils.borderRadiousonly(
                          //       bottomleft: 10,
                          //       bottomright: 10,
                          //     ),
                          //     color: AppConstant.appPrimaryColor,
                          //   ),
                          //   child: Column(
                          //     mainAxisAlignment: MainAxisAlignment.center,
                          //     crossAxisAlignment: CrossAxisAlignment.start,
                          //     children: [
                          //       AppUtils.commonTextWidget(
                          //         text: "${index + 1}",
                          //         fontWeight: FontWeight.w500,
                          //         fontSize: 14,
                          //         textColor: AppConstant.whiteColor,
                          //       ),
                          //       AppUtils.commonTextWidget(
                          //         text: "October",
                          //         fontWeight: FontWeight.w300,
                          //         fontSize: 10,
                          //         textColor: AppConstant.whiteColor,
                          //       ),
                          //     ],
                          //   ),
                          // ),
                          Expanded(
                            child: Container(
                              padding: AppUtils.edgeInsetsOnly(
                                  top: 10, left: 10, right: 10, bottom: 10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  AppUtils.commonTextWidget(
                                    text: holidayProvider.getHolidayListModel
                                            ?.data?[index].holidayTitle ??
                                        "",
                                    textColor: AppConstant.appPrimaryColor,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                  AppUtils.commonTextWidget(
                                    text: holidayProvider.getHolidayListModel
                                            ?.data?[index].holidayDescription ??
                                        "",
                                    textColor: AppConstant.appPrimaryColor,
                                    fontWeight: FontWeight.w400,
                                    fontSize: 12,
                                  ),
                                ],
                              ),
                            ),
                          ),

                          Container(
                            margin: AppUtils.edgeInsetsOnly(
                                bottom: 20, left: 0, right: 20),
                            padding: AppUtils.edgeInsetsOnly(
                                bottom: 10, right: 10, left: 10, top: 10),
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
                                  text: holidayProvider.formatDateString(
                                    holidayProvider.getHolidayListModel
                                            ?.data?[index].holidayDate ??
                                        "",
                                  ),
                                  fontWeight: FontWeight.w400,
                                  fontSize: 10,
                                  textColor: AppConstant.whiteColor,
                                ),
                              ],
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
