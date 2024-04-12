import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ontrek/core/common_widgets/app_scaffold.dart';
import 'package:ontrek/core/utils/App_utils.dart';
import 'package:ontrek/core/utils/app_constant.dart';
import 'package:ontrek/features/add_lead/model/get_all_country_model.dart';
import 'package:ontrek/features/add_lead/model/get_all_state_by_id.dart';
import 'package:ontrek/features/add_lead/provider/add_lead_provider.dart';
import 'package:provider/provider.dart';

class ChooseStateScreen extends StatefulWidget {
  String? countryId;
  ChooseStateScreen({Key? key,this.countryId}) : super(key: key);

  @override
  State<ChooseStateScreen> createState() => _ChooseStateScreenState();
}

class _ChooseStateScreenState extends State<ChooseStateScreen> {
  TextEditingController searchController = TextEditingController();
  late AddLeadProvider addLeadProvider;
  GetStateByIdModel? getStateByIdModel;
  String? selectedStateId;
  String? selectedStateName;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      addLeadProvider = Provider.of<AddLeadProvider>(context, listen: false);
      await callGetStateByCountryId();
    });
  }

  callGetStateByCountryId() {
    addLeadProvider.apiCallGetStateByCountryId(countryId: widget.countryId).then((value) {
      setState(() {
        getStateByIdModel = value;
      });
      if (getStateByIdModel?.isError == false &&
          getStateByIdModel?.isValidationFailed == false) {}
    });
  }

  @override
  Widget build(BuildContext context) {
    addLeadProvider = Provider.of<AddLeadProvider>(context);
    return AppScaffold(
      appBar: AppUtils.commonAppBar(
        context: context,
        title: "State",
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
              text: "Select State",
              textColor: AppConstant.blackColor.withOpacity(0.7),
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
            AppUtils.commonSizedBox(height: 20),
           Expanded(
              child:  addLeadProvider.isFetching
                  ? AppUtils.loaderWidget()
                  : getStateByIdModel?.data == null ||
                  (getStateByIdModel?.data?.length ?? 0 ) <= 0
                  ? Center(
                    child: AppUtils.commonNoDataFound(
                                    text: "No State Found",
                                    onPressed: () {
                    addLeadProvider.apiCallGetAllCountry();
                                    },
                                  ),
                  )
                  : ListView.builder(
                padding: const EdgeInsets.only(bottom: 30),
                physics: const BouncingScrollPhysics(),
                itemCount: getStateByIdModel?.data?.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedStateId =
                            getStateByIdModel?.data?[index].stateId;
                        selectedStateName =
                            getStateByIdModel?.data?[index].stateName;
                        print("selectedCountry$selectedStateName");
                        print("selectedCountryId$selectedStateId");
                      });
                      Navigator.pop(
                        context,
                        {
                          'stateId': selectedStateId,
                          'stateName': selectedStateName,
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
                          text: getStateByIdModel!
                              .data![index].stateName ??
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
