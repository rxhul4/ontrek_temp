import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ontrek/core/common_widgets/app_scaffold.dart';
import 'package:ontrek/core/utils/App_utils.dart';
import 'package:ontrek/core/utils/app_constant.dart';
import 'package:ontrek/features/add_lead/model/get_all_country_model.dart';
import 'package:ontrek/features/add_lead/model/get_all_state_by_id.dart';
import 'package:ontrek/features/add_lead/model/get_city_by_id.dart';
import 'package:ontrek/features/add_lead/provider/add_lead_provider.dart';
import 'package:provider/provider.dart';

class ChooseCityScreen extends StatefulWidget {
  String? stateId;
  ChooseCityScreen({Key? key,this.stateId}) : super(key: key);

  @override
  State<ChooseCityScreen> createState() => _ChooseCityScreenState();
}

class _ChooseCityScreenState extends State<ChooseCityScreen> {
  TextEditingController searchController = TextEditingController();
  late AddLeadProvider addLeadProvider;
  // GetStateByIdModel? getStateByIdModel;
  GetCityByIdModel? getCityByIdModel;
  String? selectedCityId;
  String? selectedCityName;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      addLeadProvider = Provider.of<AddLeadProvider>(context, listen: false);
      await callGetCityByStateId();
    });
  }

  callGetCityByStateId() {
    addLeadProvider.apiCallGetCityByStateId(stateId: widget.stateId).then((value) {
      setState(() {
        getCityByIdModel = value;
      });
      if (getCityByIdModel?.isError == false &&
          getCityByIdModel?.isValidationFailed == false) {

      }else{
        if(getCityByIdModel?.isError == true){
          AppUtils.showDialogBoxWithOneButton(text: "Something went wrong!",context: context);
        }
        if(getCityByIdModel?.isValidationFailed == true){
          AppUtils.showDialogBoxWithOneButton(text: getCityByIdModel?.message,context: context);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    addLeadProvider = Provider.of<AddLeadProvider>(context);
    return AppScaffold(
      appBar: AppUtils.commonAppBar(
        context: context,
        title: "City",
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
              text: "Select City",
              textColor: AppConstant.blackColor.withOpacity(0.7),
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
            AppUtils.commonSizedBox(height: 20),
            Expanded(
              child:  addLeadProvider.isFetching
                  ? AppUtils.loaderWidget()
                  : getCityByIdModel?.data == null ||
                  (getCityByIdModel?.data?.length ?? 0 ) <= 0
                  ? Center(
                child: AppUtils.commonNoDataFound(
                  text: widget.stateId == null ? "Please Select City" : "No City Found",
                  onPressed: () {
                    addLeadProvider.apiCallGetAllCountry();
                  },
                ),
              )
                  : ListView.builder(
                padding: const EdgeInsets.only(bottom: 30),
                physics: const BouncingScrollPhysics(),
                itemCount: getCityByIdModel?.data?.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedCityId =
                            getCityByIdModel?.data?[index].cityId;
                        selectedCityName =
                            getCityByIdModel?.data?[index].cityName;
                      });
                      print("selectedCityId${selectedCityId}");
                      print("selectedCityName${selectedCityName}");
                      Navigator.pop(
                        context,
                        {
                          'cityId': selectedCityId,
                          'cityName': selectedCityName,
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
                          text: getCityByIdModel!
                              .data![index].cityName ??
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
