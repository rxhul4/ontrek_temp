import 'package:flutter/material.dart';
import 'package:ontrek/core/common_widgets/app_scaffold.dart';
import 'package:ontrek/core/utils/app_constant.dart';
import 'package:ontrek/core/utils/App_utils.dart';
import 'package:ontrek/core/utils/image_path.dart';
import 'package:ontrek/features/view_task/model/get_task_by_id_model.dart';
import 'package:ontrek/features/view_task/provider/view_task_provider.dart';
import 'package:provider/provider.dart';

class ViewTaskScreen extends StatefulWidget {
  String? taskFormId;

  ViewTaskScreen({super.key, this.taskFormId});

  @override
  State<ViewTaskScreen> createState() => _ViewTaskScreenState();
}

class _ViewTaskScreenState extends State<ViewTaskScreen> {
  late ViewTaskProvider viewTaskProvider;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      viewTaskProvider = Provider.of<ViewTaskProvider>(context, listen: false);
      viewTaskProvider.apiCallGetSalesManList(taskFormId: widget.taskFormId);
    });
  }

  @override
  Widget build(BuildContext context) {
    viewTaskProvider = Provider.of<ViewTaskProvider>(context);
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
          title: Row(
            children: [
              Expanded(
                  child: AppUtils.commonTextWidget(
                      text: viewTaskProvider.getTaskById?.data?.taskTitle ?? "",
                      textColor: AppConstant.blackColor.withOpacity(0.7),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.1,
                      overflow: TextOverflow.ellipsis)),
            ],
          ),
          actions: [
            GestureDetector(
              onTap: () {
                print("you Have code About Refresh");
                viewTaskProvider.apiCallGetSalesManList(taskFormId: widget.taskFormId);
              },
              child: Icon(
                Icons.repeat,
                color: AppConstant.blackColor.withOpacity(0.7),
              ),
            ),
            AppUtils.commonSizedBox(width: 20),
          ],
          centerTitle: false,
        ),
        body: viewTaskProvider.isFetching ? AppUtils.loaderWidget() : SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AppUtils.commonContainer(
                width: double.infinity,
                margin: const EdgeInsets.only(left: 10, right: 10, top: 20),
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
                              Icons.person,
                              color: Colors.orangeAccent,
                              size: 18,
                            ),
                            AppUtils.commonSizedBox(width: 5),
                            AppUtils.commonTextWidget(
                                text: viewTaskProvider
                                        .getTaskById?.data?.taskTitle ??
                                    "",
                                fontSize: 12,
                                textColor:
                                    AppConstant.blackColor.withOpacity(0.9),
                                fontWeight: FontWeight.w500)
                          ],
                        ),
                        Row(
                          children: [
                            const Icon(
                              Icons.av_timer_rounded,
                              color: Colors.green,
                              size: 15,
                            ),
                            AppUtils.commonSizedBox(width: 3),
                            AppUtils.commonTextWidget(
                                text: AppUtils.getDate(
                                    date: viewTaskProvider
                                            .getTaskById?.data?.createdOn ??
                                        "",
                                    format: "hh:mm a"),
                                fontSize: 12,
                                textColor:
                                    AppConstant.blackColor.withOpacity(0.9),
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
                                text: /*viewTaskProvider
                                      .getTaskById?.data?.taskTitle ??*/
                                    "Task Description",
                                fontSize: 12,
                                textColor:
                                    AppConstant.blackColor.withOpacity(0.9),
                                fontWeight: FontWeight.w500)
                          ],
                        ),
                      ],
                    ),
                    AppUtils.commonSizedBox(height: 10),
                    AppUtils.commonTextWidget(
                        text: viewTaskProvider
                                .getTaskById?.data?.taskDescription ?? "",
                        fontSize: 12,
                        textColor: AppConstant.blackColor.withOpacity(0.9),
                        fontWeight: FontWeight.w400)
                  ],
                ),
              ),
              AppUtils.taskTile(
                  date: viewTaskProvider.getTaskById?.data?.createdOn,
                  titleText: "Assigned By",
                  username: viewTaskProvider.getTaskById?.data?.createdBy),
              AppUtils.taskTile(
                  date: viewTaskProvider.getTaskById?.data?.createdOn,
                  titleText: "Assigned To",
                  username: viewTaskProvider.getTaskById?.data?.userName),

            ],
          ),
        ));
  }
}
