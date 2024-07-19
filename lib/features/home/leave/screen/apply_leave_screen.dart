import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ontrek/core/common_widgets/textfield_widget.dart';
import 'package:ontrek/core/storage/preference_helper.dart';
import 'package:ontrek/core/utils/App_utils.dart';
import 'package:ontrek/core/utils/app_constant.dart';
import 'package:ontrek/features/home/leave/model/leave_type_model.dart';
import 'package:ontrek/features/home/leave/screen/choose_leave_type_screen.dart';

class ApplyLeaveScreen extends StatefulWidget {
  const ApplyLeaveScreen({super.key});

  @override
  State<ApplyLeaveScreen> createState() => _ApplyLeaveScreenState();
}

class _ApplyLeaveScreenState extends State<ApplyLeaveScreen> {
  bool isLoading = false;
  String? userName;
  TextEditingController leaveStartDateController = TextEditingController();
  TextEditingController leaveEndDateController = TextEditingController();
  TextEditingController leaveReasonController = TextEditingController();
  TextEditingController employeeNameController = TextEditingController();
  TextEditingController leaveTypeController = TextEditingController();
  DateTime? selectedStartDate;
  DateTime? selectedEndDate;
  LeaveTypeModel? leaveTypeModel;
  int selectedValue = 1;

  @override
  void initState() {
    super.initState();
    selectedStartDate = DateTime.now();
    selectedEndDate = DateTime.now();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    userName = await PreferenceHelper.getString(PreferenceHelper.USER_NAME);
    if (userName != null && userName!.isNotEmpty) {
      setState(() {
        employeeNameController.text = userName!;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: AppConstant.whiteColor,
        appBar: AppUtils.commonAppBar(
            context: context,
            title: "Apply Leave",
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
                      titleText: "Leave Apply",
                      text: "Are you sure you want to apply this application of leave",
                      onSuccessString: "Yes",
                      onCancelString: "No",
                      context: context,
                      onSuccess: () {

                      },
                      onCancel: () {

                      },
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
                  children: [
                    AppUtils.commonSizedBox(height: 20),
                    _buildCommonTextField(
                      readOnly: true,
                      controller: employeeNameController,
                      showCursor: false,
                      text: "Employee Name",
                    ),
                    AppUtils.commonSizedBox(height: 10),
                    _buildCommonTextField(
                      readOnly: true,
                      controller: leaveTypeController,
                      showCursor: false,
                      text: "Leave Type",
                      onTap: _chooseLeaveType,
                    ),
                    AppUtils.commonSizedBox(height: 10),
                    _buildRequestTypeSelector(),
                    AppUtils.commonSizedBox(height: 10),
                    _buildCommonTextField(
                      readOnly: true,
                      maxLine: 1,
                      text: "Select start Date",
                      showCursor: false,
                      controller: leaveStartDateController,
                      onTap: () => _openDatePicker(isStartDate: true),
                    ),
                    AppUtils.commonSizedBox(height: 10),
                    _buildCommonTextField(
                      readOnly: true,
                      maxLine: 1,
                      text: "Select end Date",
                      showCursor: false,
                      controller: leaveEndDateController,
                      onTap: () => _openDatePicker(isStartDate: false),
                    ),
                    AppUtils.commonSizedBox(height: 10),
                    _buildCommonTextField(
                      text: "Reason",
                      controller: leaveReasonController,
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

  Widget _buildRequestTypeSelector() {
    return AppUtils.commonContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          AppUtils.commonTextWidget(
            text: "Request Type",
            textColor: AppConstant.blackColor.withOpacity(0.6),
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
          const SizedBox(height: 5),
          Row(
            children: [
              Expanded(child: _buildRadioOption("Half Day", 1)),
              Expanded(child: _buildRadioOption("Full Day", 2)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRadioOption(String title, int value) {
    return RadioListTile<int>(
      contentPadding: EdgeInsets.zero,
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: Colors.black,
          fontSize: 12,
        ),
      ),
      activeColor: AppConstant.appPrimaryColor,
      // Replace with your app primary color
      value: value,
      groupValue: selectedValue,
      onChanged: (value) {
        setState(() {
          selectedValue = value!;
        });
      },
    );
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

  Future<void> _chooseLeaveType() async {
    final result = await Navigator.push(
      context,
      CupertinoPageRoute(builder: (context) => ChooseLeaveTypeScreen()),
    );
    if (result != null) {
      setState(() {
        leaveTypeModel = result;
        leaveTypeController.text = leaveTypeModel?.leaveName ?? "";
      });
    }
  }

  Future<void> _openDatePicker({required bool isStartDate}) async {
    DateTime? initialDate = isStartDate ? selectedStartDate : selectedEndDate;
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate!,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      initialEntryMode: DatePickerEntryMode.calendarOnly,
      selectableDayPredicate: (DateTime date) {
        return date.isAfter(DateTime.now().subtract(const Duration(days: 1)));
      },
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
        if (isStartDate) {
          selectedStartDate = picked;
          leaveStartDateController.text = AppUtils.dateFormat(
            date: selectedStartDate,
            dateFormat: "dd-MM-yyyy",
          );
        } else {
          selectedEndDate = picked;
          leaveEndDateController.text = AppUtils.dateFormat(
            date: selectedEndDate,
            dateFormat: "dd-MM-yyyy",
          );
        }
      });
    }
  }
}
