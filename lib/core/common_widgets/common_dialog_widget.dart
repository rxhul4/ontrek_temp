import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'package:ontrek/core/utils/App_utils.dart';
import 'package:ontrek/core/utils/app_constant.dart';
import 'package:ontrek/features/check_out/model/get_visit_note_model.dart';
import 'package:ontrek/features/check_out/provider/check_out_form_provider.dart';
import 'package:provider/provider.dart';

class CustomNoteDialog extends StatefulWidget {
  String? eventId;

  CustomNoteDialog({Key? key, this.eventId}) : super(key: key);

  @override
  State<CustomNoteDialog> createState() => _CustomNoteDialogState();
}

class _CustomNoteDialogState extends State<CustomNoteDialog> {
  GetVisitNoteModel? getVisitNotesModel;
 late  CheckOutProvider checkOutProvider;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      checkOutProvider = Provider.of<CheckOutProvider>(context, listen: false);
      callGetVisitNoteApi();
    });
  }
   callGetVisitNoteApi(){
    checkOutProvider.apiCallGetVisitNote(trackingEventId: widget.eventId).then((value) {
      getVisitNotesModel = value;
    });
}


  @override
  Widget build(BuildContext context) {
    checkOutProvider = Provider.of<CheckOutProvider>(context);
    return AlertDialog(
      backgroundColor: AppConstant.whiteColor,
      contentPadding: AppUtils.edgeInsetsAll(allPadding: 0),
      insetPadding:
      AppUtils.edgeInsetsOnly(top: 100, bottom: 100, right: 0, left: 0),
      titlePadding: AppUtils.edgeInsetsAll(allPadding: 0),
      content: Container(
          padding: AppUtils.edgeInsetsAll(allPadding: 8),
          width: MediaQuery.of(context).size.width - 30,
          decoration: AppUtils.commonBoxDecoration(
              color:  AppConstant.whiteColor,
              borderRadius: AppUtils.borderRadiusAll(raduis: 15)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  AppUtils.commonSizedBox(height: 60, width: 60),
                  AppUtils.commonTextWidget(text: "Notes"),
                  AppUtils.commonInkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: AppUtils.commonContainer(
                      padding: const EdgeInsets.all(14),
                      height: 60,
                      width: 60,
                      child: Icon(Icons.close),
                    ),
                  ),
                ],
              ),
              checkOutProvider.isFetching
                  ? Padding(padding: AppUtils.edgeInsetsOnly(top: 50,bottom: 100),child: AppUtils.loaderWidget(),)
                  : checkOutProvider.getVisitNoteModel?.data == null || (checkOutProvider.getVisitNoteModel?.data?.length ?? 0) <= 0
                  ? AppUtils.commonNoDataFound()
                  :
              Column(
                children: [
                  AppUtils.commonContainer(
                      padding:
                      EdgeInsets.all(15),
                      height: 150,
                      width: 150,
                      decoration: AppUtils
                          .commonBoxDecoration(
                        color: AppConstant
                            .greyWithShade,
                        borderRadius:
                        BorderRadius
                            .circular(10),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: CachedNetworkImage(
                          height: 150,
                          width: 200,
                          imageUrl: getVisitNotesModel?.data?.first.picturePath ?? "",
                          imageBuilder: (context, imageProvider) =>
                              Container(
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                      image: imageProvider,
                                      fit: BoxFit.cover),
                                ),
                              ),
                          placeholder: (context, url) =>  Center(
                              child: AppUtils.loaderWidget(color: AppConstant.appPrimaryColor)),
                          errorWidget: (context, url, error) =>
                              Icon(Icons.image,
                                  size: 40,
                                  color: AppConstant.appPrimaryColor),
                        ),
                      )
                  ),
                  AppUtils.commonSizedBox(height: 20),
                  Divider(
                    color: AppConstant.greyColor.withOpacity(0.3),
                    indent: 10,
                    endIndent: 10,
                  ),
                  AppUtils.commonSizedBox(height: 20),
                  commonRows(leftText: "Company Name",
                      rightText: getVisitNotesModel?.data?.first.companyName ?? ""),
                  AppUtils.commonSizedBox(height: 10),
                  commonRows(leftText: "Customer Name",
                      rightText: getVisitNotesModel?.data?.first.customerName ?? ""),
                  AppUtils.commonSizedBox(height: 10),
                  commonRows(leftText: "Customer Number",
                      rightText: getVisitNotesModel?.data?.first.customerPhoneNo ?? ""),
                  AppUtils.commonSizedBox(height: 10),
                  commonRows(leftText: "Visit Type",
                      rightText: getVisitNotesModel?.data?.first.visitTypeValue ?? ""),
                  AppUtils.commonSizedBox(height: 10),
                  commonRows(leftText: "Date",
                      rightText: AppUtils.getDate(date: getVisitNotesModel?.data?.first.createdOn ?? "", format: "dd MMM yyyy hh:mm a")),
                  AppUtils.commonSizedBox(height: 10),
                  commonRows(
                      leftText: "Visit Description",
                     rightText:  getVisitNotesModel?.data?.first.visitDiscussion ?? ""),
                  AppUtils.commonSizedBox(height: 30),
                ],
              ),
            ],
          )),
    );
  }

  commonRows({String? leftText, String? rightText}) {
    return Padding(
      padding: const EdgeInsets.only(left: 10),
      child: Row(
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
      ),
    );
  }
}
