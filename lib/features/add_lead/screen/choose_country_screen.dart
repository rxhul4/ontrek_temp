import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ontrek/core/common_widgets/app_scaffold.dart';
import 'package:ontrek/core/utils/App_utils.dart';
import 'package:ontrek/core/utils/app_constant.dart';
import 'package:ontrek/features/add_lead/model/get_all_country_model.dart';
import 'package:ontrek/features/add_lead/provider/add_lead_provider.dart';
import 'package:provider/provider.dart';

class ChooseCountryScreen extends StatefulWidget {
  const ChooseCountryScreen({Key? key}) : super(key: key);

  @override
  State<ChooseCountryScreen> createState() => _ChooseCountryScreenState();
}

class _ChooseCountryScreenState extends State<ChooseCountryScreen> {
  TextEditingController searchController = TextEditingController();
  late AddLeadProvider addLeadProvider;
  GetAllCountryModel? getAllCountryModel;
  String? selectedCountryId;
  String? selectedCountryName;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      addLeadProvider = Provider.of<AddLeadProvider>(context, listen: false);
      await callGetAllCountryApi();
    });
  }

  callGetAllCountryApi() {
    addLeadProvider.apiCallGetAllCountry().then((value) {
      setState(() {
        getAllCountryModel = value;
      });
      if (getAllCountryModel?.isError == false &&
          getAllCountryModel?.isValidationFailed == false) {}
    });
  }

  @override
  Widget build(BuildContext context) {
    addLeadProvider = Provider.of<AddLeadProvider>(context);
    return AppScaffold(
      appBar: AppUtils.commonAppBar(
        context: context,
        title: "Country",
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
              text: "Select Country",
              textColor: AppConstant.blackColor.withOpacity(0.7),
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
            AppUtils.commonSizedBox(height: 20),
            Expanded(
              child: addLeadProvider.isFetching
                  ? AppUtils.loaderWidget()
                  : getAllCountryModel?.data == null ||
                  getAllCountryModel!.data!.isEmpty
                  ? AppUtils.commonNoDataFound(
                text: "No Country Found",
                onPressed: () {
                  addLeadProvider.apiCallGetAllCountry();
                },
              )
                  : ListView.builder(
                padding: const EdgeInsets.only(bottom: 30),
                physics: const BouncingScrollPhysics(),
                itemCount: getAllCountryModel!.data!.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedCountryId =
                            getAllCountryModel!.data![index].countryId;
                        selectedCountryName =
                            getAllCountryModel!.data![index].countryName;
                        print("selectedCountry$selectedCountryName");
                        print("selectedCountryId$selectedCountryId");
                      });
                      Navigator.pop(
                        context,
                        {
                          'countryId': selectedCountryId,
                          'countryName': selectedCountryName,
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
                          text: getAllCountryModel!
                              .data![index].countryName ??
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
