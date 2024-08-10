import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:ontrek/core/common_widgets/textfield_widget.dart';
import 'package:ontrek/core/services/network_repository.dart';
import 'package:ontrek/core/utils/App_utils.dart';
import 'package:ontrek/core/utils/app_constant.dart';
import 'package:ontrek/features/home/expanse/model/expense_list_model.dart';
import 'package:ontrek/features/home/expanse/provider/expense_provider.dart';
import 'package:ontrek/features/home/expanse/screen/add_expense_screen.dart';
import 'package:ontrek/features/home/leave/screen/apply_leave_screen.dart';
import 'package:provider/provider.dart';

class ExpenseScreen extends StatefulWidget {
  const ExpenseScreen({super.key});

  @override
  State<ExpenseScreen> createState() => _ExpenseScreenState();
}

class _ExpenseScreenState extends State<ExpenseScreen>
    with TickerProviderStateMixin {
  late TabController tabController;
  int selectedIndex = 0;

  late ExpenseProvider expenseProvider;
  TextEditingController approvalAmountController = TextEditingController();
  TextEditingController approvalNotesController = TextEditingController();

  final PagingController<int, ListItem> myExpenseListController =
      PagingController(firstPageKey: 1);
  final PagingController<int, ListItem> EmployeeExpenseListController =
      PagingController(firstPageKey: 1);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    tabController = TabController(length: 2, vsync: this);
    myExpenseListController.addPageRequestListener((pageKey) async {
      await myExpenseListPagingFnc(pageKey);
    });
    EmployeeExpenseListController.addPageRequestListener((pageKey) async {
      await employeeExpenseListPagingFnc(pageKey);
    });
    WidgetsBinding.instance.addPostFrameCallback(
      (_) async {
        expenseProvider = Provider.of<ExpenseProvider>(context, listen: false);
      },
    );
  }

  Future<void> myExpenseListPagingFnc(int pageKey) async {
    try {

      final newItems =
          await expenseProvider.apiCallGetMyExpenseList(pageNo: pageKey);
      bool isLastPage = (newItems?.data?.listItem?.length ?? 0) < 10;
      if (isLastPage) {
        myExpenseListController.appendLastPage(newItems?.data?.listItem ?? []);
      } else {
        final nextPageKey = pageKey + 1;
        myExpenseListController.appendPage(
            newItems?.data?.listItem ?? [], nextPageKey);
      }
    } catch (error) {
      myExpenseListController.error = error;
    }
  }

  Future<void> employeeExpenseListPagingFnc(int pageKey) async {
    try {
      final newItems =
          await expenseProvider.apiCallGetEmployeeExpenseList(pageNo: pageKey);
      bool isLastPage = (newItems?.data?.listItem?.length ?? 0) < 10;
      if (isLastPage) {
        EmployeeExpenseListController.appendLastPage(
            newItems?.data?.listItem ?? []);
      } else {
        final nextPageKey = pageKey + 1;
        EmployeeExpenseListController.appendPage(
            newItems?.data?.listItem ?? [], nextPageKey);
      }
    } catch (error) {
      EmployeeExpenseListController.error = error;
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    myExpenseListController.dispose();
    EmployeeExpenseListController.dispose();
    expenseProvider.ApprovalStatus = null;
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    expenseProvider = Provider.of<ExpenseProvider>(context);
    return Scaffold(
      backgroundColor: AppConstant.whiteColor,
      appBar: AppUtils.commonAppBar(
          context: context,
          isBorder: true,
          isBack: true,
          title: "Expense",
          isActionWidgetAvailable: true,
          actions: [
            AppUtils.commonContainer(
              color: AppConstant.whiteColor,
              padding: EdgeInsets.all(5),
              child: commonIconWidget(
                iconData: Icons.add,
                iconColor: AppConstant.appPrimaryColor,
                onTap: () {
                  Navigator.push(
                      context,
                      CupertinoPageRoute(
                        builder: (context) => AddExpenseScreen(),
                      )).then((value) {
                    selectedIndex == 0
                        ? myExpenseListController.refresh()
                        : EmployeeExpenseListController.refresh();
                  },);
                },
              ),
            ),
            AppUtils.commonSizedBox(width: 10),
            InkWell(
              onTap: () {
                _showPopupMenu(context);
              },
              child: Padding(
                padding: AppUtils.edgeInsetsOnly(right: 15),
                child: Icon(
                  Icons.more_vert,
                  color: AppConstant.appPrimaryColor,
                  size: 24,
                ),
              ),
            )
          ]),
      body: Column(
        children: [
          Expanded(
              child: TabBarView(
            physics: NeverScrollableScrollPhysics(),
            controller: tabController,
            children: [
              myExpenses(),
              employeeExpenses(),
            ],
          )),
          AppUtils.commonContainer(
            height: 50,
            margin: EdgeInsets.only(top: 0, left: 0, right: 0, bottom:  Platform.isIOS ?  15 : 00),
            decoration: AppUtils.commonBoxDecoration(
              color: AppConstant.greyColor.withOpacity(0.2),
            ),
            child: TabBar.secondary(
                onTap: (value) async {
                  setState(() {
                    selectedIndex = value;
                  });
                  selectedIndex == 0 ? myExpenseListController.refresh() :  EmployeeExpenseListController.refresh();
                },
                physics: const NeverScrollableScrollPhysics(),
                isScrollable: false,
                indicatorSize: TabBarIndicatorSize.tab,
                controller: tabController,
                // padding: AppUtils.edgeInsetsAll(allPadding: 2),
                labelColor: Colors.white,
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
                  // borderRadius: AppUtils.borderRadiusAll(raduis: 5)
                ),
                tabs: const [
                  // Tab(text: 'All'),
                  Tab(text: 'My Expenses'),
                  Tab(text: 'Employee Expenses'),
                ]),
          ),
        ],
      ),
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

  void _showPopupMenu(BuildContext context) async {
    ;
    await showMenu(
      context: context,
      position: RelativeRect.fromLTRB(20, 50, 15, 0),
      items: [
        PopupMenuItem(
          child: Text("Pending"),
          value: 1,
        ),
        PopupMenuItem(
          child: Text("Approve"),
          value: 2,
        ),
        PopupMenuItem(
          child: Text("Rejected"),
          value: 3,
        ),
      ],
      elevation: 8.0,
    ).then((value) {
      if (value != null) {
        _handleMenuItemClick(value);
      }
    });
  }

  void _handleMenuItemClick(int value) {
    String message;
    switch (value) {
      case 1:
        expenseProvider.manageApprovalStatus(null);
        selectedIndex == 0
            ? myExpenseListController.refresh()
            : EmployeeExpenseListController.refresh();
        break;
      case 2:
        expenseProvider.manageApprovalStatus(true);
        selectedIndex == 0
            ? myExpenseListController.refresh()
            : EmployeeExpenseListController.refresh();
        break;

        break;
      case 3:
        expenseProvider.manageApprovalStatus(false);
        selectedIndex == 0
            ? myExpenseListController.refresh()
            : EmployeeExpenseListController.refresh();
        break;
        break;
      default:
        message = "Unknown option";
    }
  }

  myExpenses() {
    return PagedListView<int, ListItem>(
      pagingController: myExpenseListController,
      physics: BouncingScrollPhysics(),
      padding: AppUtils.edgeInsetsOnly(bottom: 20),
      builderDelegate: PagedChildBuilderDelegate<ListItem>(

        animateTransitions: true,

        firstPageProgressIndicatorBuilder: (context) {
          return Center(
            child: AppUtils.loaderWidget(),
          );
        },
        noItemsFoundIndicatorBuilder: (context) {
          return AppUtils.commonNoDataFound(
            text: "No Data Found",
            onPressed: () {
              myExpenseListController.refresh();
            },
          );
        },
        newPageProgressIndicatorBuilder: (context) {
          return Padding(
            padding: EdgeInsets.only(top: 30),
            child: AppUtils.loaderWidget(),
          );
        },
        itemBuilder: (context, item, index) {
          return AppUtils.commonContainer(
            width: double.infinity,
            margin: const EdgeInsets.only(left: 10, right: 10, top: 20),
            padding: const EdgeInsets.only(left: 15, right: 15, top: 20, bottom: 10),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InkWell(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AppUtils.openImageDialog(
                              context: context,
                              child: CachedNetworkImage(
                                height: 350,
                                width: 350,
                                imageUrl: item.invoiceImage ?? "",
                                imageBuilder: (context, imageProvider) => Container(
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                      image: imageProvider,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                placeholder: (context, url) => Center(
                                  child: AppUtils.loaderWidget(
                                    color: AppConstant.appPrimaryColor,
                                  ),
                                ),
                                errorWidget: (context, url, error) => Icon(
                                  Icons.image,
                                  size: 40,
                                  color: AppConstant.appPrimaryColor,
                                ),
                              ),
                            );
                          },
                        );
                      },
                      child: AppUtils.commonContainer(
                        padding: AppUtils.edgeInsetsAll(allPadding: 3),
                        margin: AppUtils.edgeInsetsOnly(right: 10),
                        decoration: AppUtils.commonBoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: AppConstant.appPrimaryColor),
                          borderRadius: AppUtils.borderRadiusAll(raduis: 5),
                        ),
                        child: ClipRRect(
                          child: CachedNetworkImage(
                            height: 70,
                            width: 70,
                            imageUrl: item.invoiceImage ?? "",
                            imageBuilder: (context, imageProvider) => Container(
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: imageProvider,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            placeholder: (context, url) => Center(
                              child: AppUtils.loaderWidget(
                                color: AppConstant.appPrimaryColor,
                              ),
                            ),
                            errorWidget: (context, url, error) => Icon(
                              Icons.image,
                              size: 40,
                              color: AppConstant.appPrimaryColor,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    AppUtils.commonTextWidget(
                                      text: item.userName ?? "",
                                      fontSize: 14,
                                      textColor: AppConstant.blackColor.withOpacity(0.9),
                                      fontWeight: FontWeight.w500,
                                    ),
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        AppUtils.commonTextWidget(
                                          text: AppUtils.formatDateString(
                                              item.expenseDate ?? "", "dd-MM-yyyy"),
                                          fontSize: 10,
                                          textColor:
                                          AppConstant.blackColor.withOpacity(0.9),
                                          fontWeight: FontWeight.w400,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        AppUtils.commonSizedBox(width: 5),
                                        CircleAvatar(
                                          radius: 3,
                                          backgroundColor:
                                          AppConstant.blackColor.withOpacity(0.6),
                                        ),
                                        AppUtils.commonSizedBox(width: 5),
                                        AppUtils.commonTextWidget(
                                          text: item.submittedAmount.toString(),
                                          fontWeight: FontWeight.w400,
                                          textColor: AppConstant.blackColor.withOpacity(0.9),
                                          fontSize: 10,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              AppUtils.commonContainer(
                                padding: AppUtils.edgeInsetsOnly(
                                    bottom: 3, top: 3, left: 10, right: 10),
                                decoration: AppUtils.commonBoxDecoration(
                                  borderRadius: BorderRadius.circular(6),
                                  color: item.isApproved == null
                                      ? AppConstant.greyColor
                                      : item.isApproved == false
                                      ? Colors.red
                                      : Colors.green,
                                ),
                                child: AppUtils.commonTextWidget(
                                  text: item.isApproved == null
                                      ? "Pending"
                                      : item.isApproved == false
                                      ? "Rejected"
                                      : "Approved",
                                  fontWeight: FontWeight.w400,
                                  textColor: AppConstant.whiteColor,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                          Divider(color: AppConstant.greyColor.withOpacity(0.3)),
                          AppUtils.commonTextWidget(
                            text: "Category",
                            fontSize: 12,
                            textColor: AppConstant.blackColor.withOpacity(0.9),
                            fontWeight: FontWeight.w500,
                          ),
                          AppUtils.commonTextWidget(
                            text:
                            "${item.expenseCategoryName ?? ""}/${item.expenseSubCategoryName ?? ""}",
                            fontSize: 10,
                            textColor: AppConstant.blackColor.withOpacity(0.9),
                            fontWeight: FontWeight.w400,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Divider(color: AppConstant.greyColor.withOpacity(0.3)),
                AppUtils.commonTextWidget(
                  text: "Comment",
                  fontSize: 14,
                  textColor: AppConstant.blackColor.withOpacity(0.9),
                  fontWeight: FontWeight.w500,
                ),
                AppUtils.commonSizedBox(height: 5),
                AppUtils.commonTextWidget(
                  text: item.expenseDescription ?? "",
                  fontSize: 12,
                  textColor: AppConstant.blackColor.withOpacity(0.9),
                  fontWeight: FontWeight.w400,
                ),
              ],
            ),
          );

        },
      ),
    );
  }

  employeeExpenses() {
    return PagedListView<int, ListItem>(
        pagingController: EmployeeExpenseListController,
        physics: BouncingScrollPhysics(),
        padding: AppUtils.edgeInsetsOnly(bottom: 20),
        builderDelegate: PagedChildBuilderDelegate<ListItem>(
          noItemsFoundIndicatorBuilder: (context) {
            return AppUtils.commonNoDataFound(text: "No Data Found",onPressed: () {
              EmployeeExpenseListController.refresh();
            },);
          },
            firstPageProgressIndicatorBuilder: (context) {
          return AppUtils.loaderWidget();
        }, newPageProgressIndicatorBuilder: (context) {
          return Padding(
            padding: EdgeInsets.only(top: 30),
            child: AppUtils.loaderWidget(),
          );
        }, itemBuilder: (context, item, index) {
          return AppUtils.commonContainer(
            width: double.infinity,
            margin: const EdgeInsets.only(left: 10, right: 10, top: 20),
            padding: EdgeInsets.only(
                left: 15,
                right: 15,
                top: 20,
                bottom: item.isApproved == null ? 0 : 20),
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
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        // mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AppUtils.commonTextWidget(
                                text: item.userName ?? "",
                                fontSize: 14,
                                textColor:
                                AppConstant.blackColor.withOpacity(0.9),
                                fontWeight: FontWeight.w500,
                              ),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  AppUtils.commonTextWidget(
                                    text:
                                    AppUtils.formatDateString(
                                        item.expenseDate ?? "", "dd-MM-yyyy"),
                                    fontSize: 10,
                                    textColor:
                                    AppConstant.blackColor.withOpacity(0.9),
                                    fontWeight: FontWeight.w400,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  AppUtils.commonSizedBox(width: 5),
                                  CircleAvatar(
                                    radius: 3,
                                    backgroundColor:
                                    AppConstant.blackColor.withOpacity(0.6),
                                  ),
                                  AppUtils.commonSizedBox(width: 5),
                                  AppUtils.commonTextWidget(
                                      text: item.submittedAmount.toString(),
                                      fontWeight: FontWeight.w400,
                                      textColor: AppConstant.blackColor
                                          .withOpacity(0.9),
                                      fontSize: 10),
                                  AppUtils.commonSizedBox(width: 5),

                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                      // SizedBox(width: 40),
                      AppUtils.commonContainer(
                          padding: AppUtils.edgeInsetsOnly(
                              bottom: 3, top: 3, left: 10, right: 10),
                          decoration: AppUtils.commonBoxDecoration(
                            borderRadius: BorderRadius.circular(6),
                            color: item.isApproved == null
                                ? AppConstant.greyColor
                                : item.isApproved == false
                                ? Colors.red
                                : Colors.green,
                          ),
                          child: AppUtils.commonTextWidget(
                              text: item.isApproved == null
                                  ? "Pending"
                                  : item.isApproved == false
                                  ? "Rejected"
                                  : "Approved",
                              fontWeight: FontWeight.w400,
                              textColor: AppConstant.whiteColor,
                              fontSize: 10))
                    ],
                  ),
                ),
                AppUtils.commonSizedBox(height: 5),
                Divider(
                  color: AppConstant.greyColor.withOpacity(0.3),
                ),
                AppUtils.commonSizedBox(height: 5),

                AppUtils.commonSizedBox(width: 5),
                AppUtils.commonTextWidget(
                    text: "Category",
                    fontSize: 14,
                    textColor: AppConstant.blackColor.withOpacity(0.9),
                    fontWeight: FontWeight.w500),
                AppUtils.commonSizedBox(height: 5),
                AppUtils.commonTextWidget(
                    text: "${item.expenseCategoryName ?? ""}/${item.expenseSubCategoryName ?? ""} ",
                    fontSize: 12,
                    textColor: AppConstant.blackColor.withOpacity(0.9),
                    fontWeight: FontWeight.w400),

                Divider(
                  color: AppConstant.greyColor.withOpacity(0.3),
                ),
                AppUtils.commonTextWidget(
                    text: "Comment",
                    fontSize: 14,
                    textColor: AppConstant.blackColor.withOpacity(0.9),
                    fontWeight: FontWeight.w500),
                AppUtils.commonSizedBox(height: 5),
                AppUtils.commonTextWidget(
                    text: item.expenseDescription ?? "",
                    fontSize: 12,
                    textColor: AppConstant.blackColor.withOpacity(0.9),
                    fontWeight: FontWeight.w400),
                if (item.isApproved == null)
                  Column(
                    children: [
                      Divider(
                        color: AppConstant.greyColor.withOpacity(0.3),
                      ),
                      // AppUtils.commonSizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(
                            flex: 2,
                            child: InkWell(
                              onTap: () {
                                showDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (context) {
                                    return   AppUtils.showNotesForm(
                                    context: context,
                                    controller: approvalNotesController,
                                    title: "Reject Reason",
                                    textFieldText: "Enter Reject Reason",
                                    onSave: ()async {
                                      await expenseProvider
                                          .apiCallApplyRejectExpense(
                                        pkId: item.pkId,
                                        userId: item.userId,
                                        isApproved: false,
                                        approvedRejectedOn:
                                        DateTime.now().toString(),
                                        approvedAmount: 0,
                                        approvedNotes: approvalNotesController.text,
                                        onSuccess: () async {
                                          EmployeeExpenseListController.refresh();
                                        },

                                      );
                                    },

                                    );
                                  },
                                );
                              },
                              child: AppUtils.commonContainer(
                                padding:
                                    AppUtils.edgeInsetsOnly(top: 5, bottom: 15),
                                color: Colors.white,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.close,
                                      color: Colors.red,
                                      size: 26,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: InkWell(
                              onTap: () {
                                approvalAmountController.text =
                                    item.submittedAmount.toString();
                                approvalNotesController.clear();
                                showDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (context) {
                                    return showAmountAndNotesForm(item);
                                  },
                                );

                                // AppUtils.showDialogBoxWithTwoButton(
                                //     onSuccess: () async{
                                //
                                //     },
                                //     onCancel: () {},
                                //     context: context,
                                //     onSuccessString: "Approve",
                                //     onCancelString: "Cancel",
                                //     text:
                                //     "Do you want to approve Expense request ${myEmployeeExpenseData[index].userName} ",
                                //     titleText: "Expense Request");
                              },
                              child: AppUtils.commonContainer(
                                padding:
                                    AppUtils.edgeInsetsOnly(top: 5, bottom: 15),
                                color: Colors.white,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.check,
                                      color: Colors.green,
                                      size: 26,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    ],
                  )
              ],
            ),
          );
        }));
  }

Widget showAmountAndNotesForm(ListItem item) {
  return AlertDialog(
    backgroundColor: AppConstant.whiteColor,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
    // contentPadding: AppUtils.edgeInsetsAll(allPadding: 0),
    // insetPadding:
    // AppUtils.edgeInsetsOnly(top: 0, bottom: 0, right: 0, left: 0),
    titlePadding: AppUtils.edgeInsetsOnly(top: 30, bottom: 10),
    title: AppUtils.commonTextWidget(
        text: "Approve Amount",
        textColor: AppConstant.appPrimaryColor,
        fontWeight: FontWeight.w500,
        fontSize: 14,
        textAlign: TextAlign.center),

    content: AppUtils.commonContainer(
        width: MediaQuery.of(context).size.width - 30,
        height: MediaQuery.of(context).size.height / 5,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            AppUtils.buildCommonTextField(
                readOnly: false,
                maxLine: 1,
                text: "Enter Approval Amount",
                textInputType: TextInputType.number,
                controller: approvalAmountController),
            AppUtils.commonSizedBox(height: 10),
            AppUtils.buildCommonTextField(
                readOnly: false,
                maxLine: 1,
                text: "Enter Approval Notes",
                textInputType: TextInputType.text,
                controller: approvalNotesController)
          ],
        )),
    actionsPadding: AppUtils.edgeInsetsOnly(top: 0, bottom: 10, right: 20),
    actions: [
      TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: AppUtils.commonTextWidget(
            text: "Cancel",
            fontWeight: FontWeight.w500,
            textColor: Colors.red,
            fontSize: 14,
          )),
      TextButton(
          onPressed: () async {
            Navigator.of(context).pop();
            if (item != null) {
              if (int.parse(approvalAmountController.text) >
                  (item.submittedAmount ?? 0)) {
                AppUtils.showSnackBarWithColor(
                    message:
                        "Please check the entered amount. it should not be bigger than the listed amount",
                    context: context,
                    giveColor: Colors.red);
              } else {
                await expenseProvider.apiCallApplyRejectExpense(
                  pkId: item.pkId,
                  userId: item.userId,
                  approvedAmount: int.parse(approvalAmountController.text),
                  isApproved: true,
                  approvedNotes: approvalNotesController.text,
                  approvedRejectedOn: DateTime.now().toString(),
                  onSuccess: () async {
                    EmployeeExpenseListController.refresh();
                  },
                );
              }
            }
          },
          child: AppUtils.commonTextWidget(
            text: "Save",
            fontWeight: FontWeight.w500,
            textColor: Colors.green,
            fontSize: 14,
          ))
    ],
  );
}

// Widget showNotesForm(index, List<ListItem>? myEmployeeExpenseData) {
//   return AlertDialog(
//     backgroundColor: AppConstant.whiteColor,
//     // contentPadding: AppUtils.edgeInsetsAll(allPadding: 0),
//     // insetPadding:
//     // AppUtils.edgeInsetsOnly(top: 0, bottom: 0, right: 0, left: 0),
//     titlePadding: AppUtils.edgeInsetsOnly(top: 30, bottom: 10),
//     title: AppUtils.commonTextWidget(
//         text: "Reject Notes",
//         textColor: AppConstant.appPrimaryColor,
//         fontWeight: FontWeight.w500,
//         fontSize: 14,
//         textAlign: TextAlign.center),
//
//     content: AppUtils.commonContainer(
//         width: MediaQuery.of(context).size.width - 30,
//         height: MediaQuery.of(context).size.height / 6,
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             AppUtils.buildCommonTextField(
//                 readOnly: false,
//                 maxLine: 3,
//                 text: "Enter Reject notes",
//                 maxLength: 200,
//                 textInputType: TextInputType.text,
//                 controller: approvalNotesController)
//           ],
//         )),
//     actionsPadding: AppUtils.edgeInsetsOnly(top: 0, bottom: 10, right: 20),
//     actions: [
//       TextButton(
//           onPressed: () {
//             Navigator.of(context).pop();
//           },
//           child: AppUtils.commonTextWidget(
//             text: "Cancel",
//             fontWeight: FontWeight.w500,
//             textColor: Colors.red,
//             fontSize: 14,
//           )),
//       TextButton(
//           onPressed: () async {
//             Navigator.of(context).pop();
//             if (myEmployeeExpenseData != null) {
//               if (approvalNotesController.text.isEmpty) {
//                 AppUtils.showSnackBarWithColor(
//                     message: "Please Enter Reject notes",
//                     context: context,
//                     giveColor: Colors.red);
//               } else {
//                 await expenseProvider.apiCallApplyRejectLeave(
//                   pkId: myEmployeeExpenseData[index].pkId,
//                   userId: item.userId,
//                   approvedRejectedBy: userName,
//                   approvedAmount: item.submittedAmount,
//                   isApproved: true,
//                   approvedNotes: approvalNotesController.text,
//                   approvedRejectedOn: DateTime.now().toString(),
//                   onSuccess: () async {
//                     await expenseProvider.apiCallGetEmployeeExpenseList();
//                   },
//                 );
//               }
//             }
//           },
//           child: AppUtils.commonTextWidget(
//             text: "Save",
//             fontWeight: FontWeight.w500,
//             textColor: Colors.green,
//             fontSize: 14,
//           ))
//     ],
//   );
// }
}
