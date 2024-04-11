import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ontrek/core/common_widgets/app_scaffold.dart';
import 'package:ontrek/core/utils/App_utils.dart';
import 'package:ontrek/core/utils/app_constant.dart';
import 'package:ontrek/features/add_lead/model/get_all_country_model.dart';
import 'package:ontrek/features/add_lead/provider/add_lead_provider.dart';
import 'package:ontrek/features/check_out/model/check_out_form_model.dart';
import 'package:ontrek/features/view_task/model/get_task_by_id_model.dart';
import 'package:ontrek/features/view_task/provider/view_task_provider.dart';
import 'package:provider/provider.dart';

class ChooseLeadSourceScreen extends StatefulWidget {
  const ChooseLeadSourceScreen({Key? key}) : super(key: key);

  @override
  State<ChooseLeadSourceScreen> createState() => _ChooseLeadSourceScreenState();
}

class _ChooseLeadSourceScreenState extends State<ChooseLeadSourceScreen> {
  TextEditingController searchController = TextEditingController();
  late ViewTaskProvider viewTaskProvider;
  GetTotByGroupTypeModel? getTotByGroupTypeModel;
  String? selectedLeadId;
  String? selectedLeadName;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      viewTaskProvider = Provider.of<ViewTaskProvider>(context, listen: false);
      await callGetAllCountryApi();
    });
  }

  callGetAllCountryApi() {
    viewTaskProvider.apiCallGetTotByType(groupType: AppConstant.leadTypeCode).then((value) {
      setState(() {
        getTotByGroupTypeModel = value;
      });
      if (getTotByGroupTypeModel?.isError == false &&
          getTotByGroupTypeModel?.isValidationFailed == false) {}
    });
  }

  @override
  Widget build(BuildContext context) {
    viewTaskProvider = Provider.of<ViewTaskProvider>(context);
    return AppScaffold(
      appBar: AppUtils.commonAppBar(
        context: context,
        title: "Lead Source",
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
              text: "Select Source",
              textColor: AppConstant.blackColor.withOpacity(0.7),
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
            AppUtils.commonSizedBox(height: 20),
            Expanded(
              child: viewTaskProvider.isFetching
                  ? AppUtils.loaderWidget()
                  : getTotByGroupTypeModel?.data == null ||
                  getTotByGroupTypeModel!.data!.isEmpty
                  ? AppUtils.commonNoDataFound(
                text: "No Country Found",
                onPressed: () {
                  viewTaskProvider.apiCallGetTotByType(groupType: AppConstant.leadTypeCode);
                },
              )
                  : ListView.builder(
                padding: const EdgeInsets.only(bottom: 30),
                physics: const BouncingScrollPhysics(),
                itemCount: getTotByGroupTypeModel?.data?.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedLeadId =
                            getTotByGroupTypeModel?.data?[index].totId;
                        selectedLeadName = getTotByGroupTypeModel?.data?[index].totValue;
                        print("selectedId$selectedLeadId");
                        print("selectedValue$selectedLeadName");
                      });
                      Navigator.pop(
                        context,
                        {
                          'leadId': selectedLeadId,
                          'leadName': selectedLeadName,
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
                          text: getTotByGroupTypeModel?.data?[index].totValue ??
                              '',
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
