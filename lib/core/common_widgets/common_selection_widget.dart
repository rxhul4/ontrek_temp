import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ontrek/core/common_widgets/app_scaffold.dart';
import 'package:ontrek/core/common_widgets/textfield_widget.dart';
import 'package:ontrek/core/utils/App_utils.dart';
import 'package:ontrek/core/utils/app_constant.dart';

class CommonSelectionWidget extends StatefulWidget {
  const CommonSelectionWidget({super.key});

  @override
  State<CommonSelectionWidget> createState() => _CommonSelectionWidgetState();
}

class _CommonSelectionWidgetState extends State<CommonSelectionWidget> {
  TextEditingController searchController = TextEditingController();



  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
        appBar: AppUtils.commonAppBar(
            context: context,
            title: "Choose Country",
            isBack: true,
            isBorder: true),
        body: Padding(
          padding: const EdgeInsets.only(left: 15, right: 15),
          child: Column(
            children: [
              AppUtils.commonSizedBox(height: 20),
              searchWidget(),
              AppUtils.commonSizedBox(height: 20),
              Expanded(
                  child: ListView.builder(
                padding: const EdgeInsets.only(bottom: 30),
                physics: const BouncingScrollPhysics(),
                itemCount: 30,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      print("index$index");
                    },
                    child: AppUtils.commonContainer(
                      padding: const EdgeInsets.only(top: 5, bottom: 5),
                      decoration: BoxDecoration(
                        border: Border(
                          top: index == 0
                              ? BorderSide(
                                  width: 0.5, color: Colors.grey.shade400)
                              : BorderSide.none,
                          bottom: BorderSide(
                              width: 0.5, color: Colors.grey.shade400),
                        ),
                      ),
                      child: CupertinoListTile(
                          leadingToTitle: 0,
                          leadingSize: 0,
                          padding: EdgeInsets.zero,
                          title: AppUtils.commonTextWidget(
                              text: "data",
                              textColor:
                                  AppConstant.blackColor.withOpacity(0.7))),
                    ),
                  );
                },
              ))
            ],
          ),
        ));
  }

  Widget searchWidget() {
    return AppTextField(
      controller: searchController,
      onChanged: (value) {},
      hintText: "Search",
      prefixIcon: Icon(Icons.search),
      cursorColor: AppConstant.appPrimaryColor.withOpacity(0.9),
      allBorderRadius: 8,
      fillColor: AppConstant.whiteColor,
      hintTextColor: AppConstant.greyColor.withOpacity(0.5),
    );
  }
}
