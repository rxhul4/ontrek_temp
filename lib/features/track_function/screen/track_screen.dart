import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:ontrek/core/common_widgets/textfield_widget.dart';
import 'package:ontrek/core/utils/app_constant.dart';
import 'package:ontrek/core/utils/App_utils.dart';
import 'package:ontrek/features/salesman_tracker/local_model.dart';
import 'package:ontrek/features/salesman_tracker/screen/salesman_tracker.dart';
import 'package:ontrek/features/track_function/model/salemen_list_model.dart';
import 'package:ontrek/features/track_function/provider/salesmen_list_provider.dart';
import 'package:provider/provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class TrackScreen extends StatefulWidget {
  ScrollController? scrollController;

  TrackScreen({super.key, this.scrollController});

  @override
  State<TrackScreen> createState() => _TrackScreenState();
}

class _TrackScreenState extends State<TrackScreen>
    with TickerProviderStateMixin {
  DraggableScrollableController draggableScrollableController =
      DraggableScrollableController();
  ScrollController gridScrollController = ScrollController();
  bool isSearchVisible = false;
  int? selectedIndex = 0;
  GetSalesMenListModel? getSalesMenListModel;
  TabController? tabController;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      panelController.animatePanelToSnapPoint(
          duration: Duration(milliseconds: 0));
      final getMdl = Provider.of<SalesMenListProvider>(context, listen: false);
      callGetSalesManListApi(getMdl, "");
    });
    tabController = TabController(length: 3, vsync: this);
    tabController?.addListener(() {
      setState(() {
        selectedIndex = tabController?.index;
      });


    });
  }

  callGetSalesManListApi(SalesMenListProvider getMdl, String? fullName) {
    print("fromInit");

    getMdl
        .apiCallGetSalesManList(
            eventDate: AppUtils.dateFormat(
                date: DateTime.now(), dateFormat: AppConstant.dateFormat),
            filter: searchController.text.isEmpty ? "" : searchController.text  ,
            managerId: "919e3ede-00e1-4502-87f2-6b2459554c9c",
            orgId: "10bce922-213c-46dd-aa94-0c47883b76d3")
        .then((value) {
      getSalesMenListModel = value;
      if (getSalesMenListModel?.isError == false &&
          getSalesMenListModel?.isValidationFailed == false) {
      } else {
        openDialogFnc(getSalesMenListModel?.message ?? "");
      }
    });
  }

  PanelController panelController = PanelController();

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    final getMdl = Provider.of<SalesMenListProvider>(context);
    return AppUtils.commonSlidePanel(
      panelSnapping: true,
      maxHeight: height,
      minHeight: height * 0.09,
      controller: panelController,
      isDraggable: true,
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
                    iconColor: isSearchVisible
                        ? AppConstant.greyColor
                        : AppConstant.blackColor.withOpacity(0.6),
                    onTap: () {
                      setState(() {
                        print("innnnnnn");
                        print("innnnnnn");
                        isSearchVisible = true;
                        panelController.animatePanelToPosition(1.0,duration: Duration(milliseconds: 500));
                      });
                    },
                  ),
                  AppUtils.commonSizedBox(width: 10),
                  commonIconWidget(
                    iconData: Icons.repeat,
                    onTap: () {
                      refresh(getMdl);
                    },
                  ),
                ],
                title: "Track",
                subTitle: "Select a user to Locate",
                backgroundColor: AppConstant.whiteColor,
                leadingImage:
                    "https://upload.wikimedia.org/wikipedia/commons/thumb/7/74/Location_icon_from_Noun_Project.png/640px-Location_icon_from_Noun_Project.png"),
            isSearchVisible ? searchWidget(getMdl) : SizedBox(),
            AppUtils.commonContainer(
              height: 30,
              margin: EdgeInsets.only(top: 20, left: 25, right: 25, bottom: 10),
              decoration: AppUtils.commonBoxDecoration(
                color: AppConstant.greyColor.withOpacity(0.2),
                borderRadius: AppUtils.borderRadiusAll(raduis: 5),
              ),
              child: TabBar.secondary(
                  physics: NeverScrollableScrollPhysics(),
                  isScrollable: false,
                  indicatorSize: TabBarIndicatorSize.tab,
                  controller: tabController,
                  padding: AppUtils.edgeInsetsAll(allPadding: 2),
                  // enableFeedback: true,
                  labelColor: Colors.white,
                  onTap: (value) {
                    callGetSalesManListApi(getMdl, "");
                  },
                  unselectedLabelStyle: const TextStyle(
                    fontFamily: "Poppins",
                    letterSpacing: 0.2,
                    fontWeight: FontWeight.w400,
                    fontSize: 12,
                  ),
                  indicatorWeight: 0,
                  dividerHeight: 0,
                  labelStyle: const TextStyle(
                    fontFamily: "Poppins",
                    letterSpacing: 0.2,
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
                  automaticIndicatorColorAdjustment: true,
                  indicator: BoxDecoration(
                      color: AppConstant.appPrimaryColor,
                      borderRadius: AppUtils.borderRadiusAll(raduis: 5)),
                  tabs: const [
                    Tab(text: 'All'),
                    Tab(text: 'Present'),
                    Tab(text: 'Absent'),
                  ]),
            ),
            Expanded(
              child: TabBarView(
                physics: NeverScrollableScrollPhysics(),
                controller: tabController,
                children: <Widget>[
                  widgetList(
                      controller: p0,
                      getMdl: getMdl,
                      height: height,
                      getSalesMenListModelData: getSalesMenListModel?.data),
                  widgetList(
                      controller: p0,
                      getMdl: getMdl,
                      height: height,
                      getSalesMenListModelData: getSalesMenListModel?.data
                          ?.where((element) => element.isPresent == true)
                          .toList()),
                  widgetList(
                      controller: p0,
                      getMdl: getMdl,
                      height: height,
                      getSalesMenListModelData: getSalesMenListModel?.data
                          ?.where((element) => element.isPresent == false)
                          .toList()),
                  // getMdl.isFetching || getMdl.getSalesMenListModel?.data == null
                  //     ? Center(child: AppUtils.loaderWidget())
                  //     : (getMdl.getSalesMenListModel?.data?.length ?? 0) <= 0
                  //         ? AppUtils.commonNoDataFound(onPressed: () {
                  //             callGetSalesManListApi(getMdl, "");
                  //           })
                  //         : widgetList(
                  //             controller: p0,
                  //             getMdl: getMdl,
                  //             isAll: true,
                  //             height: height,
                  //             getSalesMenListModelData:
                  //                 getSalesMenListModel?.data),
                  // getMdl.isFetching ||
                  //         getMdl.getSalesMenListModel?.data?.where(
                  //                 (element) => element.isPresent == true) ==
                  //             null
                  //     ? Center(child: AppUtils.loaderWidget())
                  //     : (getMdl.getSalesMenListModel?.data
                  //                     ?.where((element) =>
                  //                         element.isPresent == true)
                  //                     .toList()
                  //                     .length ??
                  //                 0) <=
                  //             0
                  //         ? AppUtils.commonNoDataFound(onPressed: () {
                  //             callGetSalesManListApi(getMdl, "");
                  //           })
                  //         : widgetList(
                  //             getMdl: getMdl,
                  //             getSalesMenListModelData:
                  //                 getSalesMenListModel?.data
                  //                     ?.where(
                  //                       (element) => element.isPresent == true,
                  //                     )
                  //                     .toList(),
                  //             isAll: false,
                  //             height: height,
                  //             controller: p0),
                  // getMdl.isFetching ||
                  //         getMdl.getSalesMenListModel?.data?.where(
                  //                 (element) => element.isPresent == false) ==
                  //             null
                  //     ? Center(child: AppUtils.loaderWidget())
                  //     : (getMdl.getSalesMenListModel?.data
                  //                     ?.where((element) =>
                  //                         element.isPresent == false)
                  //                     .toList()
                  //                     .length ??
                  //                 0) <=
                  //             0
                  //         ? AppUtils.commonNoDataFound(onPressed: () {
                  //             callGetSalesManListApi(getMdl, "");
                  //           })
                  //         : widgetList(
                  //             getMdl: getMdl,
                  //             getSalesMenListModelData: getSalesMenListModel
                  //                 ?.data
                  //                 ?.where(
                  //                     (element) => element.isPresent == false)
                  //                 .toList(),
                  //             isAll: false,
                  //             height: height,
                  //             controller: p0,
                  //           ),
                ],
              ),
            ),
          ],
        );
      },
    );
    // return Animate(
    //   effects: const [
    //     SlideEffect(
    //         end: Offset(0, 0),
    //         curve: Curves.decelerate,
    //         begin: Offset(0, 1),
    //         duration: Duration(milliseconds: 600)),
    //   ],
    //   child: Container(
    //     decoration: AppUtils.commonBoxDecoration(
    //         boxShadow: [
    //           BoxShadow(
    //             color: Colors.black.withOpacity(0.15),
    //             spreadRadius: 0,
    //             blurRadius: 8,
    //             offset: Offset(0, -10), // This will create a top shadow
    //           ),
    //         ],
    //         borderRadius:
    //         AppUtils.borderRadiousonly(topright: 18, topleft: 18),
    //         color: AppConstant.whiteColor),
    //     child: SingleChildScrollView(
    //       // controller: widget.scrollController,
    //       physics: /*widget.scrollController?.position.pixels == 1 ? NeverScrollableScrollPhysics() :*/ AlwaysScrollableScrollPhysics(),
    //       child: Column(
    //         children: [
    //           AppUtils.commonContainer(
    //             decoration: AppUtils.commonBoxDecoration(
    //               border: Border(
    //                 bottom: BorderSide(
    //                   width: 1,
    //                   color: AppConstant.greyColor.withOpacity(0.3),
    //                 ),
    //               ),
    //               borderRadius:
    //               AppUtils.borderRadiousonly(topleft: 18, topright: 18),
    //               color: Colors.white,
    //             ),
    //             child: Padding(
    //               padding:
    //               const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
    //               child: Column(
    //                 children: [
    //                   AppUtils.commonContainer(
    //                     width: 30,
    //                     height: 5,
    //                     decoration: AppUtils.commonBoxDecoration(
    //                         color: AppConstant.greyColor.withOpacity(0.3),
    //                         borderRadius:
    //                         AppUtils.borderRadiusAll(raduis: 12)),
    //                   ),
    //                   Row(
    //                     children: [
    //                       AppUtils.commonContainer(
    //                           height: 45,
    //                           width: 45,
    //                           decoration: AppUtils.commonBoxDecoration(
    //                             shape: BoxShape.circle,
    //                             border:
    //                             Border.all(color: Colors.grey, width: 1.2),
    //                           ),
    //                           child:
    //                           Icon(Icons.location_pin, color: Colors.cyan)),
    //                       AppUtils.commonSizedBox(width: 10),
    //                       Expanded(
    //                         child: Column(
    //                           crossAxisAlignment: CrossAxisAlignment.start,
    //                           children: [
    //                             AppUtils.commonTextWidget(
    //                               text: "Track",
    //                               fontWeight: FontWeight.w600,
    //                               textColor: AppConstant.blackColor,
    //                               letterSpacing: 0.2,
    //                               fontSize: 15,
    //                             ),
    //                             AppUtils.commonTextWidget(
    //                               text: "Select a user to locate",
    //                               fontWeight: FontWeight.w400,
    //                               textColor:
    //                               AppConstant.blackColor.withOpacity(0.3),
    //                               letterSpacing: 0,
    //                               fontSize: 13,
    //                             ),
    //                           ],
    //                         ),
    //                       ),
    //                       commonIconWidget(
    //                         iconData: Icons.search,
    //                         iconColor: isSearchVisible
    //                             ? AppConstant.greyColor
    //                             : AppConstant.blackColor.withOpacity(0.6),
    //                         onTap: () {
    //                           setState(() {
    //                             isSearchVisible = true;
    //                           });
    //                         },
    //                       ),
    //                       AppUtils.commonSizedBox(width: 10),
    //                       commonIconWidget(
    //                         iconData: Icons.repeat,
    //                         onTap: () {
    //                           refresh(getMdl);
    //                         },
    //                       ),
    //                     ],
    //                   ),
    //                 ],
    //               ),
    //             ),
    //           ),
    //
    // // getMdl.isFetching || getMdl.getSalesMenListModel?.data == null ?   Padding(
    // //   padding: const EdgeInsets.only(top: 100),
    // //   child: Center(child: CircularProgressIndicator(color: AppConstant.appPrimaryColor,)),
    // // ) :(getMdl.getSalesMenListModel?.data?.length ?? 0) <= 0 ? AppUtils.commonNoDataFound(onPressed: () {
    // //   callGetSalesManListApi(getMdl);
    // // }) :
    //           isSearchVisible ? searchWidget(getMdl) : SizedBox(),
    //           getMdl.isFetching ? Padding(
    //             padding: const EdgeInsets.only(top: 100),
    //             child: Center(child: CircularProgressIndicator(color: AppConstant.appPrimaryColor,))) :(getMdl.getSalesMenListModel?.data?.length ?? 0) <= 0?Padding(
    //               padding: const EdgeInsets.only(top: 80),
    //               child: AppUtils.commonNoDataFound(onPressed: () {
    //                         callGetSalesManListApi(getMdl,"");
    //                       }),
    //             )
    //                   : GridView.builder(
    //             itemCount: getMdl.getSalesMenListModel?.data?.length ?? 0,
    //             shrinkWrap: true,
    //             physics: widget.scrollController?.position.pixels == 1 ? AlwaysScrollableScrollPhysics() : NeverScrollableScrollPhysics(),
    //             padding: AppUtils.edgeInsetsAll(allPadding: 10),
    //             gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
    //                 crossAxisCount: 4, childAspectRatio: 4 / 4.5),
    //             itemBuilder: (BuildContext context, int index) {
    //               return  saleMenList(index, getMdl.getSalesMenListModel?.data,);
    //             },
    //           ),
    //         ],
    //       ),
    //     ),
    //   ),
    // );
  }

  bool isRefreshing = false;

  refresh(SalesMenListProvider getMdl) async {
    callGetSalesManListApi(getMdl, "");
  }

  TextEditingController searchController = TextEditingController();

  Widget searchWidget(getMdl) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: AppTextField(
        controller: searchController,
        onChanged: (value) {
          callGetSalesManListApi(getMdl, value);
        },
        hintText: "Search",
        prefixIcon: Icon(Icons.search),
        cursorColor: AppConstant.blackColor.withOpacity(0.9),
        allBorderRadius: 10,
        fillColor: AppConstant.whiteColor,
        suffixIcon: InkWell(
          onTap: () {
            setState(() {
              isSearchVisible = false;
              searchController.clear();
            });
            callGetSalesManListApi(getMdl, searchController.text);
          },
          child: Icon(Icons.close),
        ),
        hintTextColor: AppConstant.greyColor.withOpacity(0.5),
      ),
    );
  }

  Widget commonIconWidget(
      {Function()? onTap, IconData? iconData, Color? iconColor}) {
    return InkWell(
      onTap: onTap,
      child: Icon(
        iconData,
        size: 26,
        color: iconColor ?? AppConstant.blackColor.withOpacity(0.6),
      ),
    );
  }

  Widget widgetList(
      {List<Data>? getSalesMenListModelData,
      bool? isAll,
      double? height,
      SalesMenListProvider? getMdl,
      controller}) {
    print("dataaaaaaaaaaaaa${getSalesMenListModelData?.length}");

    return Column(
      children: [
        (getMdl?.isFetching ?? false)
            ?  Padding(padding: EdgeInsets.only(top: 80),child: AppUtils.loaderWidget(),)
            : (getSalesMenListModelData?.length ?? 0) <= 0
                ? Padding(padding: EdgeInsets.only(top: 50),child: AppUtils.commonNoDataFound(
          onPressed: () {
            callGetSalesManListApi(
                getMdl ?? SalesMenListProvider(), "");
          },
        ),)
                : GridView.builder(
                    itemCount: getSalesMenListModelData?.length,
                    shrinkWrap: true,
                    controller: controller,
                    padding: EdgeInsets.only(top: 20,bottom: 80,left: 20,right: 20),
                    // padding: AppUtils.edgeInsetsOnly(
                    //     bottom: 80, top: height ?? 0 * 0.05 / 2),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 4, childAspectRatio: 4 / 4.5),
                    itemBuilder: (BuildContext context, int index) {
                      return AppUtils.commonInkWell(
                        onTap: () {
                          print("index ${index}");
                          print(
                              "phone number ${getSalesMenListModelData?[index].phoneNo}");
                          Navigator.push(
                              context,
                              CupertinoPageRoute(
                                builder: (context) => SaleManTracker(
                                    index: index,
                                    name: getSalesMenListModelData?[index]
                                        .userName,
                                    userUid:
                                        getSalesMenListModelData?[index].userId,
                                    phoneNumber:
                                        getSalesMenListModelData?[index]
                                            .phoneNo),
                              ));
                        },
                        child: Column(
                          children: [
                            AppUtils.commonContainer(
                                width: 60,
                                height: 60,
                                decoration: AppUtils.commonBoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        color: AppConstant.greyColor
                                            .withOpacity(0.5)),
                                    color:
                                        AppConstant.greyColor.withOpacity(0.3)),
                                child: Icon(
                                  Icons.person,
                                  color: AppConstant.blackColor,
                                  size: 24,
                                )),
                            AppUtils.commonSizedBox(height: 5),
                            AppUtils.commonTextWidget(
                                text: /*userList[index].name*/
                                    getSalesMenListModelData?[index].userName ??
                                        "Name",
                                textColor: AppConstant.blackColor,
                                fontSize: 11),
                            // AppUtils.commonTextWidget(
                            //     text: 'Last week', textColor: Colors.cyan, fontSize: 9),
                          ],
                        ),
                      );
                    },
                  )
      ],
    );
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
                    textColor: AppConstant.appPrimaryColor,
                    letterSpacing: 1,
                    fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
