
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ontrek/core/common_widgets/textfield_widget.dart';
import 'package:ontrek/core/storage/preference_helper.dart';
import 'package:ontrek/core/utils/App_utils.dart';
import 'package:ontrek/core/utils/app_constant.dart';
import 'package:ontrek/features/home/leave/model/leave_type_model.dart';
import 'package:ontrek/features/home/leave/provider/leave_provider.dart';
import 'package:ontrek/features/home/leave/screen/choose_leave_type_screen.dart';
import 'package:provider/provider.dart';

class ApplyLeaveScreen extends StatefulWidget {
  String? pkId;
   ApplyLeaveScreen({super.key,this.pkId});

  @override
  State<ApplyLeaveScreen> createState() => _ApplyLeaveScreenState();
}

class _ApplyLeaveScreenState extends State<ApplyLeaveScreen> {
  bool isLoading = false;
  String? userName;
  String? userId;
  num numberOfLeaves =1;
  TextEditingController leaveStartDateController = TextEditingController();
  TextEditingController leaveEndDateController = TextEditingController();
  TextEditingController leaveReasonController = TextEditingController();
  TextEditingController employeeNameController = TextEditingController();
  TextEditingController leaveTypeController = TextEditingController();
  DateTime selectedStartDate = DateTime.now();
  DateTime? selectedEndDate;
  String? selectedLeaveTypeId;
  String? selectedLeaveTypeName;
  int selectedValue = 1;
  late LeaveProvider leaveProvider;
  bool? isFullDay = false;

  @override
  void initState() {
    super.initState();
    selectedStartDate = DateTime.now();
    selectedEndDate = DateTime.now();
    _loadUserName();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) async {
        leaveProvider = Provider.of<LeaveProvider>(context, listen: false);
      },
    );
  }

  Future<void> _loadUserName() async {
    userName = await PreferenceHelper.getString(PreferenceHelper.USER_NAME);
    userId = await PreferenceHelper.getString(PreferenceHelper.USER_ID);
    if (userName != null && userName!.isNotEmpty) {
      setState(() {
        employeeNameController.text = userName!;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    leaveProvider = Provider.of<LeaveProvider>(context);
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
                    checkValidationAndSubmitForm(context);
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
            if (leaveProvider.isAdding)
              AppUtils.loaderWidget(color: AppConstant.appPrimaryColor),
          ],
        ),
      ),
    );
  }


  checkValidationAndSubmitForm(BuildContext context)async{
    FocusScope.of(context).unfocus();

    if(leaveTypeController.text.isEmpty){
      AppUtils.showSnackBarWithColor(message: "Please select Leave Type",context: context,giveColor: Colors.red);
    }else if(leaveStartDateController.text.isEmpty){
      AppUtils.showSnackBarWithColor(message: "Please select Leave Start Date",context: context,giveColor: Colors.red);
    }
    else if(leaveEndDateController.text.isEmpty){
      AppUtils.showSnackBarWithColor(message: "Please select Leave End Date",context: context,giveColor: Colors.red);
    } else if(leaveReasonController.text.isEmpty){
      AppUtils.showSnackBarWithColor(message: "Please Enter Leave Reason",context: context,giveColor: Colors.red);
    }else  {
      if(selectedStartDate != null && selectedEndDate != null){
        numberOfLeaves  =selectedEndDate!.difference(selectedStartDate).inDays + 1;
      }
      AppUtils.showDialogBoxWithTwoButton(
        titleText: "Leave Apply",
        text:
        "Are you sure you want to apply this application of leave",
        onSuccessString: "Yes",
        onCancelString: "No",
        context: context,
        onSuccess: () async {
          await leaveProvider.apiCallApplyLeave(
            userId: userId,
            isFullDay: isFullDay,
            leaveCategoryTotId: selectedLeaveTypeId,
            leaveStartDate: AppUtils.dateFormat(
                date: selectedStartDate,
                dateFormat: "yyyy-MM-dd"),
            leaveEndDate:  AppUtils.dateFormat(
                date: selectedEndDate,
                dateFormat: "yyyy-MM-dd"),
            submissionDate:  AppUtils.dateFormat(
                date: DateTime.now(),
                dateFormat: "yyyy-MM-dd"),
            leaveDays: isFullDay == true ? numberOfLeaves : numberOfLeaves/2,
            leaveReason: leaveReasonController.text,
            onSuccess: () {
              Navigator.pop(context,{
                "isSuccess" : true
              });

            },

          );
        },
        onCancel: () {

        },
      );
    }


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
          if (selectedValue == 1) {
            isFullDay = false;
          } else {
            isFullDay = true;
          }
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
        selectedLeaveTypeId = result["leaveTypeId"];
        selectedLeaveTypeName = result["leaveTypeName"];
        leaveTypeController.text = selectedLeaveTypeName ?? "";
      });
    }
  }

  Future<void> _openDatePicker({required bool isStartDate}) async {
    DateTime? initialDate;
    DateTime firstDate;

    if (isStartDate) {
      initialDate = selectedStartDate;
      firstDate = DateTime(2000);
    } else {
      // For end date picker, ensure initialDate is valid
      initialDate = selectedEndDate != null && selectedEndDate!.isAfter(selectedStartDate)
          ? selectedEndDate
          : selectedStartDate;
      firstDate = selectedStartDate;
    }

    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: firstDate,
      lastDate: DateTime(2101),
      initialEntryMode: DatePickerEntryMode.calendarOnly,
      selectableDayPredicate: (DateTime date) {
        if (isStartDate) {
          // For start date selection, allow all dates from today onwards
          return date.isAfter(DateTime.now().subtract(const Duration(days: 1)));
        } else {
          // For end date selection, allow dates after the selected start date
          return date.isAfter(selectedStartDate.subtract( Duration(days: 1)));
        }
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
          // Reset the selected end date to null when a new start date is selected
          selectedEndDate = null;
          leaveEndDateController.clear();
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
