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



class TrackScreen extends StatefulWidget {
  ScrollController? scrollController;

  TrackScreen({super.key, this.scrollController});

  @override
  State<TrackScreen> createState() => _TrackScreenState();
}

class _TrackScreenState extends State<TrackScreen> {
  DraggableScrollableController draggableScrollableController = DraggableScrollableController();
  ScrollController gridScrollController = ScrollController();
  bool isSearchVisible = false;


  GetSalesMenListModel? getSalesMenListModel;


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final getMdl = Provider.of<SalesMenListProvider>(context, listen: false);
      callGetSalesManListApi(getMdl,"");
    });
  }



  callGetSalesManListApi(SalesMenListProvider getMdl,String? fullName) {
    getMdl.apiCallGetSalesManList(eventDate: AppUtils.dateFormat(dateFormat: "yyyy-MM-dd", date: DateTime.now()),fullName: fullName)
        .then((value) {
      getSalesMenListModel = value;
      if (getSalesMenListModel?.code != 200) {
        openDialogFnc(getSalesMenListModel?.message ?? "");
      }
    });
  }



  @override
  Widget build(BuildContext context) {
    final getMdl = Provider.of<SalesMenListProvider>(context);
    return Animate(
      effects: [
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
        child: SingleChildScrollView(
          controller: widget.scrollController,
          physics: /*widget.scrollController?.position.pixels == 1 ? NeverScrollableScrollPhysics() :*/ AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              AppUtils.commonContainer(
                decoration: AppUtils.commonBoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      width: 1,
                      color: AppConstant.greyColor.withOpacity(0.3),
                    ),
                  ),
                  borderRadius:
                  AppUtils.borderRadiousonly(topleft: 18, topright: 18),
                  color: Colors.white,
                ),
                child: Padding(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Column(
                    children: [
                      AppUtils.commonContainer(
                        width: 30,
                        height: 5,
                        decoration: AppUtils.commonBoxDecoration(
                            color: AppConstant.greyColor.withOpacity(0.3),
                            borderRadius:
                            AppUtils.borderRadiusAll(raduis: 12)),
                      ),
                      Row(
                        children: [
                          AppUtils.commonContainer(
                              height: 45,
                              width: 45,
                              decoration: AppUtils.commonBoxDecoration(
                                shape: BoxShape.circle,
                                border:
                                Border.all(color: Colors.grey, width: 1.2),
                              ),
                              child:
                              Icon(Icons.location_pin, color: Colors.cyan)),
                          AppUtils.commonSizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                AppUtils.commonTextWidget(
                                  text: "Track",
                                  fontWeight: FontWeight.w600,
                                  textColor: AppConstant.blackColor,
                                  letterSpacing: 0.2,
                                  fontSize: 15,
                                ),
                                AppUtils.commonTextWidget(
                                  text: "Select a user to locate",
                                  fontWeight: FontWeight.w400,
                                  textColor:
                                  AppConstant.blackColor.withOpacity(0.3),
                                  letterSpacing: 0,
                                  fontSize: 13,
                                ),
                              ],
                            ),
                          ),
                          commonIconWidget(
                            iconData: Icons.search,
                            iconColor: isSearchVisible
                                ? AppConstant.greyColor
                                : AppConstant.blackColor.withOpacity(0.6),
                            onTap: () {
                              setState(() {
                                isSearchVisible = true;
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
                      ),
                    ],
                  ),
                ),
              ),

    // getMdl.isFetching || getMdl.getSalesMenListModel?.data == null ?   Padding(
    //   padding: const EdgeInsets.only(top: 100),
    //   child: Center(child: CircularProgressIndicator(color: AppConstant.blueColor,)),
    // ) :(getMdl.getSalesMenListModel?.data?.length ?? 0) <= 0 ? AppUtils.commonNoDataFound(onPressed: () {
    //   callGetSalesManListApi(getMdl);
    // }) :
              isSearchVisible ? searchWidget(getMdl) : SizedBox(),
              getMdl.isFetching ? Padding(
                padding: const EdgeInsets.only(top: 100),
                child: Center(child: CircularProgressIndicator(color: AppConstant.blueColor,))) :(getMdl.getSalesMenListModel?.data?.length ?? 0) <= 0?Padding(
                  padding: const EdgeInsets.only(top: 80),
                  child: AppUtils.commonNoDataFound(onPressed: () {
                            callGetSalesManListApi(getMdl,"");
                          }),
                )
                      : GridView.builder(
                itemCount: getMdl.getSalesMenListModel?.data?.length ?? 0,
                shrinkWrap: true,
                physics: widget.scrollController?.position.pixels == 1 ? AlwaysScrollableScrollPhysics() : NeverScrollableScrollPhysics(),
                padding: AppUtils.edgeInsetsAll(allPadding: 10),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4, childAspectRatio: 4 / 4.5),
                itemBuilder: (BuildContext context, int index) {
                  return  saleMenList(index, getMdl.getSalesMenListModel?.data,);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool isRefreshing = false;
  refresh(SalesMenListProvider getMdl)async{
    callGetSalesManListApi(getMdl,"");
  }

  TextEditingController searchController = TextEditingController();
  Widget searchWidget(getMdl) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: AppTextField(
        controller: searchController,
        onChanged: (value) {
          callGetSalesManListApi(getMdl,value ?? "");
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
            });
            callGetSalesManListApi(getMdl, "");
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

  Widget saleMenList(int index, List<Data>? getSalesMenListModelData) {
    return AppUtils.commonInkWell(
      onTap: () {
        print("index ${index}");
        print("phone number ${getSalesMenListModelData?[index].phoneNo}");
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SaleManTracker(index: index,name: getSalesMenListModelData?[index].fullName,userUid: getSalesMenListModelData?[index].userUid,phoneNumber: getSalesMenListModelData?[index].phoneNo),
            ));
      },
      child: Column(
        children: [
          AppUtils.commonContainer(
              width: 60,
              height: 60,
              decoration: AppUtils.commonBoxDecoration(
                  shape: BoxShape.circle,
                  border:
                  Border.all(color: AppConstant.greyColor.withOpacity(0.5)),
                  color: AppConstant.greyColor.withOpacity(0.3)),
              child: Icon(
                Icons.person,
                color: AppConstant.blackColor,
                size: 24,
              )),
          AppUtils.commonSizedBox(height: 5),
          AppUtils.commonTextWidget(
              text: /*userList[index].name*/ getSalesMenListModelData?[index].fullName ?? "", textColor: AppConstant.blackColor, fontSize: 11),
          // AppUtils.commonTextWidget(
          //     text: 'Last week', textColor: Colors.cyan, fontSize: 9),
        ],
      ),
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
                    textColor: AppConstant.blueColor,
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