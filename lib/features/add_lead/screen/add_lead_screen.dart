import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ontrek/core/common_widgets/app_scaffold.dart';
import 'package:ontrek/core/common_widgets/common_selection_widget.dart';
import 'package:ontrek/core/common_widgets/textfield_widget.dart';
import 'package:ontrek/core/utils/App_utils.dart';
import 'package:ontrek/core/utils/app_constant.dart';
import 'package:ontrek/features/add_lead/model/get_all_country_model.dart';
import 'package:ontrek/features/add_lead/provider/add_lead_provider.dart';
import 'package:ontrek/features/add_lead/screen/choose_city_screen.dart';
import 'package:ontrek/features/add_lead/screen/choose_country_screen.dart';
import 'package:ontrek/features/add_lead/screen/choose_lead_source_screen.dart';
import 'package:ontrek/features/add_lead/screen/choose_state_screen.dart';
import 'package:provider/provider.dart';

class AddLeadScreen extends StatefulWidget {
  bool? isEdit;
  AddLeadScreen({super.key,this.isEdit});

  @override
  State<AddLeadScreen> createState() => _AddLeadScreenState();
}

class _AddLeadScreenState extends State<AddLeadScreen> {
  String? selectedCountryId;
  String? selectedCountryName;
  String? selectedStateName;
  String? selectedStateId;
  String? selectedCityName;
  String? selectedCityId;
  String? selectedLeadName;
  String? selectedLeadId;
  TextEditingController companyNameController = TextEditingController();
  TextEditingController customerNameController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();
  TextEditingController customerEmailController = TextEditingController();
  TextEditingController customerAddressController = TextEditingController();
  TextEditingController zipCodeController = TextEditingController();
  GetAllCountryModel? getAllCountryModel;
  late AddLeadProvider addLeadProvider;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      addLeadProvider = Provider.of<AddLeadProvider>(context, listen: false);
    });
  }

  @override
  Widget build(BuildContext context) {
    addLeadProvider = Provider.of<AddLeadProvider>(context);
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: AppScaffold(
        appBar: AppUtils.commonAppBar(
          context: context,
          title: widget.isEdit == true ? "Edit Lead" :  "Add Lead",
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(left: 10, right: 10, bottom: 20),
            child: Column(
              children: [
                AppUtils.commonSizedBox(height: 20),
                commonTextField(
                  text: "Company Name",
                  controller: companyNameController,
                ),
                AppUtils.commonSizedBox(height: 20),
                commonTextField(
                  text: "Customer Name",
                  controller: customerNameController,
                ),
                AppUtils.commonSizedBox(height: 20),
                commonTextField(
                    text: "Customer Number",
                    controller: phoneNumberController,
                    textInputType: TextInputType.phone),
                AppUtils.commonSizedBox(height: 20),
                commonTextField(
                  text: "Customer Email",
                  controller: customerEmailController,
                ),
                AppUtils.commonSizedBox(height: 20),
                commonTextField(
                    text: "Customer Address",
                    controller: customerAddressController,
                    maxLine: 3),
                AppUtils.commonSizedBox(height: 20),
                commonTextField(
                  text: "Pin Code",
                  controller: zipCodeController,
                ),
                AppUtils.commonSizedBox(height: 20),
                commonTextField(
                  text: "Select Country",
                  suffixIcon: Icon(Icons.arrow_drop_down_sharp,
                      color: AppConstant.appPrimaryColor),
                  textInputType: TextInputType.none,
                  showCursor: false,
                  controller: TextEditingController(
                    text: selectedCountryName,
                  ),
                  onTap: () async {
                    Navigator.push(
                      context,
                      CupertinoPageRoute(
                          builder: (context) => const ChooseCountryScreen()),
                    ).then((value) {
                      print("value_$value");
                      if (value != null) {
                        setState(() {
                          selectedCountryId = value['countryId'];
                          selectedCountryName = value['countryName'];
                          print("selectedCountry$selectedCountryName");
                          print("selectedCountryId$selectedCountryId");
                          selectedStateName = "";
                          selectedStateId = "";
                          selectedCityId = "";
                          selectedCityName = "";
                        });
                      }
                    });
                  },
                ),
                AppUtils.commonSizedBox(height: 20),
                commonTextField(
                  text: "Select State",
                  suffixIcon: Icon(Icons.arrow_drop_down_sharp,
                      color: AppConstant.appPrimaryColor),
                  textInputType: TextInputType.none,
                  showCursor: false,
                  controller: TextEditingController(
                    text: selectedStateName,
                  ),
                  onTap: () async {
                    Navigator.push(
                      context,
                      CupertinoPageRoute(
                          builder: (context) => ChooseStateScreen(
                                countryId: selectedCountryId,
                              )),
                    ).then((value) {
                      if (value != null) {
                        setState(() {
                          selectedStateId = value['stateId'];
                          selectedStateName = value['stateName'];
                          selectedCityId = "";
                          selectedCityName = "";
                          print("selectedCountry$selectedStateName");
                          print("selectedCountryId$selectedStateId");
                        });
                      }
                    });
                  },
                ),
                AppUtils.commonSizedBox(height: 20),
                commonTextField(
                  text: "Select City",
                  suffixIcon: Icon(Icons.arrow_drop_down_sharp,
                      color: AppConstant.appPrimaryColor),
                  textInputType: TextInputType.none,
                  showCursor: false,
                  controller: TextEditingController(
                    text: selectedCityName,
                  ),
                  onTap: () async {
                    Navigator.push(
                      context,
                      CupertinoPageRoute(
                          builder: (context) => ChooseCityScreen(
                                stateId: selectedStateId,
                              )),
                    ).then((value) {
                      if (value != null) {
                        setState(() {
                          selectedCityId = value['cityId'];
                          selectedCityName = value['cityName'];
                          print("selectedCountry$selectedStateName");
                          print("selectedCountryId$selectedStateId");
                        });
                      }
                    });
                  },
                ),
                AppUtils.commonSizedBox(height: 20),
                commonTextField(
                  text: "Select LeadSource",
                  suffixIcon: Icon(Icons.arrow_drop_down_sharp,
                      color: AppConstant.appPrimaryColor),
                  textInputType: TextInputType.none,
                  showCursor: false,
                  controller: TextEditingController(
                    text: selectedLeadName,
                  ),
                  onTap: () async {
                    Navigator.push(
                      context,
                      CupertinoPageRoute(
                          builder: (context) => const ChooseLeadSourceScreen()),
                    ).then((value) {
                      if (value != null) {
                        setState(() {
                          selectedLeadId = value["leadId"];
                          selectedLeadName = value["leadName"];
                        });
                      }
                    });
                  },
                ),
                AppUtils.commonSizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: AppUtils.commonContainer(
                          padding: const EdgeInsets.only(
                              left: 15, right: 15, bottom: 10, top: 10),
                          decoration: AppUtils.commonBoxDecoration(
                            color: Colors.white,
                            borderRadius:
                                const BorderRadius.all(Radius.circular(5)),
                            border: Border.all(
                                color: AppConstant.greyColor.withOpacity(0.4)),
                          ),
                          child: Center(
                              child: AppUtils.commonTextWidget(
                            text: "Cancel",
                            textColor: AppConstant.blackColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w300,
                          ))),
                    ),
                    GestureDetector(
                      onTap: () {
                        checkValidation();
                      },
                      child: AppUtils.commonContainer(
                          padding: const EdgeInsets.only(
                              left: 15, right: 15, bottom: 10, top: 10),
                          decoration: AppUtils.commonBoxDecoration(
                            color: AppConstant.appPrimaryColor,
                            borderRadius:
                                const BorderRadius.all(Radius.circular(5)),
                          ),
                          child: Center(
                              child: AppUtils.commonTextWidget(
                            text: "Create",
                            textColor: AppConstant.whiteColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w300,
                          ))),
                    ),
                  ],
                ),
                AppUtils.commonSizedBox(height: 5),
              ],
            ),
          ),
        ),
      ),
    );
  }

