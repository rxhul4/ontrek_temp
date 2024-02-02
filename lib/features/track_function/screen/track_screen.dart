import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:ontrek/core/common_widgets/textfield_widget.dart';
import 'package:ontrek/core/utils/app_constant.dart';
import 'package:ontrek/core/utils/App_utils.dart';
import 'package:ontrek/features/salesman_tracker/salesman_tracker.dart';

import '../../../core/utils/image_path.dart';

class TrackScreen extends StatefulWidget {
  ScrollController? scrollController;

  TrackScreen({super.key, this.scrollController});

  @override
  State<TrackScreen> createState() => _TrackScreenState();
}

class _TrackScreenState extends State<TrackScreen> {
  DraggableScrollableController draggableScrollableController =
      DraggableScrollableController();
  bool isSearchVisible = false;

  @override
  Widget build(BuildContext context) {
    return Animate(
      effects: [
        ScaleEffect(
            curve: Curves.ease,
            begin: Offset(0, -1),
            duration: Duration(milliseconds: 300)),
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
                            onTap: () {},
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              isSearchVisible ? searchWidget() : SizedBox(),
              GridView.builder(
                itemCount: 50,
                shrinkWrap: true,
                // controller: widget.scrollController,
                physics: const NeverScrollableScrollPhysics(),
                padding: AppUtils.edgeInsetsAll(allPadding: 10),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4, childAspectRatio: 4 / 4.5),
                itemBuilder: (BuildContext context, int index) {
                  return saleMenList(index);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  TextEditingController searchController = TextEditingController();
  Widget searchWidget() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: AppTextField(
        controller: searchController,
        onChanged: (p0) {

        },
        hintText: "Search",
        cursorColor: AppConstant.blackColor.withOpacity(0.9),
        allBorderRadius: 10,
        fillColor: AppConstant.whiteColor,
        suffixIcon: InkWell(
          onTap: () {
            setState(() {
              isSearchVisible = false;
            });
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

  Widget saleMenList(int index) {
    return AppUtils.commonInkWell(
      onTap: () {
        print("index ${index}");
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SaleManTracker(index: index),
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
              text: 'You', textColor: AppConstant.blackColor, fontSize: 11),
          AppUtils.commonTextWidget(
              text: 'Last week', textColor: Colors.cyan, fontSize: 9),
        ],
      ),
    );
  }
}
