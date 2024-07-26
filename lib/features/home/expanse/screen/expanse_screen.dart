import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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
  bool? isFiltered;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback(
      (_) async {
        expenseProvider = Provider.of<ExpenseProvider>(context, listen: false);
        await expenseProvider.apiCallGetMyExpenseList();
        isFiltered = false;
      },
    );
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
      floatingActionButton: GestureDetector(
        onTap: () {
          Navigator.push(
              context,
              CupertinoPageRoute(
                builder: (context) => AddExpenseScreen(),
              ));
        },
        child: AppUtils.commonContainer(
          margin: const EdgeInsets.only(top: 20, bottom: 60, right: 10),
          padding:
              const EdgeInsets.only(top: 13, bottom: 13, right: 30, left: 30),
          decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: AppUtils.borderRadiusAll(raduis: 10)),
          child: AppUtils.commonTextWidget(
            text: "Add",
            fontWeight: FontWeight.w400,
            textColor: AppConstant.whiteColor,
            fontSize: 12,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
                child: TabBarView(
              physics: NeverScrollableScrollPhysics(),
              controller: tabController,
              children: [
                myExpenses(expenseProvider.expenseListModel?.data?.listItem),
                employeeExpenses(
                    expenseProvider.expenseListModel?.data?.listItem),
                // allDayEndRequests(),
              ],
            )),
            AppUtils.commonContainer(
              height: 50,
              margin: EdgeInsets.only(top: 0, left: 0, right: 0, bottom: 0),
              decoration: AppUtils.commonBoxDecoration(
                color: AppConstant.greyColor.withOpacity(0.2),
              ),
              child: TabBar.secondary(
                  onTap: (value) async {
                    setState(() {
                      selectedIndex = value;
                    });
                    if (selectedIndex == 0) {
                      await expenseProvider.apiCallGetMyExpenseList();
                    } else {
                      await expenseProvider.apiCallGetEmployeeExpenseList();
                    }
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
        selectedIndex == 0
            ? expenseProvider.apiCallGetMyExpenseList(
                approvalStatus: null,
              )
            : expenseProvider.apiCallGetEmployeeExpenseList(
                approvalStatus: null,
              );
        break;
      case 2:
        selectedIndex == 0
            ? expenseProvider.apiCallGetMyExpenseList(
                approvalStatus: true,
              )
            : expenseProvider.apiCallGetEmployeeExpenseList(
                approvalStatus: true,
              );

        setState(() {
          isFiltered = true;
        });
        break;
      case 3:
        selectedIndex == 0
            ? expenseProvider.apiCallGetMyExpenseList(
                approvalStatus: false,
              )
            : expenseProvider.apiCallGetEmployeeExpenseList(
                approvalStatus: false,
              );
        setState(() {
          isFiltered = true;
        });
        break;
      default:
        message = "Unknown option";
    }
  }

  myExpenses(List<ListItem>? myExpenseData) {
    return expenseProvider.isFetching
        ? AppUtils.loaderWidget()
        : myExpenseData?.length == 0 ||
                myExpenseData == [] ||
                myExpenseData == null
            ? AppUtils.commonNoDataFound(
                text: "No Data Found",
                onPressed: () async {
                  await expenseProvider.apiCallGetMyExpenseList();
                },
              )
            : ListView.builder(
                physics: BouncingScrollPhysics(),
                shrinkWrap: true,
                itemCount: myExpenseData.length,
                padding: AppUtils.edgeInsetsOnly(
                    bottom: 20, top: 0, left: 0, right: 0),
                itemBuilder: (context, index) {
                  return AppUtils.commonContainer(
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
                                flex: 5,
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
                                        text:
                                            myExpenseData[index].userName ?? "",
                                        fontSize: 12,
                                        textColor: AppConstant.blackColor
                                            .withOpacity(0.9),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // SizedBox(width: 40),
                              // Adjust the width as per your requirement
                              Flexible(
                                flex: 2,
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.timer_outlined,
                                      color: Colors.green,
                                      size: 15,
                                    ),
                                    AppUtils.commonSizedBox(width: 3),
                                    Expanded(
                                      child: AppUtils.commonTextWidget(
                                        text: AppUtils.formatDateString(
                                            myExpenseData[index].expenseDate ??
                                                "",
                                            "dd-MM-yyyy"),
                                        fontSize: 12,
                                        textColor: AppConstant.blackColor
                                            .withOpacity(0.9),
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
                                    text: "Expense Status",
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
                                  color: myExpenseData[index].isApproved == true
                                      ? Colors.green
                                      : Colors.grey,
                                ),
                                child: AppUtils.commonTextWidget(
                                    text:
                                        myExpenseData[index].isApproved == true
                                            ? "Approved"
                                            : "Pending",
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
                                  Icons.category_rounded,
                                  color: Colors.cyan,
                                  size: 18,
                                ),
                                AppUtils.commonSizedBox(width: 5),
                                AppUtils.commonTextWidget(
                                    text: "Category",
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
                            text:
                                myExpenseData[index].expenseCategoryName ?? "",
                            fontSize: 12,
                            textColor: AppConstant.blackColor.withOpacity(0.9),
                            fontWeight: FontWeight.w400),
                        AppUtils.commonSizedBox(height: 5),
                        Divider(
                          color: AppConstant.greyColor.withOpacity(0.3),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        AppUtils.commonTextWidget(
                                            text: "Sub Category",
                                            fontSize: 12,
                                            textColor: AppConstant.blackColor
                                                .withOpacity(0.9),
                                            fontWeight: FontWeight.w500)
                                      ],
                                    ),
                                  ],
                                ),
                                AppUtils.commonSizedBox(height: 5),
                                AppUtils.commonTextWidget(
                                    text: myExpenseData[index]
                                            .expenseSubCategoryName ??
                                        "",
                                    fontSize: 12,
                                    textColor:
                                        AppConstant.blackColor.withOpacity(0.9),
                                    fontWeight: FontWeight.w400),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        AppUtils.commonTextWidget(
                                            text: "Expanse Amount",
                                            fontSize: 12,
                                            textColor: AppConstant.blackColor
                                                .withOpacity(0.9),
                                            fontWeight: FontWeight.w500)
                                      ],
                                    ),
                                  ],
                                ),
                                AppUtils.commonSizedBox(height: 5),
                                AppUtils.commonTextWidget(
                                    text: myExpenseData[index]
                                        .submittedAmount
                                        .toString(),
                                    fontSize: 12,
                                    textColor:
                                        AppConstant.blackColor.withOpacity(0.9),
                                    fontWeight: FontWeight.w400),
                              ],
                            ),
                          ],
                        ),
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
                                    text: "Comment",
                                    fontSize: 12,
                                    textColor:
                                        AppConstant.blackColor.withOpacity(0.9),
                                    fontWeight: FontWeight.w500)
                              ],
                            ),
                          ],
                        ),
                        AppUtils.commonSizedBox(height: 5),
                        AppUtils.commonTextWidget(
                            text: myExpenseData[index].expenseDescription ?? "",
                            fontSize: 12,
                            textColor: AppConstant.blackColor.withOpacity(0.9),
                            fontWeight: FontWeight.w400),
                      ],
                    ),
                  );
                },
              );
  }

  employeeExpenses(List<ListItem>? myEmployeeExpenseData) {
    return expenseProvider.isFetching
        ? AppUtils.loaderWidget()
        : myEmployeeExpenseData?.length == 0 ||
                myEmployeeExpenseData == [] ||
                myEmployeeExpenseData == null
            ? AppUtils.commonNoDataFound(
                text: "No Data Found",
                onPressed: () async {
                  await expenseProvider.apiCallGetEmployeeExpenseList();
                },
              )
            : ListView.builder(
                physics: BouncingScrollPhysics(),
                shrinkWrap: true,
                itemCount: myEmployeeExpenseData.length,
                padding: AppUtils.edgeInsetsOnly(
                    bottom: 20, top: 0, left: 0, right: 0),
                itemBuilder: (context, index) {
                  return AppUtils.commonContainer(
                    width: double.infinity,
                    margin: const EdgeInsets.only(left: 10, right: 10, top: 20),
                    padding:  EdgeInsets.only(
                        left: 15, right: 15, top: 20, bottom: isFiltered == true ? 20 :0),
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
                                flex: 5,
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
                                        text: myEmployeeExpenseData[index]
                                                .userName ??
                                            "",
                                        fontSize: 12,
                                        textColor: AppConstant.blackColor
                                            .withOpacity(0.9),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // SizedBox(width: 40),
                              // Adjust the width as per your requirement
                              Flexible(
                                flex: 2,
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.timer_outlined,
                                      color: Colors.green,
                                      size: 15,
                                    ),
                                    AppUtils.commonSizedBox(width: 3),
                                    Expanded(
                                      child: AppUtils.commonTextWidget(
                                        text: AppUtils.formatDateString(
                                            myEmployeeExpenseData[index]
                                                    .expenseDate ??
                                                "",
                                            "dd-MM-yyyy"),
                                        fontSize: 12,
                                        textColor: AppConstant.blackColor
                                            .withOpacity(0.9),
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
                                    text: "Expense Status",
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
                                  color:
                                  myEmployeeExpenseData[index].isApproved == null ? Colors.grey: myEmployeeExpenseData[index].isApproved ==
                                              true
                                          ? Colors.green
                                          : Colors.red,
                                ),
                                child: AppUtils.commonTextWidget(
                                    text: myEmployeeExpenseData[index].isApproved == null ? "Pending" :myEmployeeExpenseData[index]
                                                .isApproved ==
                                            true
                                        ? "Approved"
                                        : "Rejected",
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
                                  Icons.category_rounded,
                                  color: Colors.cyan,
                                  size: 18,
                                ),
                                AppUtils.commonSizedBox(width: 5),
                                AppUtils.commonTextWidget(
                                    text: "Category",
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
                            text: myEmployeeExpenseData[index]
                                    .expenseCategoryName ??
                                "",
                            fontSize: 12,
                            textColor: AppConstant.blackColor.withOpacity(0.9),
                            fontWeight: FontWeight.w400),
                        AppUtils.commonSizedBox(height: 5),
                        Divider(
                          color: AppConstant.greyColor.withOpacity(0.3),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        AppUtils.commonTextWidget(
                                            text: "Sub Category",
                                            fontSize: 12,
                                            textColor: AppConstant.blackColor
                                                .withOpacity(0.9),
                                            fontWeight: FontWeight.w500)
                                      ],
                                    ),
                                  ],
                                ),
                                AppUtils.commonSizedBox(height: 5),
                                AppUtils.commonTextWidget(
                                    text: myEmployeeExpenseData[index]
                                            .expenseSubCategoryName ??
                                        "",
                                    fontSize: 12,
                                    textColor:
                                        AppConstant.blackColor.withOpacity(0.9),
                                    fontWeight: FontWeight.w400),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        AppUtils.commonTextWidget(
                                            text: "Expanse Amount",
                                            fontSize: 12,
                                            textColor: AppConstant.blackColor
                                                .withOpacity(0.9),
                                            fontWeight: FontWeight.w500)
                                      ],
                                    ),
                                  ],
                                ),
                                AppUtils.commonSizedBox(height: 5),
                                AppUtils.commonTextWidget(
                                    text: myEmployeeExpenseData[index]
                                        .submittedAmount
                                        .toString(),
                                    fontSize: 12,
                                    textColor:
                                        AppConstant.blackColor.withOpacity(0.9),
                                    fontWeight: FontWeight.w400),
                              ],
                            ),
                          ],
                        ),
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
                                    text: "Comment",
                                    fontSize: 12,
                                    textColor:
                                        AppConstant.blackColor.withOpacity(0.9),
                                    fontWeight: FontWeight.w500)
                              ],
                            ),
                          ],
                        ),
                        AppUtils.commonSizedBox(height: 5),
                        AppUtils.commonTextWidget(
                            text: myEmployeeExpenseData[index]
                                    .expenseDescription ??
                                "",
                            fontSize: 12,
                            textColor: AppConstant.blackColor.withOpacity(0.9),
                            fontWeight: FontWeight.w400),

                        AppUtils.commonSizedBox(height: 5),
                        if(isFiltered == false)

                          Column(children: [
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
                                      AppUtils.showDialogBoxWithTwoButton(
                                          onSuccess: () async{
                                            await expenseProvider.apiCallApplyRejectLeave(
                                              pkId: myEmployeeExpenseData[index].pkId,
                                              userId: myEmployeeExpenseData[index].userId,
                                              approvedRejectedBy: userName,
                                              approvedAmount:  myEmployeeExpenseData[index].submittedAmount,
                                              isApproved: false,
                                              approvedRejectedOn: DateTime.now().toString(),
                                              onSuccess: () async{
                                                await expenseProvider.apiCallGetMyExpenseList();
                                              },
                                            );
                                          },
                                          onCancel: () {},
                                          context: context,
                                          onSuccessString: "Reject",
                                          onCancelString: "Cancel",
                                          text:
                                          "Do you want to reject Expense request ${myEmployeeExpenseData[index].userName} ",
                                          titleText: "Expense Request");
                                    },
                                    child: AppUtils.commonContainer(
                                      padding: AppUtils.edgeInsetsOnly(top: 5, bottom: 15),
                                      color: Colors.white,
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.close,color: Colors.red,size: 26,),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: InkWell(
                                    onTap: () {

                                      AppUtils.showDialogBoxWithTwoButton(
                                          onSuccess: () async{
                                            await expenseProvider.apiCallApplyRejectLeave(
                                              pkId: myEmployeeExpenseData[index].pkId,
                                              userId: myEmployeeExpenseData[index].userId,
                                              approvedRejectedBy: userName,
                                              approvedAmount:  myEmployeeExpenseData[index].submittedAmount,
                                              isApproved: true,
                                              approvedRejectedOn: DateTime.now().toString(),
                                              onSuccess: () async{
                                                await expenseProvider.apiCallGetEmployeeExpenseList();
                                              },
                                            );
                                          },
                                          onCancel: () {},
                                          context: context,
                                          onSuccessString: "Approve",
                                          onCancelString: "Cancel",
                                          text:
                                          "Do you want to approve Expense request ${myEmployeeExpenseData[index].userName} ",
                                          titleText: "Expense Request");
                                    },
                                    child: AppUtils.commonContainer(
                                      padding:
                                      AppUtils.edgeInsetsOnly(top: 5, bottom: 15),
                                      color: Colors.white,
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.check,color: Colors.green,size: 26,),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            )
                          ],)
                      ],
                    ),
                  );
                },
              );
  }


}
