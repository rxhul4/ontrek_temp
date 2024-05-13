import 'package:flutter/material.dart';
import 'package:ontrek/core/common_widgets/app_scaffold.dart';
import 'package:ontrek/core/utils/app_constant.dart';
import 'package:ontrek/core/utils/App_utils.dart';
import 'package:ontrek/core/utils/image_path.dart';
import 'package:ontrek/features/check_out/model/check_out_form_model.dart';
import 'package:ontrek/features/check_out/provider/check_out_form_provider.dart';
import 'package:ontrek/features/view_task/model/get_task_by_id_model.dart';
import 'package:ontrek/features/view_task/provider/view_task_provider.dart';
import 'package:provider/provider.dart';

class ViewTaskScreen extends StatefulWidget {
  String? taskFormId;
  String? taskTitle;
  String? taskStatus;

  ViewTaskScreen({super.key, this.taskFormId, this.taskTitle, this.taskStatus});

  @override
  State<ViewTaskScreen> createState() => _ViewTaskScreenState();
}

class _ViewTaskScreenState extends State<ViewTaskScreen> {
  late ViewTaskProvider viewTaskProvider;
  String? selectedTotValue;
  String? selectedTotId;

  @override
  void initState() {
    super.initState();
    print("intaskList");
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      try {
        viewTaskProvider =
            Provider.of<ViewTaskProvider>(context, listen: false);
        await viewTaskProvider.apiCallGetTaskByID(
            taskFormId: widget.taskFormId);
        await fetchData();
      } catch (e) {
        print("Error initializing provider: $e");
      }
    });
  }

  Future<void> fetchData() async {
    final totByTypeResult = await viewTaskProvider.apiCallGetTotByType(
        groupType: AppConstant.taskStatusCode);
    if (totByTypeResult?.isError == false &&
        totByTypeResult?.isValidationFailed == false) {
      for (int i = 0;
          i < (viewTaskProvider.getTotByGroupTypeModel?.data?.length ?? 0);
          i++) {
        if (viewTaskProvider.getTotByGroupTypeModel?.data?[i].totValue ==
            viewTaskProvider.taskByIdModel?.data?.taskStatus) {
          setState(() {
            selectedTotValue =
                viewTaskProvider.getTotByGroupTypeModel?.data?[i].totValue;
          });
          print("selectedTotValue_$selectedTotValue");
        }
      }
      setState(() {
        selectedTotId =
            viewTaskProvider.getTotByGroupTypeModel?.data?.first.totId;
      });
    }
  }

  callUpdateTaskApi() async {
    viewTaskProvider
        .apiCallUpdateStatus(
      taskTitle: viewTaskProvider.taskByIdModel?.data?.taskTitle,
      taskFormId: widget.taskFormId,
      assignedBy: viewTaskProvider.taskByIdModel?.data?.assignedBy,
      assignedTo: viewTaskProvider.taskByIdModel?.data?.assignedTo,
      startDate: viewTaskProvider.taskByIdModel?.data?.startDate,
      endDate: viewTaskProvider.taskByIdModel?.data?.endDate,
      taskDescription: viewTaskProvider.taskByIdModel?.data?.taskDescription,
      totTaskStatusId: selectedTotId,
    )
        .then((value) {
      if (value?.isError == false && value?.isValidationFailed == false) {
        Navigator.pop(context);
      }else{
        if(value?.isError == true){
          AppUtils.showDialogBoxWithOneButton(
              context: context,
              text: "Something went wrong, Please try again later!");
        }
        if( value?.isValidationFailed == true){
          AppUtils.showDialogBoxWithOneButton(
              context: context,
              text: value?.message ?? "");
        }
      }
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
                    text: widget.taskTitle ?? "",
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
              viewTaskProvider.apiCallGetTaskByID(
                  taskFormId: widget.taskFormId);
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
      body: viewTaskProvider.isFetching
          ? AppUtils.loaderWidget()
          : SingleChildScrollView(
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
                        AppUtils.commonContainer(
                          width: double.infinity,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                flex: 3,
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.person,
                                      color: Colors.orangeAccent,
                                      size: 18,
                                    ),
                                    AppUtils.commonSizedBox(width: 5),
                                    Expanded(
                                      child: AppUtils.commonTextWidget(
                                        text: viewTaskProvider.taskByIdModel?.data?.taskTitle ?? "",
                                        fontSize: 12,
                                        textColor: AppConstant.blackColor.withOpacity(0.9),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: 25), // Adjust the width as per your requirement
                              Flexible(
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.av_timer_rounded,
                                      color: Colors.green,
                                      size: 15,
                                    ),
                                    AppUtils.commonSizedBox(width: 3),
                                    Expanded(
                                      child: AppUtils.commonTextWidget(
                                        text: AppUtils.getDate(
                                          date: viewTaskProvider.taskByIdModel?.data?.createdOn ?? "",
                                          format: "hh:mm a",
                                        ),
                                        fontSize: 12,
                                        textColor: AppConstant.blackColor.withOpacity(0.9),
                                        fontWeight: FontWeight.w500,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
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
                                  Icons.task_sharp,
                                  color: Colors.blue,
                                  size: 18,
                                ),
                                AppUtils.commonSizedBox(width: 5),
                                AppUtils.commonTextWidget(
                                    text: "Task Status",
                                    fontSize: 12,
                                    textColor:
                                        AppConstant.blackColor.withOpacity(0.9),
                                    fontWeight: FontWeight.w500)
                              ],
                            ),
                            AppUtils.commonContainer(
                                padding: AppUtils.edgeInsetsOnly(
                                    bottom: 3, top: 3, left: 10, right: 10),
                                decoration: AppUtils.commonBoxDecoration(
                                    borderRadius: BorderRadius.circular(6),
                                    color: AppUtils.switchCaseForTaskStatus(
                                        viewTaskProvider.taskByIdModel?.data
                                                ?.taskStatus ??
                                            "")),
                                child: AppUtils.commonTextWidget(
                                    text: viewTaskProvider
                                            .taskByIdModel?.data?.taskStatus ??
                                        "",
                                    fontWeight: FontWeight.w400,
                                    textColor: AppConstant.whiteColor,
                                    fontSize: 10))
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
                                    text: /* viewTaskProvider
                                      .taskByIdModel?.data?.taskTitle ??*/
                                        "Task Description",
                                    fontSize: 12,
                                    textColor:
                                        AppConstant.blackColor.withOpacity(0.9),
                                    fontWeight: FontWeight.w500)
                              ],
                            ),
                          ],
                        ),
                        AppUtils.commonSizedBox(height: 8),
                        AppUtils.commonTextWidget(
                            text: viewTaskProvider
                                    .taskByIdModel?.data?.taskDescription ??
                                "",
                            fontSize: 12,
                            textColor: AppConstant.blackColor.withOpacity(0.9),
                            fontWeight: FontWeight.w400),
                      ],
                    ),
                  ),
                  AppUtils.taskTile(
                      date: viewTaskProvider.taskByIdModel?.data?.createdOn,
                      titleText: "Assigned By",
                      username:
                          viewTaskProvider.taskByIdModel?.data?.createdBy),
                  AppUtils.taskTile(
                      date: viewTaskProvider.taskByIdModel?.data?.createdOn,
                      titleText: "Assigned To",
                      username: viewTaskProvider.taskByIdModel?.data?.userName),
                  viewTaskProvider.isFetching ? AppUtils.loaderWidget(color: Colors.black,): viewTaskProvider.getTotByGroupTypeModel?.data == null ||
                          (viewTaskProvider
                                      .getTotByGroupTypeModel?.data?.length ??
                                  0) <=
                              0
                      ? AppUtils.commonSizedBox()
                      : AppUtils.commonContainer(
                          width: double.infinity,
                          margin: const EdgeInsets.only(
                              left: 10, right: 10, top: 20),
                          padding: const EdgeInsets.only(
                              left: 15, right: 15, top: 20, bottom: 20),
                          decoration: BoxDecoration(
                              color: AppConstant.whiteColor,
                              borderRadius:
                                  AppUtils.borderRadiusAll(raduis: 10),
                              boxShadow: [
                                BoxShadow(
                                    color:
                                        AppConstant.greyColor.withOpacity(0.3),
                                    blurRadius: 8,
                                    blurStyle: BlurStyle.solid,
                                    spreadRadius: 0.8),
                              ]),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.task,
                                    color: Colors.blue,
                                    size: 18,
                                  ),
                                  AppUtils.commonSizedBox(width: 5),
                                  AppUtils.commonTextWidget(
                                      text: "Update Status",
                                      fontSize: 12,
                                      textColor: AppConstant.blackColor
                                          .withOpacity(0.9),
                                      fontWeight: FontWeight.w500),
                                ],
                              ),
                              AppUtils.commonSizedBox(height: 5),
                              Divider(
                                color: AppConstant.greyColor.withOpacity(0.3),
                              ),
                              radioWidget(),
                              Divider(
                                color: AppConstant.greyColor.withOpacity(0.3),
                              ),
                              AppUtils.commonSizedBox(height: 5),
                              Align(
                                alignment: Alignment.centerRight,
                                child: AppUtils.commonElevatedBtn(
                                  onPressed: () async {
                                    await callUpdateTaskApi();
                                  },
                                  isLoading: viewTaskProvider.isLoading,
                                  borderRadiusAll: 10,
                                  text: "Submit",
                                  height: 40,
                                  width: double.infinity,
                                  bgColor: AppConstant.appPrimaryColor,
                                ),
                              )
                            ],
                          ),
                        ),
                  AppUtils.commonSizedBox(height: 10),
                ],
              ),
            ),
    );
  }

  radioWidget() {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2,childAspectRatio: 3/1),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: viewTaskProvider.getTotByGroupTypeModel?.data?.length,
      itemBuilder: (context, index) {
        return RadioListTile(
          contentPadding: AppUtils.edgeInsetsAll(allPadding: 0),
          title: AppUtils.commonContainer(
            height: 25,
            margin: const EdgeInsets.only(right: 30),
            decoration: AppUtils.commonBoxDecoration(
                borderRadius: BorderRadius.circular(6),
                color: AppUtils.switchCaseForTaskStatus(viewTaskProvider
                        .getTotByGroupTypeModel?.data?[index].totValue ??
                    "")),
            child: Center(
              child: AppUtils.commonTextWidget(
                  text: viewTaskProvider
                          .getTotByGroupTypeModel?.data?[index].totValue ??
                      "",
                  fontWeight: FontWeight.w400,
                  textColor: AppConstant.whiteColor,
                  fontSize: 10),
            ),
          ),
          activeColor: AppConstant.appPrimaryColor,
          value: viewTaskProvider.getTotByGroupTypeModel?.data?[index].totValue,
          groupValue: selectedTotValue,
          onChanged: (value) {
            setState(() {
              selectedTotValue = viewTaskProvider
                  .getTotByGroupTypeModel?.data?[index].totValue;
              selectedTotId =
                  viewTaskProvider.getTotByGroupTypeModel?.data?[index].totId;
              print("selectedTotId $selectedTotId");
              print("selectedTotValue $selectedTotValue");
            });
          },
        );
      },
    );
  }
}
