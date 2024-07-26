import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ontrek/core/common_widgets/textfield_widget.dart';
import 'package:ontrek/core/storage/preference_helper.dart';
import 'package:ontrek/core/utils/App_utils.dart';
import 'package:ontrek/core/utils/app_constant.dart';
import 'package:ontrek/features/home/expanse/provider/expense_provider.dart';
import 'package:ontrek/features/home/expanse/screen/choose_expense_category_screen.dart';
import 'package:ontrek/features/home/expanse/screen/choose_expense_sub_category_screen.dart';
import 'package:ontrek/features/home/leave/model/leave_type_model.dart';
import 'package:ontrek/features/home/leave/screen/choose_leave_type_screen.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  bool isLoading = false;
  String? userName;
  TextEditingController expenseDateController = TextEditingController();
  TextEditingController categoryController = TextEditingController();
  TextEditingController sub_categoryController = TextEditingController();
  TextEditingController amountController = TextEditingController();
  TextEditingController reasonController = TextEditingController();
  int selectedValue = 1;
  String? selectedCategoryId;
  String? selectedSubCategoryId;
  late ExpenseProvider expenseProvider;
  String? image64;
  DateTime? selectedDate;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) async {
        selectedDate = DateTime.now();
        expenseProvider = Provider.of<ExpenseProvider>(context, listen: false);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    expenseProvider = Provider.of<ExpenseProvider>(context);

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: AppConstant.whiteColor,
        appBar: AppUtils.commonAppBar(
            context: context,
            title: "Add Expense",
            isBorder: true,
            isCenter: true,
            isBack: true,
            isActionWidgetAvailable: true,
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 20),
                child: GestureDetector(
                  onTap: () {
                    AppUtils.showDialogBoxWithTwoButton(
                      titleText: "Add Expanse",
                      text:
                          "Are you sure you want to apply this application of Expense",
                      onSuccessString: "Yes",
                      onCancelString: "No",
                      context: context,
                      onSuccess: () async {
                        await expenseProvider.apiCallAddExpense(
                          pkId: null,
                          invoiceImage: image64,
                          expenseCategoryId: selectedCategoryId,
                          expenseSubCategoryId: selectedSubCategoryId,
                          expenseDate: selectedDate.toString(),
                          expenseDescription: reasonController.text,
                          submittedAmount: int.parse(
                            amountController.text,
                          ),
                          onSuccess: () async{
                            FocusScope.of(context).unfocus();
                            Navigator.pop(context);
                            if(selectedValue == 0){
                              await expenseProvider.apiCallGetMyExpenseList();
                            }else{
                              await expenseProvider.apiCallGetEmployeeExpenseList();
                            }

                          },

                        );
                      },
                      onCancel: () {},
                    );
                  },
                  child: AppUtils.commonTextWidget(
                      text: "Submit",
                      fontSize: 14,
                      textColor: AppConstant.appPrimaryColor,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0),
                ),
              )
            ]),
        body: Stack(
          children: [
            SingleChildScrollView(
              child: Padding(
                padding: AppUtils.edgeInsetsOnly(left: 10, right: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppUtils.commonSizedBox(height: 20),
                    AppUtils.commonTextWidget(
                      text: "Add Image",
                      textColor: AppConstant.blackColor.withOpacity(0.6),
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    _image != null
                        ? Align(
                            alignment: Alignment.center,
                            child: Column(
                              children: [
                                AppUtils.commonContainer(
                                    padding: EdgeInsets.all(15),
                                    height: 150,
                                    width: 150,
                                    decoration: AppUtils.commonBoxDecoration(
                                      color: AppConstant.greyWithShade,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child:
                                        // isImageLoading
                                        Image.file(
                                      _image ?? File(_image?.path ?? ""),
                                      fit: BoxFit.cover,
                                      height: 0,
                                      width: 0,
                                    )),
                                AppUtils.commonSizedBox(height: 15),
                                AppUtils.commonInkWell(
                                  onTap: () {
                                    _image = null;
                                    setState(() {});
                                  },
                                  child: AppUtils.commonTextWidget(
                                    text: "Remove",
                                    textColor: Colors.red,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                )
                              ],
                            ),
                          )
                        : InkWell(
                            enableFeedback: true,
                            borderRadius: BorderRadius.circular(5),
                            onTap: () {
                              getImage();
                            },
                            child: Center(
                              child: AppUtils.commonContainer(
                                padding: AppUtils.edgeInsetsOnly(
                                    left: 15, right: 15),
                                // alignment: Alignment.center,
                                height: 50,
                                width: double.infinity,
                                decoration: AppUtils.commonBoxDecoration(
                                  color: AppConstant.greyWithShade,
                                  borderRadius: BorderRadius.circular(5),
                                  border: Border.all(
                                      color: AppConstant.appPrimaryColor),
                                ),
                                child: Center(
                                  child: AppUtils.commonTextWidget(
                                      text: "Add Expense Picture",
                                      textColor: AppConstant.blackColor
                                          .withOpacity(0.6),
                                      fontWeight: FontWeight.w500,
                                      fontSize: 16),
                                ),
                              ),
                            ),
                          ),
                    AppUtils.commonSizedBox(height: 10),
                    _buildCommonTextField(
                      readOnly: true,
                      controller: expenseDateController,
                      showCursor: false,
                      text: "Expense Date",
                      onTap: () {
                        _openDatePicker();
                      },
                    ),
                    AppUtils.commonSizedBox(height: 10),
                    _buildCommonTextField(
                      readOnly: true,
                      controller: categoryController,
                      showCursor: false,
                      text: "Category",
                      onTap: () {
                        Navigator.push(
                            context,
                            CupertinoPageRoute(
                              builder: (context) =>
                                  ChooseExpenseCategoryScreen(),
                            )).then(
                          (value) {
                            if (value != null) {
                              sub_categoryController.clear();
                              selectedSubCategoryId = "";
                              categoryController.text =
                                  value["expenseCategoryName"];
                              selectedCategoryId = value["expenseCategoryId"];
                            }
                            setState(() {});
                          },
                        );
                      },
                      // onTap: chooseCategory,
                    ),
                    AppUtils.commonSizedBox(height: 10),
                    _buildCommonTextField(
                      readOnly: true,
                      controller: sub_categoryController,
                      showCursor: false,
                      text: "Sub-Category",
                      onTap: () {
                        Navigator.push(
                            context,
                            CupertinoPageRoute(
                              builder: (context) =>
                                  ChooseExpenseSubCategoryScreen(
                                expenseCategoryId: selectedCategoryId,
                              ),
                            )).then(
                          (value) {
                            if (value != null) {
                              sub_categoryController.text =
                                  value["expenseSubCategoryName"];
                              selectedSubCategoryId =
                                  value["expenseSubCategoryId"];
                            }
                          },
                        );
                      },
                      // onTap: chooseSubCategory,
                    ),
                    AppUtils.commonSizedBox(height: 10),
                    _buildCommonTextField(
                      readOnly: false,
                      controller: amountController,
                      showCursor: true,
                      textInputType: TextInputType.number,
                      text: "Amount",
                    ),
                    AppUtils.commonSizedBox(height: 10),
                    _buildCommonTextField(
                      text: "Reason",
                      controller: reasonController,
                      maxLength: 200,
                      maxLine: 3,
                    ),
                    AppUtils.commonSizedBox(height: 20),
                  ],
                ),
              ),
            ),
            if (isLoading)
              AppUtils.loaderWidget(color: AppConstant.appPrimaryColor),
          ],
        ),
      ),
    );
  }

  Future<void> _openDatePicker() async {
    DateTime? initialDate = selectedDate;
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      initialEntryMode: DatePickerEntryMode.calendarOnly,
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            dialogBackgroundColor: AppConstant.whiteColor,
            scaffoldBackgroundColor: AppConstant.whiteColor,
            textSelectionTheme: TextSelectionThemeData(
              selectionColor: AppConstant.appPrimaryColor,
            ),
            colorScheme: ColorScheme.light(
              background: Colors.white,
              onBackground: AppConstant.greyColor.withOpacity(0.5),
              primary: AppConstant.appPrimaryColor,
              onPrimary: AppConstant.whiteColor,
            ),
          ),
          child: child ?? Container(),
        );
      },
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
        expenseDateController.text = AppUtils.getDate(
            date: selectedDate.toString(), format: "dd-MM-yyyy");
      });
    }
  }

  Widget _buildCommonTextField({
    String? text,
    int? maxLine,
    Function()? onTap,
    TextEditingController? controller,
    bool? showCursor,
    TextInputType? textInputType,
    Widget? suffixIcon,
    bool? readOnly,
    int? maxLength,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppUtils.commonTextWidget(
          text: text ?? "",
          textColor: AppConstant.blackColor.withOpacity(0.6),
          fontWeight: FontWeight.w500,
          fontSize: 14,
        ),
        const SizedBox(height: 5),
        AppTextField(
          readOnly: readOnly,
          suffixIcon: suffixIcon,
          controller: controller,
          hintText: text ?? "",
          maxLines: maxLine ?? 1,
          maxLength: maxLength,
          cursorColor: AppConstant.appPrimaryColor.withOpacity(0.9),
          allBorderRadius: 3,
          fillColor: AppConstant.whiteColor,
          hintTextColor: AppConstant.greyColor.withOpacity(0.3),
          hintFontSize: 12,
          textInputType: textInputType,
          onTap: onTap,
          showCursor: showCursor,
        ),
      ],
    );
  }

  // Future<void> chooseCategory() async {
  //   final result = await Navigator.push(
  //     context,
  //     CupertinoPageRoute(builder: (context) => ChooseLeaveTypeScreen()),
  //   );
  //   if (result != null) {
  //     setState(() {
  //       leaveTypeModel = result;
  //       categoryController.text = leaveTypeModel?.leaveName ?? "";
  //     });
  //   }
  // }

  // Future<void> chooseSubCategory() async {
  //   final result = await Navigator.push(
  //     context,
  //     CupertinoPageRoute(builder: (context) => ChooseLeaveTypeScreen()),
  //   );
  //   if (result != null) {
  //     setState(() {
  //       leaveTypeModel = result;
  //       sub_categoryController.text = leaveTypeModel?.leaveName ?? "";
  //     });
  //   }
  // }

  var imageFull;
  File? _image;
  ImagePicker? imagePicker;

  Future<String?> getImage() async {
    // Request camera permission
    var status = await Permission.camera.request();

    // Check if permission is permanently denied or denied
    if (status.isPermanentlyDenied || status.isDenied) {
      openAppSettings();
      return null; // Return null as permission is not granted
    }

    // Permission is granted, proceed to pick image from camera
    final imagePicker = ImagePicker();
    final image = await imagePicker.pickImage(
      source: ImageSource.camera,
      imageQuality: 25,
    );

    // Check if image is picked successfully
    if (image != null) {
      final bytes = await image.readAsBytes();
      setState(() {
        image64 = "data:image/png;base64," + base64Encode(bytes);
        _image = File(image.path);
      });
      return image64; // Return base64 encoded image
    } else {
      // Image picking is cancelled or failed
      return null;
    }
  }
}
