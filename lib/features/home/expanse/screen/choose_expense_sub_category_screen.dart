
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ontrek/core/common_widgets/app_scaffold.dart';
import 'package:ontrek/core/utils/App_utils.dart';
import 'package:ontrek/core/utils/app_constant.dart';
import 'package:ontrek/features/home/expanse/provider/expense_provider.dart';
import 'package:provider/provider.dart';

class ChooseExpenseSubCategoryScreen extends StatefulWidget {
  String? expenseCategoryId;
   ChooseExpenseSubCategoryScreen({Key? key,this.expenseCategoryId}) : super(key: key);

  @override
  State<ChooseExpenseSubCategoryScreen> createState() => _ChooseExpenseSubCategoryScreenState();
}

class _ChooseExpenseSubCategoryScreenState extends State<ChooseExpenseSubCategoryScreen> {
  TextEditingController searchController = TextEditingController();
  late ExpenseProvider expenseProvider;
  String? selectSubCategoryId;
  String? selectSubCategoryName;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      expenseProvider = Provider.of<ExpenseProvider>(context, listen: false);
      await expenseProvider.apiCallExpenseSubCategory(categoryId: widget.expenseCategoryId);
    });
  }



  @override
  Widget build(BuildContext context) {
    expenseProvider = Provider.of<ExpenseProvider>(context);
    return AppScaffold(
      appBar: AppUtils.commonAppBar(
        context: context,
        title: "Expense Category",
        isBack: true,
        isBorder: true,
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 15, right: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppUtils.commonSizedBox(height: 20),
            AppUtils.commonTextWidget(
              text: "Select Category",
              textColor: AppConstant.blackColor.withOpacity(0.7),
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
            AppUtils.commonSizedBox(height: 20),
            Expanded(
              child:
              expenseProvider.isFetching
                  ? AppUtils.loaderWidget()
                  : expenseProvider.expenseSubCategoryModel?.data == null ||
                  (expenseProvider.expenseSubCategoryModel?.data?.length ?? 0) <= 0
                  ? AppUtils.commonNoDataFound(
                text: "No Sub Category Found",
                onPressed: () async{
                  await expenseProvider.apiCallExpenseCategory();
                },
              )
                  : ListView.builder(
                padding: const EdgeInsets.only(bottom: 30),
                physics: const BouncingScrollPhysics(),
                itemCount: expenseProvider.expenseSubCategoryModel?.data?.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectSubCategoryId = expenseProvider.expenseSubCategoryModel?.data?[index].subCategoryId;
                        selectSubCategoryName = expenseProvider.expenseSubCategoryModel?.data?[index].subCategoryName;

                      });
                      Navigator.pop(
                        context,
                        {
                          'expenseSubCategoryId': selectSubCategoryId,
                          'expenseSubCategoryName': selectSubCategoryName,
                        },
                      );
                    },
                    child: AppUtils.commonContainer(
                      padding: const EdgeInsets.only(
                        top: 5,
                        bottom: 5,
                      ),
                      decoration: BoxDecoration(
                        border: Border(
                          top: index == 0
                              ? BorderSide(
                              width: 0.5,
                              color: Colors.grey.shade400)
                              : BorderSide.none,
                          bottom: BorderSide(
                            width: 0.5,
                            color: Colors.grey.shade400,
                          ),
                        ),
                      ),
                      child: CupertinoListTile(
                        leadingToTitle: 0,
                        leadingSize: 0,
                        padding: EdgeInsets.zero,
                        title: AppUtils.commonTextWidget(
                          text: expenseProvider.expenseSubCategoryModel?.data?[index].subCategoryName ?? "name",
                          textColor:
                          AppConstant.blackColor.withOpacity(0.7),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
