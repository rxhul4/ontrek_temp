import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ontrek/core/common_widgets/app_scaffold.dart';
import 'package:ontrek/core/utils/App_utils.dart';
import 'package:ontrek/core/utils/app_constant.dart';
import 'package:ontrek/features/add_lead/model/get_all_country_model.dart';
import 'package:ontrek/features/add_lead/provider/add_lead_provider.dart';
import 'package:ontrek/features/home/leave/model/leave_type_model.dart';
import 'package:provider/provider.dart';

class ChooseLeaveTypeScreen extends StatefulWidget {
  const ChooseLeaveTypeScreen({Key? key}) : super(key: key);

  @override
  State<ChooseLeaveTypeScreen> createState() => _ChooseLeaveTypeScreenState();
}

class _ChooseLeaveTypeScreenState extends State<ChooseLeaveTypeScreen> {
  TextEditingController searchController = TextEditingController();
  // late AddLeadProvider addLeadProvider;
  // GetAllCountryModel? getAllCountryModel;
  int? selectedLeaveTypeId;
  String? selectedLeaveTypeName;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      // addLeadProvider = Provider.of<AddLeadProvider>(context, listen: false);
      // await callGetAllCountryApi();
    });
  }
  
  
  List<LeaveTypeModel> leaveTypedDrpDwnData = [
    LeaveTypeModel(leaveName: "Vacation", leaveTypeId: 1),
    LeaveTypeModel(leaveName: "Personal", leaveTypeId: 2),
    LeaveTypeModel(leaveName: "Medical", leaveTypeId: 3),
  ];
  

  @override
  Widget build(BuildContext context) {
    // addLeadProvider = Provider.of<AddLeadProvider>(context);
    return AppScaffold(
      appBar: AppUtils.commonAppBar(
        context: context,
        title: "Leave Type",
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
              text: "Select Leave Type",
              textColor: AppConstant.blackColor.withOpacity(0.7),
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
            AppUtils.commonSizedBox(height: 20),
            Expanded(
              child: /*addLeadProvider.isFetching
                  ? AppUtils.loaderWidget()
                  : getAllCountryModel?.data == null ||
                  (getAllCountryModel?.data?.length ?? 0) <= 0
                  ? AppUtils.commonNoDataFound(
                text: "No Country Found",
                onPressed: () {
                  addLeadProvider.apiCallGetAllCountry();
                },
              )
                  : */ListView.builder(
                padding: const EdgeInsets.only(bottom: 30),
                physics: const BouncingScrollPhysics(),
                itemCount: leaveTypedDrpDwnData.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedLeaveTypeId = leaveTypedDrpDwnData[index].leaveTypeId;
                        selectedLeaveTypeName = leaveTypedDrpDwnData[index].leaveName;
                      });
                      Navigator.pop(
                        context,
                        LeaveTypeModel(leaveName: selectedLeaveTypeName ??"", leaveTypeId: selectedLeaveTypeId ?? 0)
                        // {
                        //   'leaveTypeId': selectedLeaveTypeId,
                        //   'leaveTypeName': selectedLeaveTypeName,
                        // },
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
                          text: leaveTypedDrpDwnData[index].leaveName,
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
