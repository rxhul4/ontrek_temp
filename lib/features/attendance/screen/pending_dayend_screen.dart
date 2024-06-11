import 'package:flutter/material.dart';
import 'package:interval_time_picker/interval_time_picker.dart';
import 'package:interval_time_picker/models/visible_step.dart';
import 'package:intl/intl.dart';
import 'package:ontrek/core/common_widgets/app_scaffold.dart';
import 'package:ontrek/core/common_widgets/textfield_widget.dart';
import 'package:ontrek/core/utils/App_utils.dart';
import 'package:ontrek/core/utils/app_constant.dart';
import 'package:ontrek/features/attendance/provider/attendance_provider.dart';
import 'package:provider/provider.dart';

class PendingDayEndScreen extends StatefulWidget {
  String? sessionId;
  String? sessionStartDate;

  PendingDayEndScreen({super.key, this.sessionId, this.sessionStartDate});

  @override
  State<PendingDayEndScreen> createState() => _PendingDayEndScreenState();
}

class _PendingDayEndScreenState extends State<PendingDayEndScreen> {
  late AttendanceProvider attendanceProvider;
  String dateFormatInto24Hour = "";
  String? endDateTime;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      attendanceProvider =
          Provider.of<AttendanceProvider>(context, listen: false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final attendanceProvider = Provider.of<AttendanceProvider>(context);
    return PopScope(
      canPop: false,
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: AppScaffold(
          backgroundColor: AppConstant.whiteColor,
          appBar: AppBar(
            automaticallyImplyLeading: false, // This removes the back button
            surfaceTintColor: AppConstant.transparentColor,
            backgroundColor: Colors.white,
            elevation: 0,
            title: AppUtils.commonTextWidget(
                text: "Request Form",
                textColor: AppConstant.blackColor.withOpacity(0.7),
                fontSize: 14),
            centerTitle: true,
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 20),
                child: GestureDetector(
                    onTap: attendanceProvider.isLoading == true
                        ? () {}
                        : () {
                      attendanceProvider.checkValidationOfRequestNote(
                          sessionId: widget.sessionId,
                          sessionEndDate:
                          endDateTime);
                    },
                    child: AppUtils.commonTextWidget(
                        text: "Submit",
                        fontSize: 14,
                        textColor: AppConstant.appPrimaryColor,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0)),
              )
            ],
            bottom: PreferredSize(
              preferredSize: Size.zero,
              child: AppUtils.commonContainer(
                  decoration: AppUtils.commonBoxDecoration(
                      border: Border(
                          bottom: BorderSide(
                              color: AppConstant.blackColor.withOpacity(0.4),
                              width: 0.3)))),
            ),
          ),
          body: Stack(
            children: [
              SingleChildScrollView(
                child: Padding(
                  padding: AppUtils.edgeInsetsOnly(left: 10, right: 10),
                  child: Column(
                    children: [
                      AppUtils.commonSizedBox(height: 10),
                      Container(
                          child: AppUtils.commonTextWidget(
                              text:
                              "Note: Please complete the form below to request manual day-end processing for the previous working day, which is pending closure. Upon approval, you'll be able to proceed with today's operations.",
                              textColor: Colors.red,
                              fontSize: 10)),
                      AppUtils.commonSizedBox(height: 10),
                      commonTextField(
                          text: "Date",
                          controller: attendanceProvider.dateController,
                          readOnly: true,
                          showCursor: false),
                      AppUtils.commonSizedBox(height: 20),
                      commonTextField(
                          text: "Day start",
                          controller: attendanceProvider.dayStartTimeController,
                          readOnly: true,
                          showCursor: false),
                      AppUtils.commonSizedBox(height: 20),
                      commonTextField(
                        readOnly: true,
                        text: "Day end",
                        showCursor: false,
                        controller: attendanceProvider.timeController,
                        onTap: () {
                          _showTimePicker(
                              selectedTime: TimeOfDay.now(), context: context);
                        },
                      ),
                      AppUtils.commonSizedBox(height: 20),
                      commonTextField(
                          text: "Reason",
                          controller: attendanceProvider.reasonController,
                          maxLine: 3,),
                      AppUtils.commonSizedBox(height: 20),
                    ],
                  ),
                ),
              ),
              attendanceProvider.isLoading == true
                  ? AppUtils.loaderWidget(color: AppConstant.appPrimaryColor)
                  : AppUtils.commonSizedBox(),
            ],
          ),
        ),
      ),
    );
  }

  commonTextField({
    String? text,
    int? maxLine,
    Function()? onTap,
    TextEditingController? controller,
    bool? showCursor,
    TextInputType? textInputType,
    Widget? suffixIcon,
    bool? readOnly
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppUtils.commonTextWidget(
            text: text ?? "",
            textColor: AppConstant.blackColor.withOpacity(0.6),
            fontWeight: FontWeight.w500,
            fontSize: 14),
        const SizedBox(
          height: 5,
        ),
        AppTextField(
          readOnly: readOnly,
          suffixIcon: suffixIcon,
          controller: controller,
          hintText: text ?? "",
          maxLines: maxLine ?? 1,
          maxLength: 200,
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

  void _showTimePicker(
      {TimeOfDay? selectedTime, required BuildContext context}) async {
    TimeOfDay _time = TimeOfDay(hour: 0, minute: 0);
    VisibleStep _visibleStep = VisibleStep.fifths;
    final TimeOfDay? result = await showIntervalTimePicker(
      context: context,
      initialTime: selectedTime ?? _time,
      visibleStep: _visibleStep,

      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
          child: child ?? SizedBox(),
        );
      },
    );

    if (result != null) {
      print("Result: $result");

      // Format time in 12-hour format (hh:mm a)
      String formattedTime12H = DateFormat('hh:mm a').format(
        DateTime(2020, 1, 1, result.hour, result.minute),
      );

      // Format time in 24-hour format (HH:mm:ss)
      String formattedTime24H = DateFormat('HH:mm:ss').format(
        DateTime(2020, 1, 1, result.hour, result.minute),
      );

      print("Formatted Time (12-hour): $formattedTime12H");
      print("Formatted Time (24-hour): $formattedTime24H");

      attendanceProvider.timeController.text = formattedTime12H;
      String formatedDate = AppUtils.getDate(
        date: "${widget.sessionStartDate}",
        format: "yyyy-MM-dd",
      );
      print("formatedDate$formatedDate");
      dateFormatInto24Hour = formattedTime24H;
      print("EndDate${formatedDate + "T" + dateFormatInto24Hour}");
      endDateTime = formatedDate + "T" + dateFormatInto24Hour;
      print("endDateTime$endDateTime");
      // You can also assign the 24-hour format to another controller if needed.
    }
  }
}
