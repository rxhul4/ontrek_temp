import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ontrek/core/common_widgets/app_scaffold.dart';
import 'package:ontrek/core/utils/app_constant.dart';
import 'package:ontrek/core/utils/App_utils.dart';
import 'package:ontrek/core/utils/image_path.dart';
import 'package:ontrek/features/add_lead/screen/add_lead_screen.dart';
import 'package:ontrek/features/check_out/model/check_out_form_model.dart';
import 'package:ontrek/features/check_out/provider/check_out_form_provider.dart';
import 'package:ontrek/features/leads/provider/lead_provider.dart';
import 'package:ontrek/features/view_task/model/get_task_by_id_model.dart';
import 'package:ontrek/features/view_task/provider/view_task_provider.dart';
import 'package:provider/provider.dart';

class ViewLeadScreen extends StatefulWidget {
  String? leadId;
  String? leadTitle;

  ViewLeadScreen({
    super.key,
    this.leadId,
    this.leadTitle,
  });

  @override
  State<ViewLeadScreen> createState() => _ViewLeadScreenState();
}

class _ViewLeadScreenState extends State<ViewLeadScreen> {
  late LeadProvider leadProvider;
  String? selectedTotValue;
  String? selectedTotId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      leadProvider = Provider.of<LeadProvider>(context, listen: false);
      leadProvider.apiCallGetLeadById(leadId: widget.leadId);
    });
  }


  @override
  Widget build(BuildContext context) {
    leadProvider = Provider.of<LeadProvider>(context);
    return AppScaffold(
      appBar: AppBar(
        surfaceTintColor: AppConstant.transparentColor,
        elevation: 0,
        leading: InkWell(
            onTap: () {
              Navigator.pop(context);
            },
            child: Icon(
              Icons.arrow_back_ios_new,
              color: AppConstant.blackColor.withOpacity(0.7),
              size: 22,
            )),
        title: AppUtils.commonTextWidget(
            text: widget.leadTitle ?? "",
            textColor: AppConstant.blackColor.withOpacity(0.7),
            fontSize: 14,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.1,
            overflow: TextOverflow.ellipsis),
        actions: [
          GestureDetector(
            onTap: () {
              Navigator.push(context, CupertinoPageRoute(builder: (context) => AddLeadScreen(isEdit: true,leadId: widget.leadId,),));
            },
            child: Icon(
              Icons.edit,
              color: AppConstant.blackColor.withOpacity(0.7),
            ),
          ),
          AppUtils.commonSizedBox(width: 10),
          GestureDetector(
            onTap: () {
              leadProvider.apiCallGetLeadById(leadId: widget.leadId);
            },
            child: Icon(
              Icons.repeat,
              color: AppConstant.blackColor.withOpacity(0.7),
            ),
          ),
          AppUtils.commonSizedBox(width: 20),
        ],
        centerTitle: true,
      ),
      body: leadProvider.isFetching
          ? AppUtils.loaderWidget()
          : leadProvider.getLeadByIdModel?.data == null
              ? Center(
                child: AppUtils.commonNoDataFound(
                    text: leadProvider.getLeadByIdModel?.message,
                    onPressed: () {
                      leadProvider.apiCallGetLeadById(leadId: widget.leadId);
                    },
                  ),
              )
              : SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      AppUtils.commonContainer(
                        width: double.infinity,
                        margin:
                            const EdgeInsets.only(left: 10, right: 10, top: 20),
                        padding: const EdgeInsets.only(
                            left: 15, right: 15, top: 20, bottom: 20),
                        decoration: BoxDecoration(
                            color: AppConstant.whiteColor,
                            borderRadius: AppUtils.borderRadiusAll(raduis: 10),
                            boxShadow: [
                              BoxShadow(
                                  color: AppConstant.greyColor.withOpacity(0.3),
                                  blurRadius: 8,
                                  blurStyle: BlurStyle.solid,
                                  spreadRadius: 0.8),
                            ]),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.home,
                                      color: Colors.blue,
                                      size: 18,
                                    ),
                                    AppUtils.commonSizedBox(width: 5),
                                    AppUtils.commonTextWidget(
                                        text: widget.leadTitle ?? "",
                                        fontSize: 12,
                                        textColor: AppConstant.blackColor
                                            .withOpacity(0.9),
                                        fontWeight: FontWeight.w500)
                                  ],
                                ),
                              ],
                            ),
                            AppUtils.commonSizedBox(height: 5),
                            Divider(
                              color: AppConstant.greyColor.withOpacity(0.3),
                            ),
                            AppUtils.commonSizedBox(height: 5),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.person,
                                      color: Colors.orangeAccent,
                                      size: 18,
                                    ),
                                    AppUtils.commonSizedBox(width: 5),
                                    AppUtils.commonTextWidget(
                                        text: leadProvider.getLeadByIdModel
                                                ?.data?.customerName ??
                                            "",
                                        fontSize: 12,
                                        textColor: AppConstant.blackColor
                                            .withOpacity(0.9),
                                        fontWeight: FontWeight.w500)
                                  ],
                                ),
                              ],
                            ),
                            AppUtils.commonSizedBox(height: 5),
                            Divider(
                              color: AppConstant.greyColor.withOpacity(0.3),
                            ),
                            AppUtils.commonSizedBox(height: 5),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.email,
                                      color: Colors.blue,
                                      size: 18,
                                    ),
                                    AppUtils.commonSizedBox(width: 5),
                                    AppUtils.commonTextWidget(
                                        text: leadProvider.getLeadByIdModel
                                                ?.data?.customerEmail ??
                                            "",
                                        fontSize: 12,
                                        textColor: AppConstant.blackColor
                                            .withOpacity(0.9),
                                        fontWeight: FontWeight.w500)
                                  ],
                                ),
                              ],
                            ),
                            AppUtils.commonSizedBox(height: 5),
                            Divider(
                              color: AppConstant.greyColor.withOpacity(0.3),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.notes,
                                      color: Colors.purpleAccent,
                                      size: 18,
                                    ),
                                    AppUtils.commonSizedBox(width: 5),
                                    AppUtils.commonTextWidget(
                                        text: "Customer Address",
                                        fontSize: 12,
                                        textColor: AppConstant.blackColor
                                            .withOpacity(0.9),
                                        fontWeight: FontWeight.w500)
                                  ],
                                ),
                              ],
                            ),
                            AppUtils.commonSizedBox(height: 8),
                            AppUtils.commonTextWidget(
                                text: leadProvider.getLeadByIdModel?.data
                                        ?.customerAddress ??
                                    "",
                                fontSize: 12,
                                textColor:
                                    AppConstant.blackColor.withOpacity(0.9),
                                fontWeight: FontWeight.w400),
                          ],
                        ),
                      ),
                      leadTile(
                          titleText:
                              leadProvider.getLeadByIdModel?.data?.createdBy,
                          title: "Lead Owner",
                          subTitle:
                              leadProvider.getLeadByIdModel?.data?.createdOn),
                      AppUtils.commonContainer(
                        width: double.infinity,
                        margin:
                            const EdgeInsets.only(left: 10, right: 10, top: 20),
                        padding: const EdgeInsets.only(
                            left: 15, right: 15, top: 20, bottom: 20),
                        decoration: BoxDecoration(
                            color: AppConstant.whiteColor,
                            borderRadius: AppUtils.borderRadiusAll(raduis: 10),
                            boxShadow: [
                              BoxShadow(
                                  color: AppConstant.greyColor.withOpacity(0.3),
                                  blurRadius: 8,
                                  blurStyle: BlurStyle.solid,
                                  spreadRadius: 0.8),
                            ]),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.notes,
                                  color: AppConstant.appPrimaryColor,
                                  size: 18,
                                ),
                                AppUtils.commonSizedBox(width: 5),
                                AppUtils.commonTextWidget(
                                    text: "Other",
                                    fontSize: 12,
                                    textColor:
                                        AppConstant.blackColor.withOpacity(0.9),
                                    fontWeight: FontWeight.w500),
                              ],
                            ),
                            AppUtils.commonSizedBox(height: 5),
                            Divider(
                              color: AppConstant.greyColor.withOpacity(0.3),
                            ),
                            AppUtils.commonSizedBox(height: 10),
                            Column(
                              children: [
                                commonRows(
                                    leftText: "Source",
                                    rightText: leadProvider.getLeadByIdModel
                                        ?.data?.totDtos?.totValue),
                                AppUtils.commonSizedBox(height: 20),
                                commonRows(
                                    leftText: "Created Lead",
                                    rightText: AppUtils.getDate(
                                        date: leadProvider.getLeadByIdModel
                                                ?.data?.createdOn ??
                                            "",
                                        format: "dd MMM yyyy hh:mm a")),
                                AppUtils.commonSizedBox(height: 20),
                                commonRows(
                                    leftText: "Updated Lead",
                                    rightText: AppUtils.getDate(
                                        date: leadProvider.getLeadByIdModel
                                                ?.data?.modifiedOn ??
                                            "",
                                        format: "dd MMM yyyy hh:mm a")),
                              ],
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  commonRows({String? leftText, String? rightText}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
            child: AppUtils.commonTextWidget(
                text: leftText ?? "",
                fontSize: 12,
                fontWeight: FontWeight.w500,
                textColor: AppConstant.blackColor.withOpacity(0.6),
                letterSpacing: 0.5)),
        Expanded(
            child: Padding(
          padding: AppUtils.edgeInsetsOnly(left: 10),
          child: AppUtils.commonTextWidget(
              text: rightText ?? "",
              fontSize: 12,
              fontWeight: FontWeight.w400,
              textColor: AppConstant.blackColor.withOpacity(0.7),
              letterSpacing: 0.5),
        )),
      ],
    );
  }

  Widget leadTile({
    String? title,
    String? titleText,
    String? subTitle,
  }) {
    return AppUtils.commonContainer(
      width: double.infinity,
      margin: const EdgeInsets.only(left: 10, right: 10, top: 20),
      padding: const EdgeInsets.only(left: 15, right: 15, top: 20, bottom: 20),
      decoration: BoxDecoration(
          color: AppConstant.whiteColor,
          borderRadius: AppUtils.borderRadiusAll(raduis: 10),
          boxShadow: [
            BoxShadow(
                color: AppConstant.greyColor.withOpacity(0.3),
                blurRadius: 8,
                blurStyle: BlurStyle.solid,
                spreadRadius: 0.8),
          ]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.person,
                color: AppConstant.appPrimaryColor,
                size: 18,
              ),
              AppUtils.commonSizedBox(width: 5),
              AppUtils.commonTextWidget(
                  text: title ?? "",
                  fontSize: 12,
                  textColor: AppConstant.blackColor.withOpacity(0.9),
                  fontWeight: FontWeight.w500),
            ],
          ),
          AppUtils.commonSizedBox(height: 5),
          Divider(
            color: AppConstant.greyColor.withOpacity(0.3),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: EdgeInsets.only(right: 5),
                // padding: EdgeInsets.all(18),
                padding: EdgeInsets.all(10),
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey.withOpacity(0.3),
                  border:
                      Border.all(color: Colors.red.withOpacity(0.7), width: 1),
                ),
                child: Center(
                  child: AppUtils.commonAssetImageWidget(
                      path: profileImage,
                      boxFit: BoxFit.cover,
                      iconColor: AppConstant.appPrimaryColor,
                      height: 25,
                      width: 25),
                ),
              ),
              AppUtils.commonSizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppUtils.commonTextWidget(
                    text: titleText ?? "",
                    fontWeight: FontWeight.w500,
                    textColor: Colors.black,
                    letterSpacing: 0.3,
                    fontSize: 12,
                  ),
                  AppUtils.commonTextWidget(
                    text: subTitle ?? "",
                    fontWeight: FontWeight.w400,
                    textColor: Colors.black.withOpacity(0.7),
                    letterSpacing: 0.0,
                    fontSize: 10,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
