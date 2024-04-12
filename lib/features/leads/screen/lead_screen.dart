import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ontrek/core/common_widgets/textfield_widget.dart';
import 'package:ontrek/core/utils/App_utils.dart';
import 'package:ontrek/core/utils/app_constant.dart';
import 'package:ontrek/core/utils/image_path.dart';
import 'package:ontrek/features/add_lead/screen/add_lead_screen.dart';
import 'package:ontrek/features/leads/provider/lead_provider.dart';
import 'package:provider/provider.dart';

class LeadScreen extends StatefulWidget {
  const LeadScreen({super.key});

  @override
  State<LeadScreen> createState() => _LeadScreenState();
}

class _LeadScreenState extends State<LeadScreen> {
  late LeadProvider leadProvider;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final leadProvider = Provider.of<LeadProvider>(context, listen: false);

      callGetAllLeadApi(leadProvider);
    });
  }

  callGetAllLeadApi(LeadProvider leadProvider) {
    if (!mounted) {}
    leadProvider.apiCallGetAllLead();
  }

  @override
  Widget build(BuildContext context) {
    leadProvider = Provider.of<LeadProvider>(context);
    double height = MediaQuery
        .of(context)
        .size
        .height;
    double width = MediaQuery
        .of(context)
        .size
        .width;
    return AppUtils.commonSlidePanel(
      panelSnapping: false,
      maxHeight: height,
      minHeight: height * 0.09,
      controller: leadProvider.panelController,
      isDraggable: false,
      snapPoint: 0.35,
      panelBuilder: (p0) {
        return Column(
          children: [
            AppUtils.buildHeader(
              height: height,
              width: width,
              actionWidget: [
                commonIconWidget(
                  iconData: Icons.search,
                  onTap: () {
                    if (!mounted) {}
                    leadProvider.showAndHideSearchWidget(true);
                  },
                ),
                AppUtils.commonSizedBox(width: 10),
                commonIconWidget(
                  iconData: Icons.add,
                  size: 30,
                  onTap: () {
                    Navigator.push(
                      context,
                      CupertinoPageRoute(
                        builder: (context) => AddLeadScreen(),
                      ),
                    ).then((value) {
                      leadProvider.apiCallGetAllLead();
                    });
                  },
                ),
                AppUtils.commonSizedBox(width: 10),
                commonIconWidget(
                    iconData: Icons.repeat, onTap: leadProvider.refresh),
              ],
              title: "Lead",
              subTitle: "Create and manage a lead",
              backgroundColor: AppConstant.whiteColor,
              leadingImage: leadIconPath,
            ),
            leadProvider.isSearchVisible ?? false
                ? searchWidget(leadProvider)
                : const SizedBox(),
            Expanded(
              child: leadProvider.isFetching
                  ? Center(
                child: AppUtils.loaderWidget(),
              )
                  : leadProvider.getAllLeadModel?.data == null ||
                  (leadProvider.getAllLeadModel?.data?.length ?? 0) <= 0
                  ? AppUtils.commonNoDataFound(
                onPressed: () {
                  if (!mounted) {}
                  callGetAllLeadApi(leadProvider);
                },
              )
                  : ListView.builder(
                controller: p0,
                physics: const BouncingScrollPhysics(),
                shrinkWrap: true,
                itemCount: leadProvider.getAllLeadModel?.data?.length,
                padding: const EdgeInsets.only(bottom: 100),
                itemBuilder: (context, index) {
                  return AppUtils.commonContainer(
                    margin: AppUtils.edgeInsetsOnly(
                      top: 30,
                      right: 10,
                      left: 10,
                    ),
                    padding: AppUtils.edgeInsetsOnly(
                        left: 10, right: 10, top: 10, bottom: 10),
                    width: double.infinity,
                    decoration: AppUtils.commonBoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: AppConstant.whiteColor,
                        boxShadow: [
                          BoxShadow(
                              color: AppConstant.greyColor
                                  .withOpacity(0.2),
                              blurRadius: 8,
                              blurStyle: BlurStyle.solid,
                              spreadRadius: 0.1),
                        ]),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                                child: AppUtils.commonTextWidget(
                                    text: leadProvider
                                        .getAllLeadModel
                                        ?.data?[index]
                                        .companyName ??
                                        "",
                                    // "LL1000001 - lead customer One ",
                                    textColor: AppConstant.blackColor
                                        .withOpacity(0.9),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    overflow: TextOverflow.ellipsis,
                                    letterSpacing: -0.1)),
                            AppUtils.commonSizedBox(width: 15),
                            commonIconWidget(
                                onTap: () {
                                  AppUtils.showDialogBoxWithTwoButton(
                                      context: context,
                                      titleText: "Call",
                                      text: "Are you sure to call ${leadProvider
                                          .getAllLeadModel?.data?[index]
                                          .customerName}?",
                                    onSuccessString: "Call",
                                    onCancelString: "Cancel",
                                    onSuccess: () {
                                      AppUtils.launchToBrowser(
                                          Uri.parse(
                                              "tel:${leadProvider.getAllLeadModel?.data?[index].customerPhone}"));
                                    },
                                    onCancel: () {

                                    },
                                  );
                                },
                                iconData: Icons.call,
                                iconColor: AppConstant.blackColor
                                    .withOpacity(0.7),
                                size: 20),
                            AppUtils.commonSizedBox(width: 15),
                            commonIconWidget(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      CupertinoPageRoute(
                                        builder: (context) =>
                                            AddLeadScreen(
                                                isEdit: true,
                                                leadId: leadProvider
                                                    .getAllLeadModel
                                                    ?.data?[index]
                                                    .leadId),
                                      )).then((value) async {
                                    await callGetAllLeadApi(leadProvider);
                                  });
                                },
                                iconData: Icons.edit,
                                iconColor: AppConstant.blackColor
                                    .withOpacity(0.7),
                                size: 20),
                          ],
                        ),
                        AppUtils.commonSizedBox(height: 15),
                        Row(
                          mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  AppUtils.commonContainer(
                                      height: 30,
                                      width: 30,
                                      padding:
                                      AppUtils.edgeInsetsOnly(
                                          top: 5),
                                      decoration:
                                      AppUtils
                                          .commonBoxDecoration(
                                          color: AppConstant
                                              .greyColor
                                              .withOpacity(
                                              0.2),
                                          shape: BoxShape
                                              .circle),
                                      child: ClipOval(
                                          child: Column(
                                            children: [
                                              AppUtils
                                                  .commonNetworkImageWidget(
                                                  height: 25,
                                                  width: 25,
                                                  boxFit:
                                                  BoxFit.cover,
                                                  path: profileImage,
                                                  iconColor:
                                                  AppConstant
                                                      .blackColor
                                                      .withOpacity(
                                                      0.6)),
                                            ],
                                          ))),
                                  AppUtils.commonSizedBox(width: 10),
                                  Expanded(
                                      child:
                                      AppUtils.commonTextWidget(
                                          text: leadProvider
                                              .getAllLeadModel
                                              ?.data?[index]
                                              .customerName ??
                                              "",
                                          textColor: AppConstant
                                              .blackColor
                                              .withOpacity(0.5),
                                          fontWeight:
                                          FontWeight.w500,
                                          fontSize: 12,
                                          overflow: TextOverflow
                                              .ellipsis)),
                                ],
                              ),
                            ),
                            Expanded(
                              child: AppUtils.commonContainer(
                                  padding: const EdgeInsets.only(
                                      top: 5,
                                      bottom: 5,
                                      right: 3,
                                      left: 3),
                                  decoration:
                                  AppUtils.commonBoxDecoration(
                                    borderRadius:
                                    BorderRadius.circular(5),
                                    color: Colors.cyanAccent
                                        .withOpacity(0.05),
                                  ),
                                  child: Center(
                                      child: AppUtils.commonTextWidget(
                                          text: "Last updated: ${AppUtils
                                              .getDate(
                                              date: leadProvider.getAllLeadModel
                                                  ?.data?[index].modifiedOn ??
                                                  "",
                                              format: "dd MMM yyyy HH:mm a")}",
                                          // "Last updated: 17 Jan 2024 04:52 PM",
                                          textColor: Colors.cyan,
                                          fontWeight: FontWeight.w500,
                                          fontSize: 8,
                                          letterSpacing: 0,
                                          overflow: TextOverflow.ellipsis,
                                          margin: EdgeInsets.zero))),
                            )
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget commonIconWidget(
      {Function()? onTap, IconData? iconData, Color? iconColor, double? size}) {
    return InkWell(
      onTap: onTap,
      child: Icon(
        iconData,
        size: size ?? 26,
        color: iconColor ?? AppConstant.blackColor.withOpacity(0.6),
      ),
    );
  }

  Widget searchWidget(LeadProvider leadProvider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: AppTextField(
        controller: leadProvider.searchController,
        onChanged: (value) {},
        hintText: "Search",
        prefixIcon: const Icon(Icons.search),
        cursorColor: AppConstant.appPrimaryColor.withOpacity(0.9),
        allBorderRadius: 10,
        fillColor: AppConstant.whiteColor,
        suffixIcon: InkWell(
          onTap: () {
            leadProvider.showAndHideSearchWidget(false);
            leadProvider.searchController.clear();
          },
          child: const Icon(Icons.close),
        ),
        hintTextColor: AppConstant.greyColor.withOpacity(0.5),
      ),
    );
  }
}