// Your commonTextField function remains the same
// Make sure to include it here

  commonTextField({
    String? text,
    int? maxLine,
    Function()? onTap,
    TextEditingController? controller,
    bool? showCursor,
    TextInputType? textInputType,
    Widget? suffixIcon,
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
          suffixIcon: suffixIcon,
          controller: controller,
          hintText: text ?? "",
          maxLines: maxLine ?? 1,
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

  checkValidation() async {
    if (companyNameController.text.isEmpty) {
      AppUtils.showSnackBarWithColor(
          message: "Please Enter Company Name", context: context);
    } else if (customerNameController.text.isEmpty) {
      AppUtils.showSnackBarWithColor(
        message: "Please Enter Customer Name",
        context: context,
      );
    } else if (phoneNumberController.text.isEmpty) {
      AppUtils.showSnackBarWithColor(
          message: "Please Enter Customer Phone Number", context: context);
    } else if (customerEmailController.text.isEmpty) {
      AppUtils.showSnackBarWithColor(
          message: "Please Enter Customer Email", context: context);
    } else if (customerAddressController.text.isEmpty) {
      AppUtils.showSnackBarWithColor(
          message: "Please Enter Customer Address", context: context);
    } else if (zipCodeController.text.isEmpty) {
      AppUtils.showSnackBarWithColor(
          message: "Please Enter PinCode", context: context);
    } else if (selectedCountryName == null) {
      AppUtils.showSnackBarWithColor(
          message: "Please Select Country", context: context);
    } else if (selectedStateName == null) {
      AppUtils.showSnackBarWithColor(
          message: "Please Select State", context: context);
    } else if (selectedCityName == null) {
      AppUtils.showSnackBarWithColor(
          message: "Please Select City", context: context);
    } else if (selectedLeadName == null) {
      AppUtils.showSnackBarWithColor(
          message: "Please Select LeadSource", context: context);
    } else {
      //callApi
      AppUtils.showDialogBoxWithTwoButton(
        onSuccessString: "YES",
        onCancelString: "NO",
        text: "Are you sure you want to create ${companyNameController.text}",
        titleText: "Create Lead",
        onSuccess: ()async {
          await callCreateLeadApi();
        },
        onCancel: () {

        },
      );

    }
  }

  callCreateLeadApi() async {
    await addLeadProvider
        .apiCallCreateLead(
      companyName: companyNameController.text,
      customerName: customerNameController.text,
      customerPhone: phoneNumberController.text,
      customerEmail: customerEmailController.text,
      customerAddress: customerAddressController.text,
      zipCode: zipCodeController.text,
      countryId: selectedCountryId,
      stateId: selectedStateId,
      cityId: selectedCityId,
      totLeadSourceId: selectedLeadId,
    )
        .then((value) {
      if (value?.isError == false && value?.isValidationFailed == false) {
        Navigator.pop(context);
      } else {
        AppUtils.showDialogBoxWithOneButton(
            context: context, text: value?.message ?? "");
      }
    });
  }
}
